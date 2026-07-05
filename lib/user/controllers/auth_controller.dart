import 'dart:math';
import 'package:al_haiwan/user/repository/bottomNav/bottomNavScreen.dart';
import 'package:al_haiwan/user/repository/screens/resetpassword/verfication.dart';
import 'package:al_haiwan/user/repository/screens/login/loginpage.dart';
import 'package:al_haiwan/user/repository/screens/resetpassword/createnewpass.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:flutter/foundation.dart';

import '../../admin/views/adminside.dart';
import '../../doctor/views/doctorside.dart';
import '../../utils/services/push_notification_service.dart';

class AuthController extends GetxController {
  final isLoading = false.obs;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _verificationId = "";

  // Public method: beautiful floating SnackBar without OK button (overlay-based)
  OverlayEntry? _currentSnackOverlay;

  void showBeautifulSnackBar({
    required String title,
    required String message,
    required SnackbarType type,
    Duration? duration,
  }) {
    // Colors + icon per type
    late final IconData icon;
    late final List<Color> gradientColors;
    switch (type) {
      case SnackbarType.success:
        icon = Icons.check_circle_outline;
        gradientColors = [const Color(0xFF16A34A), const Color(0xFF12873E)];
        break;
      case SnackbarType.error:
        icon = Icons.error_outline;
        gradientColors = [const Color(0xFFEF4444), const Color(0xFFCB2E2E)];
        break;
      case SnackbarType.warning:
        icon = Icons.warning_amber_outlined;
        gradientColors = [const Color(0xFFF59E0B), const Color(0xFFD88A09)];
        break;
      case SnackbarType.info:
        icon = Icons.info_outline;
        gradientColors = [const Color(0xFF199A8E), const Color(0xFF177B74)];
        break;
    }

    final showDuration = duration ?? const Duration(seconds: 3);

    if (kDebugMode) print('[AuthController] overlay-snack called: $title / $message');

    // Remove previous overlay if any
    try {
      _currentSnackOverlay?.remove();
      _currentSnackOverlay = null;
    } catch (_) {}

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Prefer ScaffoldMessenger (most reliable) if we have a scaffold context
      final ctx = Get.context;
      if (ctx != null) {
        try {
          final messenger = ScaffoldMessenger.of(ctx);
          // Clear existing to ensure visibility
          messenger.clearSnackBars();

          if (kDebugMode) print('[AuthController] using ScaffoldMessenger to show snack');

          final snack = SnackBar(
            behavior: SnackBarBehavior.floating,
            elevation: 0,
            backgroundColor: Colors.transparent,
            duration: showDuration,
            content: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradientColors, begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 12, offset: Offset(0, 6))],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                    child: Icon(icon, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(message, style: const TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );

          messenger.showSnackBar(snack);
          return;
        } catch (e) {
          if (kDebugMode) print('[AuthController] ScaffoldMessenger snack failed: $e');
          // continue to overlay fallback
        }
      }

      // Overlay fallback
      final ctx2 = Get.overlayContext ?? Get.context;
      final overlayState = ctx2 == null ? null : Overlay.of(ctx2);
      if (overlayState == null) {
        // last resorts
        if (kDebugMode) print('[AuthController] overlayState null - trying Get.rawSnackbar');
        try {
          Get.rawSnackbar(title: title, message: message, snackPosition: SnackPosition.TOP, duration: showDuration);
          if (kDebugMode) print('[AuthController] used Get.rawSnackbar fallback');
          return;
        } catch (_) {}
        try {
          if (kDebugMode) print('[AuthController] using Get.dialog fallback');
          Get.dialog(AlertDialog(title: Text(title), content: Text(message), actions: [TextButton(onPressed: () => Get.back(), child: const Text('OK'))]));
        } catch (_) {}
        return;
      }

      final overlayEntry = OverlayEntry(builder: (context) {
        final topPadding = MediaQuery.of(context).padding.top + 12.0;
        return Positioned(
          top: topPadding,
          left: 16,
          right: 16,
          child: Material(
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradientColors, begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 12, offset: Offset(0, 6))],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                    child: Icon(icon, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(message, style: const TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      });

      overlayState.insert(overlayEntry);
      _currentSnackOverlay = overlayEntry;
      if (kDebugMode) print('[AuthController] inserted overlay entry');

       Future.delayed(showDuration, () {
         try {
           overlayEntry.remove();
           if (_currentSnackOverlay == overlayEntry) _currentSnackOverlay = null;
           if (kDebugMode) print('[AuthController] removed overlay after delay');
         } catch (_) {}
       });
    });
  }

