import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../login/loginpage.dart';
import '../signup/signup.dart';

class Loginsignupintro extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double pageheight = MediaQuery.of(context).size.height;
    double pagewidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            height: pageheight,
            width: pagewidth,
            color: Colors.white,
            child: Column(
              children: [
                SizedBox(height: 120),
                Image.asset('assets/images/logo3.png', width: 250, height: 250),
                Text(
                  'Alhewan',
                  style: TextStyle(
                    fontSize: 35,
                    color: Color(0XFF199A8E),
                    fontFamily: 'exbolditalic',
                  ),
                ),
                Text(
                  'Let’s get started!',
                  style: TextStyle(
                    fontSize: 22,
                    color: Color(0XFF101623),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Login to enjoy the features we’ve provided, and stay healthy!',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0XFF717784),
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0XFF199A8E),
                    fixedSize: Size(200, 56),
                  ),
                  onPressed: () {
                    Get.to(() => Loginpage());
                  },
                  child: Text(
                    'Login',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    fixedSize: Size(200, 56),
                    side: BorderSide(color: Color(0XFF199A8E)),
                  ),
                  onPressed: () {
                    Get.to(() => Signup());
                  },
                  child: Text(
                    'Sign Up',
                    style: TextStyle(color: Color(0XFF199A8E)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
