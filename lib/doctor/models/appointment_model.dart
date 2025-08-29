import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentModel {
  final String id;
  final String doctorId;
  final String userId;
  final String ownerName;
  final String petName;
  final Timestamp selectedDate; // Changed to Timestamp for better Firebase integration
  final String selectedTime;
  final String selectedDay;
  final double consultationFee;
  final String paymentMethod;
  final String? paymentScreenshotUrl;
  final String problem; // Made non-nullable for required field
  final String status; // Changed to String for easier status management
  final DateTime createdAt;
  final DateTime? confirmedAt;
  final String? doctorNotes;
  String? doctorName; // Added doctorName field for admin display
  String? doctorSpecialty; // Added doctorSpecialty field for admin display

  AppointmentModel({
    required this.id,
    required this.doctorId,
    required this.userId,
    required this.ownerName,
    required this.petName,
    required this.selectedDate,
    required this.selectedTime,
    required this.selectedDay,
    required this.consultationFee,
    required this.paymentMethod,
    this.paymentScreenshotUrl,
    required this.problem,
    required this.status,
    required this.createdAt,
    this.confirmedAt,
    this.doctorNotes,
    this.doctorName,
    this.doctorSpecialty,
  });

  factory AppointmentModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    Timestamp selectedDateTs;
    var rawSelectedDate = data['selectedDate'];
    if (rawSelectedDate is Timestamp) {
      selectedDateTs = rawSelectedDate;
    } else if (rawSelectedDate is String && rawSelectedDate.isNotEmpty) {
      // Parse string to DateTime, then to Timestamp
      selectedDateTs = Timestamp.fromDate(DateTime.parse(rawSelectedDate));
    } else {
      selectedDateTs = Timestamp.now();
    }
    return AppointmentModel(
      id: doc.id,
      doctorId: data['doctorId']?.toString() ?? '',
      userId: data['userId']?.toString() ?? '',
      ownerName: data['ownerName']?.toString() ?? '',
      petName: data['petName']?.toString() ?? '',
      selectedDate: selectedDateTs,
      selectedTime: data['selectedTime']?.toString() ?? '',
      selectedDay: data['selectedDay']?.toString() ?? '',
      consultationFee: _parseDouble(data['consultationFee']),
      paymentMethod: data['paymentMethod']?.toString() ?? '',
      paymentScreenshotUrl: data['paymentScreenshotUrl']?.toString(),
      problem: data['problem']?.toString() ?? data['reason']?.toString() ?? '',
      status: data['status']?.toString() ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      confirmedAt: (data['confirmedAt'] as Timestamp?)?.toDate(),
      doctorNotes: data['doctorNotes']?.toString(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'doctorId': doctorId,
      'userId': userId,
      'ownerName': ownerName,
      'petName': petName,
      'selectedDate': selectedDate,
      'selectedTime': selectedTime,
      'selectedDay': selectedDay,
      'consultationFee': consultationFee,
      'paymentMethod': paymentMethod,
      'paymentScreenshotUrl': paymentScreenshotUrl,
      'problem': problem,
      'reason': problem, // For backward compatibility
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'confirmedAt': confirmedAt != null ? Timestamp.fromDate(confirmedAt!) : null,
      'doctorNotes': doctorNotes,
    };
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  AppointmentModel copyWith({
    String? id,
    String? doctorId,
    String? userId,
    String? ownerName,
    String? petName,
    Timestamp? selectedDate,
    String? selectedTime,
    String? selectedDay,
    double? consultationFee,
    String? paymentMethod,
    String? paymentScreenshotUrl,
    String? problem,
    String? status,
    DateTime? createdAt,
    DateTime? confirmedAt,
    String? doctorNotes,
    String? doctorName,
    String? doctorSpecialty,
  }) {
    return AppointmentModel(
      id: id ?? this.id,
      doctorId: doctorId ?? this.doctorId,
      userId: userId ?? this.userId,
      ownerName: ownerName ?? this.ownerName,
      petName: petName ?? this.petName,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTime: selectedTime ?? this.selectedTime,
      selectedDay: selectedDay ?? this.selectedDay,
      consultationFee: consultationFee ?? this.consultationFee,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentScreenshotUrl: paymentScreenshotUrl ?? this.paymentScreenshotUrl,
      problem: problem ?? this.problem,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      doctorNotes: doctorNotes ?? this.doctorNotes,
      doctorName: doctorName ?? this.doctorName,
      doctorSpecialty: doctorSpecialty ?? this.doctorSpecialty,
    );
  }
}

enum AppointmentStatus {
  pending,
  paymentVerified,
  confirmed,
  cancelled,
  completed
}
