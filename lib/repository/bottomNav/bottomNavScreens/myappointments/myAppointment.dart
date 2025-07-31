import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../doctors/doctor_list_viewmodel.dart';

class Appointment {
  final Doctor doctor;
  final String date;
  final String time;
  final String reason;

  Appointment({
    required this.doctor,
    required this.date,
    required this.time,
    required this.reason,
  });
}

class MyAppointmentScreen extends StatelessWidget {
  final List<Appointment> bookedAppointments = [
    Appointment(
      doctor: Doctor(
        name: "Dr. Marcus Horizon",
        speciality: "Veterinarian",
        image: "assets/images/doc1.png",
        rating: 4.7,
        distance: "1200m",
      ),
      date: "Mon, 21",
      time: "08:00 AM",
      reason: "Follow-up checkup",
    ),
    Appointment(
      doctor: Doctor(
        name: "Dr. Maria Elena",
        speciality: "Veterinarian",
        image: "assets/images/doc2.png",
        rating: 4.7,
        distance: "600m",
      ),
      date: "Wed, 23",
      time: "10:00 AM",
      reason: "Vaccination",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'My Appointments',
          style: TextStyle(color: Color(0xFF199A8E), fontFamily: 'bolditalic'),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFF199A8E)),
      ),
      body: bookedAppointments.isEmpty
          ? Center(
        child: Text(
          'No appointments found.',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      )
          : ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: bookedAppointments.length,
        itemBuilder: (context, index) {
          final appointment = bookedAppointments[index];
          return Container(
            margin: EdgeInsets.only(bottom: 16),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFFF6F8F9),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    appointment.doctor.image,
                    width: screen.width * 0.18,
                    height: screen.width * 0.18,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.doctor.name,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        appointment.doctor.speciality,
                        style: TextStyle(color: Colors.grey),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 14, color: Color(0xFF199A8E)),
                          SizedBox(width: 4),
                          Text('${appointment.date}, ${appointment.time}'),
                        ],
                      ),
                      SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.notes, size: 14, color: Colors.grey),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              appointment.reason,
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
