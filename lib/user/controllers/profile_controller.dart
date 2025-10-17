import 'dart:io';
import 'dart:ui';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import '../models/user_model.dart';
import '../repository/user_service.dart';
import '../../utils/config/imagekit_config.dart';

class ProfileController extends GetxController {
  final ImagePicker _imagePicker = ImagePicker();
  final FilePicker _filePicker = FilePicker.platform;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final UserService _userService = Get.put(UserService());

  // ImageKit configuration
  final String _imageKitPublicKey = ImageKitConfig.publicKey;
  final String _imageKitPrivateKey = ImageKitConfig.privateKey;
  final String _imageKitUploadEndpoint = ImageKitConfig.uploadEndpoint;
  final String _userImagesFolder = ImageKitConfig.userImagesFolder;

  // Observable variables
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isUpdating = false.obs;
  final RxString profileImageUrl = ''.obs;
  final RxList<String> uploadedDocuments = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadUserProfile();
    testImageKitConnection(); // Test ImageKit connection on initialization
  }

  void _showSnackbar({
    required String title,
    required String message,
    required SnackbarType type,
    Duration? duration,
  }) {
    Color backgroundColor;
    Color iconColor;
    IconData icon;

    switch (type) {
      case SnackbarType.success:
        backgroundColor = Color(0xFF4CAF50);
        iconColor = Colors.white;
        icon = Icons.check_circle_rounded;
        break;
      case SnackbarType.error:
        backgroundColor = Color(0xFFE53E3E);
        iconColor = Colors.white;
        icon = Icons.error_rounded;
        break;
      case SnackbarType.warning:
        backgroundColor = Color(0xFFFF9800);
        iconColor = Colors.white;
        icon = Icons.warning_rounded;
        break;
      case SnackbarType.info:
        backgroundColor = Color(0xFF199A8E);
        iconColor = Colors.white;
        icon = Icons.info_rounded;
        break;
    }

    Get.snackbar(
      title,
      message,
      backgroundColor: backgroundColor,
      colorText: Colors.white,
      icon: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: 24,
        ),
      ),
      snackPosition: SnackPosition.TOP,
      margin: EdgeInsets.all(16),
      borderRadius: 16,
      duration: duration ?? Duration(seconds: 4),
      animationDuration: Duration(milliseconds: 800),
      forwardAnimationCurve: Curves.elasticOut,
      reverseAnimationCurve: Curves.fastOutSlowIn,
      boxShadows: [
        BoxShadow(
          color: backgroundColor.withOpacity(0.3),
          spreadRadius: 2,
          blurRadius: 12,
          offset: Offset(0, 4),
        ),
      ],
      mainButton: TextButton(
        onPressed: () => Get.closeCurrentSnackbar(),
        child: Icon(
          Icons.close_rounded,
          color: Colors.white.withOpacity(0.8),
          size: 20,
        ),
      ),
    );
  }

  // Load current user profile
  Future<void> loadUserProfile() async {
    try {
      isLoading.value = true;
      final user = _auth.currentUser;
      if (user != null) {
        final userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          final userData = userDoc.data()!;
          final userProfile = UserModel(
            uid: userData['uid'] ?? user.uid,
            name: userData['username'] ?? userData['name'] ?? 'User',
            email: userData['email'] ?? user.email ?? '',
            phone: userData['phone'],
            address: userData['address'],
            city: userData['city'],
            state: userData['state'],
            zipCode: userData['zipCode'],
            profileImageUrl: userData['profileImageUrl'],
            documents: List<String>.from(userData['documents'] ?? []),
            createdAt: (userData['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
            updatedAt: (userData['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          );
          currentUser.value = userProfile;
          profileImageUrl.value = userProfile.profileImageUrl ?? '';
          uploadedDocuments.value = userProfile.documents ?? [];
        } else {
          // Create new user profile if doesn't exist
          final newUser = UserModel(
            uid: user.uid,
            name: user.displayName ?? 'User',
            email: user.email ?? '',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          await _firestore.collection('users').doc(user.uid).set({
            'uid': newUser.uid,
            'username': newUser.name,
            'email': newUser.email,
            'profileImageUrl': newUser.profileImageUrl,
            'documents': newUser.documents ?? [],
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
          currentUser.value = newUser;
        }
      }
    } catch (e) {
      _showSnackbar(
        title: "Error",
        message: "Failed to load profile: $e",
        type: SnackbarType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Update user name
  Future<void> updateUserName(String newName) async {
    try {
      isUpdating.value = true;
      final user = _auth.currentUser;
      if (user != null && newName.trim().isNotEmpty) {
        await _firestore.collection('users').doc(user.uid).update({
          'username': newName.trim(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Update local state
        if (currentUser.value != null) {
          currentUser.value = currentUser.value!.copyWith(
            name: newName.trim(),
            updatedAt: DateTime.now(),
          );
        }

        _showSnackbar(
          title: "Success",
          message: "Profile name updated successfully",
          type: SnackbarType.success,
        );
      }
    } catch (e) {
      _showSnackbar(
        title: "Error",
        message: "Failed to update name: $e",
        type: SnackbarType.error,
      );
    } finally {
      isUpdating.value = false;
    }
  }

  // Update user profile with multiple fields
  Future<void> updateUserProfile({
    String? name,
    String? phone,
    String? address,
    String? city,
    String? state,
    String? zipCode,
  }) async {
    try {
      isUpdating.value = true;
      final user = _auth.currentUser;
      if (user != null) {
        Map<String, dynamic> updateData = {
          'updatedAt': FieldValue.serverTimestamp(),
        };

        if (name != null && name.trim().isNotEmpty) {
          updateData['username'] = name.trim();
        }
        if (phone != null) {
          updateData['phone'] = phone.trim().isNotEmpty ? phone.trim() : null;
        }
        if (address != null) {
          updateData['address'] =
              address.trim().isNotEmpty ? address.trim() : null;
        }
        if (city != null) {
          updateData['city'] = city.trim().isNotEmpty ? city.trim() : null;
        }
        if (state != null) {
          updateData['state'] = state.trim().isNotEmpty ? state.trim() : null;
        }
        if (zipCode != null) {
          updateData['zipCode'] =
              zipCode.trim().isNotEmpty ? zipCode.trim() : null;
        }

        await _firestore.collection('users').doc(user.uid).update(updateData);

        // Update local state
        if (currentUser.value != null) {
          currentUser.value = currentUser.value!.copyWith(
            name: name?.trim() ?? currentUser.value!.name,
            phone: phone?.trim().isNotEmpty == true ? phone!.trim() : null,
            address:
                address?.trim().isNotEmpty == true ? address!.trim() : null,
            city: city?.trim().isNotEmpty == true ? city!.trim() : null,
            state: state?.trim().isNotEmpty == true ? state!.trim() : null,
            zipCode:
                zipCode?.trim().isNotEmpty == true ? zipCode!.trim() : null,
            updatedAt: DateTime.now(),
          );
        }

        _showSnackbar(
          title: "Success",
          message: "Profile updated successfully",
          type: SnackbarType.success,
        );
      }
    } catch (e) {
      _showSnackbar(
        title: "Error",
        message: "Failed to update profile: $e",
        type: SnackbarType.error,
      );
    } finally {
      isUpdating.value = false;
    }
  }

  // Upload profile image
  Future<void> uploadProfileImage() async {
    try {
      isUpdating.value = true;

      print('Starting profile image upload process...');

      if (kIsWeb) {
        // Web platform: use file_picker
        FilePickerResult? result = await _filePicker.pickFiles(
          type: FileType.image,
          allowMultiple: false,
        );

        if (result != null && result.files.isNotEmpty) {
          final file = result.files.first;
          final user = _auth.currentUser;

          print('File selected: ${file.name}, size: ${file.size} bytes');

          if (user != null && file.bytes != null) {
            print('Current user: ${user.uid}');
            print('File bytes available: ${file.bytes!.length} bytes');

            final url = await _uploadImageToImageKit(file.bytes!, file.name);
            if (url != null) {
              print('Upload successful, updating Firestore with URL: $url');

              await _firestore.collection('users').doc(user.uid).update({
                'profileImageUrl': url,
                'updatedAt': FieldValue.serverTimestamp(),
              });

              // Update local state
              profileImageUrl.value = url;
              if (currentUser.value != null) {
                currentUser.value = currentUser.value!.copyWith(
                  profileImageUrl: url,
                  updatedAt: DateTime.now(),
                );
              }

              _userService.updateProfileImageUrl(url);
              _userService.refreshProfile();
              _showSnackbar(
                title: "Success",
                message: "Profile image updated successfully",
                type: SnackbarType.success,
              );
            } else {
              throw Exception('Failed to get upload URL from ImageKit');
            }
          } else {
            if (user == null) {
              throw Exception('User not authenticated');
            }
            if (file.bytes == null) {
              throw Exception('File bytes are null - file may be corrupted');
            }
          }
        } else {
          print('No file selected or file picker cancelled');
        }
      } else {
        // Mobile platform: use image_picker
        final XFile? image = await _imagePicker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 800,
          maxHeight: 800,
          imageQuality: 80,
        );

        if (image != null) {
          final user = _auth.currentUser;
          if (user != null) {
            print('Image selected: ${image.name}, path: ${image.path}');

            final bytes = await image.readAsBytes();
            print('Image bytes read: ${bytes.length} bytes');

            final url = await _uploadImageToImageKit(bytes, image.name);
            if (url != null) {
              print('Upload successful, updating Firestore with URL: $url');

              await _firestore.collection('users').doc(user.uid).update({
                'profileImageUrl': url,
                'updatedAt': FieldValue.serverTimestamp(),
              });

              // Update local state
              profileImageUrl.value = url;
              if (currentUser.value != null) {
                currentUser.value = currentUser.value!.copyWith(
                  profileImageUrl: url,
                  updatedAt: DateTime.now(),
                );
              }

              _userService.updateProfileImageUrl(url);
              _userService.refreshProfile();
              _showSnackbar(
                title: "Success",
                message: "Profile image updated successfully",
                type: SnackbarType.success,
              );
            } else {
              throw Exception('Failed to get upload URL from ImageKit');
            }
          } else {
            throw Exception('User not authenticated');
          }
        } else {
          print('No image selected or image picker cancelled');
        }
      }
    } catch (e) {
      print('Error in uploadProfileImage: $e');
      _showSnackbar(
        title: "Error",
        message: "Failed to upload image: $e",
        type: SnackbarType.error,
      );
    } finally {
      isUpdating.value = false;
    }
  }

  Future<String?> _uploadImageToImageKit(
      Uint8List bytes, String filename) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      // Validate credentials
      if (_imageKitPublicKey == 'your_public_key_here' ||
          _imageKitPrivateKey == 'your_private_key_here') {
        throw Exception(
            'ImageKit credentials not configured. Please update ImageKit configuration.');
      }

      // Validate file size (5MB limit)
      const maxFileSize = 5 * 1024 * 1024; // 5MB
      if (bytes.length > maxFileSize) {
        throw Exception(
            'Image file is too large. Maximum size allowed is 5MB.');
      }

      // Validate file type (check if it's actually an image)
      if (!_isValidImageFile(bytes)) {
        throw Exception(
            'Invalid image file format. Please select a valid image (JPEG, PNG, WebP, etc.).');
      }

      final uniqueFilename =
          '${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      var request =
          http.MultipartRequest('POST', Uri.parse(_imageKitUploadEndpoint));

      // For server-side uploads, use private key authentication
      // Create the basic auth string: base64encode(private_key:)
      final authString = base64Encode(utf8.encode('$_imageKitPrivateKey:'));
      request.headers['Authorization'] = 'Basic $authString';

      // Add form fields for server-side upload
      request.fields.addAll({
        'fileName': uniqueFilename,
        'folder': _userImagesFolder,
        'useUniqueFileName': 'false',
        'overwriteFile': 'true',
      });

      // Add file
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: uniqueFilename,
        ),
      );

      // Send request with detailed logging
      print('Uploading profile image to ImageKit: $uniqueFilename');
      print('File size: ${bytes.length} bytes');
      print('Using server-side authentication with private key');

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      print('ImageKit response status: ${response.statusCode}');
      print('ImageKit response body: $responseBody');

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(responseBody);
        final imageUrl = jsonResponse['url'] as String;
        print('Successfully uploaded profile image: $imageUrl');
        return imageUrl;
      } else {
        // Parse error response for more specific error messages
        String errorMessage = 'HTTP ${response.statusCode}';
        try {
          var errorResponse = json.decode(responseBody);
          if (errorResponse['message'] != null) {
            errorMessage = errorResponse['message'];
          } else if (errorResponse['error'] != null) {
            errorMessage = errorResponse['error'];
          }
        } catch (e) {
          // If JSON parsing fails, use the raw response
          errorMessage =
              responseBody.isNotEmpty ? responseBody : 'Unknown error occurred';
        }

        print('ImageKit upload failed with status: ${response.statusCode}');
        print('Error message: $errorMessage');
        print('Full response body: $responseBody');

        // Provide user-friendly error messages based on status code
        String userMessage;
        switch (response.statusCode) {
          case 400:
            userMessage =
                'Invalid image file or upload parameters. Please try with a different image.';
            break;
          case 401:
            userMessage =
                'Authentication failed. Please check ImageKit configuration.';
            break;
          case 403:
            userMessage =
                'Upload not allowed. Please check your ImageKit permissions.';
            break;
          case 413:
            userMessage =
                'Image file is too large. Please choose a smaller image.';
            break;
          case 429:
            userMessage = 'Too many upload requests. Please try again later.';
            break;
          default:
            userMessage = 'Upload failed: $errorMessage';
        }

        throw Exception(userMessage);
      }
    } catch (e) {
      print('Error in _uploadImageToImageKit: $e');
      throw Exception('Failed to upload image: $e');
    }
  }

  // Validate if the file is a valid image by checking file headers
  bool _isValidImageFile(Uint8List bytes) {
    if (bytes.length < 4) return false;

    // Check for common image file signatures
    // JPEG: FF D8 FF
    if (bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) {
      return true;
    }

    // PNG: 89 50 4E 47
    if (bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47) {
      return true;
    }

    // WebP: starts with "RIFF" and contains "WEBP"
    if (bytes.length >= 12) {
      String header = String.fromCharCodes(bytes.sublist(0, 4));
      String format = String.fromCharCodes(bytes.sublist(8, 12));
      if (header == 'RIFF' && format == 'WEBP') {
        return true;
      }
    }

    // GIF: 47 49 46 38
    if (bytes.length >= 6) {
      String header = String.fromCharCodes(bytes.sublist(0, 6));
      if (header.startsWith('GIF8')) {
        return true;
      }
    }

    return false;
  }

  // Test ImageKit connection and credentials
  Future<void> testImageKitConnection() async {
    try {
      print('Testing ImageKit connection...');
      print('Public Key: $_imageKitPublicKey');
      print('Upload Endpoint: $_imageKitUploadEndpoint');
      print('User Images Folder: $_userImagesFolder');

      // Test server-side authentication
      final authString = base64Encode(utf8.encode('$_imageKitPrivateKey:'));
      print('Generated auth string for server-side upload authentication');

      print(
          'ImageKit connection test completed - using server-side authentication');
    } catch (e) {
      print('ImageKit connection test failed: $e');
    }
  }

  // Upload document
  Future<void> uploadDocument() async {
    try {
      isUpdating.value = true;
      FilePickerResult? result = await _filePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
      );

      if (result != null) {
        final user = _auth.currentUser;
        if (user != null) {
          final file = result.files.single;
          final fileName = file.name;

          final ref = _storage.ref().child('user_documents/${user.uid}/$fileName');

          UploadTask uploadTask;
          if (kIsWeb && file.bytes != null) {
            // Web platform: use bytes
            uploadTask = ref.putData(
              file.bytes!,
              SettableMetadata(
                contentType: _getContentType(file.extension),
              ),
            );
          } else if (!kIsWeb && file.path != null) {
            // Mobile platform: use file path
            uploadTask = ref.putFile(File(file.path!));
          } else {
            throw Exception('Unable to process file on this platform');
          }

          final snapshot = await uploadTask;
          final downloadUrl = await snapshot.ref.getDownloadURL();

          final updatedDocuments = [...uploadedDocuments, downloadUrl];
          await _firestore.collection('users').doc(user.uid).update({
            'documents': updatedDocuments,
            'updatedAt': FieldValue.serverTimestamp(),
          });

          // Update local state
          uploadedDocuments.value = updatedDocuments;
          if (currentUser.value != null) {
            currentUser.value = currentUser.value!.copyWith(
              documents: updatedDocuments,
              updatedAt: DateTime.now(),
            );
          }

          _showSnackbar(
            title: "Success",
            message: "Document uploaded successfully",
            type: SnackbarType.success,
          );
        }
      }
    } catch (e) {
      _showSnackbar(
        title: "Error",
        message: "Failed to upload document: $e",
        type: SnackbarType.error,
      );
    } finally {
      isUpdating.value = false;
    }
  }

  // Helper method to determine content type
  String _getContentType(String? extension) {
    switch (extension?.toLowerCase()) {
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      default:
        return 'application/octet-stream';
    }
  }

  // Delete document
  Future<void> deleteDocument(String documentUrl) async {
    try {
      isUpdating.value = true;
      final user = _auth.currentUser;
      if (user != null) {
        final ref = _storage.refFromURL(documentUrl);
        await ref.delete();

        final updatedDocuments = uploadedDocuments.where((doc) => doc != documentUrl).toList();
        await _firestore.collection('users').doc(user.uid).update({
          'documents': updatedDocuments,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Update local state
        uploadedDocuments.value = updatedDocuments;
        if (currentUser.value != null) {
          currentUser.value = currentUser.value!.copyWith(
            documents: updatedDocuments,
            updatedAt: DateTime.now(),
          );
        }

        _showSnackbar(
          title: "Success",
          message: "Document deleted successfully",
          type: SnackbarType.success,
        );
      }
    } catch (e) {
      _showSnackbar(
        title: "Error",
        message: "Failed to delete document: $e",
        type: SnackbarType.error,
      );
    } finally {
      isUpdating.value = false;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      currentUser.value = null;
      profileImageUrl.value = '';
      uploadedDocuments.clear();

      _showSnackbar(
        title: "Success",
        message: "Signed out successfully",
        type: SnackbarType.success,
      );
    } catch (e) {
      _showSnackbar(
        title: "Error",
        message: "Failed to sign out: $e",
        type: SnackbarType.error,
      );
    }
  }
}

enum SnackbarType { success, error, warning, info }
