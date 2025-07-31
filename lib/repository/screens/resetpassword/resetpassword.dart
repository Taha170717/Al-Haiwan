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

  @override
  void dispose() {
    inputController.dispose();
    super.dispose();
  }

  String? validateInput(String value) {
    if (isEmailSelected) {
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(value)) {
        return 'Enter a valid email address';
      }
    } else {
      final phoneRegex = RegExp(r'^\d{10,15}$');
      if (!phoneRegex.hasMatch(value)) {
        return 'Enter a valid phone number';
      }
    }
    return null;
  }

  void handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      final input = inputController.text.trim();
      await authController.sendResetCode(input: input, isEmail: isEmailSelected);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          'Reset Password',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Color(0XFF199A8E)),
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 30),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(height: 30),
                Text(
                  'Forgot Your Password?',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Inter',
                    color: Color(0XFF199A8E),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Enter your email or phone number, we will send you a confirmation code.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0XFFA1A8B0),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 20),

                // Toggle
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              isEmailSelected = true;
                              inputController.clear();
                            });
                          },
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isEmailSelected
                                  ? Colors.white
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              "Email",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isEmailSelected
                                    ? Color(0XFF199A8E)
                                    : Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              isEmailSelected = false;
                              inputController.clear();
                            });
                          },
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: !isEmailSelected
                                  ? Colors.white
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              "Phone",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: !isEmailSelected
                                    ? Color(0XFF199A8E)
                                    : Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),

                // Input
                TextFormField(
                  controller: inputController,
                  keyboardType: isEmailSelected
                      ? TextInputType.emailAddress
                      : TextInputType.phone,
                  validator: (value) =>
                      validateInput(value!.trim()),
                  decoration: InputDecoration(
                    labelText:
                    isEmailSelected ? "Enter Email" : "Enter Phone Number",
                    prefixIcon: Icon(
                      isEmailSelected ? Icons.email_outlined : Icons.phone,
                      color: Color(0XFF199A8E),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    hintText: isEmailSelected ? 'Email' : 'Phone Number',
                    hintStyle: TextStyle(color: Colors.grey),
                    contentPadding:
                    EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide:
                      BorderSide(color: Color(0XFF199A8E), width: 2),
                    ),
                  ),
                ),
                SizedBox(height: 24),

                // Button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF199A8E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      'Reset Password',
                      style: TextStyle(color: Colors.white, fontSize: 16),
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
}
