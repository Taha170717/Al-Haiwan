import 'package:al_haiwan/user/repository/screens/login/loginpage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../controllers/auth_controller.dart';

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

  // Country codes and selection
  final List<String> countryCodes = [
    "+1",
    "+92",
    "+44",
    "+91",
    "+61",
    "+971",
    "+81",
    "+49",
    "+33",
    "+39",
  ];
  String selectedCountryCode = "+1";

  final AuthController authController = Get.find();

  @override
  void dispose() {
    username.dispose();
    email.dispose();
    phone.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Sign Up',
          style: TextStyle(
            color: Color(0XFF199A8E),
            fontFamily: "bolditalic",
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Obx(
            () => Stack(
          children: [
            SingleChildScrollView(
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: screenHeight * 0.03),

                      Image.asset(
                        'assets/images/logo3.png',
                        width: screenWidth * 0.4,
                        height: screenWidth * 0.4,
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      buildTextField(
                        username,
                        "Username",
                        Icons.account_circle,
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      buildTextField(
                        email,
                        "Email",
                        Icons.email_outlined,
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      buildPhoneField(),
                      SizedBox(height: screenHeight * 0.02),
                      buildTextField(
                        password,
                        "Password",
                        Icons.lock,
                        TextInputType.text,
                        true, // obscure password input
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      buildCheckbox(
                        "I agree to the medidoc Terms of Service and Privacy Policy",
                        isTermsAccepted,
                            (val) => setState(() => isTermsAccepted = val!),
                      ),
                      buildCheckbox(
                        "Are you a Doctor?",
                        isDoctor,
                            (val) => setState(() => isDoctor = val!),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_validateInputs()) {
                              final cleanedLocalNumber = phone.text.replaceAll(RegExp(r'[^0-9]'), '');
                              final fullPhoneNumber = '$selectedCountryCode$cleanedLocalNumber';

                              authController.registerUser(
                                username: username.text.trim(),
                                email: email.text.trim(),
                                phone: fullPhoneNumber, // send with country code joined
                                password: password.text.trim(),
                                isDoctor: isDoctor,
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0XFF199A8E),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            "Sign Up",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Already Have Account? ",
                            style: TextStyle(color: Colors.grey),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Loginpage(),
                              ),
                            ),
                            child: const Text(
                              "Sign In",
                              style: TextStyle(
                                color: Color(0XFF199A8E),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
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
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Color(0XFF199A8E),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // General text field builder
  Widget buildTextField(
      TextEditingController controller,
      String label,
      IconData icon, [
        TextInputType keyboardType = TextInputType.text,
        bool isPassword = false,
      ]) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF199A8E), fontSize: 16),
        prefixIcon: Icon(icon, color: const Color(0xFF199A8E)),
        hintText: 'Enter your $label',
        hintStyle: const TextStyle(color: Color(0XFFA1A8B0)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: Colors.grey, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: Color(0XFF199A8E), width: 2),
        ),
      ),
    );
  }

  // Phone field with country code dropdown
  Widget buildPhoneField() {
    return TextField(
      controller: phone,
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9\s\-]')),
        LengthLimitingTextInputFormatter(15),
      ],
      decoration: InputDecoration(
        labelText: "Phone",
        labelStyle: const TextStyle(color: Color(0xFF199A8E), fontSize: 16),
        hintText: 'Enter your Phone',
        hintStyle: const TextStyle(color: Color(0XFFA1A8B0)),
        // Country code dropdown as prefix
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 8, right: 4),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedCountryCode,
              icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF199A8E)),
              items: countryCodes
                  .map(
                    (c) => DropdownMenuItem<String>(
                  value: c,
                  child: Text(
                    c,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => selectedCountryCode = value);
                }
              },
            ),
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: Colors.grey, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: Color(0XFF199A8E), width: 2),
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
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: Colors.black87, fontSize: 13),
          ),
        ),
      ],
    );
  }

  bool _validateInputs() {
    if (username.text.trim().isEmpty ||
        email.text.trim().isEmpty ||
        phone.text.trim().isEmpty ||
        password.text.isEmpty) {
      Get.snackbar("Error", "All fields are required");
      return false;
    }

    if (!email.text.contains("@") || !email.text.contains(".")) {
      Get.snackbar("Error", "Enter a valid email");
      return false;
    }

    // Validate local part of the phone (digits only after cleaning)
    final cleanedLocalNumber = phone.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanedLocalNumber.length < 7 || cleanedLocalNumber.length > 15) {
      Get.snackbar("Error", "Enter a valid phone number");
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