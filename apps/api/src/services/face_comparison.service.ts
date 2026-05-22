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
 * Generates a 64-bit difference hash (dHash) for an image.
 * Resizes the image to 9x8, grayscales it, and compares adjacent horizontal pixels.
 * Highly resilient to lighting shifts, uniform color changes, and scaling.
 */
async function getPerceptualHash(imageBuffer: Buffer): Promise<string> {
  const image = await Jimp.read(imageBuffer);
  
  // Resize to 9x8 to perform difference hashing (creates 64 comparisons/bits)
  image.resize({ w: 9, h: 8 });
  image.greyscale();
  
  let hash = '';
  
  for (let y = 0; y < 8; y++) {
    for (let x = 0; x < 8; x++) {
      const colorLeft = image.getPixelColor(x, y);
      const colorRight = image.getPixelColor(x + 1, y);
      
      // Get the red channel (since it is grayscale, R = G = B)
      const rLeft = (colorLeft >> 24) & 0xff;
      const rRight = (colorRight >> 24) & 0xff;
      
      hash += rLeft > rRight ? '1' : '0';
    }
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
