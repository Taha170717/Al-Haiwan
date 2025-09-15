import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/user_appointment_model.dart';
import '../../utils/snackbar_utils.dart';

class AppointmentController extends GetxController {
  var ownerName = ''.obs;
  var petName = ''.obs;
  var selectedPaymentMethod = ''.obs;
  var paymentScreenshotPath = ''.obs;
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
      }
    } catch (e) {
      SnackbarUtils.showError(
          'Image Selection Failed', 'Failed to pick image: $e');
    }
  }

  Future<String?> _uploadPaymentScreenshot(String appointmentId) async {
    if (paymentScreenshotPath.value.isEmpty) return null;

    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('payment_screenshots')
          .child('$appointmentId.jpg');

      if (kIsWeb) {
        // On web, upload using bytes from XFile
        final xfile = XFile(paymentScreenshotPath.value);
        final bytes = await xfile.readAsBytes();
        await ref.putData(bytes);
      } else {
        // On mobile/desktop, upload using File
        final file = File(paymentScreenshotPath.value);
        await ref.putFile(file);
      }

      return await ref.getDownloadURL();
    } catch (e) {
      print('Error uploading screenshot: $e');
      return null;
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

      // Upload payment screenshot
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
