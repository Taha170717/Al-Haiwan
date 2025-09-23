import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:get/get.dart';
import '../../../controllers/auth_controller.dart';

class Verification extends StatefulWidget {
  final String contactInfo; // Can be email or phone number
  final bool isEmail; // Indicates if it's an email or phone verification
  final String emailLinked; // Email linked to the phone number (optional)

  const Verification({
    super.key,
    required this.contactInfo,
    required this.isEmail,
    required this.emailLinked,
  });

  @override
  State<Verification> createState() => _VerificationState();
}

class _VerificationState extends State<Verification> {
  final TextEditingController _otpController = TextEditingController();
  final AuthController _authController = Get.find();

  bool _isLoading = false;
  bool _isResending = false;

  Future<void> _verifyOTP() async {
    final otp = _otpController.text.trim();

    if (otp.length != 6) {
      Get.snackbar(
        "Invalid Code",
        "Please enter a valid 6-digit OTP.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.black,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (widget.isEmail) {
        // For email verification
        await _authController.verifyResetCode(
          contactInfo: widget.contactInfo,
          userOtp: otp,
        );
      } else {
        // For phone verification
        await _authController.verifyPhoneResetCode(
          phoneNumber: widget.contactInfo,
          otp: otp,
          emailLinked: widget.emailLinked, // Pass linked email
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.black,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _resendOTP() async {
    setState(() => _isResending = true);

    try {
      if (widget.isEmail) {
        await _authController.sendResetCode(
          email: widget.contactInfo,
          isEmail: true,
        );
      } else {
        await _authController.sendResetCodeToPhone(phoneNumber: widget.contactInfo);
      }

      Get.snackbar(
        "Success",
        "OTP has been resent successfully.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.black,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to resend OTP: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.black,
      );
    } finally {
      setState(() => _isResending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Verification',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Enter Verification Code',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              Text(
                widget.isEmail
                    ? 'Enter the 6-digit code sent to your email address: ${widget.contactInfo}'
                    : 'Enter the 6-digit code sent to your phone number: ${widget.contactInfo}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF7D8FAB),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 30),

              // OTP Input Field
              PinCodeTextField(
                appContext: context,
                controller: _otpController,
                length: 6,
                keyboardType: TextInputType.number,
                animationType: AnimationType.fade,
                enableActiveFill: true,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(8),
                  fieldHeight: 55,
                  fieldWidth: 45,
                  activeColor: Colors.teal,
                  inactiveColor: Colors.grey.shade300,
                  selectedColor: Colors.teal,
                  activeFillColor: Colors.white,
                  inactiveFillColor: Colors.white,
                  selectedFillColor: Colors.white,
                ),
                onChanged: (_) {},
              ),

              const SizedBox(height: 30),

              // Verify Button
              _isLoading
                  ? const CircularProgressIndicator(color: Color(0XFF199A8E))
                  : SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _verifyOTP,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF199A8E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Verify',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // Resend OTP
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Didn’t receive the code? ",
                      style: TextStyle(color: Colors.grey)),
                  GestureDetector(
                    onTap: _isResending ? null : _resendOTP,
                    child: Text(
                      _isResending ? "Sending..." : "Resend Code",
                      style: TextStyle(
                        color: Colors.teal,
                        fontWeight: FontWeight.bold,
                        decoration: _isResending
                            ? TextDecoration.none
                            : TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}