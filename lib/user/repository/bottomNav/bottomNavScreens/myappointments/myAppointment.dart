import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Appointment {
  final String id;
  final String doctorId;
  final String doctorName;
  final String doctorSpecialty;
  final String doctorProfileImage;
  final String petName;
  final String date;
  final String time;
  final String reason;
  final String status;
  final DateTime createdAt;

  Appointment({
    required this.id,
    required this.doctorId,
    required this.doctorName,
    required this.doctorSpecialty,
    required this.doctorProfileImage,
    required this.petName,
    required this.date,
    required this.time,
    required this.reason,
    required this.status,
    required this.createdAt,
  });

  factory Appointment.fromFirestore(Map<String, dynamic> data, String id) {
    return Appointment(
      id: id,
      doctorId: data['doctorId'] ?? '',
      doctorName: data['doctorName'] ?? 'Unknown Doctor',
      doctorSpecialty: data['doctorSpecialty'] ?? 'Veterinarian',
      doctorProfileImage: data['doctorProfileImage'] ?? '',
      petName: data['petName'] ?? '',
      date: data['appointmentDate'] ?? '',
      time: data['appointmentTime'] ?? '',
      reason: data['reason'] ?? '',
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class MyAppointmentScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    final isTablet = screen.width > 600;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'My Appointments',
          style: TextStyle(
            color: Color(0xFF199A8E),
            fontFamily: 'bolditalic',
            fontSize: screen.width * (isTablet ? 0.035 : 0.045),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFF199A8E)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('appointments')
            .where('userId', isEqualTo: 'current_user_id') // Replace with actual user ID
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF199A8E)),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading appointments',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: screen.width * (isTablet ? 0.03 : 0.04),
                ),
              ),
            );
          }

          final appointments = snapshot.data?.docs.map((doc) =>
              Appointment.fromFirestore(doc.data() as Map<String, dynamic>, doc.id)
          ).toList() ?? [];

          if (appointments.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today, size: screen.width * 0.2, color: Colors.grey[300]),
                  SizedBox(height: screen.height * 0.02),
                  Text(
                    'No appointments found.',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: screen.width * (isTablet ? 0.03 : 0.04),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(screen.width * 0.04),
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final appointment = appointments[index];
              return Container(
                margin: EdgeInsets.only(bottom: screen.height * 0.02),
                padding: EdgeInsets.all(screen.width * 0.04),
                decoration: BoxDecoration(
                  color: Color(0xFFF6F8F9),
                  borderRadius: BorderRadius.circular(screen.width * 0.03),
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
                    Container(
                      width: screen.width * (isTablet ? 0.12 : 0.18),
                      height: screen.width * (isTablet ? 0.12 : 0.18),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(screen.width * 0.025),
                        border: Border.all(color: Color(0xFF199A8E), width: 1),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(screen.width * 0.025),
                        child: appointment.doctorProfileImage.isNotEmpty
                            ? Image.network(
                          appointment.doctorProfileImage,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[200],
                              child: Icon(Icons.person, color: Colors.grey),
                            );
                          },
                        )
                            : Container(
                          color: Colors.grey[200],
                          child: Icon(Icons.person, color: Colors.grey),
                        ),
                      ),
                    ),
                    SizedBox(width: screen.width * 0.03),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appointment.doctorName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: screen.width * (isTablet ? 0.03 : 0.04),
                            ),
                          ),
                          Text(
                            appointment.doctorSpecialty,
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: screen.width * (isTablet ? 0.025 : 0.035),
                            ),
                          ),
                          SizedBox(height: screen.height * 0.005),
                          Row(
                            children: [
                              Icon(Icons.calendar_today, size: screen.width * (isTablet ? 0.03 : 0.035), color: Color(0xFF199A8E)),
                              SizedBox(width: screen.width * 0.01),
                              Text(
                                '${appointment.date}, ${appointment.time}',
                                style: TextStyle(fontSize: screen.width * (isTablet ? 0.025 : 0.03)),
                              ),
                            ],
                          ),
                          SizedBox(height: screen.height * 0.005),
                          Row(
                            children: [
                              Icon(Icons.pets, size: screen.width * (isTablet ? 0.03 : 0.035), color: Colors.grey),
                              SizedBox(width: screen.width * 0.01),
                              Text(
                                appointment.petName,
                                style: TextStyle(
                                  fontSize: screen.width * (isTablet ? 0.025 : 0.03),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: screen.height * 0.005),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.notes, size: screen.width * (isTablet ? 0.03 : 0.035), color: Colors.grey),
                              SizedBox(width: screen.width * 0.01),
                              Expanded(
                                child: Text(
                                  appointment.reason,
                                  style: TextStyle(fontSize: screen.width * (isTablet ? 0.025 : 0.03)),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: screen.width * 0.02,
                        vertical: screen.height * 0.005,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(appointment.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(screen.width * 0.02),
                      ),
                      child: Text(
                        appointment.status.toUpperCase(),
                        style: TextStyle(
                          color: _getStatusColor(appointment.status),
                          fontSize: screen.width * (isTablet ? 0.02 : 0.025),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
