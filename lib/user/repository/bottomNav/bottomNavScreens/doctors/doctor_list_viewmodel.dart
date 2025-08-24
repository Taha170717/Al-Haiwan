class Doctor {
  final String id;
  final String fullName;
  final String email;
  final String specialty;
  final String profileImageUrl;
  final String experience;
  final String clinicAddress; // Changed from location to clinicAddress
  final bool isVerified;
  final String phoneNumber;
  final String clinicName;
  final String registrationNumber;
  final String about;
  final double consultationFee;
  final List<String> availableDays;
  final List<String> availableTimeSlots;

  Doctor({
    required this.id,
    required this.fullName,
    required this.email,
    required this.specialty,
    required this.profileImageUrl,
    required this.experience,
    required this.clinicAddress, // Updated parameter name
    required this.isVerified,
    required this.phoneNumber,
    required this.clinicName,
    required this.registrationNumber,
    required this.about,
    required this.consultationFee,
    required this.availableDays,
    required this.availableTimeSlots, required String bio,
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
      consultationFee: _parseDouble(professionalDetails['consultationFee'] ?? 800),
      availableDays: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
      availableTimeSlots: ['08:00 AM', '10:00 AM', '11:00 AM', '01:00 PM', '02:00 PM', '03:00 PM', '04:00 PM', '07:00 PM', '08:00 PM'], bio: '',
    );
  }

  factory Doctor.fromFirestoreProfile(
      Map<String, dynamic> profileData,
      String id,
      Map<String, dynamic>? verificationData,
      Map<String, dynamic>? availabilityData,
      ) {
    String experience = '5+ years'; // default
    if (verificationData != null) {
      final professionalDetails = verificationData['professionalDetails'] as Map<String, dynamic>? ?? {};
      final expValue = professionalDetails['experience'];
      if (expValue != null) {
        experience = expValue.toString();
      }
    }

    // Extract availability from availability data
    List<String> availableDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    List<String> availableTimeSlots = ['08:00 AM', '10:00 AM', '11:00 AM', '01:00 PM', '02:00 PM', '03:00 PM', '04:00 PM', '07:00 PM', '08:00 PM'];

    if (availabilityData != null) {
      final days = availabilityData['availableDays'] as List<dynamic>?;
      if (days != null) {
        availableDays = days.map((day) => day.toString()).toList();
      }

      final slots = availabilityData['timeSlots'] as List<dynamic>?;
      if (slots != null) {
        availableTimeSlots = slots.map((slot) => slot.toString()).toList();
      }
    }

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
      consultationFee: _parseDouble(profileData['consultationFee'] ?? 800),
      availableDays: availableDays,
      availableTimeSlots: availableTimeSlots, bio: '',
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
    required super.consultationFee,
    required super.availableDays,
    required super.availableTimeSlots, required super.bio,
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
      consultationFee: doctor.consultationFee,
      availableDays: doctor.availableDays,
      availableTimeSlots: doctor.availableTimeSlots, bio: '',
    );
  }
}
