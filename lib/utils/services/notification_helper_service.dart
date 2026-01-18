import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class NotificationHelperService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  /// Send notification to doctor about new appointment
  static Future<void> sendAppointmentNotificationToDoctor({
    required String doctorId,
    required String appointmentId,
    required String patientName,
    required String consultationType,
    required String appointmentDate,
    required String appointmentTime,
    required double consultationFee,
  }) async {
    try {
      if (kDebugMode) {
        print('[v0] Starting to send appointment notification to doctor: $doctorId');
      }

      // Step 1: Get doctor's FCM token
      final doctorDoc = await _firestore.collection('users').doc(doctorId).get();

      if (!doctorDoc.exists) {
        if (kDebugMode) {
          print('[v0] Doctor document not found for ID: $doctorId');
        }
        return;
      }

      final doctorFCMToken = doctorDoc.data()?['fcmToken'] as String?;

      if (doctorFCMToken == null || doctorFCMToken.isEmpty) {
        if (kDebugMode) {
          print('[v0] No FCM token found for doctor: $doctorId');
        }
        return;
      }

      if (kDebugMode) {
        print('[v0] Doctor FCM token found: $doctorFCMToken');
      }

      // Step 2: Create notification data
      final notificationData = {
        'title': 'New Appointment Request',
        'body': 'You have a new appointment request from $patientName for $consultationType consultation',
        'appointmentId': appointmentId,
        'patientName': patientName,
        'consultationType': consultationType,
        'appointmentDate': appointmentDate,
        'appointmentTime': appointmentTime,
        'consultationFee': consultationFee.toString(),
        'notificationType': 'appointment',
        'timestamp': DateTime.now().toIso8601String(),
      };

      // Step 3: Save notification to Firestore for doctor
      await _saveNotificationToFirestore(
        userId: doctorId,
        notificationData: notificationData,
      );

      if (kDebugMode) {
        print('[v0] Notification saved to Firestore for doctor: $doctorId');
      }

      // Step 4: Call backend to send FCM message
      // Note: This would ideally be done through a Cloud Function to keep API key secure
      // For now, we're storing the notification in Firestore which the doctor app can listen to

      if (kDebugMode) {
        print('[v0] Appointment notification prepared for doctor: $doctorId');
        print('[v0] Appointment ID: $appointmentId');
        print('[v0] Patient Name: $patientName');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[v0] Error sending appointment notification: $e');
      }
    }
  }

  /// Save notification to Firestore for persistence
  static Future<void> _saveNotificationToFirestore({
    required String userId,
    required Map<String, dynamic> notificationData,
  }) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(userId)
          .collection('appointments')
          .add({
        ...notificationData,
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (kDebugMode) {
        print('[v0] Notification saved successfully for user: $userId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[v0] Error saving notification to Firestore: $e');
      }
    }
  }

  /// Mark notification as read
  static Future<void> markNotificationAsRead(String userId, String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(userId)
          .collection('appointments')
          .doc(notificationId)
          .update({'read': true});

      if (kDebugMode) {
        print('[v0] Notification marked as read: $notificationId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[v0] Error marking notification as read: $e');
      }
    }
  }

  /// Get unread notifications count for doctor
  static Future<int?> getUnreadNotificationsCount(String doctorId) async {
    try {
      final snapshot = await _firestore
          .collection('notifications')
          .doc(doctorId)
          .collection('appointments')
          .where('read', isEqualTo: false)
          .count()
          .get();

      return snapshot.count;
    } catch (e) {
      if (kDebugMode) {
        print('[v0] Error getting unread notifications count: $e');
      }
      return 0;
    }
  }

  /// Stream of notifications for real-time updates
  static Stream<QuerySnapshot> getNotificationsStream(String userId) {
    return _firestore
        .collection('notifications')
        .doc(userId)
        .collection('appointments')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}
