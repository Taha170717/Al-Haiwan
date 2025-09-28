class ImageKitConfig {
  // Replace these with your actual ImageKit credentials
  // You can get these from your ImageKit dashboard: https://imagekit.io/dashboard

  static const String publicKey = 'public_PZlQaFn7qH7zGf31Yp3rLKnUMGc=';
  static const String privateKey = 'private_sWCIXKsbU9kaLKEer34eiiF3sKw=';
  static const String urlEndpoint = 'https://ik.imagekit.io/cijuvl58g';

  // Upload endpoint (usually doesn't change)
  static const String uploadEndpoint = 'https://upload.imagekit.io/api/v1/files/upload';

  // Folder configuration
  static const String productImagesFolder = 'product_images/';

  // Quality and size settings
  static const int imageQuality = 80; // 1-100, higher is better quality but larger file
  static const int maxImageWidth = 1200; // Maximum width in pixels
  static const int maxImageHeight = 1200; // Maximum height in pixels

  // File size limits (in bytes)
  static const int maxFileSize = 5 * 1024 * 1024; // 5MB
}