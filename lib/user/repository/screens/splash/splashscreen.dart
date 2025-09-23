import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:lottie/lottie.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Screens
import 'package:al_haiwan/user/repository/screens/introscreens/introscreen1.dart';
import '../../../../admin/views/adminside.dart';
import '../../../../doctor/views/doctorside.dart';
import '../../bottomNav/bottomNavScreen.dart';
import '../login/loginpage.dart';

class SplashController extends GetxController {
  final storage = GetStorage();

  @override
  void onInit() {
    super.onInit();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await Future.delayed(Duration(seconds: 3)); // Splash delay
    final storage = GetStorage();
    final _auth = FirebaseAuth.instance;
    final _firestore = FirebaseFirestore.instance;
    final user = _auth.currentUser;
    final hasSeenIntro = storage.read('seenIntro') ?? false;

    if (user != null) {
      final email = user.email;
      if (email == "tahazafar112@gmail.com") {
        // ✅ Admin
        Get.offAll(() => AdminScreen());
        return;
      }

      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists && userDoc['isDoctor'] == true) {
        // ✅ Doctor
        Get.offAll(() => DoctorScreen());
      } else {
        // ✅ Regular User
        Get.offAll(() => BottomNavScreen());
      }
    } else {
      if (hasSeenIntro) {
        Get.offAll(() => Loginpage());
      } else {
        storage.write('seenIntro', true);
        Get.offAll(() => Introscreen1());
      }
    }
  }
}

class SplashScreen extends StatelessWidget {
  final SplashController controller = Get.put(SplashController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: Duration(seconds: 2),
              curve: Curves.easeInOut,
              child: Image.asset(
                'assets/images/logo3.png',
                width: 200,
                height: 200,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Alhewan',
              style: TextStyle(
                fontSize: 35,
                color: Color(0xFF199A8E),
                fontFamily: 'exbolditalic',
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: AnimatedTextKit(
                animatedTexts: [
                  FadeAnimatedText(
                    'Expert Care for Every Paw and Claw.',
                    textStyle: TextStyle(
                      fontSize: 18,
                      color: Color(0xFF199A8E),
                      fontFamily: 'semibolditalic',
                    ),
                    textAlign: TextAlign.center,
                    duration: Duration(seconds: 3),
                  ),
                ],
                isRepeatingAnimation: false,
                totalRepeatCount: 1,
                pause: Duration.zero,
                displayFullTextOnTap: true,
              ),
            ),
            SizedBox(height: 10),
            Lottie.asset(
              'assets/animations/loadings.json',
              width: 250,
              height: 180,
              repeat: true,
              animate: true,
            ),
          ],
        ),
      ),
    );
  }
}
