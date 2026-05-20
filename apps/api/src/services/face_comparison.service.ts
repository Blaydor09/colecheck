import { Jimp } from 'jimp';

/**
 * Normalizes a base64 string and converts it to a Node Buffer.
 */
function base64ToBuffer(base64Str: string): Buffer {
  // Remove data URI prefix if present
  const base64Data = base64Str.replace(/^data:image\/\w+;base64,/, '');
  return Buffer.from(base64Data, 'base64');
}

/**
 * Generates a 256-bit perceptual hash (aHash) for an image.
 * Resizes the image to 16x16, grayscales it, and generates a binary string
 * comparing each pixel's brightness to the average brightness.
 */
async function getPerceptualHash(imageBuffer: Buffer): Promise<string> {
  const image = await Jimp.read(imageBuffer);
  
  // Resize to a standardized small grid to normalize resolutions
  image.resize({ w: 16, h: 16 });
  image.greyscale();
  
  const pixels: number[] = [];
  let sum = 0;
  
  for (let y = 0; y < 16; y++) {
    for (let x = 0; x < 16; x++) {
      const color = image.getPixelColor(x, y);
      // Get the red channel (since it is grayscale, R = G = B)
      // Jimp color is represented as a 32-bit integer: RGBA
      const r = (color >> 24) & 0xff;
      pixels.push(r);
      sum += r;
    }
  }
  
  const average = sum / pixels.length;
  let hash = '';
  for (const pixel of pixels) {
    hash += pixel >= average ? '1' : '0';
  }
  
  return hash;
}

/**
 * Calculates the Hamming Distance between two binary strings.
 */
function calculateHammingDistance(hash1: string, hash2: string): number {
  let distance = 0;
  const length = Math.min(hash1.length, hash2.length);
  for (let i = 0; i < length; i++) {
    if (hash1[i] !== hash2[i]) {
      distance++;
    }
  }
  return distance;
}

/**
 * Compares two base64-encoded images and returns a similarity percentage (0 to 100).
 */
export async function compareFaces(img1Base64: string, img2Base64: string): Promise<number> {
  if (!img1Base64 || !img2Base64) {
    return 0;
  }
  
  try {
    const buffer1 = base64ToBuffer(img1Base64);
    const buffer2 = base64ToBuffer(img2Base64);
    
    const hash1 = await getPerceptualHash(buffer1);
    const hash2 = await getPerceptualHash(buffer2);
    
    const distance = calculateHammingDistance(hash1, hash2);
    const similarity = (1 - distance / hash1.length) * 100;
    
    return Math.round(similarity * 100) / 100; // Round to two decimal places
  } catch (error) {
    console.error('Error during face comparison service execution:', error);
    return 0;
  }
}
