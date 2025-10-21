import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../../../../doctor/controller/doctor_chat_controller.dart';
import '../../../../../doctor/views/bottom_nav_pages/chat/doctor_chat_screen.dart';
import '../../../../../doctor/views/bottom_nav_pages/chat/doctor_chat_screen_list.dart';


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
    // Handle selectedDate - could be Timestamp or String
    String formattedDate = '';
    var rawDate = data['selectedDate'];
    if (rawDate is Timestamp) {
      formattedDate = DateFormat('MMM dd, yyyy').format(rawDate.toDate());
    } else if (rawDate is String && rawDate.isNotEmpty) {
      try {
        DateTime parsedDate = DateTime.parse(rawDate);
        formattedDate = DateFormat('MMM dd, yyyy').format(parsedDate);
      } catch (e) {
        formattedDate = rawDate; // fallback to original string
      }
    }

    // Handle selectedTime - should be a simple string
    String formattedTime = data['selectedTime']?.toString() ?? '';

    return Appointment(
      id: id,
      doctorId: data['doctorId'] ?? '',
      doctorName: data['doctorName'] ?? 'Unknown Doctor',
      doctorSpecialty: data['doctorSpecialty'] ?? 'Veterinarian',
      doctorProfileImage: data['doctorprofilepic'] ?? '',
      petName: data['petName'] ?? '',
      date: formattedDate,
      time: formattedTime,
      reason: data['reason'] ?? '',
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class MyAppointmentScreen extends StatelessWidget {
  final DoctorChatController chatController = Get.put(DoctorChatController());

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
            .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
            .where('status', whereIn: ['confirmed', 'completed'])
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

          final appointments = snapshot.data?.docs.map((doc) {
                print('Raw appointment data: ${doc.data()}');
                return Appointment.fromFirestore(
                    doc.data() as Map<String, dynamic>, doc.id);
              }).toList() ??
              [];

          if (appointments.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today, size: screen.width * 0.2, color: Colors.grey[300]),
                  SizedBox(height: screen.height * 0.02),
                  Text(
                    'No confirmed appointments found.',
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
                child: Column(
                  children: [
                    Row(
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
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        appointment.date,
                                        style: TextStyle(
                                            fontSize: screen.width *
                                                (isTablet ? 0.025 : 0.03)),
                                      ),
                                      if (appointment.time.isNotEmpty)
                                        Text(
                                          appointment.time,
                                          style: TextStyle(
                                            fontSize: screen.width *
                                                (isTablet ? 0.023 : 0.028),
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                    ],
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
                        Column(
                          children: [
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
                            if (appointment.status.toLowerCase() == 'confirmed')
                              SizedBox(height: screen.height * 0.01),
                            if (appointment.status.toLowerCase() == 'confirmed')
                              GestureDetector(
                                onTap: () async {
                                  try {
                                    // Validate required data
                                    if (appointment.doctorId.isEmpty) {
                                      throw Exception('Doctor ID is empty');
                                    }
                                    if (appointment.doctorName.isEmpty) {
                                      throw Exception('Doctor name is empty');
                                    }

                                    print(
                                        'Starting chat with doctor: ${appointment.doctorId}');
                                    print(
                                        'Doctor name: ${appointment.doctorName}');
                                    print(
                                        'Doctor image: ${appointment.doctorProfileImage}');

                                    final chatId = await chatController.startChatWithDoctor(
                                      doctorId: appointment.doctorId,
                                      doctorName: appointment.doctorName,
                                      doctorImage: appointment.doctorProfileImage,
                                    );

                                    print('Chat ID created: $chatId');

                                    Get.to(() => DoctorChatScreen(
                                      chatId: chatId,
                                      doctorName: appointment.doctorName,
                                      doctorImage: appointment.doctorProfileImage,
                                    ));
                                  } catch (e) {
                                    print('Error starting chat: $e');
                                    Get.snackbar(
                                      'Error',
                                      'Failed to start chat: ${e.toString()}',
                                      backgroundColor:
                                          Colors.red.withOpacity(0.8),
                                      colorText: Colors.white,
                                      duration: Duration(seconds: 5),
                                    );
                                  }
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: screen.width * 0.03,
                                    vertical: screen.height * 0.008,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF199A8E),
                                    borderRadius: BorderRadius.circular(screen.width * 0.02),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.chat, color: Colors.white, size: screen.width * 0.04),
                                      SizedBox(width: screen.width * 0.01),
                                      Text(
                                        'Chat',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: screen.width * (isTablet ? 0.02 : 0.025),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
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
      case 'completed':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
