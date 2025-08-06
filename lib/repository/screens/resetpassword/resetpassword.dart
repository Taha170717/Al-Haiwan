// ✅ Save this as reset_password.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';

class ResetPassword extends StatefulWidget {
  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  bool isEmailSelected = true;
  final TextEditingController inputController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final authController = Get.put(AuthController());

  String? validateInput(String? value) {
    if (value == null || value.trim().isEmpty) {
      return isEmailSelected
          ? 'Please enter your email address'
          : 'Phone reset not supported yet';
    }

    if (isEmailSelected) {
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(value.trim())) {
        return 'Enter a valid email address';
      }
    } else {
      return 'Phone reset not supported yet';
    }

    return null;
  }

  void handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      final input = inputController.text.trim();

      if (!isEmailSelected) {
        Get.snackbar("Unavailable", "Phone reset is not supported yet.");
        return;
      }

      Get.dialog(
        const Center(child: CircularProgressIndicator(color: Color(0XFF199A8E))),
        barrierDismissible: false,
      );

      try {
        await authController.sendResetCode(
          email: input,
          isEmail: isEmailSelected,
        );

        Get.back(); // Close loading

        // Show success dialog
        Get.defaultDialog(
          title: "Success",
          titleStyle: const TextStyle(color: Color(0XFF199A8E), fontWeight: FontWeight.bold, fontSize: 20),
          content: Column(
            children: [
              const Icon(Icons.check_circle_outline, color: Color(0XFF199A8E), size: 60),
              const SizedBox(height: 10),
              Text(
                "A confirmation code has been sent to:\n\n$input",
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
        Get.snackbar("Error", "Failed to send confirmation code.");
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Reset Password',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0XFF199A8E)),
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
                const Text('Forgot Your Password?',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0XFF199A8E))),
                const SizedBox(height: 10),
                const Text(
                  'Enter your email and we’ll send you a code to reset your password.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0XFFA1A8B0), fontSize: 14),
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
                      _buildToggleOption("Phone", false, disabled: true),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Input
                TextFormField(
                  controller: inputController,
                  keyboardType: isEmailSelected ? TextInputType.emailAddress : TextInputType.phone,
                  validator: validateInput,
                  decoration: InputDecoration(
                    labelStyle: const TextStyle(color: Color(0XFF199A8E)),
                    labelText: isEmailSelected ? "Enter Email" : "Phone reset not available",
                    prefixIcon: Icon(isEmailSelected ? Icons.email_outlined : Icons.phone),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(color: Color(0XFF199A8E), width: 2),
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

  Widget _buildToggleOption(String label, bool emailSelected, {bool disabled = false}) {
    final isSelected = isEmailSelected == emailSelected;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (!disabled) {
            setState(() {
              isEmailSelected = emailSelected;
              inputController.clear();
            });
          } else {
            Get.snackbar("Unavailable", "Phone reset is not yet supported.");
          }
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
              color: disabled
                  ? Colors.grey
                  : (isSelected ? const Color(0XFF199A8E) : Colors.grey),
            ),
          ),
        ),
      ),
    );
  }
}
