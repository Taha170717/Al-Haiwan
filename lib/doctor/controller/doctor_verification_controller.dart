import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'doctor_bottom_nav_Controller.dart';

class DoctorVerificationController extends GetxController {
  final formKey = GlobalKey<FormState>();
  var isLoading = false.obs;
  var loadingMessage = ''.obs;
  var uploadProgress = 0.0.obs;
  var currentStep = 0.obs;
  final totalSteps = 6;

  // Controllers
  final fullNameController = TextEditingController();
  final fatherNameController = TextEditingController();
  final dobController = TextEditingController();
  final contactController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  final registrationController = TextEditingController();
  final clinicNameController = TextEditingController();
  final clinicAddressController = TextEditingController();
  final clinicContactController = TextEditingController();
  final specializationController = TextEditingController();
  final experienceController = TextEditingController();
  final aboutController = TextEditingController();
  final consultationFeeController = TextEditingController();

  // Gender
  var selectedGender = ''.obs;
  final List<String> genders = ['Male', 'Female', 'Other'];

  // Documents
  XFile? profilePicture;
  PlatformFile? medicalLicense;
  PlatformFile? degreeCertificate;
  PlatformFile? specializationCertificate;
  PlatformFile? governmentId;
  PlatformFile? affiliationLetter;

  // 🔑 ImageKit Config
  final String imageKitUploadUrl = "https://upload.imagekit.io/api/v1/files/upload";

  final String imageKitPrivateKey = "private_sWCIXKsbU9kaLKEer34eiiF3sKw=";
  final String imageKitEndpoint = "https://ik.imagekit.io/cijuvl58g/";

  @override
  void onInit() {
    super.onInit();
    _loadUserEmail();
  }

