import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/doctor_verification_controller.dart';

class DoctorVerificationPage extends StatefulWidget {
  const DoctorVerificationPage({super.key});

  @override
  State<DoctorVerificationPage> createState() => _DoctorVerificationPageState();
}

class _DoctorVerificationPageState extends State<DoctorVerificationPage> {
  final DoctorVerificationController controller =
      Get.put(DoctorVerificationController());

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
      body: Obx(() =>
          controller.isLoading.value ? _buildLoadingView() : _buildFormView()),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF199A8E), Color(0xFF17C3B2)],
                    ),
                  ),
                  child: const Icon(
                    Icons.cloud_upload,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 20),
                Obx(() => LinearProgressIndicator(
                      value: controller.uploadProgress.value,
                      backgroundColor: Colors.grey[300],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF199A8E)),
                    )),
                const SizedBox(height: 16),
                Obx(() => Text(
                      controller.loadingMessage.value,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF199A8E),
                      ),
                    )),
                const SizedBox(height: 8),
                Obx(() => Text(
                      'Step ${controller.currentStep.value} of ${controller.totalSteps}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    )),
                const SizedBox(height: 4),
                Obx(() => Text(
                      '${(controller.uploadProgress.value * 100).toInt()}% Complete',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormView() {
    return SingleChildScrollView(
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
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader("Basic Information", Icons.person),
                const SizedBox(height: 20),
                _buildTextField("Full Name", controller.fullNameController,
                    "Enter your full name as per official documents"),
                const SizedBox(height: 16),
                _buildTextField(
                    "Father's Name",
                    controller.fatherNameController,
                    "Enter your father's name"),
                const SizedBox(height: 16),
                _buildDateField("Date of Birth", controller.dobController),
                const SizedBox(height: 16),
                _buildGenderDropdown(),
                const SizedBox(height: 16),
                _buildTextField("Contact Number", controller.contactController,
                    "Enter your contact number", TextInputType.phone),
                const SizedBox(height: 16),
                _buildTextField("Email Address", controller.emailController,
                    "Enter your email address", TextInputType.emailAddress),
                const SizedBox(height: 16),
                _buildTextField(
                  "Current Address",
                  controller.addressController,
                  "Enter your current address",
                  TextInputType.multiline,
                ),
                const SizedBox(height: 35),
                _buildSectionHeader("Professional Details", Icons.work),
                const SizedBox(height: 20),
                _buildTextField(
                    "Professional Registration Number",
                    controller.registrationController,
                    "Enter your veterinary council registration number"),
                const SizedBox(height: 16),
                _buildTextField(
                    "Clinic / Hospital Name",
                    controller.clinicNameController,
                    "Enter clinic or hospital name"),
                const SizedBox(height: 16),
                _buildTextField(
                  "Clinic / Hospital Address",
                  controller.clinicAddressController,
                  "Enter clinic or hospital address",
                  TextInputType.multiline,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                    "Clinic / Hospital Contact",
                    controller.clinicContactController,
                    "Enter clinic or hospital contact number",
                    TextInputType.phone),
                const SizedBox(height: 16),
                _buildTextField(
                  "Specialization",
                  controller.specializationController,
                  "Enter your specialization (optional)",
                  TextInputType.text,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                    "Consultation Fee (Rs.)",
                    controller.consultationFeeController,
                    "Enter your consultation fee",
                    TextInputType.number),
                const SizedBox(height: 16),
                _buildTextField(
                    "Years of Experience",
                    controller.experienceController,
                    "Enter your years of experience",
                    TextInputType.number),
                const SizedBox(height: 16),
                _buildTextField("About You", controller.aboutController,
                    "Tell us about yourself", TextInputType.multiline, 4, true),
                const SizedBox(height: 35),
                _buildSectionHeader("Required Documents", Icons.folder),
                const SizedBox(height: 20),
                _buildProfilePictureUpload(),
                const SizedBox(height: 16),
                _buildDocumentUpload(
                    "Medical / Veterinary License", 'medical_license',
                    required: true),
                const SizedBox(height: 16),
                _buildDocumentUpload(
                    "Degree / Diploma Certificate", 'degree_certificate',
                    required: true),
                const SizedBox(height: 16),
                _buildDocumentUpload(
                    "Specialization Certificate", 'specialization_certificate'),
                const SizedBox(height: 16),
                _buildDocumentUpload("Government-issued ID", 'government_id',
                    required: true),
                const SizedBox(height: 16),
                _buildDocumentUpload("Clinic / Hospital Affiliation Letter",
                    'affiliation_letter'),
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
                    onPressed: () {
                      controller.submitVerificationRequest();
                    },
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
        Obx(() => DropdownButtonFormField<String>(
              value: controller.selectedGender.value.isEmpty
                  ? null
                  : controller.selectedGender.value,
              validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select gender';
            }
            return null;
          },
          onChanged: (value) {
            controller.selectedGender.value = value ?? '';
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
          items: controller.genders.map((gender) {
            return DropdownMenuItem<String>(
              value: gender,
              child: Text(gender),
            );
          }).toList(),
            )),
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
        GetBuilder<DoctorVerificationController>(
          builder: (controller) => GestureDetector(
            onTap: () async {
              await controller.pickProfilePicture();
            },
            child: Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                color: controller.profilePicture != null
                    ? Colors.green[50]
                    : Colors.grey[50],
                border: Border.all(
                  color: controller.profilePicture != null
                      ? Colors.green
                      : Colors.grey[300]!,
                  width: controller.profilePicture != null ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              //wqeqwesad
              child: controller.profilePicture != null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 32),
                        const SizedBox(height: 8),
                        Text(
                          "Profile Picture Selected",
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          controller.profilePicture!.name,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Tap to change",
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 11,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo,
                            color: Colors.grey[400], size: 32),
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
        ),
      ],
    );
  }

  Widget _buildDocumentUpload(String label, String documentType,
      {bool required = false}) {
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
        GetBuilder<DoctorVerificationController>(
          builder: (controller) {
            PlatformFile? document;
            switch (documentType) {
              case 'medical_license':
                document = controller.medicalLicense;
                break;
              case 'degree_certificate':
                document = controller.degreeCertificate;
                break;
              case 'specialization_certificate':
                document = controller.specializationCertificate;
                break;
              case 'government_id':
                document = controller.governmentId;
                break;
              case 'affiliation_letter':
                document = controller.affiliationLetter;
                break;
            }
            final isSelected = document != null;

            return GestureDetector(
              onTap: () async {
                await controller.pickDocument(documentType);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.green[50] : Colors.grey[50],
                  border: Border.all(
                    color: isSelected ? Colors.green : Colors.grey[300]!,
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected ? Icons.check_circle : Icons.upload_file,
                      color: isSelected ? Colors.green : Colors.grey[400],
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isSelected
                                ? "Document Selected"
                                : "Upload Document",
                            style: TextStyle(
                              color:
                                  isSelected ? Colors.green : Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isSelected
                                ? document!.name
                                : "PDF, JPG, PNG (Max 10MB)",
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.grey[600]
                                  : Colors.grey[400],
                              fontSize: 12,
                            ),
                          ),
                          if (isSelected) ...[
                            const SizedBox(height: 2),
                            Text(
                              "Tap to change",
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: isSelected ? Colors.green : Colors.grey[400],
                      size: 16,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}