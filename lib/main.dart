import 'package:Alhewan/repository/screens/splash/splashscreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Make sure this is imported

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Al-Haiwan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Add your theme config here
      ),
      home: SplashScreen(),
    );
  }
}
