import 'package:al_haiwan/repository/resetpassword/resetpassword.dart';
import 'package:al_haiwan/repository/signup/signup.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Loginpage extends StatefulWidget{
  @override
  State<Loginpage> createState() => _LoginpageState();
}

class _LoginpageState extends State<Loginpage> {
  @override
  Widget build(BuildContext context) {
    TextEditingController email = TextEditingController();
    TextEditingController password = TextEditingController();

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
        automaticallyImplyLeading: true,
        // Shows the back button
        backgroundColor: Colors.white,
        elevation: 0,

        title: Text('Login', style: TextStyle(
            color: Colors.black, fontWeight: FontWeight.w700, fontSize: 18)),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
        
                SizedBox(height: screenHeight * 0.05),
        
                // Email Field
                TextField(controller: email,
                  decoration: InputDecoration(
                    labelText: "Email",
                    // Floating label text
                    labelStyle: TextStyle(color: Color(0XFFA1A8B0), fontSize: 16),
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                    // Label styling
        
                    prefixIcon: Icon(
                        Icons.email_outlined, color: Color(0XFFA1A8B0)),
                    // Email icon
                    hintText: 'Enter your email',
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
        
        
                SizedBox(height: screenHeight * 0.03),
        
                // Password Field
                TextField(controller: password,
                  obscureText: true, // Hides the password
                  decoration: InputDecoration(
                    labelText: "Password",
                    // Floating label text
                    labelStyle: TextStyle(color: Color(0XFFA1A8B0), fontSize: 16),

                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                    // Smooth animation

                    prefixIcon: Icon(
                        Icons.lock_outline, color: Color(0XFFA1A8B0)),
                    // Lock icon

                    suffixIcon: Icon(
                        Icons.visibility_off, color: Color(0XFFA1A8B0)),
                    // Eye icon (can be made tappable)

                    hintText: 'Enter your password',
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
        
        
                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder:(context)=> Resetpassword()),);
                    },
                    child: Text("Forgot Password?",
                        style: TextStyle(color: Color(0XFF199A8E))),
                  ),
                ),
        
                // Login Button
                SizedBox(height: screenHeight * 0.01),
                SizedBox(
                  width: double.infinity,
                  height: screenHeight * 0.06,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0XFF199A8E),
                      fixedSize: Size(327, 56),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32)),
                    ),
                    child: Text('Login', style: TextStyle(fontSize: 16,
                        color: Colors.white,
                        
                        fontWeight: FontWeight.w600)),
                  ),
                ),
        
                SizedBox(height: screenHeight * 0.02),
        
                // Sign Up Option
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account?"),
                    TextButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context)=> Signup()));
                      },
                      child: Text(
                          "Sign Up", style: TextStyle(color: Color(0XFF199A8E))),
                    ),
                  ],
                ),
        
                // OR Divider
                SizedBox(height: screenHeight * 0.02),
                Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text("OR"),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
        
                // Social Login Buttons
                SizedBox(height: screenHeight * 0.02),

                Column(
                  children: [
                    socialButton(
                        "Sign in with Google",
                        "assets/images/google.png",
                            () {
                          // TODO: Implement Google sign-in logic
                          print("Google Sign-In Clicked");
                        }
                    ),
                    SizedBox(height: 12),
                    socialButton(
                        "Sign in with Facebook",
                        "assets/images/facebook.png",
                            () {
                          // TODO: Implement Facebook sign-in logic
                          print("Facebook Sign-In Clicked");
                        }
                    ),
                  ],
                )


          ],
            ),
          ),
        ),
      ),
    );
  }
}
Widget socialButton(String text, String iconPath, VoidCallback onPressed) {
  return SizedBox(
    width: 300, // Set a fixed width
    child: ElevatedButton.icon(
      onPressed: onPressed, // Action when clicked
      icon: Image.asset(iconPath, width: 18, height: 18), // Logo size
      label: Text(text, style: TextStyle(color: Colors.black, fontSize: 16)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 12), // Adjust padding
        elevation: 1, // Soft shadow effect
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30), // Full rounded shape
          side: BorderSide(color: Colors.grey.shade300), // Light border
        ),
      ),
    ),
  );
}