import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/auth_controller.dart';

class ResetPassword extends StatefulWidget {
  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  bool isEmailSelected = true;
  String selectedCountryCode = "+1"; // Default country code
  final TextEditingController inputController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final authController = Get.put(AuthController());

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

  String? validateInput(String? value) {
    if (value == null || value.trim().isEmpty) {
      return isEmailSelected
          ? 'Please enter your email address'
          : 'Please enter your phone number';
    }

    if (isEmailSelected) {
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(value.trim())) {
        return 'Enter a valid email address';
      }
    } else {
      final phoneRegex = RegExp(r'^\d{6,14}$'); // Numeric validation for phone
      if (!phoneRegex.hasMatch(value.trim())) {
        return 'Enter a valid phone number (no spaces or special characters)';
      }
    }

    return null;
  }

  void handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      String input = inputController.text.trim();

      if (!isEmailSelected) {
        input = selectedCountryCode + input; // Prepend country code to phone number
      }

      Get.dialog(
        const Center(child: CircularProgressIndicator(color: Color(0XFF199A8E))),
        barrierDismissible: false,
      );

      try {
        if (isEmailSelected) {
          await authController.sendResetCode(
            email: input,
            isEmail: true,
          );
        } else {
          await authController.sendResetCodeToPhone(phoneNumber: input);
        }

        Get.back(); // Close loading

        Get.defaultDialog(
          title: "Success",
          titleStyle: const TextStyle(
            color: Color(0XFF199A8E),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
          content: Column(
            children: [
              const Icon(Icons.check_circle_outline, color: Color(0XFF199A8E), size: 60),
              const SizedBox(height: 10),
              Text(
                isEmailSelected
                    ? "A confirmation code has been sent to:\n\n$input"
                    : "A verification SMS has been sent to:\n\n$input",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          confirm: ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0XFF199A8E),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text("OK", style: TextStyle(color: Colors.white)),
          ),
        );
      } catch (e) {
        Get.back(); // Close loading
        Get.snackbar("Error", "Failed to send confirmation code: $e");
      }
    }
  }

  Widget _buildToggleOption(String label, bool emailSelected) {
    final isSelected = isEmailSelected == emailSelected;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            isEmailSelected = emailSelected;
            inputController.clear(); // Clear input field
          });
        },
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isSelected ? const Color(0XFF199A8E) : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Reset Password',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 18, color: Color(0XFF199A8E)),
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 30),
                const Text(
                  'Forgot Your Password?',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0XFF199A8E)),
                ),
                const SizedBox(height: 10),
                Text(
                  isEmailSelected
                      ? 'Enter your email and we’ll send you a code to reset your password.'
                      : 'Enter your phone number and we’ll send you an SMS to reset your password.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0XFFA1A8B0), fontSize: 14),
                ),
                const SizedBox(height: 20),
                // Toggle
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      _buildToggleOption("Email", true),
                      _buildToggleOption("Phone", false),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Country code selector and phone number input
                if (!isEmailSelected)
                  Row(
                    children: [
                      DropdownButton<String>(
                        value: selectedCountryCode,
                        items: countryCodes
                            .map((code) => DropdownMenuItem(
                          value: code,
                          child: Text(code),
                        ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedCountryCode = value!;
                          });
                        },
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: inputController,
                          keyboardType: TextInputType.phone,
                          validator: validateInput,
                          decoration: InputDecoration(
                            labelStyle: const TextStyle(color: Color(0XFF199A8E)),
                            labelText: "Enter Phone Number",
                            prefixIcon: const Icon(Icons.phone),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(color: Color(0XFF199A8B), width: 2),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                if (isEmailSelected)
                // Email input
                  TextFormField(
                    controller: inputController,
                    keyboardType: TextInputType.emailAddress,
                    validator: validateInput,
                    decoration: InputDecoration(
                      labelStyle: const TextStyle(color: Color(0XFF199A8E)),
                      labelText: "Enter Email",
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(color: Color(0XFF199A8B), width: 2),
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF199A8E),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text('Reset Password', style: TextStyle(color: Colors.white, fontSize: 16)),
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