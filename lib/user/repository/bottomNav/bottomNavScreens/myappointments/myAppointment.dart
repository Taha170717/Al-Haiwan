import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../models/user_appointment_model.dart';
import 'package:intl/intl.dart';

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
            .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid) // Replace with actual user ID
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
                        child: appointment.doctorprofilepic != null && appointment.doctorprofilepic!.isNotEmpty
                            ? Image.network(
                          appointment.doctorprofilepic!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[200],
                              child: Icon(Icons.person, color: Colors.grey),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: Colors.grey[200],
                              child: Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF199A8E)),
                                  strokeWidth: 2,
                                ),
                              ),
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
                            'Veterinarian',
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
                                _formattedDate(appointment.selectedDate) + ', ' + appointment.selectedTime,
                                style: TextStyle(fontSize: screen.width * (isTablet ? 0.025 : 0.03)),
                              ),
                            ],
                          ),
                          SizedBox(height: screen.height * 0.005),

                          // Dynamic consultation type display
                          _buildConsultationInfo(appointment, screen, isTablet),

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
                        color: _getStatusColor(appointment.status.name)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(screen.width * 0.02),
                      ),
                      child: Text(
                        appointment.status.name.toUpperCase(),
                        style: TextStyle(
                          color: _getStatusColor(appointment.status.name),
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
  Widget _buildConsultationInfo(Appointment appointment, Size screen, bool isTablet) {
    // Handle backward compatibility - if consultationType is not available, use petName to determine type
    ConsultationType consultationType;
    try {
      consultationType = appointment.consultationType;
    } catch (e) {
      // For backward compatibility with old appointments
      consultationType = appointment.petName != null ? ConsultationType.pet : ConsultationType.livestock;
    }

    switch (consultationType) {
      case ConsultationType.pet:
        return Column(
          children: [
            if (appointment.petType != null) ...[
              Row(
                children: [
                  Icon(Icons.category, size: screen.width * (isTablet ? 0.03 : 0.035), color: Colors.grey),
                  SizedBox(width: screen.width * 0.01),
                  Text(
                    appointment.petType!,
                    style: TextStyle(
                      fontSize: screen.width * (isTablet ? 0.025 : 0.03),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: screen.height * 0.005),
            ],
            Row(
              children: [
                Icon(Icons.pets, size: screen.width * (isTablet ? 0.03 : 0.035), color: Colors.grey),
                SizedBox(width: screen.width * 0.01),
                Text(
                  appointment.petName ?? 'Pet',
                  style: TextStyle(
                    fontSize: screen.width * (isTablet ? 0.025 : 0.03),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        );
      case ConsultationType.livestock:
        return Row(
          children: [
            Icon(Icons.agriculture, size: screen.width * (isTablet ? 0.03 : 0.035), color: Colors.grey),
            SizedBox(width: screen.width * 0.01),
            Text(
              '${appointment.numberOfPatients ?? 1} Livestock Animals',
              style: TextStyle(
                fontSize: screen.width * (isTablet ? 0.025 : 0.03),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        );
      case ConsultationType.poultry:
        return Row(
          children: [
            Icon(Icons.egg, size: screen.width * (isTablet ? 0.03 : 0.035), color: Colors.grey),
            SizedBox(width: screen.width * 0.01),
            Text(
              '${appointment.numberOfPatients ?? 1} Poultry Birds',
              style: TextStyle(
                fontSize: screen.width * (isTablet ? 0.025 : 0.03),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        );
    }
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

  String _formattedDate(String dateStr) {
    try {
      final date = DateTime.tryParse(dateStr);
      if (date != null) {
        return DateFormat('yyyy-MM-dd').format(date);
      }
      return dateStr.split(' ').first;
    } catch (_) {
      return dateStr;
    }
  }
}
