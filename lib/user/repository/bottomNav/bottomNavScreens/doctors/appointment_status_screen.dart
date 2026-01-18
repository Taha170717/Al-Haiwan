import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../controllers/appointment_controller.dart';
import '../../../../models/user_appointment_model.dart';


class AppointmentStatusScreen extends StatefulWidget {
  @override
  _AppointmentStatusScreenState createState() => _AppointmentStatusScreenState();
}

class _AppointmentStatusScreenState extends State<AppointmentStatusScreen> {
  final AppointmentController appointmentController = Get.put(AppointmentController());

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        body: Center(
          child: Text('Please login to view appointments'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "My Appointments",
          style: TextStyle(
            color: Color(0xFF199A8E),
            fontWeight: FontWeight.bold,
            fontSize: screen.width * 0.045,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Color(0xFF199A8E)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('appointments')
            .where('userId', isEqualTo: user.uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Color(0xFF199A8E)));
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today, size: screen.width * 0.2, color: Colors.grey),
                  SizedBox(height: screen.height * 0.02),
                  Text(
                    'No appointments found',
                    style: TextStyle(
                      fontSize: screen.width * 0.04,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(screen.width * 0.04),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final appointment = Appointment.fromFirestore(
                doc.data() as Map<String, dynamic>,
                doc.id,
              );

              return _buildAppointmentCard(screen, appointment);
            },
          );
        },
      ),
    );
  }

  Widget _buildAppointmentCard(Size screen, Appointment appointment) {
    Color statusColor = _getStatusColor(appointment.status);
    String statusText = _getStatusText(appointment.status);
    IconData statusIcon = _getStatusIcon(appointment.status);

    return Container(
      margin: EdgeInsets.only(bottom: screen.height * 0.02),
      padding: EdgeInsets.all(screen.width * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(screen.width * 0.03),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Appointment #${appointment.id.substring(0, 8)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: screen.width * 0.04,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: screen.width * 0.03,
                  vertical: screen.height * 0.005,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(screen.width * 0.02),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: screen.width * 0.035, color: statusColor),
                    SizedBox(width: screen.width * 0.01),
                    Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                        fontSize: screen.width * 0.03,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: screen.height * 0.015),

          // Doctor Profile Picture and Name
          Row(
            children: [
              CircleAvatar(
                radius: screen.width * 0.06,
                backgroundImage: appointment.doctorprofilepic != null && appointment.doctorprofilepic!.isNotEmpty
                    ? NetworkImage(appointment.doctorprofilepic!)
                    : null,
                child: appointment.doctorprofilepic == null || appointment.doctorprofilepic!.isEmpty
                    ? Icon(Icons.person, size: screen.width * 0.06, color: Colors.grey)
                    : null,
              ),
              SizedBox(width: screen.width * 0.03),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dr. ${appointment.doctorName}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: screen.width * 0.04,
                      ),
                    ),
                    Text(
                      'Veterinarian',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: screen.width * 0.035,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: screen.height * 0.015),

          _buildInfoRow(screen, Icons.person, 'Owner', appointment.ownerName),

          // Dynamic consultation type display
          _buildConsultationTypeInfo(screen, appointment),

          _buildInfoRow(screen, Icons.calendar_today, 'Date', '${appointment.selectedDay}, ${appointment.selectedDate}'),
          _buildInfoRow(screen, Icons.access_time, 'Time', appointment.selectedTime),
          _buildInfoRow(screen, Icons.payment, 'Payment', appointment.paymentMethod),
          _buildInfoRow(screen, Icons.attach_money, 'Fee', '₨ ${appointment.consultationFee.toInt()}'),

          if (appointment.status == AppointmentStatus.pending) ...[
            SizedBox(height: screen.height * 0.02),
            Container(
              padding: EdgeInsets.all(screen.width * 0.03),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(screen.width * 0.02),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange, size: screen.width * 0.04),
                  SizedBox(width: screen.width * 0.02),
                  Expanded(
                    child: Text(
                      'Waiting for doctor to verify payment and confirm appointment',
                      style: TextStyle(
                        color: Colors.orange[800],
                        fontSize: screen.width * 0.032,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (appointment.status == AppointmentStatus.confirmed) ...[
            SizedBox(height: screen.height * 0.02),
            Container(
              padding: EdgeInsets.all(screen.width * 0.03),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(screen.width * 0.02),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle_outline, color: Colors.green, size: screen.width * 0.04),
                  SizedBox(width: screen.width * 0.02),
                  Expanded(
                    child: Text(
                      'Appointment confirmed! Please arrive on time.',
                      style: TextStyle(
                        color: Colors.green[800],
                        fontSize: screen.width * 0.032,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildConsultationTypeInfo(Size screen, Appointment appointment) {
    // Handle backward compatibility - if consultationType is not available, use petName to determine type
    ConsultationType consultationType;
    try {
      consultationType = appointment.consultationType;
    } catch (e) {
      // For backward compatibility with old appointments that might not have consultationType
      consultationType = appointment.petName != null ? ConsultationType.pet : ConsultationType.livestock;
    }

    switch (consultationType) {
      case ConsultationType.pet:
        return Column(
          children: [
            _buildInfoRow(screen, Icons.pets, 'Pet Type', appointment.petType ?? 'Not specified'),
            _buildInfoRow(screen, Icons.favorite, 'Pet Name', appointment.petName ?? 'Not specified'),
          ],
        );
      case ConsultationType.livestock:
        return _buildInfoRow(screen, Icons.agriculture, 'Livestock Count', '${appointment.numberOfPatients ?? 1} animals');
      case ConsultationType.poultry:
        return _buildInfoRow(screen, Icons.egg, 'Poultry Count', '${appointment.numberOfPatients ?? 1} birds');
    }
  }


  Widget _buildInfoRow(Size screen, IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: screen.height * 0.008),
      child: Row(
        children: [
          Icon(icon, size: screen.width * 0.04, color: Colors.grey[600]),
          SizedBox(width: screen.width * 0.03),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: screen.width * 0.035,
              color: Colors.grey[600],
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: screen.width * 0.035,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.pending:
        return Colors.orange;
      case AppointmentStatus.paymentVerified:
        return Colors.blue;
      case AppointmentStatus.confirmed:
        return Colors.green;
      case AppointmentStatus.cancelled:
        return Colors.red;
      case AppointmentStatus.completed:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.pending:
        return 'Pending';
      case AppointmentStatus.paymentVerified:
        return 'Payment Verified';
      case AppointmentStatus.confirmed:
        return 'Confirmed';
      case AppointmentStatus.cancelled:
        return 'Cancelled';
      case AppointmentStatus.completed:
        return 'Completed';
      default:
        return 'Unknown';
    }
  }

  IconData _getStatusIcon(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.pending:
        return Icons.schedule;
      case AppointmentStatus.paymentVerified:
        return Icons.payment;
      case AppointmentStatus.confirmed:
        return Icons.check_circle;
      case AppointmentStatus.cancelled:
        return Icons.cancel;
      case AppointmentStatus.completed:
        return Icons.done_all;
      default:
        return Icons.help_outline;
    }
  }
}
