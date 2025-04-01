import 'package:al_haiwan/repository/screens/resetpassword/createnewpass.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class Verification extends StatefulWidget {
  @override
  State<Verification> createState() => _VerificationState();
}

class _VerificationState extends State<Verification> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Verification',
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.w700, fontSize: 18),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SafeArea(
            child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              SizedBox(height: 20),
              Text(
                'Enter Verification Code',
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Inter',
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Enter code that we have sent to your number 08528188*** ',
                textAlign: TextAlign.start,
                style: TextStyle(
                    color: Color(0XFFA1A8B0),
                    fontSize: 14,
                    fontWeight: FontWeight.w400),
              ),
              SizedBox(
                height: 20,
              ),
              PinCodeTextField(
                appContext: context,
                length: 6,
                keyboardType: TextInputType.number,
                obscureText: false,
                animationType: AnimationType.fade,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(10),
                  fieldHeight: 50,
                  fieldWidth: 40,
                  activeFillColor: Colors.white,
                  inactiveColor: Colors.grey,
                  selectedColor: Colors.green,
                ),
                onChanged: (value) {},
              ),
              SizedBox(height: 20,),
              SizedBox(
                width: 230,
                height: 55,
                child: ElevatedButton(
                  onPressed:  () {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> Creatnewpass()),);

                  } ,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF199A8E),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  child:
                  Text('Verify', style: TextStyle(color: Colors.white)),
                ),
              ),
              SizedBox(height: 20,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Didn’t receive the code? ",style: TextStyle(color: Colors.grey)),
                  GestureDetector(
                    onTap: (){},
                    child: Text("Resend Code",style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
                  )
                ],
              )
            ],
          ),
        )),
      ),
    );
  }
}
