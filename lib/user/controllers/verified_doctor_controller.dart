import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/doctor_list_viewmodel.dart';

class VerifiedDoctorsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var verifiedDoctors = <Doctor>[].obs;
  var isLoading = true.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchVerifiedDoctors();
  }

  Future<void> fetchVerifiedDoctors() async {
    try {
      isLoading.value = true;
      hasError.value = false;

      final QuerySnapshot snapshot = await _firestore
          .collection('doctor_verification_requests')
          .where('isVerified', isEqualTo: true)
          .get();

      final List<Doctor> doctors = [];

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final doctor = Doctor.fromFirestore(data, doc.id);
        doctors.add(doctor);
      }

      verifiedDoctors.value = doctors;
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Error fetching verified doctors: ${e.toString()}';
      print('Error fetching verified doctors: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshDoctors() async {
    await fetchVerifiedDoctors();
  }

  Future<Doctor?> getDoctorById(String doctorId) async {
    try {
      final DocumentSnapshot profileDoc = await _firestore
          .collection('doctor_profiles')
          .doc(doctorId)
          .get();

      if (profileDoc.exists) {
        final profileData = profileDoc.data() as Map<String, dynamic>;

        Map<String, dynamic>? verificationData;
        try {
          final verificationDoc = await _firestore
              .collection('doctor_verification_requests')
              .doc(doctorId)
              .get();
          if (verificationDoc.exists) {
            verificationData = verificationDoc.data() as Map<String, dynamic>;
          }
        } catch (e) {
          print('Error fetching verification data: $e');
        }

        Map<String, dynamic>? availabilityData;
        try {
          final availabilityDoc = await _firestore
              .collection('doctor_availability')
              .doc(doctorId)
              .get();
          if (availabilityDoc.exists) {
            availabilityData = availabilityDoc.data() as Map<String, dynamic>;
          }
        } catch (e) {
          print('Error fetching availability data: $e');
        }

        return Doctor.fromFirestoreProfile(
            profileData,
            doctorId,
            verificationData,
            availabilityData
        );
      }
      return null;
    } catch (e) {
      print('Error fetching doctor by ID: $e');
      return null;
    }
  }
}
