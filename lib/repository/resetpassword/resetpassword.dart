import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Resetpassword extends StatefulWidget{
  @override
  State<Resetpassword> createState() => _ResetpasswordState();
}

class _ResetpasswordState extends State<Resetpassword> {
  bool isEmailSelected = true;
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    double screenHeight = MediaQuery
        .of(context)
        .size
        .height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Reset Password', style: TextStyle(
            color: Colors.black, fontWeight: FontWeight.w700, fontSize: 18)),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
          child: Column(
            children: [
              SizedBox(height: 30,),
              Text('Forgot Your Password? ',style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                fontFamily: 'inter'
              ),),
              SizedBox(height: 10,),
              Text('Enter your email or your phone number, we will send you confirmation code',style: TextStyle(
                color: Color(0XFFA1A8B0),
                fontSize: 14,
                fontWeight: FontWeight.w400
                ),
              ),
              SizedBox(height: 20,),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [


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

                    // Input Field (Switches between Email and Phone)
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: TextField(
                        keyboardType: isEmailSelected ? TextInputType.emailAddress : TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: "Password",
                          // Floating label text
                          labelStyle: TextStyle(color: Color(0XFFA1A8B0), fontSize: 16),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                          prefixIcon: Icon(
                            isEmailSelected ? Icons.email_outlined : Icons.phone,
                            color: Color(0xFF199A8E),
                          ),
                          suffixIcon: Icon(Icons.check, color: Color(0xFF199A8E)),
                          hintText: isEmailSelected ? 'Enter Email' : 'Phone Number',
                          hintStyle: TextStyle(color: Colors.grey, ),
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
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF199A8E),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        child: Text('Reset Password', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}