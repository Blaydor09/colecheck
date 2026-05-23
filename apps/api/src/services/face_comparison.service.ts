import * as faceapi from '@vladmandic/face-api/dist/face-api.node-wasm.js';
import * as tf from '@tensorflow/tfjs';
import * as canvas from 'canvas';
import * as path from 'path';

// Patch face-api environment for Node.js
const { Canvas, Image, ImageData } = canvas;
faceapi.env.monkeyPatch({ Canvas, Image, ImageData } as any);

const MODEL_PATH = path.join(__dirname, '../../models');
let modelsLoaded = false;
let loadingPromise: Promise<void> | null = null;

/**
 * Ensures that the WebAssembly backend is initialized and face-api models are loaded.
 */
async function ensureModels(): Promise<void> {
  if (modelsLoaded) return;
  if (loadingPromise) return loadingPromise;

  loadingPromise = (async () => {
    console.log(`[Face Recognition] Initializing WASM backend...`);
    await tf.setBackend('wasm');
    await tf.ready();

    console.log(`[Face Recognition] Loading models from: ${MODEL_PATH}`);
    await Promise.all([
      faceapi.nets.ssdMobilenetv1.loadFromDisk(MODEL_PATH),
      faceapi.nets.faceLandmark68Net.loadFromDisk(MODEL_PATH),
      faceapi.nets.faceRecognitionNet.loadFromDisk(MODEL_PATH),
    ]);
    
    modelsLoaded = true;
    console.log('[Face Recognition] Models and WASM backend loaded successfully.');
  })();

  return loadingPromise;
}

/**
 * Normalizes a base64 string and converts it to a Node Buffer.
 */
function base64ToBuffer(base64Str: string): Buffer {
  const base64Data = base64Str.trim().replace(/^data:image\/\w+;base64,/, '');
  return Buffer.from(base64Data, 'base64');
}

/**
 * Detects a face and extracts its 128-dimensional descriptor (embedding).
 */
async function getDescriptor(base64Str: string): Promise<Float32Array | null> {
  try {
    const buffer = base64ToBuffer(base64Str);
    const img = await canvas.loadImage(buffer);
    
    const detection = await faceapi
      .detectSingleFace(img as any)
      .withFaceLandmarks()
      .withFaceDescriptor();

    return detection ? detection.descriptor : null;
  } catch (error) {
    console.error('[Face Recognition] Error extracting descriptor:', error);
    return null;
  }
}

/**
 * Compares two base64-encoded face images and returns a similarity percentage (0 to 100).
 * Highly optimized using @vladmandic/face-api with WebAssembly backend.
 */
export async function compareFaces(img1Base64: string, img2Base64: string): Promise<number> {
  if (!img1Base64 || !img2Base64) {
    return 0;
  }

  try {
    await ensureModels();

    const [desc1, desc2] = await Promise.all([
      getDescriptor(img1Base64),
      getDescriptor(img2Base64)
    ]);

    if (!desc1 || !desc2) {
      console.log('[Face Recognition] Could not detect a face or extract descriptor in one or both images.');
      return 0;
    }

    const distance = faceapi.euclideanDistance(desc1, desc2);
    console.log(`[Face Recognition] Calculated Euclidean Distance: ${distance.toFixed(4)}`);

    // Map Euclidean distance to similarity percentage (0-100) matching a 60% confidence threshold:
    // - distance <= 0.6: similarity = 100 - (distance / 0.6) * 40   (maps 0.0-0.6 distance to 100%-60% similarity)
    // - distance > 0.6: similarity = Math.max(0, 60 - ((distance - 0.6) / 0.4) * 60) (maps 0.6-1.0 distance to 60%-0% similarity)
    let similarity = 0;
    if (distance <= 0.6) {
      similarity = 100 - (distance / 0.6) * 40;
    } else {
      similarity = Math.max(0, 60 - ((distance - 0.6) / 0.4) * 60);
    }

    const roundedSimilarity = Math.round(similarity * 100) / 100;
    console.log(`[Face Recognition] Mapped Similarity: ${roundedSimilarity}%`);

    return roundedSimilarity;
  } catch (error) {
    console.error('[Face Recognition] Error during face comparison service execution:', error);
    return 0;
  }
}
