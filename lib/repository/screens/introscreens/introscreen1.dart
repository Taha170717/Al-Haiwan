import 'package:Alhewan/repository/screens/introscreens/introscreen2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'loginsignupintro.dart';

class Introscreen1 extends StatefulWidget{
  @override
  State<Introscreen1> createState() => _Introscreen1State();
}

class _Introscreen1State extends State<Introscreen1> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(

        children: [
          Container(
            color: Colors.white,
          ),

          /// Full-Screen Doctor Image
          Positioned(

            top: 90,
            left: 20,
            right: 20,
            child: Image.asset(
              'assets/images/d3.png', // Replace with your image
              // width: screenWidth * 0.8,
              // height: screenHeight * 0.5,
              fit: BoxFit.cover,
            ),
          ),

          ///  Skip Button
          Positioned(
            top: 40, // Adjust as needed
            right: 20, // Adjust as needed
            child: GestureDetector(
              onTap: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Loginsignupintro()),);
              },
              child: Text(
                'Skip',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),




          /// Bottom Rounded Container
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: screenHeight * 0.3,
              width: screenWidth,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ///  Title & Description
                  Text(
                    'Consult only with a doctor you trust',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 15),

                  /// Page Indicator & Arrow Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            height: 6,
                            width: 20,
                            decoration: BoxDecoration(
                              color: Color(0xFF357964),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          SizedBox(width: 5),
                          Container(
                            height: 6,
                            width: 6,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 5),
                          Container(
                            height: 6,
                            width: 6,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),

                      /// Next Button
                      FloatingActionButton(
                        onPressed: () {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Introscreen2()),);
                        },
                        shape: CircleBorder(),
                        backgroundColor: Color(0xFF357964),
                        child: Icon(Icons.arrow_forward, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

    );
  }
}