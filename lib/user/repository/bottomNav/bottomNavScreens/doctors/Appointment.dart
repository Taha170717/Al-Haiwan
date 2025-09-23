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
  final ImagePicker _picker = ImagePicker();
  File? _paymentScreenshot;

  Rx<PaymentMethod> selectedPaymentMethod = PaymentMethod.EasyPaisa.obs;
  double consultationFee = 800;

  // final double adminFee = 100; // REMOVE

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
        Text("Payment Screenshot", style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: screen.width * 0.035
        )),
        SizedBox(height: screen.height * 0.01),
        Container(
          width: double.infinity,
          height: screen.height * 0.15,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(screen.width * 0.03),
          ),
          child: _paymentScreenshot != null
              ? Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(screen.width * 0.03),
                      child: kIsWeb
                          ? Container(
                              width: double.infinity,
                              height: double.infinity,
                              color: Colors.grey[300],
                              child: Center(
                                child: Text(
                                  "Screenshot preview not available on Web",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.grey),
                                ),
                              ),
                            )
                          : Image.file(
                              _paymentScreenshot!,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () => setState(() => _paymentScreenshot = null),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child:
                              Icon(Icons.close, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ],
                )
              : GestureDetector(
                  onTap: _pickPaymentScreenshot,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt,
                          size: screen.width * 0.08, color: Colors.grey),
                      SizedBox(height: screen.height * 0.01),
                      Text("Upload Payment Screenshot",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: screen.width * 0.035,
                          )),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  Future<void> _pickPaymentScreenshot() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _paymentScreenshot = File(image.path);
        });
      }
    } catch (e) {
      SnackbarUtils.showError("Error", "Failed to pick image: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    final total = consultationFee; // REMOVE adminFee addition

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
            // _paymentRow("Admin Fee", "₨ ${adminFee.toInt()}", isBold: true), // REMOVE
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

                    if (_paymentScreenshot == null) {
                                SnackbarUtils.showError("Missing Screenshot",
                                    "Please upload payment screenshot");
                                return;
                              }

                    // Set appointment controller values
                    appointmentController.ownerName.value = ownerNameController.text.trim();
                    if (appointmentController.consultationType.value == ConsultationType.pet) {
                      appointmentController.petName.value = petNameController.text.trim();
                    }
                    appointmentController.selectedPaymentMethod.value = selectedPaymentMethod.value.toString().split('.').last;
                    appointmentController.paymentScreenshotPath.value = _paymentScreenshot!.path;
                    appointmentController.reason.value = reasonController.text.trim();


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
