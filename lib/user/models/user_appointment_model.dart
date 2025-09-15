import 'package:cloud_firestore/cloud_firestore.dart';

class Appointment {
  final String id;
  final String doctorId;
  final String userId;
  final String ownerName;
  final String? petName; // Optional for pets only
  final String? petType; // Optional for pets only (Dog, Cat, etc.)
  final int? numberOfPatients; // Optional for livestock/poultry
  final ConsultationType consultationType; // Pet, Livestock, or Poultry
  final String selectedDate;
  final String selectedTime;
  final String selectedDay;
  final double consultationFee;
  final String paymentMethod;
  final String? paymentScreenshotUrl;
  final AppointmentStatus status;
  final DateTime createdAt;
  final String? doctorprofilepic;
  final DateTime? confirmedAt;
  final String? doctorNotes;
  final String doctorName;
  final String reason;

  Appointment({
    required this.id,
    required this.doctorId,
    required this.userId,
    required this.ownerName,
    this.petName,
    this.petType,
    this.numberOfPatients,
    required this.consultationType,
    required this.selectedDate,
    required this.selectedTime,
    this.doctorprofilepic,
    required this.selectedDay,
    required this.consultationFee,
    required this.paymentMethod,
    this.paymentScreenshotUrl,
    required this.status,
    required this.createdAt,
    this.confirmedAt,
    this.doctorNotes,
    required this.doctorName,
    required this.reason,
  });

  factory Appointment.fromFirestore(Map<String, dynamic> data, String id) {
    return Appointment(
      id: id,
      doctorId: data['doctorId']?.toString() ?? '',
      userId: data['userId']?.toString() ?? '',
      ownerName: data['ownerName']?.toString() ?? '',
      petName: data['petName']?.toString(),
      petType: data['petType']?.toString(),
      numberOfPatients: data['numberOfPatients'] as int?,
      consultationType: ConsultationType.values.firstWhere(
            (e) => e.toString().split('.').last == data['consultationType'],
        orElse: () => ConsultationType.pet,
      ),
      selectedDate: data['selectedDate']?.toString() ?? '',
      selectedTime: data['selectedTime']?.toString() ?? '',
      selectedDay: data['selectedDay']?.toString() ?? '',
      consultationFee: _parseDouble(data['consultationFee']),
      paymentMethod: data['paymentMethod']?.toString() ?? '',
      paymentScreenshotUrl: data['paymentScreenshotUrl']?.toString(),
      status: AppointmentStatus.values.firstWhere(
            (e) => e.toString().split('.').last == data['status'],
        orElse: () => AppointmentStatus.pending,
      ),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      confirmedAt: (data['confirmedAt'] as Timestamp?)?.toDate(),
      doctorNotes: data['doctorNotes']?.toString(),
      doctorName: data['doctorName']?.toString() ?? '',
      reason: data['reason']?.toString() ?? '',
      doctorprofilepic: data['doctorprofilepic']?.toString(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'doctorId': doctorId,
      'userId': userId,
      'ownerName': ownerName,
      'petName': petName,
      'petType': petType,
      'numberOfPatients': numberOfPatients,
      'consultationType': consultationType.toString().split('.').last,
      'selectedDate': selectedDate,
      'selectedTime': selectedTime,
      'selectedDay': selectedDay,
      'consultationFee': consultationFee,
      'paymentMethod': paymentMethod,
      'paymentScreenshotUrl': paymentScreenshotUrl,
      'status': status.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
      'confirmedAt': confirmedAt != null ? Timestamp.fromDate(confirmedAt!) : null,
      'doctorNotes': doctorNotes,
      'doctorName': doctorName,
      'reason': reason,
      'doctorprofilepic': doctorprofilepic,
    };
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

enum ConsultationType {
  pet,
  livestock,
  poultry
}

enum AppointmentStatus {
  pending,
  paymentVerified,
  confirmed,
  cancelled,
  completed
}
