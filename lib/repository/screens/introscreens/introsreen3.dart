import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'loginsignupintro.dart';

class Intro3Controller extends GetxController {
  void skipOrFinish() => Get.off(() => Loginsignupintro());
}

class Introscreen3 extends StatelessWidget {
  final Intro3Controller controller = Get.put(Intro3Controller());

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          Container(color: Colors.white),

          /// First Image (Top)
          Positioned(
            top: 60,
            child: Image.asset(
              'assets/images/d1.png',
              height: screenHeight * 0.4,
              fit: BoxFit.cover,
            ),
          ),

          /// Second Image (Right)
          Positioned(
            top: 250,
            right: 40,
            child: Image.asset(
              'assets/images/d5.png',
              height: screenHeight * 0.4,
              fit: BoxFit.cover,
            ),
          ),

          /// Skip Button
          Positioned(
            top: 40,
            right: 20,
            child: GestureDetector(
              onTap: controller.skipOrFinish,
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

          /// Bottom Container
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
                  Text(
                    'Compassionate care for your furry friends, anytime, anywhere',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 15),

                  /// Page Indicator + Next Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(radius: 3, backgroundColor: Colors.grey.shade300),
                          SizedBox(width: 5),
                          CircleAvatar(radius: 3, backgroundColor: Colors.grey.shade300),
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
                      FloatingActionButton(
                        onPressed: controller.skipOrFinish,
                        backgroundColor: Color(0xFF357964),
                        shape: CircleBorder(),
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