  void _loadUserEmail() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      emailController.text = user.email ?? '';
    }
  }

  Future<void> pickProfilePicture() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );
      if (pickedFile != null) {
        profilePicture = pickedFile;
        update();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick profile picture: ${e.toString()}');
    }
  }

  Future<void> pickDocument(String documentType) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );
      if (result != null) {
        switch (documentType) {
          case 'medical_license':
            medicalLicense = result.files.first;
            break;
          case 'degree_certificate':
            degreeCertificate = result.files.first;
            break;
          case 'specialization_certificate':
            specializationCertificate = result.files.first;
            break;
          case 'government_id':
            governmentId = result.files.first;
            break;
          case 'affiliation_letter':
            affiliationLetter = result.files.first;
            break;
        }
        update();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick document: ${e.toString()}');
    }
  }

  // 🟢 Upload file to ImageKit with folder structure
  Future<String?> uploadFileToImageKit(
      dynamic file, String fileName, String folderPath) async {
    try {
      List<int> fileBytes = [];
      String? mimeType;

      if (file is XFile) {
        fileBytes = await file.readAsBytes();
        mimeType = "image/jpeg";
      } else if (file is PlatformFile) {
        if (kIsWeb && file.bytes != null) {
          fileBytes = file.bytes!;
        } else if (file.path != null) {
          fileBytes = await File(file.path!).readAsBytes();
        }
        mimeType = "application/octet-stream";
      }
      //qwew

      final request = http.MultipartRequest("POST", Uri.parse(imageKitUploadUrl));
      request.fields['fileName'] = fileName;
      request.fields['folder'] = folderPath; // Add folder structure
      request.fields['useUniqueFileName'] = "true";
      request.headers['Authorization'] =
          "Basic ${base64Encode(utf8.encode("$imageKitPrivateKey:"))}";
      request.files.add(http.MultipartFile.fromBytes("file", fileBytes, filename: fileName, contentType: null));

      final response = await request.send();
      final respStr = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = json.decode(respStr);
        return data['url'];
      } else {
        print("ImageKit upload failed: $respStr");
        return null;
      }
    } catch (e) {
      print("Error uploading to ImageKit: $e");
      return null;
    }
  }

  Future<void> submitVerificationRequest() async {
    if (!formKey.currentState!.validate()) return;
    if (selectedGender.value.isEmpty) {
      Get.snackbar('Error', 'Please select gender');
      return;
    }
    if (profilePicture == null || medicalLicense == null ||
        degreeCertificate == null || governmentId == null) {
      Get.snackbar('Error', 'Please upload all required documents');
      return;
    }

    isLoading.value = true;
    currentStep.value = 0;
    uploadProgress.value = 0.0;
    loadingMessage.value = 'Preparing verification request...';

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');
      final userId = user.uid;
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      currentStep.value = 1;
      uploadProgress.value = 0.17;
      loadingMessage.value = 'Uploading profile picture...';
      final profilePictureUrl = await uploadFileToImageKit(profilePicture,
          '${userId}_profile_$timestamp.jpg', 'documents/profile_pictures/');

      currentStep.value = 2;
      uploadProgress.value = 0.33;
      loadingMessage.value = 'Uploading medical license...';
      final medicalLicenseUrl = await uploadFileToImageKit(medicalLicense,
          '${userId}_license_$timestamp', 'documents/medical_licenses/');

      currentStep.value = 3;
      uploadProgress.value = 0.50;
      loadingMessage.value = 'Uploading degree certificate...';
      final degreeCertificateUrl = await uploadFileToImageKit(degreeCertificate,
          '${userId}_degree_$timestamp', 'documents/degree_certificates/');

      currentStep.value = 4;
      uploadProgress.value = 0.67;
      loadingMessage.value = 'Uploading government ID...';
      final governmentIdUrl = await uploadFileToImageKit(
          governmentId, '${userId}_id_$timestamp', 'documents/government_ids/');

      String? specializationCertificateUrl;
      if (specializationCertificate != null) {
        loadingMessage.value = 'Uploading specialization certificate...';
        specializationCertificateUrl = await uploadFileToImageKit(
            specializationCertificate,
            '${userId}_specialization_$timestamp',
            'documents/specialization_certificates/');
      }

      String? affiliationLetterUrl;
      if (affiliationLetter != null) {
        loadingMessage.value = 'Uploading affiliation letter...';
        affiliationLetterUrl = await uploadFileToImageKit(
            affiliationLetter,
            '${userId}_affiliation_$timestamp',
            'documents/affiliation_letters/');
      }

      currentStep.value = 5;
      uploadProgress.value = 0.83;
      loadingMessage.value = 'Saving verification data...';

      final verificationData = {
        'userId': userId,
        'basicInfo': {
          'fullName': fullNameController.text.trim(),
          'fatherName': fatherNameController.text.trim(),
          'dateOfBirth': dobController.text.trim(),
          'gender': selectedGender.value,
          'contactNumber': contactController.text.trim(),
          'email': emailController.text.trim(),
          'currentAddress': addressController.text.trim(),
        },
        'professionalDetails': {
          'registrationNumber': registrationController.text.trim(),
          'clinicName': clinicNameController.text.trim(),
          'clinicAddress': clinicAddressController.text.trim(),
          'clinicContact': clinicContactController.text.trim(),
          'specialization': specializationController.text.trim(),
          'consultationFee': consultationFeeController.text.trim(),
          'experience': experienceController.text.trim(),
          'about': aboutController.text.trim(),
        },
        'documents': {
          'profilePicture': profilePictureUrl,
          'medicalLicense': medicalLicenseUrl,
          'degreeCertificate': degreeCertificateUrl,
          'governmentId': governmentIdUrl,
          'specializationCertificate': specializationCertificateUrl,
          'affiliationLetter': affiliationLetterUrl,
        },
        'verificationStatus': 'pending',
        'submittedAt': FieldValue.serverTimestamp(),
        'isVerified': false,
      };

      await FirebaseFirestore.instance
          .collection('doctor_verification_requests')
          .doc(userId)
          .set(verificationData);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({
        'verificationStatus': 'pending',
        'verificationSubmittedAt': FieldValue.serverTimestamp(),
      });

      currentStep.value = 6;
      uploadProgress.value = 1.0;
      loadingMessage.value = 'Verification request submitted successfully!';
      await Future.delayed(const Duration(milliseconds: 500));
      Get.dialog(_buildSuccessDialog());
    } catch (e) {
      Get.snackbar('Error', 'Failed to submit verification: ${e.toString()}');
    } finally {
      isLoading.value = false;
      uploadProgress.value = 0.0;
      currentStep.value = 0;
      loadingMessage.value = '';
    }
  }

  Widget _buildSuccessDialog() {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFEFF9F8),
              ),
              child: const Icon(Icons.check_circle, color: Color(0xFF199A8E), size: 32),
            ),
            const SizedBox(height: 20),
            const Text(
              "Verification Request Submitted!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Your verification request has been submitted successfully. Admin will review your documents and approve your account within 24-48 hours.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Get.back(); // Close dialog
                  _navigateToHome();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF199A8E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text("Continue to Home",
                    style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToHome() {
    // Navigate back to bottom navigation and set index to 0 (home page)
    // This will go back to the previous screen (bottom navigation) and clear the verification form
    Get.back(); // Go back to bottom navigation

    // Reset bottom navigation to home page (index 0)
    try {
      final bottomNavController = Get.find<DoctorBottomNavController>();
      bottomNavController.changeIndex(0); // Set to home page (index 0)
    } catch (e) {
      // If controller not found, just print debug info
      print('Bottom navigation controller not found: $e');
    }

    // Show success message on home screen
    Get.snackbar(
      'Success',
      'Verification request submitted successfully!',
      backgroundColor: const Color(0xFF199A8E),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
    );
  }

  @override
  void onClose() {
    fullNameController.dispose();
    fatherNameController.dispose();
    dobController.dispose();
    contactController.dispose();
    emailController.dispose();
    addressController.dispose();
    registrationController.dispose();
    clinicNameController.dispose();
    clinicAddressController.dispose();
    clinicContactController.dispose();
    specializationController.dispose();
    consultationFeeController.dispose();
    experienceController.dispose();
    aboutController.dispose();
    super.onClose();
  }
}
