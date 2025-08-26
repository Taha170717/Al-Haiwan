class TimeSlot {
  final String id;
  final String startTime;
  final String endTime;
  final int maxPatients;
  final bool isAvailable;

  TimeSlot({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.maxPatients,
    this.isAvailable = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'startTime': startTime,
      'endTime': endTime,
      'maxPatients': maxPatients,
      'isAvailable': isAvailable,
    };
  }

  factory TimeSlot.fromMap(Map<String, dynamic> map) {
    return TimeSlot(
      id: map['id'] ?? '',
      startTime: map['startTime'] ?? '',
      endTime: map['endTime'] ?? '',
      maxPatients: map['maxPatients'] ?? 1,
      isAvailable: map['isAvailable'] ?? true,
    );
  }
}

class DayAvailability {
  final String day;
  final bool isAvailable;
  final List<TimeSlot> timeSlots;

  DayAvailability({
    required this.day,
    required this.isAvailable,
    required this.timeSlots,
  });

  Map<String, dynamic> toMap() {
    return {
      'day': day,
      'isAvailable': isAvailable,
      'timeSlots': timeSlots.map((slot) => slot.toMap()).toList(),
    };
  }

  factory DayAvailability.fromMap(Map<String, dynamic> map) {
    return DayAvailability(
      day: map['day'] ?? '',
      isAvailable: map['isAvailable'] ?? false,
      timeSlots: List<TimeSlot>.from(
        map['timeSlots']?.map((slot) => TimeSlot.fromMap(slot)) ?? [],
      ),
    );
  }
}

class DoctorProfile {
  final String doctorId;
  final double consultationFee;
  final String profileImageUrl;
  final String bio;
  final String clinicAddress;
  final String clinicContact;
  final String clinicName;
  final String about;
  final String registrationNumber;
  final String specialization;
  final bool isOnlineOnly;
  final bool isCurrentlyAvailable;
  final List<DayAvailability> weeklyAvailability;
  final DateTime lastUpdated;
  final String easypaisaNumber;
  final String jazzcashNumber;
  final String bankName;
  final String bankAccountNumber;
  final String bankHolderName;

  DoctorProfile({
    required this.doctorId,
    required this.consultationFee,
    required this.profileImageUrl,
    required this.bio,
    required this.clinicAddress,
    required this.clinicContact,
    required this.clinicName,
    required this.about,
    required this.registrationNumber,
    required this.specialization,
    required this.isOnlineOnly,
    required this.isCurrentlyAvailable,
    required this.weeklyAvailability,
    required this.lastUpdated,
    required this.easypaisaNumber,
    required this.jazzcashNumber,
    required this.bankName,
    required this.bankAccountNumber,
    required this.bankHolderName,
  });

  Map<String, dynamic> toMap() {
    return {
      'doctorId': doctorId,
      'consultationFee': consultationFee,
      'profileImageUrl': profileImageUrl,
      'bio': bio,
      'clinicAddress': clinicAddress,
      'clinicContact': clinicContact,
      'clinicName': clinicName,
      'about': about,
      'registrationNumber': registrationNumber,
      'specialization': specialization,
      'isOnlineOnly': isOnlineOnly,
      'isCurrentlyAvailable': isCurrentlyAvailable,
      'weeklyAvailability': weeklyAvailability.map((day) => day.toMap()).toList(),
      'lastUpdated': lastUpdated.toIso8601String(),
      'easypaisaNumber': easypaisaNumber,
      'jazzcashNumber': jazzcashNumber,
      'bankName': bankName,
      'bankAccountNumber': bankAccountNumber,
      'bankHolderName': bankHolderName,
    };
  }

  factory DoctorProfile.fromMap(Map<String, dynamic> map) {
    return DoctorProfile(
      doctorId: map['doctorId'] ?? '',
      consultationFee: (map['consultationFee'] ?? 0.0).toDouble(),
      profileImageUrl: map['profileImageUrl'] ?? '',
      bio: map['bio'] ?? '',
      clinicAddress: map['clinicAddress'] ?? '',
      clinicContact: map['clinicContact'] ?? '',
      clinicName: map['clinicName'] ?? '',
      about: map['about'] ?? '',
      registrationNumber: map['registrationNumber'] ?? '',
      specialization: map['specialization'] ?? '',
      isOnlineOnly: map['isOnlineOnly'] ?? false,
      isCurrentlyAvailable: map['isCurrentlyAvailable'] ?? true,
      weeklyAvailability: List<DayAvailability>.from(
        map['weeklyAvailability']?.map((day) => DayAvailability.fromMap(day)) ?? [],
      ),
      lastUpdated: DateTime.parse(map['lastUpdated'] ?? DateTime.now().toIso8601String()),
      easypaisaNumber: map['easypaisaNumber'] ?? '',
      jazzcashNumber: map['jazzcashNumber'] ?? '',
      bankName: map['bankName'] ?? '',
      bankAccountNumber: map['bankAccountNumber'] ?? '',
      bankHolderName: map['bankHolderName'] ?? '',
    );
  }
}
