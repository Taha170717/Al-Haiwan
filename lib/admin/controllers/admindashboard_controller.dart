import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class AdminDashboardController extends GetxController {
  final RxInt users = 0.obs;
  final RxInt doctors = 0.obs;
  final RxBool loading = true.obs;
  final RxnString error = RxnString();

  Query<Map<String, dynamic>> usersQuery =
  FirebaseFirestore.instance.collection('users');

  Query<Map<String, dynamic>> doctorsQuery = FirebaseFirestore.instance
      .collection('users')
      .where('isDoctor', isEqualTo: true);

  static const Duration _timeout = Duration(seconds: 10);
  bool _inFlight = false;

  @override
  void onInit() {
    super.onInit();

    // Wait for an authenticated user before fetching counts
    final current = FirebaseAuth.instance.currentUser;
    if (current != null) {
      fetchCounts();
    } else {
      loading.value = true;
      FirebaseAuth.instance
          .authStateChanges()
          .firstWhere((u) => u != null)
          .then((_) => fetchCounts())
          .catchError((_) {
        loading.value = false;
        error.value = 'Please sign in to view stats.';
      });
    }
  }

  Future<void> fetchCounts({bool showLoading = true}) async {
    if (_inFlight) return;
    _inFlight = true;

    // Guard: do not query if not authenticated (common cause of permission-denied)
    if (FirebaseAuth.instance.currentUser == null) {
      if (showLoading) loading.value = false;
      error.value = 'Please sign in to view stats.';
      _inFlight = false;
      return;
    }

    if (showLoading) loading.value = true;
    error.value = null;

    try {
      final results = await Future.wait<AggregateQuerySnapshot>([
        usersQuery.count().get().timeout(_timeout),
        doctorsQuery.count().get().timeout(_timeout),
      ]);

      users.value = results[0].count!;
      doctors.value = results[1].count!;
    } on TimeoutException {
      error.value = 'Request timed out. Please try again.';
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        error.value = 'You do not have permission to view these stats.';
      } else if (e.code == 'unauthenticated') {
        error.value = 'Please sign in to view stats.';
      } else {
        error.value = 'Could not load stats. Pull to refresh.';
      }
    } catch (_) {
      error.value = 'Could not load stats. Pull to refresh.';
    } finally {
      loading.value = false;
      _inFlight = false;
    }
  }

  Future<void> refreshCounts() => fetchCounts(showLoading: false);

  void useSeparateDoctorsCollection(bool enabled) {
    doctorsQuery = enabled
        ? FirebaseFirestore.instance.collection('doctors')
        : FirebaseFirestore.instance
        .collection('users')
        .where('isDoctor', isEqualTo: true);
  }
}