  /// Send OTP to phone and link to associated email
    Future<void> sendResetCodeToPhone({required String phoneNumber}) async {
    try {
      isLoading.value = true;
      print("Started fetching user for phone number: $phoneNumber"); // Debugging Log

      // Try to query Firestore to find the user matching the phone number.
      // In some deployments Firestore rules may block unauthenticated reads; if that happens
      // we fall back to sending the phone verification without a linked email.
      String? userEmail;
      try {
        final userDoc = await _firestore.collection('users').where('phone', isEqualTo: phoneNumber).get();
        if (userDoc.docs.isNotEmpty) {
          userEmail = userDoc.docs.first.data()['email'] as String?;
          print("User email associated with phone: $userEmail.");
        } else {
          print("No user found with this phone number: $phoneNumber");
          // Do not return here; proceed to send OTP so user can still verify phone.
        }
      } catch (e) {
        // Permission denied or other Firestore error - log and continue to phone verification.
        print("Firestore query for phone lookup failed (permission or network): $e");
        userEmail = null;
      }

      // Send OTP via Firebase phone authentication.
      print("Starting Firebase phone verification for $phoneNumber."); // Debug Log

      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          print("Auto-verification completed for phone: $phoneNumber"); // Debugging Log
          showBeautifulSnackBar(
            title: "Auto-Verification Complete",
            message: "Phone number verified automatically",
            type: SnackbarType.success,
          );
        },
        verificationFailed: (FirebaseAuthException e) {
          print("Phone verification failed: ${e.message}"); // Debugging Log
          showBeautifulSnackBar(
            title: "Verification Failed",
            message: "Failed to send OTP: ${e.message}",
            type: SnackbarType.error,
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          print("OTP successfully sent to phone: $phoneNumber"); // Debugging Log

          showBeautifulSnackBar(
            title: "OTP Sent Successfully",
            message: "Please check your phone for the verification code",
            type: SnackbarType.success,
          );

          Get.to(() => Verification(
            contactInfo: phoneNumber,
            isEmail: false,
            emailLinked: userEmail ?? '',
          ));
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
          print("Code auto-retrieval timeout for phone: $phoneNumber"); // Debugging Log
        },
      );
    } catch (e) {
      print("Error sending reset code to phone: $e"); // Debugging Log
      showBeautifulSnackBar(
        title: "Network Error",
        message: "Failed to send OTP. Please check your connection",
        type: SnackbarType.error,
      );
    } finally {
      isLoading.value = false;
    }
    }

  /// Verify Phone OTP and reset password for associated email
  Future<void> verifyPhoneResetCode({
    required String phoneNumber,
    required String otp,
    required String emailLinked, // Email to reset the password
  }) async {
    try {
      isLoading.value = true;

      final phoneAuthCredential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: otp,
      );

      // If verification succeeds
      await _auth.signInWithCredential(phoneAuthCredential);

      // Mark OTP verification as complete in Firestore
      await _firestore.collection('otp_verifications').doc(phoneNumber).set({
        'used': true,
        'verified': true,
        'verifiedAt': FieldValue.serverTimestamp()
      });

      showBeautifulSnackBar(
        title: "Verification Successful",
        message: "Phone number verified! You can now reset your password",
        type: SnackbarType.success,
      );

      // Navigate to password reset screen with Email linked
      Get.to(() => CreateNewPass(
        email: emailLinked,
        isEmail: true, resetCode: '', destination: '', // To show old password if needed
      ));
    } catch (e) {
      showBeautifulSnackBar(
        title: "Verification Failed",
        message: "Invalid OTP. Please try again",
        type: SnackbarType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Generate a 6-digit OTP
  String _generateOTP() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  /// Send OTP to email
  Future<void> sendResetCode({
    required String email,
    required bool isEmail,
  }) async {
    try {
      isLoading.value = true;

      final otp = _generateOTP();
      final otpRef = _firestore.collection('otp_verifications').doc(email);

      // Delete old OTP if it exists
      final existingDoc = await otpRef.get();
      if (existingDoc.exists) {
        await otpRef.delete();
      }

      // Email setup
      final smtpServer = gmail(
        'tahazafar112@gmail.com',
        'fyua tkso jhpq ncmv', // Store in env/secure vault in production
      );

      final message = Message()
        ..from = Address('tahazafar112@gmail.com', 'Al-Haiwan App')
        ..recipients.add(email)
        ..subject = 'Your OTP Code for Password Reset'
        ..text = 'Your OTP code is: $otp.\n\nThis code is valid for 5 minutes.';

      // Send the email
      await send(message, smtpServer);

      // Save OTP to Firestore
      await otpRef.set({
        'otp': otp,
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': Timestamp.fromDate(DateTime.now().add(Duration(minutes: 5))),
        'used': false,
      });

      showBeautifulSnackBar(
        title: "OTP Sent Successfully",
        message: "Please check your email for the verification code",
        type: SnackbarType.success,
      );

      Get.to(() => Verification(contactInfo: email, isEmail: true, emailLinked: '',));
    } catch (e) {
      showBeautifulSnackBar(
        title: "Email Send Failed",
        message: "Failed to send OTP. Please try again",
        type: SnackbarType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Verify OTP
  Future<void> verifyResetCode({
    required String contactInfo,
    required String userOtp,
  }) async {
    try {
      isLoading.value = true;
      final doc = await _firestore.collection('otp_verifications').doc(contactInfo).get();

      if (!doc.exists) {
        showBeautifulSnackBar(
          title: "OTP Not Found",
          message: "No OTP found. Please request a new one",
          type: SnackbarType.warning,
        );
        return;
      }

      final data = doc.data();
      final storedOtp = data?['otp'];
      final createdAt = data?['createdAt'] as Timestamp?;
      final used = data?['used'] ?? false;

      if (used == true) {
        showBeautifulSnackBar(
          title: "OTP Already Used",
          message: "This OTP has already been used. Please request a new one",
          type: SnackbarType.warning,
        );
        return;
      }

      if (storedOtp != userOtp) {
        showBeautifulSnackBar(
          title: "Incorrect OTP",
          message: "The OTP you entered is incorrect. Please try again",
          type: SnackbarType.error,
        );
        return;
      }

      if (createdAt == null ||
          DateTime.now().difference(createdAt.toDate()).inMinutes > 5) {
        showBeautifulSnackBar(
          title: "OTP Expired",
          message: "Your OTP has expired. Please request a new one",
          type: SnackbarType.warning,
        );
        // 🟢 ADD THIS LINE TO AUTO DELETE
        await _firestore.collection('otp_verifications').doc(contactInfo).delete().catchError((_) {});
        return;
      }

      await _firestore.collection('otp_verifications').doc(contactInfo).update({'used': true});

      showBeautifulSnackBar(
        title: "OTP Verified Successfully",
        message: "You can now create a new password",
        type: SnackbarType.success,
      );

      Get.to(() => CreateNewPass(email: contactInfo, resetCode: '', destination: '', isEmail: true,));
    } catch (e) {
      showBeautifulSnackBar(
        title: "Verification Error",
        message: "Failed to verify OTP. Please try again",
        type: SnackbarType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Reset password after OTP
  Future<void> resetPassword(String newPassword) async {
    try {
      isLoading.value = true;
      final user = _auth.currentUser;

      if (user != null) {
        final email = user.email;

        await user.updatePassword(newPassword);

        // Delete OTP after successful password reset
        if (email != null) {
          await _firestore.collection('otp_verifications').doc(email).delete().catchError((_) {});
        }

        showBeautifulSnackBar(
          title: "Password Reset Successful",
          message: "Your password has been updated successfully",
          type: SnackbarType.success,
        );

        Get.offAll(() => Loginpage());
      } else {
        showBeautifulSnackBar(
          title: "Session Expired",
          message: "Please restart the password reset process",
          type: SnackbarType.warning,
        );
      }
    } catch (e) {
      showBeautifulSnackBar(
        title: "Password Reset Failed",
        message: "Failed to reset password. Please try again",
        type: SnackbarType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Re-authenticate and reset password
  Future<void> resetPasswordWithReauth({
    required String email,
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      isLoading.value = true;

      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: oldPassword,
      );

      await userCredential.user?.updatePassword(newPassword);

      showBeautifulSnackBar(
        title: "Password Updated",
        message: "Your password has been changed successfully",
        type: SnackbarType.success,
      );

      Get.offAll(() => Loginpage());
    } catch (e) {
      showBeautifulSnackBar(
        title: "Password Change Failed",
        message:
        "Failed to change password. Please check your current password",
        type: SnackbarType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Register
  Future<void> registerUser({
    required String username,
    required String email,
    required String phone,
    required String password,
    required bool isDoctor,
  }) async {
    try {
      isLoading.value = true;

      // 1) Create Firebase Auth user
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw FirebaseAuthException(
          code: 'user-null',
          message: 'User could not be created.',
        );
      }

      final uid = user.uid;
      final now = FieldValue.serverTimestamp();

      // 2) Prepare common user data
      final userData = <String, dynamic>{
        'uid': uid,
        'username': username,
        'email': email,
        'phone': phone,
        'isDoctor': isDoctor,
        'role': isDoctor ? 'doctor' : 'user',
        'createdAt': now,
        'updatedAt': now,
      };

      // 3) Prepare doctor data if applicable
      final doctorData = <String, dynamic>{
        'uid': uid,
        'name': username,
        'email': email,
        'phone': phone,
        'status': 'Pending',
        'isVerified': 'false',
        'createdAt': now,
        'updatedAt': now,
      };

      // 4) Write both documents atomically (users + doctors if needed)
      final usersDocRef = _firestore.collection('users').doc(uid);
      final doctorsDocRef = _firestore.collection('doctors').doc(uid);

      final batch = _firestore.batch();
      batch.set(usersDocRef, userData);
      if (isDoctor) {
        batch.set(doctorsDocRef, doctorData);
      }
      await batch.commit();

      // 5) Navigate based on user type
      showBeautifulSnackBar(
        title: "Registration Successful",
        message: "Welcome to Al-Haiwan! Your account has been created",
        type: SnackbarType.success,
        duration: Duration(seconds: 3),
      );

      showSuccessDialog();
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Registration failed";
      if (e.code == 'email-already-in-use') {
        errorMessage = "This email is already registered";
      } else if (e.code == 'weak-password') {
        errorMessage = "Password is too weak";
      } else if (e.code == 'invalid-email') {
        errorMessage = "Invalid email address";
      }

      showBeautifulSnackBar(
        title: "Registration Failed",
        message: errorMessage,
        type: SnackbarType.error,
      );
    } catch (e) {
      // If Firestore write failed after auth creation, try to rollback the auth user
      try {
        await _auth.currentUser?.delete();
      } catch (_) {
        // ignore cleanup errors
      }
      showBeautifulSnackBar(
        title: "Registration Error",
        message: "Something went wrong. Please try again",
        type: SnackbarType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Login
  Future<void> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;

      final userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      final uid = userCredential.user!.uid;

      // Admin Check
      if (email == "tahazafar112@gmail.com") {
        showBeautifulSnackBar(
          title: "Admin Access Granted",
          message: "Welcome back, Administrator!",
          type: SnackbarType.success,
        );
        Get.offAll(() => AdminScreen());
        return;
      }

      // Check Firestore for role
      final userDoc = await _firestore.collection('users').doc(uid).get();

      if (!userDoc.exists) {
        showBeautifulSnackBar(
          title: "Account Error",
          message: "User record not found. Please contact support",
          type: SnackbarType.error,
        );
        return;
      }

      final isDoctor = userDoc['isDoctor'] ?? false;

      final fcmToken = await PushNotificationService.getFCMToken();
      if (fcmToken != null) {
        if (isDoctor) {
          await _firestore.collection('doctors').doc(uid).update({
            'fcmToken': fcmToken,
            'updatedAt': FieldValue.serverTimestamp(),
          }).catchError((e) {
            print('[v0] Error updating doctor FCM token: $e');
          });
        } else {
          await _firestore.collection('users').doc(uid).update({
            'fcmToken': fcmToken,
            'updatedAt': FieldValue.serverTimestamp(),
          }).catchError((e) {
            print('[v0] Error updating user FCM token: $e');
          });
        }
        if (kDebugMode) {
          print('[v0] FCM token saved for ${isDoctor ? 'doctor' : 'user'}: $uid');
        }
      }

      showBeautifulSnackBar(
        title: "Login Successful",
        message: "Welcome back! Redirecting to your dashboard",
        type: SnackbarType.success,
      );

      showLoginSuccessDialog(isDoctor: isDoctor, email: '');
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Login failed";
      if (e.code == 'user-not-found') {
        errorMessage = "No account found with this email";
      } else if (e.code == 'wrong-password') {
        errorMessage = "Incorrect password";
      } else if (e.code == 'invalid-email') {
        errorMessage = "Invalid email address";
      } else if (e.code == 'user-disabled') {
        errorMessage = "This account has been disabled";
      }

      showBeautifulSnackBar(
        title: "Login Failed",
        message: errorMessage,
        type: SnackbarType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Google Sign-In
  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;

      // Initialize GoogleSignIn with scopes
      final googleSignIn = GoogleSignIn(
        scopes: [
          'email',
          'profile',
        ],
      );

      // Sign out first to show account picker dialog
      try {
        await googleSignIn.signOut();
      } catch (_) {
        // Ignore sign-out errors
      }

      if (kDebugMode) {
        print('[GoogleSignIn] Starting Google Sign-In process...');
      }

      final googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        if (kDebugMode) {
          print('[GoogleSignIn] User cancelled the sign-in');
        }
        showBeautifulSnackBar(
          title: "Sign-in Cancelled",
          message: "Google sign-in was cancelled",
          type: SnackbarType.info,
        );
        return;
      }

      if (kDebugMode) {
        print('[GoogleSignIn] User signed in: ${googleUser.email}');
      }

      final googleAuth = await googleUser.authentication;

      if (kDebugMode) {
        print('[GoogleSignIn] Got authentication tokens');
      }

      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        if (kDebugMode) {
          print('[GoogleSignIn] Missing tokens - accessToken: ${googleAuth.accessToken}, idToken: ${googleAuth.idToken}');
        }
        showBeautifulSnackBar(
          title: "Authentication Failed",
          message: "Failed to get authentication tokens. Please try again",
          type: SnackbarType.error,
        );
        return;
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      if (kDebugMode) {
        print('[GoogleSignIn] Created Firebase credential');
      }

      final userCredential = await _auth.signInWithCredential(credential);

      if (kDebugMode) {
        print('[GoogleSignIn] Firebase sign-in successful: ${userCredential.user?.email}');
      }

      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        if (kDebugMode) {
          print('[GoogleSignIn] New user - creating Firestore document');
        }

        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'username': userCredential.user!.displayName ?? 'Google User',
          'email': userCredential.user!.email ?? '',
          'phone': userCredential.user!.phoneNumber ?? '',
          'isDoctor': false,
          'role': 'user',
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        }).catchError((e) {
          if (kDebugMode) {
            print('[GoogleSignIn] Error creating user doc: $e');
          }
        });

        showBeautifulSnackBar(
          title: "Account Created",
          message: "Welcome to Al-Haiwan! Your Google account has been linked",
          type: SnackbarType.success,
        );
      } else {
        if (kDebugMode) {
          print('[GoogleSignIn] Existing user logging in');
        }
        showBeautifulSnackBar(
          title: "Welcome Back",
          message: "Successfully signed in with Google",
          type: SnackbarType.success,
        );
      }

      showLoginSuccessDialog(isDoctor: false, email: '');
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('[GoogleSignIn] FirebaseAuthException: ${e.code} - ${e.message}');
      }
      String errorMessage = "Google Sign-in failed";
      if (e.code == 'account-exists-with-different-credential') {
        errorMessage = "This email is already registered with different credentials";
      } else if (e.code == 'invalid-credential') {
        errorMessage = "Invalid credentials. Please try again";
      }

      showBeautifulSnackBar(
        title: "Google Sign-in Failed",
        message: errorMessage,
        type: SnackbarType.error,
      );
    } catch (e) {
      if (kDebugMode) {
        print('[GoogleSignIn] Exception: $e');
      }
      showBeautifulSnackBar(
        title: "Google Sign-in Failed",
        message: "Failed to sign in with Google. Please try again: $e",
        type: SnackbarType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Dialogs
  void showSuccessDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_outline, color: Color(0xFF199A8E), size: 60),
              const SizedBox(height: 20),
              const Text(
                "Registration Successful!",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF199A8E),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Your account has been created successfully.\nYou can now log in to continue.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF199A8E),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.login, color: Colors.white),
                label: const Text("Login", style: TextStyle(color: Colors.white)),
                onPressed: () => Get.offAll(() => Loginpage()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showLoginSuccessDialog({required bool isDoctor, required String email}) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_outline, color: Color(0xFF199A8E), size: 60),
              const SizedBox(height: 20),
              const Text(
                "Welcome Back!",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF199A8E)),
              ),
              const SizedBox(height: 10),
              const Text(
                "Login Successful. You're being redirected...",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF199A8E),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.arrow_forward, color: Colors.white),
                label: const Text("Continue", style: TextStyle(color: Colors.white)),
                onPressed: () {
                  if (isDoctor) {
                    Get.offAll(() => DoctorScreen());
                  }
                  else if (email == "tahazafar112@gmail.com"){
                    Get.offAll(() => AdminScreen());
                  }
                  else {
                    Get.offAll(() => BottomNavScreen());
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum SnackbarType { success, error, warning, info }
