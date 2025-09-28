import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../../doctor/models/doctor_availability_model.dart';
import '../../../../controllers/appointment_controller.dart';
import '../../../../models/user_appointment_model.dart';
import '../../../../models/doctor_detail_viewmodel.dart' hide DoctorProfile;
import '../../../../models/doctor_list_viewmodel.dart';
import '../../bottomNavScreen.dart';
import '../../../../../utils/snackbar_utils.dart';

enum PaymentMethod { EasyPaisa, JazzCash, BankAccount }

class AppointmentSummaryView extends StatefulWidget {
  final Doctor doctor;
  final DoctorProfile? doctorProfile;

  AppointmentSummaryView({required this.doctor, this.doctorProfile});

  @override
  _AppointmentSummaryViewState createState() => _AppointmentSummaryViewState();
}

class _AppointmentSummaryViewState extends State<AppointmentSummaryView> {
  final reasonController = TextEditingController();
  final ownerNameController = TextEditingController();
  final petNameController = TextEditingController();

  Rx<PaymentMethod> selectedPaymentMethod = PaymentMethod.EasyPaisa.obs;
  double consultationFee = 800;

  late AppointmentController appointmentController;
  late DoctorDetailViewModel detailVM;

  RxString selectedAnimalType = 'Dog'.obs;

  @override
  void initState() {
    super.initState();
    consultationFee = widget.doctorProfile?.consultationFee ?? widget.doctor.consultationFee;
    appointmentController = Get.put(AppointmentController());
    detailVM = Get.find<DoctorDetailViewModel>();

    if (widget.doctorProfile == null) {
      detailVM.fetchDoctorProfile(widget.doctor.id);
    }
  }

  @override
  void dispose() {
    reasonController.dispose();
    ownerNameController.dispose();
    petNameController.dispose();
    super.dispose();
  }

