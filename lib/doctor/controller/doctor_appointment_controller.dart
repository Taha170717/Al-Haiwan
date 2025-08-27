import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';

class DoctorAppointmentsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  var pendingAppointments = <Map<String, dynamic>>[].obs;
  var confirmedAppointments = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  var selectedTab = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAppointments();
  }

  void fetchAppointments() async {
    try {
      isLoading.value = true;
      final user = _auth.currentUser;
      if (user != null) {
        final pendingSnapshot = await _firestore
            .collection('appointments')
            .where('doctorId', isEqualTo: user.uid)
            .where('status', isEqualTo: 'pending')
            .get();

        final confirmedSnapshot = await _firestore
            .collection('appointments')
            .where('doctorId', isEqualTo: user.uid)
            .where('status', isEqualTo: 'confirmed')
            .get();

        var pendingDocs = pendingSnapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
        var confirmedDocs = confirmedSnapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();

        pendingDocs.sort((a, b) {
          final aTime = a['createdAt'] as Timestamp?;
          final bTime = b['createdAt'] as Timestamp?;
          if (aTime == null || bTime == null) return 0;
          return bTime.compareTo(aTime);
        });

        confirmedDocs.sort((a, b) {
          final aTime = a['createdAt'] as Timestamp?;
          final bTime = b['createdAt'] as Timestamp?;
          if (aTime == null || bTime == null) return 0;
          return bTime.compareTo(aTime);
        });

        pendingAppointments.value = pendingDocs;
        confirmedAppointments.value = confirmedDocs;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch appointments: $e',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
    } finally {
      isLoading.value = false;
    }
  }

  void approveAppointment(String appointmentId, String userId) async {
    try {
      await _firestore.collection('appointments').doc(appointmentId).update({
        'status': 'confirmed',
        'confirmedAt': FieldValue.serverTimestamp(),
      });

      await _firestore.collection('notifications').add({
        'userId': userId,
        'title': 'Appointment Confirmed! 🎉',
        'message': 'Great news! Your appointment has been confirmed by the doctor. Please arrive 10 minutes early.',
        'type': 'appointment_confirmed',
        'appointmentId': appointmentId,
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': false,
        'priority': 'high',
      });

      Get.snackbar('Success', 'Appointment approved successfully! 🎉',
        backgroundColor: Colors.green[100],
        colorText: Colors.green[800],
        icon: Icon(Icons.check_circle, color: Colors.green[800]),
      );
      fetchAppointments();
    } catch (e) {
      Get.snackbar('Error', 'Failed to approve appointment: $e',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
    }
  }

  void completeAppointment(String appointmentId, String userId) async {
    try {
      await _firestore.collection('appointments').doc(appointmentId).update({
        'status': 'completed',
        'completedAt': FieldValue.serverTimestamp(),
      });

      await _firestore.collection('notifications').add({
        'userId': userId,
        'title': 'Appointment Completed ✅',
        'message': 'Your appointment has been completed. Thank you for visiting!',
        'type': 'appointment_completed',
        'appointmentId': appointmentId,
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': false,
        'priority': 'medium',
      });

      Get.snackbar('Success', 'Appointment marked as completed! ✅',
        backgroundColor: Colors.blue[100],
        colorText: Colors.blue[800],
        icon: Icon(Icons.task_alt, color: Colors.blue[800]),
      );
      fetchAppointments();
    } catch (e) {
      Get.snackbar('Error', 'Failed to complete appointment: $e',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
    }
  }

  void rejectAppointment(String appointmentId, String userId, String reason) async {
    try {
      await _firestore.collection('appointments').doc(appointmentId).update({
        'status': 'rejected',
        'doctorNotes': reason,
        'rejectedAt': FieldValue.serverTimestamp(),
      });

      await _firestore.collection('notifications').add({
        'userId': userId,
        'title': 'Appointment Update ⚠️',
        'message': 'Unfortunately, your appointment has been rescheduled. Reason: $reason',
        'type': 'appointment_rejected',
        'appointmentId': appointmentId,
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': false,
        'priority': 'high',
      });

      Get.snackbar('Success', 'Appointment rejected with reason provided',
        backgroundColor: Colors.orange[100],
        colorText: Colors.orange[800],
      );
      fetchAppointments();
    } catch (e) {
      Get.snackbar('Error', 'Failed to reject appointment: $e',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
    }
  }
}


