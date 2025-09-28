import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io' if (dart.library.html) 'dart:io';
import 'package:crypto/crypto.dart';

import '../config/imagekit_config.dart';

class ImageKitService {
  // Replace these with your actual ImageKit credentials
  // static const String _publicKey = 'your_public_key_here';
  // static const String _privateKey = 'your_private_key_here';
  // static const String _urlEndpoint = 'https://ik.imagekit.io/your_imagekit_id';
  // static const String _uploadEndpoint = 'https://upload.imagekit.io/api/v1/files/upload';

  /// Upload multiple images to ImageKit storage in the product_images folder
  static Future<List<String>> uploadProductImages(
    List<XFile> images,
    String productId,
  ) async {
    List<String> uploadedUrls = [];

    for (int i = 0; i < images.length; i++) {
      try {
        final image = images[i];
        final fileName =
            '${productId}_${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
        final folderPath = ImageKitConfig.productImagesFolder;

        String imageUrl = await _uploadSingleImage(image, fileName, folderPath);
        uploadedUrls.add(imageUrl);
      } catch (e) {
        print('Error uploading image ${i + 1}: $e');
        throw Exception('Failed to upload image ${i + 1}: $e');
      }
    }

    return uploadedUrls;
  }

  /// Upload a single image to ImageKit
  static Future<String> _uploadSingleImage(
    XFile image,
    String fileName,
    String folderPath,
  ) async {
    try {
      // Validate credentials
      if (ImageKitConfig.publicKey == 'your_public_key_here' ||
          ImageKitConfig.privateKey == 'your_private_key_here') {
        throw Exception(
            'ImageKit credentials not configured. Please update lib/admin/config/imagekit_config.dart');
      }

      // Get image bytes
      Uint8List imageBytes;
      if (kIsWeb) {
        imageBytes = await image.readAsBytes();
      } else {
        final file = File(image.path);
        imageBytes = await file.readAsBytes();
      }

      // Generate authentication parameters
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final token = _generateAuthToken(timestamp);

      // Prepare multipart request
      var request = http.MultipartRequest(
          'POST', Uri.parse(ImageKitConfig.uploadEndpoint));

      // Add authorization header
      final authString =
          base64Encode(utf8.encode('${ImageKitConfig.privateKey}:'));
      request.headers['Authorization'] = 'Basic $authString';

      // Add form fields
      request.fields.addAll({
        'publicKey': ImageKitConfig.publicKey,
        'signature': token,
        'expire':
            (DateTime.now().millisecondsSinceEpoch ~/ 1000 + 2400).toString(),
        'token': token,
        'fileName': fileName,
        'folder': folderPath,
        'useUniqueFileName': 'false',
        'overwriteFile': 'false',
        'overwriteAITags': 'false',
        'overwriteTags': 'false',
        'overwriteCustomMetadata': 'false',
      });

      // Add file
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          imageBytes,
          filename: fileName,
        ),
      );

      // Send request
      print('Uploading image to ImageKit: $fileName');
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(responseBody);
        final imageUrl = jsonResponse['url'] as String;
        print('Successfully uploaded image: $imageUrl');
        return imageUrl;
      } else {
        print('ImageKit upload failed with status: ${response.statusCode}');
        print('Response body: $responseBody');
        throw Exception(
            'Failed to upload image to ImageKit: HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('Error in _uploadSingleImage: $e');
      rethrow;
    }
  }

  /// Generate authentication token for ImageKit upload
  /// For production, implement proper HMAC-SHA1 signature generation
  static String _generateAuthToken(String timestamp) {
    try {
      // Simple token generation - for production, use proper HMAC-SHA1
      // with your private key and include timestamp + other parameters
      var bytes = utf8.encode(timestamp + ImageKitConfig.privateKey);
      var digest = sha256.convert(bytes);
      return digest.toString();
    } catch (e) {
      throw Exception('Failed to generate authentication token: $e');
    }
  }

  /// Delete an image from ImageKit (optional utility method)
  static Future<bool> deleteImage(String fileId) async {
    try {
      final url = 'https://api.imagekit.io/v1/files/$fileId';
      final authString =
          base64Encode(utf8.encode('${ImageKitConfig.privateKey}:'));

      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Authorization': 'Basic $authString',
        },
      );

      return response.statusCode == 204;
    } catch (e) {
      print('Error deleting image: $e');
      return false;
    }
  }

  /// Get optimized image URL with transformations
  static String getOptimizedImageUrl(
    String originalUrl, {
    int? width,
    int? height,
    int? quality,
    String? format,
  }) {
    if (!originalUrl.contains('ik.imagekit.io')) {
      return originalUrl; // Not an ImageKit URL
    }

    List<String> transformations = [];

    if (width != null) transformations.add('w-$width');
    if (height != null) transformations.add('h-$height');
    if (quality != null) transformations.add('q-$quality');
    if (format != null) transformations.add('f-$format');

    if (transformations.isEmpty) return originalUrl;

    final transformString = transformations.join(',');

    // Insert transformation parameters into the URL
    final uri = Uri.parse(originalUrl);
    final pathSegments = uri.pathSegments.toList();

    if (pathSegments.isNotEmpty) {
      pathSegments.insert(pathSegments.length - 1, 'tr:$transformString');
      return uri.replace(pathSegments: pathSegments).toString();
    }

    return originalUrl;
  }
}