  Widget _paymentRow(String title, String value, {bool isBold = false}) {
    final screen = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: screen.height * 0.005),
      child: Row(
        children: [
          Text(
              title,
              style: TextStyle(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  fontSize: screen.width * 0.035
              )
          ),
          Spacer(),
          Text(
              value,
              style: TextStyle(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  fontSize: screen.width * 0.035
              )
          ),
        ],
      ),
    );
  }

  Widget _buildOwnerPetFields(Size screen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Consultation Type", style: TextStyle(fontWeight: FontWeight.bold, fontSize: screen.width * 0.035)),
        SizedBox(height: screen.height * 0.02),

        // Consultation Type Selector
        Obx(() => Column(
          children: [
            _buildConsultationOption(screen, ConsultationType.pet, "Pet", Icons.pets),
            _buildConsultationOption(screen, ConsultationType.livestock, "Livestock", Icons.agriculture),
            _buildConsultationOption(screen, ConsultationType.poultry, "Poultry", Icons.egg),
          ],
        )),

        SizedBox(height: screen.height * 0.02),

        // Owner Name (always shown)
        TextField(
          controller: ownerNameController,
          decoration: InputDecoration(
            labelText: "Owner Name *",
            hintText: "Enter owner's full name",
            hintStyle: TextStyle(fontSize: screen.width * 0.032),
            fillColor: Colors.grey[100],
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(screen.width * 0.03),
              borderSide: BorderSide.none,
            ),
            prefixIcon: Icon(Icons.person, color: Color(0xFF199A8E)),
          ),
        ),

        SizedBox(height: screen.height * 0.015),

        // Dynamic fields based on consultation type
        Obx(() => _buildDynamicFields(screen)),
      ],
    );
  }

  Widget _buildConsultationOption(Size screen, ConsultationType type, String title, IconData icon) {
    return Container(
      margin: EdgeInsets.only(bottom: screen.height * 0.01),
      decoration: BoxDecoration(
        border: Border.all(
          color: appointmentController.consultationType.value == type
              ? Color(0xFF199A8E)
              : Colors.grey[300]!,
          width: appointmentController.consultationType.value == type ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(screen.width * 0.03),
      ),
      child: RadioListTile<ConsultationType>(
        value: type,
        groupValue: appointmentController.consultationType.value,
        onChanged: (ConsultationType? value) {
          if (value != null) {
            appointmentController.consultationType.value = value;
          }
        },
        title: Row(
          children: [
            Icon(icon, color: Color(0xFF199A8E), size: screen.width * 0.05),
            SizedBox(width: screen.width * 0.03),
            Text(title, style: TextStyle(fontSize: screen.width * 0.035)),
          ],
        ),
        activeColor: Color(0xFF199A8E),
      ),
    );
  }

  Widget _buildDynamicFields(Size screen) {
    switch (appointmentController.consultationType.value) {
      case ConsultationType.pet:
        return Column(
          children: [
            // Pet Type Dropdown
            DropdownButtonFormField<String>(
              value: appointmentController.petType.value.isEmpty ? null : appointmentController.petType.value,
              items: appointmentController.petTypes
                  .map((type) => DropdownMenuItem(
                value: type,
                child: Text(type, style: TextStyle(fontSize: screen.width * 0.032)),
              ))
                  .toList(),
              onChanged: (val) {
                if (val != null) appointmentController.petType.value = val;
              },
              decoration: InputDecoration(
                labelText: "Pet Type *",
                fillColor: Colors.grey[100],
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(screen.width * 0.03),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(Icons.pets, color: Color(0xFF199A8E)),
              ),
            ),
            SizedBox(height: screen.height * 0.015),
            // Pet Name
            TextField(
              controller: petNameController,
              decoration: InputDecoration(
                labelText: "Pet Name *",
                hintText: "Enter pet's name",
                hintStyle: TextStyle(fontSize: screen.width * 0.032),
                fillColor: Colors.grey[100],
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(screen.width * 0.03),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(Icons.pets, color: Color(0xFF199A8E)),
              ),
            ),
          ],
        );

      case ConsultationType.livestock:
      case ConsultationType.poultry:
        return Column(
          children: [
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Number of ${appointmentController.consultationType.value.name.capitalize} *",
                hintText: "Enter number of animals",
                hintStyle: TextStyle(fontSize: screen.width * 0.032),
                fillColor: Colors.grey[100],
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(screen.width * 0.03),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(Icons.numbers, color: Color(0xFF199A8E)),
              ),
              onChanged: (value) {
                appointmentController.numberOfPatients.value = int.tryParse(value) ?? 1;
              },
            ),
          ],
        );
    }
  }


  Widget _buildPaymentMethodSelector(Size screen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Select Payment Method", style: TextStyle(fontWeight: FontWeight.bold, fontSize: screen.width * 0.035)),
        SizedBox(height: screen.height * 0.02),

        _buildPaymentOption(
          screen,
          PaymentMethod.EasyPaisa,
          "EasyPaisa",
          Icons.phone_android,
          Colors.green,
        ),
        _buildPaymentOption(
          screen,
          PaymentMethod.JazzCash,
          "JazzCash",
          Icons.phone_android,
          Colors.red,
        ),
        _buildPaymentOption(
          screen,
          PaymentMethod.BankAccount,
          "Bank Account",
          Icons.account_balance,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildPaymentOption(Size screen, PaymentMethod method, String title, IconData icon, Color color) {
    return Container(
      margin: EdgeInsets.only(bottom: screen.height * 0.01),
      decoration: BoxDecoration(
        border: Border.all(
          color: selectedPaymentMethod.value == method
              ? Color(0xFF199A8E)
              : Colors.grey[300]!,
          width: selectedPaymentMethod.value == method ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(screen.width * 0.03),
      ),
      child: CheckboxListTile(
        value: selectedPaymentMethod.value == method,
        onChanged: (bool? value) {
          if (value == true) {
            selectedPaymentMethod.value = method;
          }
        },
        title: Row(
          children: [
            Icon(icon, color: color, size: screen.width * 0.05),
            SizedBox(width: screen.width * 0.03),
            Text(title, style: TextStyle(fontSize: screen.width * 0.035)),
            Text(title, style: TextStyle(fontSize: screen.width * 0.035)),
          ],
        ),
        activeColor: Color(0xFF199A8E),
        controlAffinity: ListTileControlAffinity.trailing,
      ),
    );
  }

  Widget _buildPaymentInputFields(Size screen) {
    switch (selectedPaymentMethod.value) {
      case PaymentMethod.EasyPaisa:
        String easyPaisaNumber = _getPaymentDetail('easyPaisa');
        return _buildDoctorPaymentDetails(
          screen,
          "EasyPaisa Number",
          easyPaisaNumber,
          Icons.phone_android,
          Colors.green,
        );

      case PaymentMethod.JazzCash:
        String jazzCashNumber = _getPaymentDetail('jazzCash');
        return _buildDoctorPaymentDetails(
          screen,
          "JazzCash Number",
          jazzCashNumber,
          Icons.phone_android,
          Colors.red,
        );

      case PaymentMethod.BankAccount:
        String bankName = _getPaymentDetail('bankName');
        String bankAccount = _getPaymentDetail('bankAccount');
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDoctorPaymentDetails(
              screen,
              "Bank Name",
              bankName,
              Icons.account_balance,
              Colors.purple,
            ),
            SizedBox(height: screen.height * 0.02),
            _buildDoctorPaymentDetails(
              screen,
              "Account Number",
              bankAccount,
              Icons.account_balance_wallet,
              Colors.purple,
            ),
          ],
        );
    }
  }

  String _getPaymentDetail(String type) {
    String value = "Not Available";

    // First try to get from doctorProfile (from doctor_profiles collection)
    if (widget.doctorProfile != null) {
      switch (type) {
        case 'easyPaisa':
          value = widget.doctorProfile!.easypaisaNumber ?? value;
          break;
        case 'jazzCash':
          value = widget.doctorProfile!.jazzcashNumber ?? value;
          break;
        case 'bankName':
          value = widget.doctorProfile!.bankName ?? value;
          break;
        case 'bankAccount':
          value = widget.doctorProfile!.bankAccountNumber ?? value;
          break;
      }
    }

    // If still not available, try from doctor (from doctor_verification_requests)
    if (value == "Not Available") {
      switch (type) {
        case 'easyPaisa':
          value = widget.doctor.easyPaisaNumber ?? value;
          break;
        case 'jazzCash':
          value = widget.doctor.jazzCashNumber ?? value;
          break;
        case 'bankName':
          value = widget.doctor.bankName ?? value;
          break;
        case 'bankAccount':
          value = widget.doctor.bankAccountNumber ?? value;
          break;
      }
    }

    // If still not available, try from reactive doctorProfile
    if (value == "Not Available" && detailVM.doctorProfile.value != null) {
      switch (type) {
        case 'easyPaisa':
          value = detailVM.doctorProfile.value!.easypaisaNumber ?? value;
          break;
        case 'jazzCash':
          value = detailVM.doctorProfile.value!.jazzcashNumber ?? value;
          break;
        case 'bankName':
          value = detailVM.doctorProfile.value!.bankName ?? value;
          break;
        case 'bankAccount':
          value = detailVM.doctorProfile.value!.bankAccountNumber ?? value;
          break;
      }
    }

    return value;
  }

  Widget _buildDoctorPaymentDetails(Size screen, String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(screen.width * 0.04),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(screen.width * 0.03),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: screen.width * 0.035,
            color: color,
          )),
          SizedBox(height: screen.height * 0.01),
          Row(
            children: [
              Icon(icon, color: color, size: screen.width * 0.05),
              SizedBox(width: screen.width * 0.03),
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: screen.width * 0.04,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: value));
                  SnackbarUtils.showCopied(title);
                },
                icon: Icon(Icons.copy, color: color),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScreenshotUpload(Size screen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text("Payment Screenshot",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: screen.width * 0.035)),
            Text(" *",
                style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: screen.width * 0.035)),
            Spacer(),
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: screen.width * 0.02,
                  vertical: screen.height * 0.005),
              decoration: BoxDecoration(
                color: Color(0xFF199A8E).withOpacity(0.1),
                borderRadius: BorderRadius.circular(screen.width * 0.02),
              ),
              child: Text(
                "Required",
                style: TextStyle(
                  color: Color(0xFF199A8E),
                  fontSize: screen.width * 0.03,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: screen.height * 0.01),
        Text(
          "Upload a clear screenshot of your payment confirmation",
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: screen.width * 0.032,
          ),
        ),
        SizedBox(height: screen.height * 0.015),
        Container(
          width: double.infinity,
          height: screen.height * 0.2,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(screen.width * 0.03),
            color: Colors.grey[50],
          ),
          child: Obx(() {
            final hasScreenshot =
                appointmentController.paymentScreenshotPath.value.isNotEmpty;

            return hasScreenshot
                ? Stack(
                    children: [
                      ClipRRect(
                        borderRadius:
                            BorderRadius.circular(screen.width * 0.03),
                        child: _buildImagePreview(screen),
                      ),
                      // Delete button
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () {
                            appointmentController.clearPaymentScreenshot();
                          },
                          child: Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(Icons.close,
                                color: Colors.white, size: 18),
                          ),
                        ),
                      ),
                      // Platform indicator
                      Positioned(
                        bottom: 8,
                        left: 8,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: screen.width * 0.02,
                              vertical: screen.height * 0.005),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius:
                                BorderRadius.circular(screen.width * 0.02),
                          ),
                          child: Text(
                            kIsWeb ? "Web Upload" : "Mobile Upload",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: screen.width * 0.025,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : GestureDetector(
                    onTap: () => appointmentController.pickPaymentScreenshot(),
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.all(screen.width * 0.04),
                            decoration: BoxDecoration(
                              color: Color(0xFF199A8E).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                                kIsWeb ? Icons.upload_file : Icons.camera_alt,
                                size: screen.width * 0.08,
                                color: Color(0xFF199A8E)),
                          ),
                          SizedBox(height: screen.height * 0.015),
                          Text(
                            kIsWeb
                                ? "Click to Upload Screenshot"
                                : "Tap to Select from Gallery",
                            style: TextStyle(
                              color: Color(0xFF199A8E),
                              fontSize: screen.width * 0.037,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: screen.height * 0.008),
                          Text(
                            kIsWeb
                                ? "Supports JPG, PNG • Max 5MB"
                                : "From Gallery or Camera • Max 5MB",
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: screen.width * 0.032,
                            ),
                          ),
                          SizedBox(height: screen.height * 0.015),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: screen.width * 0.04,
                                vertical: screen.height * 0.008),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Color(0xFF199A8E).withOpacity(0.3)),
                              borderRadius:
                                  BorderRadius.circular(screen.width * 0.02),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  size: screen.width * 0.035,
                                  color: Color(0xFF199A8E),
                                ),
                                SizedBox(width: screen.width * 0.02),
                                Text(
                                  "Clear payment proof required",
                                  style: TextStyle(
                                    color: Color(0xFF199A8E),
                                    fontSize: screen.width * 0.03,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
          }),
        ),
      ],
    );
  }

  Widget _buildImagePreview(Size screen) {
    if (kIsWeb) {
      // Web platform: use bytes for preview
      final bytes = appointmentController.paymentScreenshotBytes.value;
      if (bytes != null && bytes.isNotEmpty) {
        return Image.memory(
          bytes,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print('Error displaying web image: $error');
            return Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.grey[300],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error,
                      color: Colors.red, size: screen.width * 0.06),
                  SizedBox(height: 8),
                  Text(
                    "Error loading image",
                    style: TextStyle(fontSize: 14, color: Colors.red),
                  ),
                  Text(
                    "Please try selecting again",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            );
          },
        );
      } else {
        // Fallback for web when bytes are not available but path exists
        final path = appointmentController.paymentScreenshotPath.value;
        if (path.isNotEmpty) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.green[50],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle,
                    color: Colors.green, size: screen.width * 0.06),
                SizedBox(height: 8),
                Text(
                  "Image selected successfully",
                  style: TextStyle(fontSize: 14, color: Colors.green),
                ),
                Text(
                  "Ready to upload",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          );
        }
      }
    } else {
      // Mobile platform: use File for preview
      final path = appointmentController.paymentScreenshotPath.value;
      if (path.isNotEmpty) {
        return Image.file(
          File(path),
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print('Error displaying mobile image: $error');
            return Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.grey[300],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error,
                      color: Colors.red, size: screen.width * 0.06),
                  SizedBox(height: 8),
                  Text(
                    "Error loading image",
                    style: TextStyle(fontSize: 14, color: Colors.red),
                  ),
                  Text(
                    "Please try selecting again",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            );
          },
        );
      }
    }

    // Default state when no image is selected
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey[100],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_outlined,
              color: Colors.grey[400], size: screen.width * 0.08),
          SizedBox(height: 8),
          Text(
            "No image selected",
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          Text(
            "Tap to select payment screenshot",
            style: TextStyle(fontSize: 12, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    final total = consultationFee;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        title: Text(
          "Appointment",
          style: TextStyle(
            color: Color(0xFF199A8E),
            fontWeight: FontWeight.bold,
            fontSize: screen.width * 0.045,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Color(0xFF199A8E)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(screen.width * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(screen.width * 0.03),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(screen.width * 0.03),
                color: Colors.grey[100],
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(screen.width * 0.025),
                    child: Image.network(
                      widget.doctor.profileImageUrl,
                      width: screen.width * 0.18,
                      height: screen.width * 0.18,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: screen.width * 0.18,
                          height: screen.width * 0.18,
                          color: Colors.grey[300],
                          child: Icon(Icons.person, size: screen.width * 0.1),
                        );
                      },
                    ),
                  ),
                  SizedBox(width: screen.width * 0.03),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            widget.doctor.fullName,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: screen.width * 0.04
                            )
                        ),
                        Text(
                            widget.doctor.specialty,
                            style: TextStyle(
                                color: Colors.grey,
                                fontSize: screen.width * 0.035
                            )
                        ),
                        Row(
                          children: [
                            Icon(Icons.work_outline, size: screen.width * 0.035, color: Colors.grey),
                            SizedBox(width: screen.width * 0.01),
                            Text(
                                widget.doctor.experience,
                                style: TextStyle(fontSize: screen.width * 0.035)
                            ),
                            SizedBox(width: screen.width * 0.02),
                            Icon(Icons.location_on, size: screen.width * 0.035, color: Colors.grey),
                            Flexible(
                              child: Text(
                                widget.doctorProfile?.clinicAddress ?? widget.doctor.clinicAddress,
                                style: TextStyle(fontSize: screen.width * 0.035),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: screen.height * 0.025),

            Row(
              children: [
                Icon(Icons.calendar_today_outlined, size: screen.width * 0.035, color: Color(0xFF199A8E)),
                SizedBox(width: screen.width * 0.03),
                Obx(() => Text(
                  "${detailVM.selectedDay.value?.day ?? ''}, ${detailVM.selectedDay.value?.date ?? ''} | ${detailVM.selectedTime.value}",
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: screen.width * 0.035),
                )),
                Spacer(),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Text("Change", style: TextStyle(color: Colors.blue, fontSize: screen.width * 0.035)),
                ),
              ],
            ),
            Divider(height: screen.height * 0.05),

            _buildOwnerPetFields(screen),
            SizedBox(height: screen.height * 0.025),

            Text("Reason", style: TextStyle(fontWeight: FontWeight.bold, fontSize: screen.width * 0.035)),
            SizedBox(height: screen.height * 0.02),
            TextField(
              controller: reasonController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: "e.g. Chest pain, follow-up",
                hintStyle: TextStyle(fontSize: screen.width * 0.032),
                fillColor: Colors.grey[100],
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(screen.width * 0.03),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: screen.height * 0.025),

            Text("Payment Detail", style: TextStyle(fontWeight: FontWeight.bold, fontSize: screen.width * 0.035)),
            SizedBox(height: screen.height * 0.02),
            _paymentRow("Consultation", "₨ ${consultationFee.toInt()}", isBold: true),
            _paymentRow("Discount", "-"),
            Divider(),
            _paymentRow("Total", "₨ ${total.toInt()}", isBold: true),
            SizedBox(height: screen.height * 0.025),
            Obx(() => _buildPaymentMethodSelector(screen)),
            SizedBox(height: screen.height * 0.02),
            Obx(() => _buildPaymentInputFields(screen)),
            SizedBox(height: screen.height * 0.025),

            _buildScreenshotUpload(screen),
            SizedBox(height: screen.height * 0.025),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    "Total: ₨ ${total.toInt()}",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: screen.width * 0.04
                    )
                ),
                Obx(() => ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF199A8E),
                    padding: EdgeInsets.symmetric(
                        horizontal: screen.width * 0.15,
                        vertical: screen.height * 0.025
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(screen.width * 0.05)
                    ),
                  ),
                  onPressed: appointmentController.isBookingAppointment.value ? null : () async {
                    if (ownerNameController.text.trim().isEmpty) {
                                SnackbarUtils.showError(
                                    "Missing Info", "Please enter owner name");
                                return;
                              }

                              // Validation based on consultation type
                              if (appointmentController
                                      .consultationType.value ==
                                  ConsultationType.pet) {
                                if (petNameController.text.trim().isEmpty) {
                                  SnackbarUtils.showError(
                                      "Missing Info", "Please enter pet name");
                                  return;
                                }
                                if (appointmentController
                                    .petType.value.isEmpty) {
                                  SnackbarUtils.showError(
                                      "Missing Info", "Please select pet type");
                                  return;
                                }
                              } else {
                                // For livestock and poultry
                                if (appointmentController
                                        .numberOfPatients.value <=
                                    0) {
                                  SnackbarUtils.showError("Missing Info",
                                      "Please enter number of patients");
                                  return;
                                }
                              }

                              if (reasonController.text.isEmpty) {
                                SnackbarUtils.showError("Missing Info",
                                    "Please enter reason for the appointment");
                                return;
                              }

                              if (appointmentController
                                  .paymentScreenshotPath.value.isEmpty) {
                                SnackbarUtils.showError("Missing Screenshot",
                                    "Please upload payment screenshot");
                                return;
                              }

                              // Set appointment controller values
                              appointmentController.ownerName.value =
                                  ownerNameController.text.trim();
                              if (appointmentController.consultationType.value == ConsultationType.pet) {
                      appointmentController.petName.value = petNameController.text.trim();
                    }
                    appointmentController.selectedPaymentMethod.value = selectedPaymentMethod.value.toString().split('.').last;
                              appointmentController
                                      .paymentScreenshotPath.value =
                                  appointmentController
                                      .paymentScreenshotPath.value;
                              appointmentController.reason.value =
                                  reasonController.text.trim();

                              // Book appointment
                              final success = await appointmentController.bookAppointment(
                      doctorId: widget.doctor.id,
                      selectedDate: detailVM.selectedDate.value?.toString() ?? '',
                      selectedTime: detailVM.selectedTime.value,
                      selectedDay: detailVM.selectedDay.value?.day ?? '',
                      consultationFee: consultationFee,
                    );

                    if (success) {
                      _showPendingDialog(context, screen);
                    }
                  },
                  child: appointmentController.isBookingAppointment.value
                      ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : Text(
                      "Submit Appointment",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: screen.width * 0.035
                      )
                  ),
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showPendingDialog(BuildContext context, Size screen) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(screen.width * 0.05)
          ),
          child: Padding(
            padding: EdgeInsets.all(screen.width * 0.04),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.orange.withOpacity(0.1),
                  ),
                  padding: EdgeInsets.all(screen.width * 0.03),
                  child: Icon(
                      Icons.schedule,
                      size: screen.width * 0.1,
                      color: Colors.orange
                  ),
                ),
                SizedBox(height: screen.height * 0.02),
                Text(
                  "Appointment Submitted",
                  style: TextStyle(
                      fontSize: screen.width * 0.045,
                      fontWeight: FontWeight.bold
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: screen.height * 0.01),
                Text(
                  "Your appointment request has been submitted. Please wait for the doctor to confirm your payment and appointment.",
                  style: TextStyle(
                      fontSize: screen.width * 0.035,
                      color: Colors.grey
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: screen.height * 0.03),
                ElevatedButton(
                  onPressed: () {
                    Get.offAll(() => BottomNavScreen());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0XFF199A8E),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(screen.width * 0.05)
                    ),
                    minimumSize: Size(double.infinity, screen.height * 0.06),
                  ),
                  child: Text(
                      "Go to home",
                      style: TextStyle(
                          fontSize: screen.width * 0.035,
                          color: Colors.white
                      )
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
