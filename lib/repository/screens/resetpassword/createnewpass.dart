import 'package:Alhewan/repository/screens/login/loginpage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Creatnewpass extends StatefulWidget {
  @override
  State<Creatnewpass> createState() => _CreatnewpassState();
}

class _CreatnewpassState extends State<Creatnewpass> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    TextEditingController password = TextEditingController();
    TextEditingController confirmpassword = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,

      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SafeArea(
            child: Padding(padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Text(
                  'Create New Password',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Inter',
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Create your new password to login into your Account',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      color: Color(0XFFA1A8B0),
                      fontSize: 16,
                      fontWeight: FontWeight.w400),
                ),
                SizedBox(height: 30,),

                TextField(controller: password,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Password",
                    // Floating label text
                    labelStyle: TextStyle(color: Color(0XFFA1A8B0), fontSize: 16),
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                    // Label styling

                    prefixIcon: Icon(
                      Icons.lock, color: Color(0xFF199A8E),),
                    suffixIcon: Icon(
                        Icons.visibility_off, color: Color(0XFFA1A8B0)),
                    // Email icon
                    hintText: 'Enter your Password',
                    hintStyle: TextStyle(color: Color(0XFFA1A8B0)),
                    // Lighter hint text

                    // Default Border - Gray when not focused
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(color: Colors.grey, width: 2),
                    ),

                    // Focused Border - Teal when clicked
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(color: Color(0XFF199A8E), width: 2),
                    ),

                    // Error Border - Red when validation fails
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(color: Colors.red, width: 2),
                    ),

                    // Focused Error Border - Red with Teal glow
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(color: Colors.redAccent, width: 2),
                    ),

                    errorStyle: TextStyle(
                        color: Colors.red, fontSize: 14), // Error text styling
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                TextField(controller: confirmpassword,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Confirm Password",
                    // Floating label text
                    labelStyle: TextStyle(color: Color(0XFFA1A8B0), fontSize: 16),
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                    // Label styling

                    prefixIcon: Icon(
                      Icons.lock, color: Color(0xFF199A8E),),
                    suffixIcon: Icon(
                        Icons.visibility_off, color: Color(0XFFA1A8B0)),
                    // Email icon
                    hintText: 'Please Confirm Password',
                    hintStyle: TextStyle(color: Color(0XFFA1A8B0)),
                    // Lighter hint text

                    // Default Border - Gray when not focused
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(color: Colors.grey, width: 2),
                    ),

                    // Focused Border - Teal when clicked
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(color: Color(0XFF199A8E), width: 2),
                    ),

                    // Error Border - Red when validation fails
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(color: Colors.red, width: 2),
                    ),

                    // Focused Error Border - Red with Teal glow
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(color: Colors.redAccent, width: 2),
                    ),

                    errorStyle: TextStyle(
                        color: Colors.red, fontSize: 14), // Error text styling
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed:  () {
                      loginPageCreatepass(context);
                    } ,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF199A8E),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    child:
                    Text('Create Password', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
            )
        ),
      ),
    );
  }
  void loginPageCreatepass(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0XFFF5F8FF) // Background color for the circle
                  ),
                  padding: EdgeInsets.all(12), // Adjust padding for proper spacing
                  child: Icon(Icons.check, size: 60, color: Color(0xFF199A8E)), // Green tick
                ),
                SizedBox(height: 16),
                Text(
                  "Success!",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  "You have successfully reset your password.",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => Loginpage()), // Replace with your Home Screen
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0XFF199A8E),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    minimumSize: Size(double.infinity, 50),
                  ),
                  child: Text("Login", style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
