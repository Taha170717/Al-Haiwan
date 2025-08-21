import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
///abch
class DoctorVerificationPage extends StatefulWidget {
  const DoctorVerificationPage({super.key});

  @override
  State<DoctorVerificationPage> createState() => _DoctorVerificationPageState();
}

class _DoctorVerificationPageState extends State<DoctorVerificationPage> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  String loadingMessage = '';
  double uploadProgress = 0.0;
  int currentStep = 0;
  int totalSteps = 6;

  // Basic Information Controllers
  final fullNameController = TextEditingController();
  final fatherNameController = TextEditingController();
  final dobController = TextEditingController();
  final contactController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();

  // Professional Details Controllers
  final registrationController = TextEditingController();
  final clinicNameController = TextEditingController();
  final clinicAddressController = TextEditingController();
  final clinicContactController = TextEditingController();
  final specializationController = TextEditingController();
  final experienceController = TextEditingController();
  final aboutController = TextEditingController();
  final consultationFeeController = TextEditingController();

  // Gender Selection
  String selectedGender = '';
  final List<String> genders = ['Male', 'Female', 'Other'];

  // Document Upload Variables
  XFile? profilePicture;
  PlatformFile? medicalLicense;
  PlatformFile? degreeCertificate;
  PlatformFile? specializationCertificate;
  PlatformFile? governmentId;
  PlatformFile? affiliationLetter;

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
  }

  void _loadUserEmail() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      emailController.text = user.email ?? '';
    }
  }

  Future<void> _pickProfilePicture() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );
      if (pickedFile != null) {
        setState(() {
          profilePicture = pickedFile;
        });
      }
    } catch (e) {
      _showErrorSnackbar('Failed to pick profile picture: ${e.toString()}');
    }
  }

  Future<void> _pickDocument(String documentType) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result != null) {
        setState(() {
          switch (documentType) {
            case 'medical_license':
              medicalLicense = result.files.first;
              break;
            case 'degree_certificate':
              degreeCertificate = result.files.first;
              break;
            case 'specialization_certificate':
              specializationCertificate = result.files.first;
              break;
            case 'government_id':
              governmentId = result.files.first;
              break;
            case 'affiliation_letter':
              affiliationLetter = result.files.first;
              break;
          }
        });
      }
    } catch (e) {
      _showErrorSnackbar('Failed to pick document: ${e.toString()}');
    }
  }

  Future<String?> _uploadFile(dynamic file, String folder, String fileName) async {
    try {
      final storage = FirebaseStorage.instance;
      final ref = storage.ref().child('doctor_verification/$folder/$fileName');

      if (file is XFile) {
        // Handle image file
        if (kIsWeb) {
          final bytes = await file.readAsBytes();
          await ref.putData(bytes);
        } else {
          await ref.putFile(File(file.path));
        }
      } else if (file is PlatformFile) {
        // Handle document file
        if (kIsWeb && file.bytes != null) {
          await ref.putData(file.bytes!);
        } else if (file.path != null) {
          await ref.putFile(File(file.path!));
        }
      }

      return await ref.getDownloadURL();
    } catch (e) {
      print('Error uploading file: $e');
      return null;
    }
  }

  Future<void> _submitVerificationRequest() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedGender.isEmpty) {
      _showErrorSnackbar('Please select gender');
      return;
    }

    if (profilePicture == null || medicalLicense == null ||
        degreeCertificate == null || governmentId == null) {
      _showErrorSnackbar('Please upload all required documents');
      return;
    }

    setState(() {
      isLoading = true;
      currentStep = 0;
      uploadProgress = 0.0;
      loadingMessage = 'Preparing verification request...';
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final userId = user.uid;
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      setState(() {
        currentStep = 1;
        uploadProgress = 0.17;
        loadingMessage = 'Uploading profile picture...';
      });
      final profilePictureUrl = await _uploadFile(
          profilePicture, 'profile_pictures', '${userId}_profile_$timestamp.jpg'
      );

      setState(() {
        currentStep = 2;
        uploadProgress = 0.33;
        loadingMessage = 'Uploading medical license...';
      });
      final medicalLicenseUrl = await _uploadFile(
          medicalLicense, 'medical_licenses', '${userId}_license_$timestamp'
      );

      setState(() {
        currentStep = 3;
        uploadProgress = 0.50;
        loadingMessage = 'Uploading degree certificate...';
      });
      final degreeCertificateUrl = await _uploadFile(
          degreeCertificate, 'degree_certificates', '${userId}_degree_$timestamp'
      );

      setState(() {
        currentStep = 4;
        uploadProgress = 0.67;
        loadingMessage = 'Uploading government ID...';
      });
      final governmentIdUrl = await _uploadFile(
          governmentId, 'government_ids', '${userId}_id_$timestamp'
      );

      String? specializationCertificateUrl;
      if (specializationCertificate != null) {
        setState(() {
          loadingMessage = 'Uploading specialization certificate...';
        });
        specializationCertificateUrl = await _uploadFile(
            specializationCertificate, 'specialization_certificates', '${userId}_specialization_$timestamp'
        );
      }

      String? affiliationLetterUrl;
      if (affiliationLetter != null) {
        setState(() {
          loadingMessage = 'Uploading affiliation letter...';
        });
        affiliationLetterUrl = await _uploadFile(
            affiliationLetter, 'affiliation_letters', '${userId}_affiliation_$timestamp'
        );
      }

      setState(() {
        currentStep = 5;
        uploadProgress = 0.83;
        loadingMessage = 'Saving verification data...';
      });

      // Create verification request document
      final verificationData = {
        'userId': userId,
        'basicInfo': {
          'fullName': fullNameController.text.trim(),
          'fatherName': fatherNameController.text.trim(),
          'dateOfBirth': dobController.text.trim(),
          'gender': selectedGender,
          'contactNumber': contactController.text.trim(),
          'email': emailController.text.trim(),
          'currentAddress': addressController.text.trim(),
        },
        'professionalDetails': {
          'registrationNumber': registrationController.text.trim(),
          'clinicName': clinicNameController.text.trim(),
          'clinicAddress': clinicAddressController.text.trim(),
          'clinicContact': clinicContactController.text.trim(),
          'specialization': specializationController.text.trim(),
          'consultationFee': consultationFeeController.text.trim(),
          'experience': experienceController.text.trim(),
          'about': aboutController.text.trim(),
        },
        'documents': {
          'profilePicture': profilePictureUrl,
          'medicalLicense': medicalLicenseUrl,
          'degreeCertificate': degreeCertificateUrl,
          'governmentId': governmentIdUrl,
          'specializationCertificate': specializationCertificateUrl,
          'affiliationLetter': affiliationLetterUrl,
        },
        'verificationStatus': 'pending',
        'submittedAt': FieldValue.serverTimestamp(),
        'isVerified': false,
      };

      // Save to Firestore
      await FirebaseFirestore.instance
          .collection('doctor_verification_requests')
          .doc(userId)
          .set(verificationData);

      // Update user document
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({
        'verificationStatus': 'pending',
        'verificationSubmittedAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        currentStep = 6;
        uploadProgress = 1.0;
        loadingMessage = 'Verification request submitted successfully!';
      });

      await Future.delayed(const Duration(milliseconds: 500));
      _showSuccessDialog();

    } catch (e) {
      _showErrorSnackbar('Failed to submit verification: ${e.toString()}');
    } finally {
      setState(() {
        isLoading = false;
        uploadProgress = 0.0;
        currentStep = 0;
        loadingMessage = '';
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFEFF9F8),
                ),
                child: const Icon(Icons.check_circle, color: Color(0xFF199A8E), size: 32),
              ),
              const SizedBox(height: 20),
              const Text(
                "Verification Request Submitted!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Your verification request has been submitted successfully. Admin will review your documents and approve your account within 24-48 hours.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF199A8E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text("OK", style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      "Error",
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Doctor Verification",
          style: TextStyle(
            color: Color(0xFF199A8E),
            fontFamily: "bolditalic",
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF199A8E)),
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF199A8E), Color(0xFF17C3B2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF199A8E).withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.verified_user,
                        color: Colors.white,
                        size: 40,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Complete Your Verification",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Please fill out all required information to get your account verified by our admin team.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader("Basic Information", Icons.person),
                      const SizedBox(height: 20),
                      _buildTextField("Full Name", fullNameController, "Enter your full name as per official documents"),
                      const SizedBox(height: 16),
                      _buildTextField("Father's Name", fatherNameController, "Enter your father's name"),
                      const SizedBox(height: 16),
                      _buildDateField("Date of Birth", dobController),
                      const SizedBox(height: 16),
                      _buildGenderDropdown(),
                      const SizedBox(height: 16),
                      _buildTextField("Contact Number", contactController, "Enter your contact number", TextInputType.phone),
                      const SizedBox(height: 16),
                      _buildTextField("Email Address", emailController, "Enter your email address", TextInputType.emailAddress),
                      const SizedBox(height: 16),
                      _buildTextField("Current Address", addressController, "Enter your current address", TextInputType.multiline,),

                      const SizedBox(height: 35),
                      _buildSectionHeader("Professional Details", Icons.work),
                      const SizedBox(height: 20),
                      _buildTextField("Professional Registration Number", registrationController, "Enter your veterinary council registration number"),
                      const SizedBox(height: 16),
                      _buildTextField("Clinic / Hospital Name", clinicNameController, "Enter clinic or hospital name"),
                      const SizedBox(height: 16),
                      _buildTextField("Clinic / Hospital Address", clinicAddressController, "Enter clinic or hospital address", TextInputType.multiline, ),
                      const SizedBox(height: 16),
                      _buildTextField("Clinic / Hospital Contact", clinicContactController, "Enter clinic or hospital contact number", TextInputType.phone),
                      const SizedBox(height: 16),
                      _buildTextField("Specialization", specializationController, "Enter your specialization (optional)", TextInputType.text, ),
                      const SizedBox(height: 16),
                      _buildTextField(
                          "Consultation Fee (Rs.)",
                          consultationFeeController,
                          "Enter your consultation fee",
                          TextInputType.number),
                      const SizedBox(height: 16),
                      _buildTextField(
                          "Years of Experience",
                          experienceController,
                          "Enter your years of experience",
                          TextInputType.number),
                      const SizedBox(height: 16),
                      _buildTextField(
                          "About You",
                          aboutController,
                          "Tell us about yourself",
                          TextInputType.multiline,
                          4,
                          true),
                      const SizedBox(height: 35),
                      _buildSectionHeader("Required Documents", Icons.folder),
                      const SizedBox(height: 20),
                      _buildProfilePictureUpload(),
                      const SizedBox(height: 16),
                      _buildDocumentUpload("Medical / Veterinary License", medicalLicense, 'medical_license', required: true),
                      const SizedBox(height: 16),
                      _buildDocumentUpload("Degree / Diploma Certificate", degreeCertificate, 'degree_certificate', required: true),
                      const SizedBox(height: 16),
                      _buildDocumentUpload("Specialization Certificate", specializationCertificate, 'specialization_certificate'),
                      const SizedBox(height: 16),
                      _buildDocumentUpload("Government-issued ID", governmentId, 'government_id', required: true),
                      const SizedBox(height: 16),
                      _buildDocumentUpload("Clinic / Hospital Affiliation Letter", affiliationLetter, 'affiliation_letter'),

                      const SizedBox(height: 50),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF199A8E), Color(0xFF17C3B2)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.4),
                              blurRadius: 15,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _submitVerificationRequest,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 18),
                          ),
                          child: const Text(
                            "Submit Verification Request",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: Center(
                child: Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 80,
                            height: 80,
                            child: CircularProgressIndicator(
                              value: uploadProgress,
                              strokeWidth: 6,
                              backgroundColor: Colors.grey[200],
                              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF199A8E)),
                            ),
                          ),
                          Text(
                            '${(uploadProgress * 100).toInt()}%',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF199A8E),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        loadingMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Step $currentStep of $totalSteps',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(totalSteps, (index) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: index < currentStep
                                  ? const Color(0xFF199A8E)
                                  : Colors.grey[300],
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF199A8E).withOpacity(0.1),
            const Color(0xFF17C3B2).withOpacity(0.05),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF199A8E).withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFF199A8E),
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF199A8E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, String hint,
      [TextInputType keyboardType = TextInputType.text, int maxLines = 1, bool required = true]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            children: required ? [
              const TextSpan(
                text: ' *',
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
            ] : [],
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: required ? (value) {
            if (value == null || value.trim().isEmpty) {
              return 'This field is required';
            }
            return null;
          } : null,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF199A8E), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
            text: "Date of Birth",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            children: [
              TextSpan(
                text: ' *',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: true,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Date of birth is required';
            }
            return null;
          },
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now().subtract(const Duration(days: 365 * 25)),
              firstDate: DateTime(1950),
              lastDate: DateTime.now(),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: Color(0xFF199A8E),
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (date != null) {
              controller.text = "${date.day}/${date.month}/${date.year}";
            }
          },
          decoration: InputDecoration(
            hintText: "Select your date of birth",
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.grey[50],
            suffixIcon: const Icon(Icons.calendar_today, color: Color(0xFF199A8E)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF199A8E), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
            text: "Gender",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            children: [
              TextSpan(
                text: ' *',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedGender.isEmpty ? null : selectedGender,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select gender';
            }
            return null;
          },
          onChanged: (value) {
            setState(() {
              selectedGender = value ?? '';
            });
          },
          decoration: InputDecoration(
            hintText: "Select gender",
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF199A8E), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          items: genders.map((gender) {
            return DropdownMenuItem<String>(
              value: gender,
              child: Text(gender),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildProfilePictureUpload() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
            text: "Profile Picture (Passport Style)",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            children: [
              TextSpan(
                text: ' *',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickProfilePicture,
          child: Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border.all(
                color: profilePicture != null ? const Color(0xFF199A8E) : Colors.grey[300]!,
                width: profilePicture != null ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: profilePicture != null
                ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, color: Color(0xFF199A8E), size: 32),
                const SizedBox(height: 8),
                Text(
                  "Profile picture selected",
                  style: TextStyle(
                    color: const Color(0xFF199A8E),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Tap to change",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            )
                : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_a_photo, color: Colors.grey[400], size: 32),
                const SizedBox(height: 8),
                Text(
                  "Upload Profile Picture",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "JPG, PNG (Max 5MB)",
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentUpload(String label, PlatformFile? file, String documentType, {bool required = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            children: required ? [
              const TextSpan(
                text: ' *',
                style: TextStyle(color: Colors.red),
              ),
            ] : [],
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _pickDocument(documentType),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border.all(
                color: file != null ? const Color(0xFF199A8E) : Colors.grey[300]!,
                width: file != null ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  file != null ? Icons.check_circle : Icons.upload_file,
                  color: file != null ? const Color(0xFF199A8E) : Colors.grey[400],
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        file != null ? file!.name : "Upload Document",
                        style: TextStyle(
                          color: file != null ? const Color(0xFF199A8E) : Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        file != null ? "Tap to change" : "PDF, JPG, PNG (Max 10MB)",
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[400],
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    fullNameController.dispose();
    fatherNameController.dispose();
    dobController.dispose();
    contactController.dispose();
    emailController.dispose();
    addressController.dispose();
    registrationController.dispose();
    clinicNameController.dispose();
    clinicAddressController.dispose();
    clinicContactController.dispose();
    specializationController.dispose();
    consultationFeeController.dispose();
    experienceController.dispose();
    aboutController.dispose();
    super.dispose();
  }
}
