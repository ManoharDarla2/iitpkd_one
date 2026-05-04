import { v2 as cloudinary } from 'cloudinary';
import { resize, toWebp, metadata } from 'imgkit';

cloudinary.config({
  cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
  api_key: process.env.CLOUDINARY_API_KEY,
  api_secret: process.env.CLOUDINARY_API_SECRET,
  secure: true,
});

export const imageService = {
  async optimizeAndUpload(
    fileBuffer: Buffer,
    options?: {
      maxWidth?: number;
      maxHeight?: number;
      quality?: number;
      folder?: string;
    }
  ): Promise<string> {
    const {
      maxWidth = 1920,
      maxHeight = 1080,
      quality = 85,
      folder = 'colab',
    } = options || {};

    const meta = await metadata(fileBuffer);
    let optimizedBuffer: Buffer = fileBuffer;

    if (meta.width > maxWidth || meta.height > maxHeight) {
      const resized = await resize(fileBuffer, {
        width: Math.min(meta.width, maxWidth),
        height: Math.min(meta.height, maxHeight),
        fit: 'inside',
      });
      optimizedBuffer = await toWebp(resized, { quality });
    } else {
      optimizedBuffer = await toWebp(fileBuffer, { quality });
    }

    return new Promise((resolve, reject) => {
      const uploadStream = cloudinary.uploader.upload_stream(
        {
          folder,
          format: 'webp',
          transformation: [
            { quality: 'auto' },
            { fetch_format: 'auto' },
          ],
        },
        (error, result) => {
          if (error) return reject(error);
          resolve(result?.secure_url || '');
        }
      );
      uploadStream.end(optimizedBuffer);
    });
  },
};
