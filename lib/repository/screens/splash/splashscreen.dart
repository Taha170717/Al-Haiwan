import 'package:al_haiwan/repository/screens/introscreens/introscreen1.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 4), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Introscreen1()), // Replace with your Home Screen
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Colors.white
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
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
                padding: const EdgeInsets.all(15.0),
                child: AnimatedTextKit(
                  animatedTexts: [
                    TypewriterAnimatedText(
                      'Expert Care for Every Paw and Claw.',
                      textStyle: TextStyle(
                        fontSize: 18,
                        color: Color(0XFF199A8E),
                        fontFamily: 'semibolditalic',
                      ),textAlign: TextAlign.center,
                      speed: Duration(milliseconds: 80),
                    ),
                  ],
                  totalRepeatCount: 1,
                ),
              ),
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


