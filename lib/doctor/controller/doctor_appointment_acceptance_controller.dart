import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class DoctorAppointmentAcceptanceController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  var isLoading = false.obs;

  Future<bool> acceptAppointment({
    required String appointmentId,
    required String userId,
    String? doctorNotes,
  }) async {
    try {
      isLoading.value = true;

      // Update appointment status
      await _firestore.collection('appointments').doc(appointmentId).update({
        'status': 'confirmed',
        'confirmedAt': FieldValue.serverTimestamp(),
        'doctorNotes': doctorNotes ?? '',
      });

      // Get user's FCM token
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final userFcmToken = userDoc.data()?['fcmToken'] as String?;

      // Send notification to user
      if (userFcmToken != null) {
        await _sendAppointmentAcceptanceNotificationToUser(
          userFcmToken: userFcmToken,
          appointmentId: appointmentId,
          userId: userId,
          doctorNotes: doctorNotes,
        );
      }

      if (kDebugMode) {
        print('[v0] Appointment accepted: $appointmentId, notification sent to user');
      }

      return true;
    } catch (e) {
      print('Error accepting appointment: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _sendAppointmentAcceptanceNotificationToUser({
    required String userFcmToken,
    required String appointmentId,
    required String userId,
    String? doctorNotes,
  }) async {
    try {
      // Fetch appointment details for notification
      final appointmentDoc = await _firestore
          .collection('appointments')
          .doc(appointmentId)
          .get();

      if (appointmentDoc.exists) {
        final appointmentData = appointmentDoc.data() as Map<String, dynamic>;
        final doctorName = appointmentData['doctorName'] ?? 'Doctor';
        final selectedDate = appointmentData['selectedDate'];
        final selectedTime = appointmentData['selectedTime'] ?? '';

        // Save notification to Firestore for user
        await _firestore.collection('user_notifications').add({
          'userId': userId,
          'appointmentId': appointmentId,
          'title': 'Appointment Confirmed',
          'message': 'Your appointment with Dr. $doctorName has been confirmed for $selectedTime',
          'type': 'appointment_accepted',
          'isRead': false,
          'createdAt': FieldValue.serverTimestamp(),
          'doctorName': doctorName,
          'appointmentDate': selectedDate,
          'appointmentTime': selectedTime,
          'doctorNotes': doctorNotes ?? '',
        });

        if (kDebugMode) {
          print('[v0] User notification created for accepted appointment: $appointmentId');
        }
      }
    } catch (e) {
      print('Error sending user notification: $e');
    }
  }

  Future<bool> rejectAppointment({
    required String appointmentId,
    required String userId,
    required String rejectReason,
  }) async {
    try {
      isLoading.value = true;

      // Update appointment status
      await _firestore.collection('appointments').doc(appointmentId).update({
        'status': 'rejected',
        'rejectedAt': FieldValue.serverTimestamp(),
        'rejectReason': rejectReason,
      });

      // Get user's FCM token
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final userFcmToken = userDoc.data()?['fcmToken'] as String?;

      // Send rejection notification to user
      if (userFcmToken != null) {
        await _firestore.collection('user_notifications').add({
          'userId': userId,
          'appointmentId': appointmentId,
          'title': 'Appointment Rejected',
          'message': 'Your appointment request has been rejected. Reason: $rejectReason',
          'type': 'appointment_rejected',
          'isRead': false,
          'createdAt': FieldValue.serverTimestamp(),
          'rejectReason': rejectReason,
        });
      }

      if (kDebugMode) {
        print('[v0] Appointment rejected and user notified: $appointmentId');
      }

      return true;
    } catch (e) {
      print('Error rejecting appointment: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    isLoading.close();
    super.onClose();
  }
}
