import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import '../models/user_appointment_model.dart';
import '../../utils/snackbar_utils.dart';

class AppointmentController extends GetxController {
  static const String _imageKitPublicKey =
      'public_PZlQaFn7qH7zGf31Yp3rLKnUMGc=';
  static const String _imageKitPrivateKey =
      'private_sWCIXKsbU9kaLKEer34eiiF3sKw=';
  static const String _imageKitUploadEndpoint =
      'https://upload.imagekit.io/api/v1/files/upload';
  static const String _paymentScreenshotsFolder = 'payment_screenshots/';

  var ownerName = ''.obs;
  var petName = ''.obs;
  var selectedPaymentMethod = ''.obs;
  var paymentScreenshotPath = ''.obs;
  var paymentScreenshotBytes = Rx<Uint8List?>(null); // For web platform
  var isLoading = false.obs;
  var isBookingAppointment = false.obs;
  var petType = ''.obs;
  var numberOfPatients = 1.obs;
  var consultationType = ConsultationType.pet.obs;
  var currentAppointment = Rx<Appointment?>(null);
  final List<String> petTypes = [
    'Dog',
    'Cat',
    'Bird',
    'Horse',
    'Other',
  ];
  var reason = ''.obs;

  final ImagePicker _picker = ImagePicker();

  Future<void> pickPaymentScreenshot() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        paymentScreenshotPath.value = image.path;

        // For web platform, also store bytes for preview
        if (kIsWeb) {
          paymentScreenshotBytes.value = await image.readAsBytes();
        }
      }
    } catch (e) {
      SnackbarUtils.showError(
          'Image Selection Failed', 'Failed to pick image: $e');
    }
  }

  // Clear screenshot data
  void clearPaymentScreenshot() {
    paymentScreenshotPath.value = '';
    paymentScreenshotBytes.value = null;
  }

  Future<String?> _uploadPaymentScreenshot(String appointmentId) async {
    if (paymentScreenshotPath.value.isEmpty) return null;

    try {
      Uint8List imageBytes;

      if (kIsWeb) {
        // On web, use the stored bytes
        if (paymentScreenshotBytes.value != null) {
          imageBytes = paymentScreenshotBytes.value!;
        } else {
          final xfile = XFile(paymentScreenshotPath.value);
          imageBytes = await xfile.readAsBytes();
        }
      } else {
        // On mobile/desktop, read from file
        final file = File(paymentScreenshotPath.value);
        imageBytes = await file.readAsBytes();
      }

      final uniqueFilename =
          '${appointmentId}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Generate authentication parameters
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final token = _generateAuthToken(timestamp);

      // Prepare multipart request
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
        'folder': _paymentScreenshotsFolder,
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
          imageBytes,
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
            'Failed to upload screenshot to ImageKit: HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('Error uploading payment screenshot: $e');
      return null;
    }
  }

  /// Generate authentication token for ImageKit upload
  String _generateAuthToken(String timestamp) {
    try {
      var bytes = utf8.encode(timestamp + _imageKitPrivateKey);
      var digest = sha256.convert(bytes);
      return digest.toString();
    } catch (e) {
      throw Exception('Failed to generate authentication token: $e');
    }
  }

  Future<bool> bookAppointment({
    required String doctorId,
    required String selectedDate,
    required String selectedTime,
    required String selectedDay,
    required double consultationFee,
  }) async {
    // Basic required field validations FIRST
    if (ownerName.value.trim().isEmpty) {
      SnackbarUtils.showError('Error', 'Please enter owner name');
      return false;
    }

    if (selectedPaymentMethod.value.isEmpty) {
      SnackbarUtils.showError('Error', 'Please select a payment method');
      return false;
    }

    if (paymentScreenshotPath.value.isEmpty) {
      SnackbarUtils.showError('Error', 'Please upload payment screenshot');
      return false;
    }

    if (reason.value.isEmpty) {
      SnackbarUtils.showError(
          'Error', 'Please enter reason for the appointment');
      return false;
    }

    // Consultation type specific validations
    if (consultationType.value == ConsultationType.pet) {
      if (petName.value.trim().isEmpty) {
        SnackbarUtils.showError('Error', 'Please enter pet name');
        return false;
      }
      if (petType.value.isEmpty) {
        SnackbarUtils.showError('Error', 'Please select pet type');
        return false;
      }
    } else {
      // For livestock and poultry
      if (numberOfPatients.value <= 0) {
        SnackbarUtils.showError('Error', 'Please enter number of patients');
        return false;
      }
    }

    try {
      isBookingAppointment.value = true;

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        SnackbarUtils.showError('Error', 'Please login to book appointment');
        return false;
      }

      // Create appointment document
      final appointmentRef = FirebaseFirestore.instance
          .collection('appointments')
          .doc();

      // Upload payment screenshot via ImageKit
      final screenshotUrl = await _uploadPaymentScreenshot(appointmentRef.id);

      // Fetch doctor full name and profile picture
      final doctorDoc = await FirebaseFirestore.instance
          .collection('doctor_verification_requests')
          .doc(doctorId)
          .get();
      final doctorName = doctorDoc.data()?['basicInfo']?['fullName'] ?? '';
      final doctorprofilepic = doctorDoc.data()?['documents']?['profilePicture'] ?? '';

      final appointment = Appointment(
        id: appointmentRef.id,
        doctorId: doctorId,
        userId: user.uid,
        ownerName: ownerName.value.trim(),
        selectedDate: selectedDate,
        selectedTime: selectedTime,
        selectedDay: selectedDay,
        consultationFee: consultationFee,
        paymentMethod: selectedPaymentMethod.value,
        petName: consultationType.value == ConsultationType.pet ? petName.value.trim() : null,
        petType: consultationType.value == ConsultationType.pet ? petType.value : null,
        numberOfPatients: consultationType.value != ConsultationType.pet ? numberOfPatients.value : null,
        consultationType: consultationType.value,
        paymentScreenshotUrl: screenshotUrl,
        status: AppointmentStatus.pending,
        createdAt: DateTime.now(),
        doctorName: doctorName,
        doctorprofilepic: doctorprofilepic,
        reason: reason.value,
      );

      await appointmentRef.set(appointment.toFirestore());

      currentAppointment.value = appointment;

      SnackbarUtils.showSuccess('Success',
          'Appointment booked successfully! Please wait for doctor verification.',
          duration: const Duration(seconds: 3));
      return true;
    } catch (e) {
      SnackbarUtils.showError('Error', 'Failed to book appointment: $e');
      return false;
    } finally {
      isBookingAppointment.value = false;
    }
  }

  Future<void> checkAppointmentStatus(String appointmentId, dynamic currentAppointment) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('appointments')
          .doc(appointmentId)
          .get();

      if (doc.exists) {
        currentAppointment.value = Appointment.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }
    } catch (e) {
      print('Error checking appointment status: $e');
    }
  }

  void resetForm() {
    ownerName.value = '';
    petName.value = '';
    petType.value = '';
    numberOfPatients.value = 1;
    consultationType.value = ConsultationType.pet;
    selectedPaymentMethod.value = '';
    paymentScreenshotPath.value = '';
    currentAppointment.value = null;
    reason.value = '';
  }

  @override
  void onClose() {
    ownerName.close();
    petName.close();
    selectedPaymentMethod.close();
    paymentScreenshotPath.close();
    isLoading.close();
    isBookingAppointment.close();
    currentAppointment.close();
    reason.close();
    super.onClose();
  }
}
