import 'package:al_haiwan/repository/login/loginpage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Signup extends StatefulWidget{
  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  @override
  Widget build(BuildContext context) {
    TextEditingController username = TextEditingController();
    TextEditingController email = TextEditingController();
    TextEditingController phone = TextEditingController();
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
       backgroundColor: Colors.white,
       title: Text('Sign Up', style: TextStyle(
           color: Colors.black, fontWeight: FontWeight.w700, fontSize: 18)),
       centerTitle: true,
     ),
     backgroundColor: Colors.white,
     body: SingleChildScrollView(
       child: Container(

         child: Padding(
           padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
           child: Column(
             crossAxisAlignment: CrossAxisAlignment.center,
             children: [
               SizedBox(
                 height: screenHeight * 0.05,
               ),
               TextField(controller: username,
                 decoration: InputDecoration(
                   labelText: "Username",
                   // Floating label text
                   labelStyle: TextStyle(color: Color(0XFFA1A8B0), fontSize: 16),
                   floatingLabelBehavior: FloatingLabelBehavior.auto,
                   // Label styling

                   prefixIcon: Icon(
                       Icons.account_circle, color: Color(0XFFA1A8B0)),
                   // Email icon
                   hintText: 'Enter Username',
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
               SizedBox(height: screenHeight * 0.02),
               TextField(controller: phone,keyboardType: TextInputType.number,
                 decoration: InputDecoration(
                   labelText: "Phone",
                   // Floating label text
                   labelStyle: TextStyle(color: Color(0XFFA1A8B0), fontSize: 16),
                   floatingLabelBehavior: FloatingLabelBehavior.auto,
                   // Label styling

                   prefixIcon: Icon(
                       Icons.email_outlined, color: Color(0XFFA1A8B0)),
                   // Email icon
                   hintText: 'Enter your Phone No',
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
               TextField(controller: password,
                 obscureText: true,
                 decoration: InputDecoration(
                   labelText: "Password",
                   // Floating label text
                   labelStyle: TextStyle(color: Color(0XFFA1A8B0), fontSize: 16),
                   floatingLabelBehavior: FloatingLabelBehavior.auto,
                   // Label styling

                   prefixIcon: Icon(
                       Icons.email_outlined, color: Color(0XFFA1A8B0)),
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
               Row(
                 crossAxisAlignment: CrossAxisAlignment.start, // Align text to the top
                 children: [
                   Checkbox(
                     value: true,
                     onChanged: (value) {
                       setState(() {

                       });
                     },
                     shape: RoundedRectangleBorder(
                       borderRadius: BorderRadius.circular(4),
                     ),
                     activeColor: Colors.teal,
                   ),
                   SizedBox(width: 8), // Space between checkbox and text
                   Expanded(
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Text("I agree to the ", style: TextStyle(color: Colors.black87)),
                         Row(
                           children: [
                             Text("medidoc ", style: TextStyle(fontWeight: FontWeight.w600)),
                             Text("Terms of Service ", style: TextStyle(color: Colors.teal, fontWeight: FontWeight.w600)),
                           ],
                         ),
                         Row(
                           children: [
                             Text("and "),
                             Text("Privacy Policy", style: TextStyle(color: Colors.teal, fontWeight: FontWeight.w600)),
                           ],
                         ),
                       ],
                     ),
                   ),
                 ],
               ),

               SizedBox(height: screenHeight * 0.01),
               Row(
                 crossAxisAlignment: CrossAxisAlignment.start, // Align text to the top
                 children: [
                   Checkbox(
                     value: true,
                     onChanged: (value) {
                       setState(() {

                       });
                     },
                     shape: RoundedRectangleBorder(
                       borderRadius: BorderRadius.circular(4),
                     ),
                     activeColor: Colors.teal,
                   ),
                   SizedBox(width: 8), // Space between checkbox and text
                   Expanded(
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         SizedBox(height: 15,),
                         Text("Are You Doctor? ", style: TextStyle(color: Colors.black87,fontSize: 13,fontFamily: 'bold')),

                       ],
                     ),
                   ),
                 ],
               ),

               SizedBox(height: 20),

               // Sign Up Button
               SizedBox(
                 width: double.infinity,
                 height: 50,
                 child: ElevatedButton(
                   onPressed: () {

                   },
                   style: ElevatedButton.styleFrom(
                     backgroundColor: Color(0XFF199A8E),
                     shape: RoundedRectangleBorder(
                       borderRadius: BorderRadius.circular(30), // Fully rounded button
                     ),
                     padding: EdgeInsets.symmetric(vertical: 14),
                   ),
                   child: Text(
                     "Sign Up",
                     style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                   ),
                 ),
               ),

               SizedBox(height: 20),

               // "Don't have an account? Sign Up" Text
               Row(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   Text("Already Have Account? ", style: TextStyle(color: Colors.grey)),
                   GestureDetector(
                     onTap: () {
                       Navigator.push(context, MaterialPageRoute(builder: (context)=> Loginpage()),);
                     },
                     child: Text(
                       "Sign In",
                       style: TextStyle(color: Color(0XFF199A8E), fontWeight: FontWeight.w600),
                     ),
                   ),
                 ],
               ),
             ],
           ),
         ),
         
       ),
     ),

   );
  }
}