class DoctorVerificationModel {
  final String userId;
  final Map<String, dynamic> basicInfo;
  final Map<String, dynamic> professionalDetails;
  final Map<String, dynamic> documents;
  final String verificationStatus;
  final DateTime? submittedAt;
  final bool isVerified;

  DoctorVerificationModel({
    required this.userId,
    required this.basicInfo,
    required this.professionalDetails,
    required this.documents,
    required this.verificationStatus,
    this.submittedAt,
    required this.isVerified,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'basicInfo': basicInfo,
      'professionalDetails': professionalDetails,
      'documents': documents,
      'verificationStatus': verificationStatus,
      'submittedAt': submittedAt,
      'isVerified': isVerified,
    };
  }
}