import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:lottie/lottie.dart';
import 'package:al_haiwan/repository/screens/introscreens/introscreen1.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    Timer(Duration(seconds: 3), () {
      Get.off(() => Introscreen1());
    });
  }
}

class SplashScreen extends StatelessWidget {
  final SplashController controller = Get.put(SplashController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        width: double.infinity,
        height: double.infinity,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: Duration(seconds: 2),
                curve: Curves.easeInOut,
                child: Image.asset('assets/images/logo.png', width: 200, height: 200),
              ),
              SizedBox(height: 10),
              Text(
                'Alhewan',
                style: TextStyle(
                  fontSize: 35,
                  color: Color(0XFF199A8E),
                  fontFamily: 'exbolditalic',
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15),
                child: AnimatedTextKit(
                  animatedTexts: [
                    FadeAnimatedText(
                      'Expert Care for Every Paw and Claw.',
                      textStyle: TextStyle(
                        fontSize: 18,
                        color: Color(0XFF199A8E),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
