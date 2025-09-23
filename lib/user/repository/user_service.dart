import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class UserService extends GetxController {
  static UserService get instance => Get.find();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Rx<User?> user = Rx<User?>(null);
  RxString userName = ''.obs;
  RxString userEmail = ''.obs;
  RxString profileImageUrl = ''.obs;
  RxBool isLoadingProfile = false.obs;

  @override
  void onInit() {
    super.onInit();
    user.bindStream(_auth.authStateChanges());
    // Listen to auth state changes and load profile when user logs in
    ever(user, (User? user) {
      if (user != null && !user.isAnonymous) {
        loadUserProfile();
      } else {
        clearUserProfile();
      }
    });
  }

  String? get currentUserId => user.value?.uid;
  bool get isLoggedIn => user.value != null && !user.value!.isAnonymous;

  String? get getUserName => userName.value.isEmpty ? null : userName.value;

  String? get getUserEmail => userEmail.value.isEmpty ? null : userEmail.value;

  String? get getUserImage =>
      profileImageUrl.value.isEmpty ? null : profileImageUrl.value;

  // Load user profile data from Firestore
  Future<void> loadUserProfile() async {
    if (currentUserId == null || user.value?.isAnonymous == true) return;

    try {
      isLoadingProfile.value = true;
      final doc = await _firestore.collection('users').doc(currentUserId).get();

      if (doc.exists) {
        final data = doc.data()!;
        // Only update if the user role is 'user'
        if (data['role'] == 'user') {
          userName.value = data['username'] ?? '';
          userEmail.value = data['email'] ?? user.value?.email ?? '';
          profileImageUrl.value = data['profileImageUrl'] ?? '';
        }
      }
    } catch (e) {
      print('Error loading user profile: $e');
      // Fallback to Firebase Auth email if Firestore fails
      userEmail.value = user.value?.email ?? '';
    } finally {
      isLoadingProfile.value = false;
    }
  }

  // Clear user profile data
  void clearUserProfile() {
    userName.value = '';
    userEmail.value = '';
    profileImageUrl.value = '';
  }

  // Simple anonymous authentication for cart tracking
  Future<void> signInAnonymously() async {
    try {
      await _auth.signInAnonymously();
    } catch (e) {
      Get.snackbar('Error', 'Failed to authenticate: $e');
    }
  }

  Future<void> signOut() async {
    clearUserProfile();
    await _auth.signOut();
  }

  // Get or create anonymous user for cart tracking
  Future<String> ensureUserAuthenticated() async {
    if (currentUserId == null) {
      await signInAnonymously();
    }
    return currentUserId ?? '';
  }

  // Refresh user profile data
  Future<void> refreshProfile() async {
    await loadUserProfile();
  }
}
