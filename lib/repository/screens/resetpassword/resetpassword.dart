import 'package:al_haiwan/repository/screens/resetpassword/verfication.dart';
import 'package:flutter/material.dart';

import '../login/loginpage.dart';

class ResetPassword extends StatefulWidget {
  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  bool isEmailSelected = true;
  TextEditingController inputController = TextEditingController();
  bool isInputValid = false;

  @override
  void initState() {
    super.initState();
    inputController.addListener(() {
      setState(() {
        isInputValid = inputController.text.isNotEmpty;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Reset Password',
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.w700, fontSize: 18),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              children: [
                SizedBox(height: 30),
                Text(
                  'Forgot Your Password?',
                  style: TextStyle(
                      fontSize: 24, fontWeight: FontWeight.w700, fontFamily: 'Inter'),
                ),
                SizedBox(height: 10),
                Text(
                  'Enter your email or phone number, we will send you a confirmation code.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Color(0XFFA1A8B0),
                      fontSize: 14,
                      fontWeight: FontWeight.w400),
                ),
                SizedBox(height: 20),
          
                // Toggle between Email and Phone
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
                              color: isEmailSelected ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              "Email",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isEmailSelected ? Color(0XFF199A8E) : Colors.grey,
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
                              color: !isEmailSelected ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              "Phone",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: !isEmailSelected ? Color(0XFF199A8E) : Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
          
                // Input Field
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: TextField(
                    controller: inputController,
                    keyboardType:
                    isEmailSelected ? TextInputType.emailAddress : TextInputType.number,
                    decoration: InputDecoration(
                      labelText: isEmailSelected ? "Enter Email" : "Enter Phone Number",
                      labelStyle: TextStyle(color: Color(0XFFA1A8B0), fontSize: 16),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                      EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      prefixIcon: Icon(
                        isEmailSelected ? Icons.email_outlined : Icons.phone,
                        color: Color(0xFF199A8E),
                      ),
                      suffixIcon: isInputValid
                          ? Icon(Icons.check, color: Color(0xFF199A8E))
                          : null,
                      hintText: isEmailSelected ? 'Enter Email' : 'Phone Number',
                      hintStyle: TextStyle(color: Colors.grey),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: Color(0XFF199A8E), width: 2),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24),
          
                // Reset Password Button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed:  () {
                     Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> Verification()),);
                    } ,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF199A8E),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    child:
                    Text('Reset Password', style: TextStyle(color: Colors.white)),
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