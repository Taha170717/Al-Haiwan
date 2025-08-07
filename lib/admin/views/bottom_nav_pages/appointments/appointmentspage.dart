import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AdminAppointment extends StatefulWidget {
  const AdminAppointment({super.key});

  @override
  State<AdminAppointment> createState() => _AdminAppointmentState();
}

class _AdminAppointmentState extends State<AdminAppointment> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.greenAccent,
      body: Container(child: Center(
        child: Text("Admin Appointment Page"),
      ),
      ),
    );
  }
}
