import 'package:flutter/material.dart';

class DoctorScreen extends StatefulWidget {
  const DoctorScreen({super.key});

  @override
  State<DoctorScreen> createState() => _DoctorScreenState();
}

class _DoctorScreenState extends State<DoctorScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text(
            'Doctor Dashboard',
            style: TextStyle(
              color: Color(0XFF199A8E),
              fontFamily: "bolditalic",
              fontSize: 22,
            ),
          ),
          centerTitle: true,
        ),
        backgroundColor: Colors.white,
        body: Center(
          child: Text(
            'Welcome to the Doctor Dashboard',
            style: TextStyle(
              fontSize: 24,
              color: Color(0XFF199A8E),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );

  }
}
