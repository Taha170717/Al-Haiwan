import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class DoctorNotificationsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  var notifications = <Map<String, dynamic>>[].obs;
  var unreadCount = 0.obs;
  var isLoading = false.obs;
  var listenerError = ''.obs; // expose Firestore listen errors to UI

  StreamSubscription<User?>? _authSub;
  StreamSubscription<QuerySnapshot>? _notifSub;

  @override
  void onInit() {
    super.onInit();
    // Listen for auth state changes so we attach/detach notification listeners appropriately
    _authSub = _auth.authStateChanges().listen((user) {
      if (user != null) {
        listenToNotifications();
        fetchUnreadCount();
      } else {
        // Clear state when signed out
        notifications.clear();
        unreadCount.value = 0;
        _notifSub?.cancel();
        _notifSub = null;
      }
    });

    // If user already signed in at controller init, start listening immediately
    if (_auth.currentUser != null) {
      listenToNotifications();
      fetchUnreadCount();
    }
  }

  /// Listen to real-time notifications for the current doctor
  Future<void> listenToNotifications() async {
    final doctorId = _auth.currentUser?.uid;
    if (doctorId == null) {
      if (kDebugMode) print('[v0] Doctor ID is null, cannot listen to notifications');
      listenerError.value = 'Not signed in';
      return;
    }

    if (kDebugMode) print('[v0] Starting to listen for notifications for doctor: $doctorId');

    // Cancel existing subscription if present
    _notifSub?.cancel();
    listenerError.value = '';

    // Helper to process snapshots (shared between filtered and unfiltered listeners)
    void _processSnapshot(QuerySnapshot snapshot) {
      try {
        if (kDebugMode) print('[v0] Received ${snapshot.docs.length} notifications (raw)');

        // Map docs to plain maps and include id
        final items = snapshot.docs.map((doc) {
          final data = Map<String, dynamic>.from(doc.data() as Map<String, dynamic>);
          data['id'] = doc.id;
          return data;
        }).where((data) {
          // If we used server-side filtering this is a no-op, but keep client-side resilience
          final possibleKeys = ['doctorId', 'doctor_id', 'doctor', 'doctorUid', 'doctorUID'];
          for (var key in possibleKeys) {
            if (data.containsKey(key)) {
              final val = data[key];
              if (val != null && val.toString() == doctorId) return true;
            }
          }
          return false;
        }).toList();

        // Sort locally by createdAt (most recent first). Accept various types.
        items.sort((a, b) {
          final aTs = _extractCreatedAtMillis(a['createdAt']);
          final bTs = _extractCreatedAtMillis(b['createdAt']);
          return (bTs ?? 0).compareTo(aTs ?? 0);
        });

        notifications.value = items;

        // Keep unread count in sync (best-effort)
        fetchUnreadCount();

        if (kDebugMode) {
          print('[v0] Notifications updated: ${notifications.length} notifications');
          for (var notif in notifications) {
            print('[v0] Notification: ${notif['title']} - ${notif['patientName']}');
          }
        }

        // Clear any previous listener error on successful processing
        listenerError.value = '';
      } catch (e) {
        if (kDebugMode) print('[v0] Error processing notifications snapshot: $e');
        listenerError.value = 'Processing error: $e';
      }
    }

    // Try to attach a server-side filtered query first to reduce data transfer
    try {
      final query = _firestore.collection('doctor_notifications').where('doctorId', isEqualTo: doctorId);
      _notifSub = query.snapshots().listen((snapshot) {
        _processSnapshot(snapshot);
      }, onError: (error) {
        if (kDebugMode) print('[v0] Error in filtered listener: $error');
        // If there is a permission or query error, fallback to unfiltered listener below
        listenerError.value = error.toString();
      });
    } catch (e) {
      // Fallback: if server-side where() fails, listen to the whole collection and filter client-side
      if (kDebugMode) print('[v0] Server-side filtered listener failed, falling back to full collection: $e');
      listenerError.value = 'Falling back to unfiltered listener: $e';
      _notifSub = _firestore.collection('doctor_notifications').snapshots().listen((snapshot) {
        _processSnapshot(snapshot);
      }, onError: (error) {
        if (kDebugMode) print('[v0] Error in unfiltered listener: $error');
        listenerError.value = error.toString();
      });
    }
  }

  /// Attempt to extract millis since epoch from different createdAt representations
  int? _extractCreatedAtMillis(dynamic raw) {
    try {
      if (raw == null) return null;
      if (raw is Timestamp) return raw.millisecondsSinceEpoch;
      if (raw is int) return raw; // assume already millis
      if (raw is double) return raw.toInt();
      if (raw is String) {
        final dt = DateTime.tryParse(raw);
        if (dt != null) return dt.millisecondsSinceEpoch;
        final parsed = int.tryParse(raw);
        if (parsed != null) return parsed; // epoch millis as string
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  /// Fetch unread notifications count
  Future<void> fetchUnreadCount() async {
    try {
      final doctorId = _auth.currentUser?.uid;
      if (doctorId == null) return;

      // Try aggregation count when available
      try {
        final snapshot = await _firestore
            .collection('doctor_notifications')
            .where('doctorId', isEqualTo: doctorId)
            .where('read', isEqualTo: false)
            .count()
            .get();

        unreadCount.value = snapshot.count ?? 0;
        return;
      } catch (e) {
        if (kDebugMode) print('[v0] Aggregation count failed, falling back to query get(): $e');
        // fallthrough to non-aggregation approach
      }

      // Fallback: normal query and count documents (best-effort)
      try {
        final snapshot = await _firestore
            .collection('doctor_notifications')
            .where('doctorId', isEqualTo: doctorId)
            .where('read', isEqualTo: false)
            .get();

        unreadCount.value = snapshot.docs.length;
      } catch (e) {
        if (kDebugMode) print('[v0] Error fetching unread count with query: $e');
        // Last resort: fetch all and filter client-side
        try {
          final snapshot = await _firestore.collection('doctor_notifications').get();
          final docsForDoctor = snapshot.docs.where((doc) {
            final data = doc.data();
            final possibleKeys = ['doctorId', 'doctor_id', 'doctor', 'doctorUid', 'doctorUID'];
            for (var key in possibleKeys) {
              if (data.containsKey(key) && data[key]?.toString() == doctorId) {
                final read = data['read'];
                if (read == false) return true;
              }
            }
            return false;
          }).length;
          unreadCount.value = docsForDoctor;
        } catch (e) {
          if (kDebugMode) print('[v0] Final fallback failed fetching unread count: $e');
        }
      }

      if (kDebugMode) print('[v0] Unread notifications count: ${unreadCount.value}');
    } catch (e) {
      if (kDebugMode) print('[v0] Error fetching unread count: $e');
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      final doctorId = _auth.currentUser?.uid;
      if (doctorId == null) return;

      await _firestore.collection('doctor_notifications').doc(notificationId).update({'read': true});

      await fetchUnreadCount();

      if (kDebugMode) {
        print('[v0] Notification marked as read: $notificationId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[v0] Error marking notification as read: $e');
      }
      listenerError.value = e.toString();
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      final doctorId = _auth.currentUser?.uid;
      if (doctorId == null) return;

      final batch = _firestore.batch();
      for (var notification in notifications) {
        final id = notification['id'];
        if (id != null) {
          final docRef = _firestore.collection('doctor_notifications').doc(id);
          batch.update(docRef, {'read': true});
        }
      }

      await batch.commit();
      await fetchUnreadCount();

      if (kDebugMode) {
        print('[v0] All notifications marked as read');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[v0] Error marking all as read: $e');
      }
      listenerError.value = e.toString();
    }
  }

  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      final doctorId = _auth.currentUser?.uid;
      if (doctorId == null) return;

      await _firestore.collection('doctor_notifications').doc(notificationId).delete();

      if (kDebugMode) {
        print('[v0] Notification deleted: $notificationId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[v0] Error deleting notification: $e');
      }
      listenerError.value = e.toString();
    }
  }

  /// Get notification details with appointment info
  Future<Map<String, dynamic>?> getNotificationDetails(String appointmentId) async {
    try {
      final appointmentDoc = await _firestore.collection('appointments').doc(appointmentId).get();

      if (appointmentDoc.exists) {
        final data = appointmentDoc.data();
        if (data == null) return null;
        // Ensure a Map<String, dynamic> is returned
        return Map<String, dynamic>.from(data as Map);
      }
    } catch (e) {
      if (kDebugMode) {
        print('[v0] Error fetching notification details: $e');
      }
    }
    return null;
  }

  @override
  void onClose() {
    _authSub?.cancel();
    _notifSub?.cancel();
    super.onClose();
  }
}
