import 'package:al_haiwan/user/controllers/auth_controller.dart';
import 'package:al_haiwan/user/repository/screens/signup/signup.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../resetpassword/resetpassword.dart';

class Loginpage extends StatefulWidget {
  @override
  State<Loginpage> createState() => _LoginpageState();
}

class _LoginpageState extends State<Loginpage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final AuthController authController = Get.find();

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Login', style: TextStyle(color: Color(0XFF199A8E), fontFamily: "bolditalic", fontSize: 22)),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Obx(() => Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
              child: Column(

                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: screenHeight * 0.02),

                  Image.asset('assets/images/logo3.png',width: 200,height: 200,),
                  SizedBox(height: screenHeight * 0.01),
                  Text(
                    "Welcome Back!",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0XFF199A8E)),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Text(
                    "Login to your account",
                    style: TextStyle(fontSize: 16, color: Color(0XFF199A8E), fontFamily: 'bolditalic'),
                  ),
                  SizedBox(height: screenHeight * 0.06),
                  buildTextField(emailController, "Email", Icons.email_outlined),
                  SizedBox(height: screenHeight * 0.02),
                  buildTextField(passwordController, "Password", Icons.lock, isPassword: true),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder:(context)=> ResetPassword()),);
                      },
                      child: Text("Forgot Password?",
                          style: TextStyle(color: Color(0XFF199A8E))),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        authController.loginUser(
                          email: emailController.text.trim(),
                          password: passwordController.text.trim(),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0XFF199A8E),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        padding: EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text("Login", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Row(
                    children: [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text("OR"),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.04),

                  buildGoogleButton(),
                  SizedBox(height: screenHeight * 0.04),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don’t have an account? ", style: TextStyle(color: Colors.grey)),
                      GestureDetector(
                        onTap: () => Get.to(() => Signup()),
                        child: Text("Sign Up", style: TextStyle(color: Color(0XFF199A8E), fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (authController.isLoading.value)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(child: CircularProgressIndicator(
                color: Color(0XFF199A8E)
              )),
            ),
        ],
      )),
    );
  }

  Widget buildTextField(TextEditingController controller, String label, IconData icon, {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Color(0xFF199A8E), fontSize: 16),
        prefixIcon: Icon(icon, color: Color(0xFF199A8E)),
        hintText: 'Enter your $label',
        hintStyle: TextStyle(color: Color(0XFFA1A8B0)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: Colors.grey, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: Color(0XFF199A8E), width: 2),
        ),
      ),
    );
  }

  Widget buildGoogleButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: () {
          authController.signInWithGoogle();
        },
        icon: Image.asset("assets/images/google.png", height: 24),
        label: Text("Login with Google", style: TextStyle(color: Colors.black)),
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          side: BorderSide(color: Colors.grey),
          padding: EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}
