import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/doctor_availability_model.dart';

class DoctorProfileController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  var isLoading = false.obs;
  var doctorProfile = Rxn<DoctorProfile>();

  var consultationFee = 0.0.obs;
  var bio = ''.obs;
  var clinicAddress = ''.obs;
  var clinicContact = ''.obs;
  var clinicName = ''.obs;
  var about = ''.obs;
  var registrationNumber = ''.obs;
  var specialization = ''.obs;
  var isOnlineOnly = false.obs;
  var isCurrentlyAvailable = true.obs;
  var weeklyAvailability = <DayAvailability>[].obs;

  var easypaisaNumber = ''.obs;
  var jazzcashNumber = ''.obs;
  var bankName = ''.obs;
  var bankAccountNumber = ''.obs;
  var bankHolderName = ''.obs;

  final List<String> daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  @override
  void onInit() {
    super.onInit();
    initializeWeeklyAvailability();
    loadDoctorProfile();
  }

  void initializeWeeklyAvailability() {
    weeklyAvailability.value = daysOfWeek
        .map((day) => DayAvailability(
              day: day,
              isAvailable: false,
              timeSlots: [],
            ))
        .toList();
  }

  Future<void> loadDoctorProfile() async {
    try {
      isLoading.value = true;
      final user = _auth.currentUser;
      if (user == null) return;

      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists || userDoc.data()?['isVerified'] != true) {
        Get.snackbar('Error', 'Only verified doctors can access this feature');
        return;
      }

      final profileDoc =
          await _firestore.collection('doctor_profiles').doc(user.uid).get();

      if (profileDoc.exists) {
        doctorProfile.value = DoctorProfile.fromMap(profileDoc.data()!);
        _updateLocalVariables();
      } else {
        await createProfileFromVerificationData();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load profile: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createProfileFromVerificationData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Get data from verification request
      final verificationDoc = await _firestore
          .collection('doctor_verification_requests')
          .doc(user.uid)
          .get();

      Map<String, dynamic> professionalDetails = {};
      if (verificationDoc.exists) {
        professionalDetails =
            verificationDoc.data()?['professionalDetails'] ?? {};
      }

      final defaultProfile = DoctorProfile(
        doctorId: user.uid,
        consultationFee:
            (professionalDetails['consultationFee'] ?? 500.0).toDouble(),
        profileImageUrl: '',
        bio: professionalDetails['about'] ?? '',
        clinicAddress: professionalDetails['clinicAddress'] ?? '',
        clinicContact: professionalDetails['clinicContact'] ?? '',
        clinicName: professionalDetails['clinicName'] ?? '',
        about: professionalDetails['about'] ?? '',
        registrationNumber: professionalDetails['registrationNumber'] ?? '',
        specialization: professionalDetails['specialization'] ?? '',
        isOnlineOnly: false,
        isCurrentlyAvailable: true,
        weeklyAvailability: weeklyAvailability.value,
        lastUpdated: DateTime.now(),
        easypaisaNumber: professionalDetails['easypaisaNumber'] ?? '',
        jazzcashNumber: professionalDetails['jazzcashNumber'] ?? '',
        bankName: professionalDetails['bankName'] ?? '',
        bankAccountNumber: professionalDetails['bankAccountNumber'] ?? '',
        bankHolderName: professionalDetails['bankHolderName'] ?? '',
      );

      await _firestore
          .collection('doctor_profiles')
          .doc(user.uid)
          .set(defaultProfile.toMap());

      await _firestore.collection('doctor_availability').doc(user.uid).set({
        'doctorId': user.uid,
        'isCurrentlyAvailable': true,
        'weeklyAvailability':
            weeklyAvailability.value.map((day) => day.toMap()).toList(),
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      doctorProfile.value = defaultProfile;
      _updateLocalVariables();
    } catch (e) {
      Get.snackbar('Error', 'Failed to create profile: $e');
    }
  }

  void _updateLocalVariables() {
    if (doctorProfile.value != null) {
      consultationFee.value = doctorProfile.value!.consultationFee;
      bio.value = doctorProfile.value!.bio;
      clinicAddress.value = doctorProfile.value!.clinicAddress;
      clinicContact.value = doctorProfile.value!.clinicContact;
      clinicName.value = doctorProfile.value!.clinicName;
      about.value = doctorProfile.value!.about;
      registrationNumber.value = doctorProfile.value!.registrationNumber;
      specialization.value = doctorProfile.value!.specialization;
      isOnlineOnly.value = doctorProfile.value!.isOnlineOnly;
      isCurrentlyAvailable.value = doctorProfile.value!.isCurrentlyAvailable;
      weeklyAvailability.value = doctorProfile.value!.weeklyAvailability;
      easypaisaNumber.value = doctorProfile.value!.easypaisaNumber;
      jazzcashNumber.value = doctorProfile.value!.jazzcashNumber;
      bankName.value = doctorProfile.value!.bankName;
      bankAccountNumber.value = doctorProfile.value!.bankAccountNumber;
      bankHolderName.value = doctorProfile.value!.bankHolderName;
    }
  }

  Future<void> updateProfile() async {
    try {
      isLoading.value = true;
      final user = _auth.currentUser;
      if (user == null) return;

      final updatedProfile = DoctorProfile(
        doctorId: user.uid,
        consultationFee: consultationFee.value,
        profileImageUrl: doctorProfile.value?.profileImageUrl ?? '',
        bio: bio.value,
        clinicAddress: clinicAddress.value,
        clinicContact: clinicContact.value,
        clinicName: clinicName.value,
        about: about.value,
        registrationNumber: registrationNumber.value,
        specialization: specialization.value,
        isOnlineOnly: isOnlineOnly.value,
        isCurrentlyAvailable: isCurrentlyAvailable.value,
        weeklyAvailability: weeklyAvailability.value,
        lastUpdated: DateTime.now(),
        easypaisaNumber: easypaisaNumber.value,
        jazzcashNumber: jazzcashNumber.value,
        bankName: bankName.value,
        bankAccountNumber: bankAccountNumber.value,
        bankHolderName: bankHolderName.value,
      );

      await _firestore
          .collection('doctor_profiles')
          .doc(user.uid)
          .set(updatedProfile.toMap());

      await _firestore.collection('doctor_availability').doc(user.uid).set({
        'doctorId': user.uid,
        'isCurrentlyAvailable': isCurrentlyAvailable.value,
        'weeklyAvailability':
            weeklyAvailability.value.map((day) => day.toMap()).toList(),
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      doctorProfile.value = updatedProfile;
      Get.snackbar(
        'Success',
        'Profile updated successfully',
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: EdgeInsets.all(16),
        borderRadius: 16,
        duration: Duration(seconds: 2),
        icon: Icon(Icons.check_circle, color: Colors.white, size: 28),
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to update profile: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void toggleDayAvailability(int dayIndex) {
    final updatedDay = DayAvailability(
      day: weeklyAvailability[dayIndex].day,
      isAvailable: !weeklyAvailability[dayIndex].isAvailable,
      timeSlots: weeklyAvailability[dayIndex].timeSlots,
    );
    weeklyAvailability[dayIndex] = updatedDay;
  }

  void addTimeSlot(
      int dayIndex, String startTime, String endTime, int maxPatients) {
    final newSlot = TimeSlot(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      startTime: startTime,
      endTime: endTime,
      maxPatients: maxPatients,
    );

    final updatedSlots =
        List<TimeSlot>.from(weeklyAvailability[dayIndex].timeSlots);
    updatedSlots.add(newSlot);

    final updatedDay = DayAvailability(
      day: weeklyAvailability[dayIndex].day,
      isAvailable: weeklyAvailability[dayIndex].isAvailable,
      timeSlots: updatedSlots,
    );

    weeklyAvailability[dayIndex] = updatedDay;
  }

  void removeTimeSlot(int dayIndex, String slotId) {
    final updatedSlots = weeklyAvailability[dayIndex]
        .timeSlots
        .where((slot) => slot.id != slotId)
        .toList();

    final updatedDay = DayAvailability(
      day: weeklyAvailability[dayIndex].day,
      isAvailable: weeklyAvailability[dayIndex].isAvailable,
      timeSlots: updatedSlots,
    );

    weeklyAvailability[dayIndex] = updatedDay;
  }

  void toggleAvailabilityStatus() {
    isCurrentlyAvailable.value = !isCurrentlyAvailable.value;
    updateProfile();
  }
}
