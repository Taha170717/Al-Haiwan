import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'introsreen3.dart';
import 'loginsignupintro.dart';
//abc
class Intro2Controller extends GetxController {
  void skip() => Get.off(() => Loginsignupintro());
  void next() => Get.off(() => Introscreen3());
}

class Introscreen2 extends StatelessWidget {
  final Intro2Controller controller = Get.put(Intro2Controller());

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          Container(color: Colors.white),

          /// Image
          Positioned(
            top: 90,
            left: 20,
            right: 20,
            child: Image.asset(
              'assets/images/d4.png',
              fit: BoxFit.cover,
            ),
          ),

          /// Skip Button
          Positioned(
            top: 40,
            right: 20,
            child: GestureDetector(
              onTap: controller.skip,
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

          /// Bottom Content
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
                    'Find a lot of specialist doctors in one place',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 15),

                  /// Page Indicator & Next
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 3,
                            backgroundColor: Colors.grey.shade300,
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
                          CircleAvatar(
                            radius: 3,
                            backgroundColor: Colors.grey.shade300,
                          ),
                        ],
                      ),

                      FloatingActionButton(
                        onPressed: controller.next,
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
