class Doctor {
  final String id;
  final String fullName;
  final String email;
  final String specialty;
  final String profileImageUrl;
  final double rating;
  final String experience;
  final String location;
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
    required this.rating,
    required this.experience,
    required this.location,
    required this.isVerified,
    required this.phoneNumber,
    required this.clinicName,
    required this.registrationNumber,
    required this.about,
    required this.consultationFee,
    required this.availableDays,
    required this.availableTimeSlots, required String name,
  });

  factory Doctor.fromFirestore(Map<String, dynamic> data, String id) {
    final basicInfo = data['basicInfo'] as Map<String, dynamic>? ?? {};
    final professionalDetails = data['professionalDetails'] as Map<String, dynamic>? ?? {};
    final documents = data['documents'] as Map<String, dynamic>? ?? {};

    return Doctor(
      id: id,
      fullName: basicInfo['fullName'] ?? 'Unknown Doctor',
      email: basicInfo['email'] ?? '',
      specialty: professionalDetails['specialization'] ?? 'General Veterinarian',
      profileImageUrl: documents['profilePicture'] ?? '',
      rating: 4.5, // Default rating since not in verification data
      experience: '5+ years', // Default experience
      location: professionalDetails['clinicAddress'] ?? 'Unknown Location',
      isVerified: data['isVerified'] ?? false,
      phoneNumber: basicInfo['contactNumber'] ?? '',
      clinicName: professionalDetails['clinicName'] ?? '',
      registrationNumber: professionalDetails['registrationNumber'] ?? '',
      about: 'Experienced veterinarian dedicated to providing quality care for your pets.',
      consultationFee: 800.0, // Default consultation fee
      availableDays: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
      availableTimeSlots: ['08:00 AM', '10:00 AM', '11:00 AM', '01:00 PM', '02:00 PM', '03:00 PM', '04:00 PM', '07:00 PM', '08:00 PM'], name: '',
    );
  }

  // Backward compatibility getter
  String get name => fullName;
}

