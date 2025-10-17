import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'dart:io';
import '../models/user_appointment_model.dart';
import '../../utils/snackbar_utils.dart';
import '../../utils/services/imagekit_service.dart';

class AppointmentController extends GetxController {
  var ownerName = ''.obs;
  var petName = ''.obs;
  var selectedPaymentMethod = ''.obs;
  var paymentScreenshotPath = ''.obs;
  var paymentScreenshotBytes = Rx<Uint8List?>(null);
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
      // Create XFile from the selected image
      XFile imageFile;

      if (kIsWeb && paymentScreenshotBytes.value != null) {
        // For web, create XFile from bytes
        imageFile = XFile.fromData(
          paymentScreenshotBytes.value!,
          name: 'payment_screenshot_${appointmentId}.jpg',
        );
      } else {
        // For mobile/desktop, use the file path
        imageFile = XFile(paymentScreenshotPath.value);
      }

      // Use the ImageKitService to upload the screenshot
      final imageUrl = await ImageKitService.uploadPaymentScreenshot(
          imageFile, appointmentId);

      return imageUrl;
    } catch (e) {
      print('Error uploading payment screenshot: $e');
      // Re-throw the error so it's handled properly in the booking process
      throw Exception('Failed to upload payment screenshot: $e');
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
