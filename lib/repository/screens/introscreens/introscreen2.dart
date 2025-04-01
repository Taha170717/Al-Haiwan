import 'package:al_haiwan/repository/screens/introscreens/introsreen3.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'loginsignupintro.dart';

class Introscreen2 extends StatefulWidget{
  const Introscreen2({super.key});

  @override
  State<Introscreen2> createState() => _Introscreen2State();
}

class _Introscreen2State extends State<Introscreen2> {


  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.height;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: Colors.white,
          ),
          // Image**
          Positioned(
            top: 90,
            left: 20,
            right: 20,
            child: Image.asset(
              'assets/images/d4.png', // Replace with your image
              // width: screenWidth * 0.8,
              // height: screenHeight * 0.5,
              fit: BoxFit.cover,
            ),
          ),

          //Skip Button
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
                  /// Title Description
                  Text(
                    'Find a lot of specialist doctors in one place',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 15),

                  ///  Page Indicator & Arrow Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [


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
                        ],
                      ),

                      /// Next Button
                      FloatingActionButton(
                        onPressed: () {
                         Navigator.pushReplacement(context, MaterialPageRoute(builder:

                         (context)=> Introscreen3()),);
                        },
                        backgroundColor: Color(0xFF357964),
                        shape: CircleBorder(), // Ensures a perfect circular shape
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