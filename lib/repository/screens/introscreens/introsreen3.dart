import 'package:al_haiwan/repository/screens/introscreens/loginsignupintro.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Introscreen3 extends StatelessWidget{
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
          ///Full-Screen Doctor Image
          Positioned(
            top: 60,

            child: Image.asset(
              'assets/images/d1.png', // Replace with your image
              height: screenHeight *0.4,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 250,
            right: 40,

            child: Image.asset(
              'assets/images/d5.png', // Replace with your image

              height: screenHeight *0.4,

              fit: BoxFit.cover,
            ),
          ),

          /// Skip Button
          Positioned(
            top: 40, // Adjust as needed
            right: 20, // Adjust as needed
            child: GestureDetector(
              onTap: () {
                // Add navigation or action
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
                    'Compassionate care for your furry friends, anytime, anywhere',
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
                          SizedBox(width: 5),
                          Container(
                            height: 6,
                            width: 20,
                            decoration: BoxDecoration(
                              color: Color(0xFF357964),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ],
                      ),

                      ///  Next Button
                      FloatingActionButton(
                        onPressed: () {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Loginsignupintro()),);
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