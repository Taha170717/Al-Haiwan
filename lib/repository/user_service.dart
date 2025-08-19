import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class UserService extends GetxController {
  static UserService get instance => Get.find();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Rx<User?> user = Rx<User?>(null);

  @override
  void onInit() {
    super.onInit();
    user.bindStream(_auth.authStateChanges());
  }

  String? get currentUserId => user.value?.uid;
  bool get isLoggedIn => user.value != null;

  // Simple anonymous authentication for cart tracking
  Future<void> signInAnonymously() async {
    try {
      await _auth.signInAnonymously();
    } catch (e) {
      Get.snackbar('Error', 'Failed to authenticate: $e');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get or create anonymous user for cart tracking
  Future<String> ensureUserAuthenticated() async {
    if (currentUserId == null) {
      await signInAnonymously();
    }
    return currentUserId ?? '';
  }
}
