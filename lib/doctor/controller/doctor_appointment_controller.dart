import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class DoctorAppointmentsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  var pendingAppointments = <Map<String, dynamic>>[].obs;
  var confirmedAppointments = <Map<String, dynamic>>[].obs;
  var rejectedAppointments = <Map<String, dynamic>>[].obs;
  var completedAppointments = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  var selectedTab = 0.obs;

  // Stream subscriptions for real-time updates
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _pendingSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _confirmedSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _completedSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _rejectedSub;
  StreamSubscription<User?>? _authSub;

  @override
  void onInit() {
    super.onInit();
    // Listen to auth state so we (re)subscribe when a user logs in/out
    _authSub = _auth.authStateChanges().listen((user) {
      _cancelAllSubscriptions();
      if (user != null) {
        _subscribeToAppointments(user.uid);
      } else {
        // Clear local lists when signed out
        pendingAppointments.clear();
        confirmedAppointments.clear();
        completedAppointments.clear();
        rejectedAppointments.clear();
      }
    });

    // If already signed in, subscribe immediately
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      _subscribeToAppointments(currentUser.uid);
    }
  }

  void _subscribeToAppointments(String doctorUid) {
    isLoading.value = true;

    List<Map<String, dynamic>> _mapDocs(QuerySnapshot<Map<String, dynamic>> snap) {
      return snap.docs.map((d) {
        final data = Map<String, dynamic>.from(d.data());
        data['id'] = d.id;
        return data;
      }).toList();
    }

    try {
      _pendingSub = _firestore
          .collection('appointments')
          .where('doctorId', isEqualTo: doctorUid)
          .where('status', isEqualTo: 'pending')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .listen((snap) {
        pendingAppointments.value = _mapDocs(snap);
        isLoading.value = false;
      }, onError: (e) {
        print('Pending listener error: $e');
        isLoading.value = false;
      });
    } catch (e) {
      // If the query fails (permissions / indexing), fall back to single fetch
      print('Failed to subscribe pending: $e');
      fetchAppointments();
    }

    try {
      _confirmedSub = _firestore
          .collection('appointments')
          .where('doctorId', isEqualTo: doctorUid)
          .where('status', isEqualTo: 'confirmed')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .listen((snap) {
        confirmedAppointments.value = _mapDocs(snap);
      }, onError: (e) => print('Confirmed listener error: $e'));
    } catch (e) {
      print('Failed to subscribe confirmed: $e');
      fetchAppointments();
    }

    try {
      _completedSub = _firestore
          .collection('appointments')
          .where('doctorId', isEqualTo: doctorUid)
          .where('status', isEqualTo: 'completed')
          .orderBy('completedAt', descending: true)
          .snapshots()
          .listen((snap) {
        completedAppointments.value = _mapDocs(snap);
      }, onError: (e) => print('Completed listener error: $e'));
    } catch (e) {
      print('Failed to subscribe completed: $e');
      fetchAppointments();
    }

    try {
      _rejectedSub = _firestore
          .collection('appointments')
          .where('doctorId', isEqualTo: doctorUid)
          .where('status', isEqualTo: 'rejected')
          .orderBy('rejectedAt', descending: true)
          .snapshots()
          .listen((snap) {
        rejectedAppointments.value = _mapDocs(snap);
      }, onError: (e) => print('Rejected listener error: $e'));
    } catch (e) {
      print('Failed to subscribe rejected: $e');
      fetchAppointments();
    }
  }

  void _cancelAllSubscriptions() {
    try {
      _pendingSub?.cancel();
    } catch (_) {}
    try {
      _confirmedSub?.cancel();
    } catch (_) {}
    try {
      _completedSub?.cancel();
    } catch (_) {}
    try {
      _rejectedSub?.cancel();
    } catch (_) {}
  }

  @override
  void onClose() {
    _cancelAllSubscriptions();
    try {
      _authSub?.cancel();
    } catch (_) {}
    super.onClose();
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

        final completedSnapshot = await _firestore
            .collection('appointments')
            .where('doctorId', isEqualTo: user.uid)
            .where('status', isEqualTo: 'completed')
            .get();

        final rejectedSnapshot = await _firestore
            .collection('appointments')
            .where('doctorId', isEqualTo: user.uid)
            .where('status', isEqualTo: 'rejected')
            .get();

        var pendingDocs = pendingSnapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
        var confirmedDocs = confirmedSnapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
        var completedDocs = completedSnapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
        var rejectedDocs = rejectedSnapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();

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

        completedDocs.sort((a, b) {
          final aTime = a['completedAt'] as Timestamp? ?? a['createdAt'] as Timestamp?;
          final bTime = b['completedAt'] as Timestamp? ?? b['createdAt'] as Timestamp?;
          if (aTime == null || bTime == null) return 0;
          return bTime.compareTo(aTime);
        });

        rejectedDocs.sort((a, b) {
          final aTime = a['rejectedAt'] as Timestamp? ?? a['createdAt'] as Timestamp?;
          final bTime = b['rejectedAt'] as Timestamp? ?? b['createdAt'] as Timestamp?;
          if (aTime == null || bTime == null) return 0;
          return bTime.compareTo(aTime);
        });

        pendingAppointments.value = pendingDocs;
        confirmedAppointments.value = confirmedDocs;
        completedAppointments.value = completedDocs;
        rejectedAppointments.value = rejectedDocs;
      }
    } catch (e) {
      // Avoid UI-specific behavior in the controller; surface errors via logs
      print('Failed to fetch appointments: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> approveAppointment(String appointmentId, String userId) async {
    try {
      await _firestore.collection('appointments').doc(appointmentId).update({
        'status': 'confirmed',
        'confirmedAt': FieldValue.serverTimestamp(),
      });

      // NOTE: Notification creation is handled server-side by Cloud Function onAppointmentUpdated.
      // Client no longer writes to `notifications` to avoid permission errors.

      // Refresh local lists
      fetchAppointments();
      return true;
    } catch (e) {
      print('Failed to approve appointment: $e');
      return false;
    }
  }

  Future<bool> completeAppointment(String appointmentId, String userId) async {
    try {
      await _firestore.collection('appointments').doc(appointmentId).update({
        'status': 'completed',
        'completedAt': FieldValue.serverTimestamp(),
      });

      // NOTE: server function will create a user notification and send FCM.

      fetchAppointments();
      return true;
    } catch (e) {
      print('Failed to complete appointment: $e');
      return false;
    }
  }

  Future<bool> rejectAppointment(String appointmentId, String userId, String reason) async {
    // Make reject robust: try update, if that fails try set with merge
    try {
      await _firestore.collection('appointments').doc(appointmentId).update({
        'status': 'rejected',
        'doctorNotes': reason,
        'rejectedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Update failed for reject; attempting set with merge: $e');
      try {
        await _firestore.collection('appointments').doc(appointmentId).set({
          'status': 'rejected',
          'doctorNotes': reason,
          'rejectedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (e2) {
        print('Failed to set (merge) rejected fields: $e2');
        // Still try to refresh local state
        fetchAppointments();
        return false;
      }
    }

    // Do NOT write client-side notifications here; server will handle

    // Optimistically update local lists so UI moves appointment immediately
    try {
      final idx = pendingAppointments.indexWhere((a) => a['id'] == appointmentId);
      if (idx != -1) {
        final removed = Map<String, dynamic>.from(pendingAppointments[idx]);
        // update fields
        removed['status'] = 'rejected';
        removed['doctorNotes'] = reason;
        removed['rejectedAt'] = Timestamp.now();

        // remove from pending and insert at start of rejected
        pendingAppointments.removeAt(idx);
        rejectedAppointments.insert(0, removed);
      } else {
        // If not in pending (unlikely), append a minimal rejected entry
        rejectedAppointments.insert(0, {
          'id': appointmentId,
          'status': 'rejected',
          'doctorNotes': reason,
          'rejectedAt': Timestamp.now(),
        });
      }
    } catch (localErr) {
      print('Failed to optimistically update local lists: $localErr');
    }

    // Refresh from server to reconcile any differences
    fetchAppointments();
    return true;
  }
}