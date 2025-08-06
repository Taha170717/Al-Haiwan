import 'package:al_haiwan/repository/screens/resetpassword/passresetsucessscreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';

class CreateNewPass extends StatefulWidget {
  final String email;

  const CreateNewPass({
    Key? key,
    required this.email,
    required String resetCode,
    required String destination,
  }) : super(key: key);

  @override
  State<CreateNewPass> createState() => _CreateNewPassState();
}

class _CreateNewPassState extends State<CreateNewPass> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final AuthController _authController = Get.put(AuthController());

  bool _isLoading = false;

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _authController.resetPasswordWithReauth(
        email: widget.email,
        oldPassword: _oldPasswordController.text.trim(),
        newPassword: _newPasswordController.text.trim(),
      );

      // On success, navigate to `PasswordResetSuccessScreen`
      Get.off(() => PasswordResetSuccessScreen());
    } catch (e) {
      Get.snackbar("Error", "Failed to reset password. Please try again.");
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "Create New Password",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Color(0XFF199A8E),
          ),
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
                  "Reset Your Password",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0XFF199A8E),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Enter your old password and set a new one.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0XFFA1A8B0),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 20),

                // Old Password Field
                _buildPasswordField(
                  controller: _oldPasswordController,
                  label: "Old Password",
                ),
                const SizedBox(height: 16),

                // New Password Field
                _buildPasswordField(
                  controller: _newPasswordController,
                  label: "New Password",
                ),
                const SizedBox(height: 16),

                // Confirm Password Field
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Confirm Password",
                    labelStyle: const TextStyle(color: Color(0XFF199A8E)),
                    prefixIcon: const Icon(Icons.lock_outline, color: Color(0XFF199A8E)),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(color: Color(0XFF199A8E), width: 2),
                    ),
                  ),
                  validator: (val) => val != _newPasswordController.text
                      ? "Passwords do not match"
                      : null,
                ),
                const SizedBox(height: 30),

                // Reset Password Button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0XFF199A8E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Reset Password",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0XFF199A8E)),
        prefixIcon: const Icon(Icons.lock_outline, color: Color(0XFF199A8E)),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Color(0XFF199A8E), width: 2),
        ),
      ),
      validator: (val) => val == null || val.isEmpty || val.length < 6
          ? "Password must be at least 6 characters"
          : null,
    );
  }
}