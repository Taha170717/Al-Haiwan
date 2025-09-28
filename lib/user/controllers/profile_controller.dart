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

class ProfileController extends GetxController {
  final ImagePicker _imagePicker = ImagePicker();
  final FilePicker _filePicker = FilePicker.platform;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final UserService _userService = Get.put(UserService());

  // ImageKit configuration
  static const String _imageKitPublicKey =
      'public_PZlQaFn7qH7zGf31Yp3rLKnUMGc=';
  static const String _imageKitPrivateKey =
      'private_sWCIXKsbU9kaLKEer34eiiF3sKw=';
  static const String _imageKitUploadEndpoint =
      'https://upload.imagekit.io/api/v1/files/upload';
  static const String _userImagesFolder = 'userimages/';

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

      if (kIsWeb) {
        // Web platform: use file_picker
        FilePickerResult? result = await _filePicker.pickFiles(
          type: FileType.image,
          allowMultiple: false,
        );

        if (result != null && result.files.isNotEmpty) {
          final file = result.files.first;
          final user = _auth.currentUser;

          if (user != null && file.bytes != null) {
            final url = await _uploadImageToImageKit(file.bytes!, file.name);
            if (url != null) {
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

              _userService.profileImageUrl(url);
              _userService.refreshProfile();
              _showSnackbar(
                title: "Success",
                message: "Profile image updated successfully",
                type: SnackbarType.success,
              );
            }
          }
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
            final bytes = await image.readAsBytes();
            final url = await _uploadImageToImageKit(bytes, image.name);
            if (url != null) {
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
            }
          }
        }
      }
    } catch (e) {
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

      final uniqueFilename =
          '${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final token = _generateAuthToken(timestamp);

      var request =
          http.MultipartRequest('POST', Uri.parse(_imageKitUploadEndpoint));

      // Add authorization header
      final authString = base64Encode(utf8.encode('$_imageKitPrivateKey:'));
      request.headers['Authorization'] = 'Basic $authString';

      // Add form fields
      request.fields.addAll({
        'publicKey': _imageKitPublicKey,
        'signature': token,
        'expire':
            (DateTime.now().millisecondsSinceEpoch ~/ 1000 + 2400).toString(),
        'token': token,
        'fileName': uniqueFilename,
        'folder': _userImagesFolder,
        'useUniqueFileName': 'false',
        'overwriteFile': 'true',
        'overwriteAITags': 'false',
        'overwriteTags': 'false',
        'overwriteCustomMetadata': 'false',
      });

      // Add file
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: uniqueFilename,
        ),
      );

      // Send request
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(responseBody);
        final imageUrl = jsonResponse['url'] as String;
        return imageUrl;
      } else {
        throw Exception(
            'Failed to upload image to ImageKit: HTTP ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  /// Generate authentication token for ImageKit upload
  String _generateAuthToken(String timestamp) {
    try {
      // Simple token generation - for production, use proper HMAC-SHA1
      // with your private key and include timestamp + other parameters
      var bytes = utf8.encode(timestamp + _imageKitPrivateKey);
      var digest = sha256.convert(bytes);
      return digest.toString();
    } catch (e) {
      throw Exception('Failed to generate authentication token: $e');
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
