# ImageKit Setup Guide

This guide will help you set up ImageKit for image storage in your Al Haiwan app.

## 1. Create ImageKit Account

1. Go to [ImageKit.io](https://imagekit.io) and create a free account
2. Complete the registration process

## 2. Get Your Credentials

After logging in to your ImageKit dashboard:

1. **Public Key**: Found in Dashboard > Developer Options > API Keys
2. **Private Key**: Found in Dashboard > Developer Options > API Keys
3. **URL Endpoint**: Found in Dashboard > Developer Options > API Keys (e.g.,
   `https://ik.imagekit.io/your_imagekit_id`)

## 3. Configure Your App

1. Open `lib/admin/config/imagekit_config.dart`
2. Replace the placeholder values with your actual credentials:

```dart
class ImageKitConfig {
  static const String publicKey = 'public_YOUR_ACTUAL_PUBLIC_KEY';
  static const String privateKey = 'private_YOUR_ACTUAL_PRIVATE_KEY';
  static const String urlEndpoint = 'https://ik.imagekit.io/your_imagekit_id';
  
  // ... rest of the configuration
}
```

## 4. Install Dependencies

Run the following command in your project directory:

```bash
flutter pub get
```

## 5. Test the Setup

1. Run your app
2. Go to Admin Panel > Add Products
3. Try uploading some product images
4. Check your ImageKit dashboard to see if images are uploaded to the `product_images/` folder

## 6. ImageKit Features Used

- **Automatic folder organization**: All product images go to `product_images/` folder
- **Unique file naming**: Each image gets a unique name with product ID and timestamp
- **File size validation**: Images larger than 5MB are rejected
- **Optimized delivery**: Images are automatically optimized for web delivery
- **Transformations**: You can resize images on-the-fly using URL parameters

## 7. Optional Optimizations

### Image Transformations

You can get optimized versions of images using the `getOptimizedImageUrl` method:

```dart
String optimizedUrl = ImageKitService.getOptimizedImageUrl(
  originalUrl,
  width: 300,
  height: 300,
  quality: 80,
  format: 'webp',
);
```

### Delete Images

To delete images from ImageKit:

```dart
bool deleted = await ImageKitService.deleteImage(fileId);
```

## 8. Security Notes

- Keep your private key secure and never expose it in client-side code
- For production apps, implement proper server-side authentication
- Consider implementing file type validation for additional security

## 9. Troubleshooting

### Common Issues:

1. **Authentication Error**: Double-check your public and private keys
2. **Upload Failed**: Verify your URL endpoint is correct
3. **File Too Large**: Check if image is under 5MB limit
4. **Network Error**: Ensure you have internet connectivity

### Debug Mode:

The service includes console logging to help debug upload issues. Check your console for detailed
error messages.

## 10. Migration from Firebase

Your existing Firebase Firestore database structure remains unchanged. Only the image storage has
been moved to ImageKit. All your existing products and data will continue to work normally.

The change is seamless from the user perspective - they'll see the same functionality but with
better image performance through ImageKit's CDN.