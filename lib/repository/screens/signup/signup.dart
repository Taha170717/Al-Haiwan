import 'package:al_haiwan/repository/screens/login/loginpage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';

class Signup extends StatefulWidget {
  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final username = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();
  final password = TextEditingController();

  bool isTermsAccepted = false;
  bool isDoctor = false;

  final AuthController authController = Get.find();

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Sign Up', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 18)),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Obx(() => Stack(
        children: [
          SingleChildScrollView(
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: screenHeight * 0.05),
                    buildTextField(username, "Username", Icons.account_circle),
                    SizedBox(height: screenHeight * 0.02),
                    buildTextField(email, "Email", Icons.email_outlined),
                    SizedBox(height: screenHeight * 0.02),
                    buildTextField(phone, "Phone", Icons.phone, TextInputType.number),
                    SizedBox(height: screenHeight * 0.02),
                    buildTextField(password, "Password", Icons.lock, TextInputType.text, ),
                    SizedBox(height: screenHeight * 0.02),
                    buildCheckbox("I agree to the medidoc Terms of Service and Privacy Policy", isTermsAccepted, (val) => setState(() => isTermsAccepted = val!)),
                    buildCheckbox("Are you a Doctor?", isDoctor, (val) => setState(() => isDoctor = val!)),
                    SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_validateInputs()) {
                            Get.dialog(Center(child: CircularProgressIndicator()), barrierDismissible: false);
                            authController.registerUser(
                              username: username.text.trim(),
                              email: email.text.trim(),
                              phone: phone.text.trim(),
                              password: password.text.trim(),
                              isDoctor: isDoctor,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0XFF199A8E),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          padding: EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text("Sign Up", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Already Have Account? ", style: TextStyle(color: Colors.grey)),
                        GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => Loginpage())),
                          child: Text("Sign In", style: TextStyle(color: Color(0XFF199A8E), fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (authController.isLoading.value)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      )),
    );
  }

  Widget buildTextField(TextEditingController controller, String label, IconData icon, [TextInputType keyboardType = TextInputType.text, bool isPassword = false]) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Color(0XFFA1A8B0), fontSize: 16),
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

  Widget buildCheckbox(String label, bool value, Function(bool?) onChanged) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          activeColor: Colors.teal,
        ),
        SizedBox(width: 8),
        Expanded(child: Text(label, style: TextStyle(color: Colors.black87, fontSize: 13))),
      ],
    );
  }

  bool _validateInputs() {
    if (username.text.isEmpty || email.text.isEmpty || phone.text.isEmpty || password.text.isEmpty) {
      Get.snackbar("Error", "All fields are required");
      return false;
    }
    if (!email.text.contains("@")) {
      Get.snackbar("Error", "Enter a valid email");
      return false;
    }
    if (password.text.length < 6) {
      Get.snackbar("Error", "Password must be at least 6 characters");
      return false;
    }
    if (!isTermsAccepted) {
      Get.snackbar("Error", "You must agree to the terms");
      return false;
    }
    return true;
  }
}
