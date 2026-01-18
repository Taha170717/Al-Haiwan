import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

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
    String formattedDate = '';
    var rawDate = data['selectedDate'];
    if (rawDate is Timestamp) {
      formattedDate = DateFormat('MMM dd, yyyy').format(rawDate.toDate());
    } else if (rawDate is String && rawDate.isNotEmpty) {
      try {
        DateTime parsedDate = DateTime.parse(rawDate);
        formattedDate = DateFormat('MMM dd, yyyy').format(parsedDate);
      } catch (e) {
        formattedDate = rawDate;
      }
    }

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