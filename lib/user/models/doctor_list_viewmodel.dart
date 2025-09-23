class Doctor {
  final String id;
  final String fullName;
  final String email;
  final String specialty;
  final String profileImageUrl;
  final String experience;
  final String clinicAddress;
  final bool isVerified;
  final String phoneNumber;
  final String clinicName;
  final String registrationNumber;
  final String about;
  final String bio; // Added bio field
  final double consultationFee;
  final List<String> availableDays;
  final List<String> availableTimeSlots;
  final String? bankAccountNumber;
  final String? bankName;
  final String? easyPaisaNumber;
  final String? jazzCashNumber;

  Doctor({
    required this.id,
    required this.fullName,
    required this.email,
    required this.specialty,
    required this.profileImageUrl,
    required this.experience,
    required this.clinicAddress,
    required this.isVerified,
    required this.phoneNumber,
    required this.clinicName,
    required this.registrationNumber,
    required this.about,
    required this.bio,
    required this.consultationFee,
    required this.availableDays,
    required this.availableTimeSlots,
    this.bankAccountNumber,
    this.bankName,
    this.easyPaisaNumber,
    this.jazzCashNumber,
  });

  factory Doctor.fromFirestore(Map<String, dynamic> data, String id) {
    final basicInfo = data['basicInfo'] as Map<String, dynamic>? ?? {};
    final professionalDetails = data['professionalDetails'] as Map<String, dynamic>? ?? {};
    final documents = data['documents'] as Map<String, dynamic>? ?? {};
    final verificationData = data['verificationData'] as Map<String, dynamic>? ?? {};

    String experience = '5+ years'; // default
    if (verificationData.isNotEmpty) {
      final profDetails = verificationData['professionalDetails'] as Map<String, dynamic>? ?? {};
      final expValue = profDetails['experience'];
      if (expValue != null) {
        experience = expValue.toString(); // Convert any type to string
      }
    } else {
      // Fallback to professionalDetails if verificationData is empty
      final expValue = professionalDetails['experience'];
      if (expValue != null) {
        experience = expValue.toString();
      }
    }

    return Doctor(
      id: id,
      fullName: (basicInfo['fullName'] ?? 'Unknown Doctor').toString(),
      email: (basicInfo['email'] ?? '').toString(),
      specialty: (professionalDetails['specialization'] ?? 'General Veterinarian').toString(),
      profileImageUrl: (documents['profilePicture'] ?? '').toString(),
      experience: experience,
      clinicAddress: (professionalDetails['clinicAddress'] ?? 'Unknown Location').toString(),
      isVerified: data['isVerified'] ?? false,
      phoneNumber: (basicInfo['contactNumber'] ?? '').toString(),
      clinicName: (professionalDetails['clinicName'] ?? '').toString(),
      registrationNumber: (professionalDetails['registrationNumber'] ?? '').toString(),
      about: (professionalDetails['about'] ?? 'Experienced veterinarian dedicated to providing quality care for your pets.').toString(),
      bio: (professionalDetails['bio'] ?? 'Professional veterinarian with years of experience.').toString(), // Added bio from doctor_profiles
      consultationFee: _parseDouble(professionalDetails['consultationFee'] ?? 800),
      availableDays: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
      availableTimeSlots: ['08:00 AM', '10:00 AM', '11:00 AM', '01:00 PM', '02:00 PM', '03:00 PM', '04:00 PM', '07:00 PM', '08:00 PM'],
      bankAccountNumber: basicInfo['bankAccountNumber']?.toString(),
      bankName: basicInfo['bankName']?.toString(),
      easyPaisaNumber: basicInfo['easyPaisaNumber']?.toString(),
      jazzCashNumber: basicInfo['jazzCashNumber']?.toString(),
    );
  }

  factory Doctor.fromFirestoreProfile(
      Map<String, dynamic> profileData,
      String id,
      Map<String, dynamic>? verificationData,
      Map<String, dynamic>? availabilityData,
      ) {
    String experience = '5+ years';
    if (verificationData != null) {
      final professionalDetails = verificationData['professionalDetails'] as Map<String, dynamic>? ?? {};
      final expValue = professionalDetails['experience'];
      if (expValue != null) {
        experience = expValue.toString();
      }
    }

    List<String> availableDays = [];
    List<String> availableTimeSlots = [];

    if (availabilityData != null) {
      final schedule = availabilityData['schedule'] as Map<String, dynamic>? ?? {};

      // Extract available days from schedule
      schedule.forEach((day, dayData) {
        if (dayData is Map<String, dynamic> && dayData['isAvailable'] == true) {
          availableDays.add(day);

          // Extract time slots for this day
          final slots = dayData['timeSlots'] as List<dynamic>? ?? [];
          for (var slot in slots) {
            if (slot is Map<String, dynamic> && slot['isAvailable'] == true) {
              String timeSlot = '${slot['startTime']} - ${slot['endTime']}';
              if (!availableTimeSlots.contains(timeSlot)) {
                availableTimeSlots.add(timeSlot);
              }
            }
          }
        }
      });
    }

    final paymentInfo = profileData['paymentInfo'] as Map<String, dynamic>? ?? {};

    return Doctor(
      id: id,
      fullName: (profileData['fullName'] ?? 'Unknown Doctor').toString(),
      email: (profileData['email'] ?? '').toString(),
      specialty: (profileData['specialization'] ?? 'General Veterinarian').toString(),
      profileImageUrl: (profileData['profileImageUrl'] ?? '').toString(),
      experience: experience,
      clinicAddress: (profileData['clinicAddress'] ?? 'Unknown Location').toString(),
      isVerified: profileData['isVerified'] ?? false,
      phoneNumber: (profileData['phoneNumber'] ?? '').toString(),
      clinicName: (profileData['clinicName'] ?? '').toString(),
      registrationNumber: (profileData['registrationNumber'] ?? '').toString(),
      about: (profileData['about'] ?? 'Experienced veterinarian dedicated to providing quality care for your pets.').toString(),
      bio: (profileData['bio'] ?? 'Professional veterinarian with years of experience.').toString(),
      consultationFee: _parseDouble(profileData['consultationFee'] ?? 800),
      availableDays: availableDays,
      availableTimeSlots: availableTimeSlots,
      bankAccountNumber: (paymentInfo['bankAccountNumber'] ??
          profileData['bankAccountNumber'] ??
          profileData['bankAccount'])?.toString(),
      bankName: (paymentInfo['bankName'] ??
          profileData['bankName'])?.toString(),
      easyPaisaNumber: (paymentInfo['easyPaisaNumber'] ??
          profileData['easyPaisaNumber'] ??
          profileData['easypaisa'])?.toString(),
      jazzCashNumber: (paymentInfo['jazzCashNumber'] ??
          profileData['jazzCashNumber'] ??
          profileData['jazzcash'])?.toString(),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 800.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 800.0;
    return 800.0;
  }

  // Backward compatibility getters
  String get name => fullName;
  String get location => clinicAddress; // Map old location to clinicAddress
}

// Keep the old DoctorModel for backward compatibility
class DoctorModel extends Doctor {
  DoctorModel({
    required super.id,
    required super.fullName,
    required super.email,
    required super.specialty,
    required super.profileImageUrl,
    required super.experience,
    required super.clinicAddress,
    required super.isVerified,
    required super.phoneNumber,
    required super.clinicName,
    required super.registrationNumber,
    required super.about,
    required super.bio,
    required super.consultationFee,
    required super.availableDays,
    required super.availableTimeSlots,
    super.bankAccountNumber,
    super.bankName,
    super.easyPaisaNumber,
    super.jazzCashNumber,
  });

  factory DoctorModel.fromFirestore(Map<String, dynamic> data, String id) {
    final doctor = Doctor.fromFirestore(data, id);
    return DoctorModel(
      id: doctor.id,
      fullName: doctor.fullName,
      email: doctor.email,
      specialty: doctor.specialty,
      profileImageUrl: doctor.profileImageUrl,
      experience: doctor.experience,
      clinicAddress: doctor.clinicAddress,
      isVerified: doctor.isVerified,
      phoneNumber: doctor.phoneNumber,
      clinicName: doctor.clinicName,
      registrationNumber: doctor.registrationNumber,
      about: doctor.about,
      bio: doctor.bio,
      consultationFee: doctor.consultationFee,
      availableDays: doctor.availableDays,
      availableTimeSlots: doctor.availableTimeSlots,
      bankAccountNumber: doctor.bankAccountNumber,
      bankName: doctor.bankName,
      easyPaisaNumber: doctor.easyPaisaNumber,
      jazzCashNumber: doctor.jazzCashNumber,
    );
  }
}
