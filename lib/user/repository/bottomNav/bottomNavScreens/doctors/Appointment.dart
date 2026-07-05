import 'package:flutter/foundation.dart';
import 'dart:io' if (dart.library.html) 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../../doctor/models/doctor_availability_model.dart';
import '../../../../controllers/appointment_controller.dart';
import '../../../../models/doctor_detail_viewmodel.dart' hide DoctorProfile;
import '../../../../models/doctor_list_viewmodel.dart';
import '../../../../models/user_appointment_model.dart';
import '../../bottomNavScreen.dart';
import 'package:al_haiwan/utils/custom_snackbar.dart';

class AppointmentSummaryView extends StatefulWidget {
  final Doctor doctor;
  final DoctorProfile? doctorProfile;

  const AppointmentSummaryView({super.key, required this.doctor, this.doctorProfile});

  @override
  State<AppointmentSummaryView> createState() => _AppointmentSummaryViewState();
}

class _AppointmentSummaryViewState extends State<AppointmentSummaryView> {
  final reasonController = TextEditingController();
  final ownerNameController = TextEditingController();
  final petNameController = TextEditingController();

  late AppointmentController appointmentController;
  late DoctorDetailViewModel detailVM;

  double consultationFee = 800;

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

  // Root method: decides whether we need reactivity at all.
  //
  // BUG THAT WAS HERE:
  //   final profile = widget.doctorProfile ?? detailVM.doctorProfile.value;
  // `??` short-circuits: when widget.doctorProfile is non-null (which it is
  // on this screen), detailVM.doctorProfile.value is NEVER read. That means
  // the Obx wrapping this widget subscribes to zero observables, which is
  // exactly what triggers GetX's "improper use of GetX" error.
  //
  // FIX: only wrap in Obx when we actually depend on the reactive value
  // (i.e. when we don't already have a concrete profile passed in).
  Widget _buildDoctorAccountDetails(Size screen) {
    if (widget.doctorProfile != null) {
      // We already have the data - no observable involved, no Obx needed.
      return _buildAccountDetailsContent(screen, widget.doctorProfile!);
    }

    // Only this branch actually needs to react to async-fetched data.
    return Obx(() {
      final profile = detailVM.doctorProfile.value;
      if (profile == null) return const SizedBox.shrink();
      return _buildAccountDetailsContent(screen, profile);
    });
  }

  Widget _buildAccountDetailsContent(Size screen, DoctorProfile profile) {
    final hasAny = profile.easypaisaNumber.isNotEmpty ||
        profile.jazzcashNumber.isNotEmpty ||
        profile.bankName.isNotEmpty ||
        profile.bankAccountNumber.isNotEmpty ||
        profile.bankHolderName.isNotEmpty;

    if (!hasAny) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(screen.width * 0.04),
      margin: EdgeInsets.only(top: screen.height * 0.02),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(screen.width * 0.03),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Doctor Payment Accounts',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: screen.width * 0.038)),
        SizedBox(height: screen.height * 0.01),
        if (profile.easypaisaNumber.isNotEmpty)
          _paymentRow('EasyPaisa', profile.easypaisaNumber),
        if (profile.jazzcashNumber.isNotEmpty)
          _paymentRow('JazzCash', profile.jazzcashNumber),
        if (profile.bankName.isNotEmpty || profile.bankAccountNumber.isNotEmpty)
          _paymentRow('Bank',
              '${profile.bankName}${profile.bankAccountNumber.isNotEmpty ? ' - ${profile.bankAccountNumber}' : ''}'),
        if (profile.bankHolderName.isNotEmpty)
          _paymentRow('Account Holder', profile.bankHolderName),
      ]),
    );
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
          Text(title,
              style: TextStyle(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  fontSize: screen.width * 0.035)),
          const Spacer(),
          Text(value,
              style: TextStyle(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  fontSize: screen.width * 0.035)),
        ],
      ),
    );
  }

  Widget _buildOwnerPetFields(Size screen) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text("Consultation Type",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: screen.width * 0.035)),
      SizedBox(height: screen.height * 0.02),

      Obx(() => Column(children: [
        _buildConsultationOption(screen, ConsultationType.pet, "Pet", Icons.pets),
        _buildConsultationOption(screen, ConsultationType.livestock, "Livestock", Icons.agriculture),
        _buildConsultationOption(screen, ConsultationType.poultry, "Poultry", Icons.egg),
      ])),

      SizedBox(height: screen.height * 0.02),

      TextField(
        controller: ownerNameController,
        decoration: InputDecoration(
          labelText: "Owner Name *",
          fillColor: Colors.grey[100],
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(screen.width * 0.03),
            borderSide: BorderSide.none,
          ),
          prefixIcon: const Icon(Icons.person, color: Color(0xFF199A8E)),
        ),
      ),

      SizedBox(height: screen.height * 0.015),
      Obx(() => _buildDynamicFields(screen)),
    ]);
  }

  Widget _buildConsultationOption(Size screen, ConsultationType type, String title, IconData icon) {
    return Container(
      margin: EdgeInsets.only(bottom: screen.height * 0.01),
      decoration: BoxDecoration(
        border: Border.all(
          color: appointmentController.consultationType.value == type
              ? const Color(0xFF199A8E)
              : Colors.grey[300]!,
          width: appointmentController.consultationType.value == type ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(screen.width * 0.03),
      ),
      child: RadioListTile<ConsultationType>(
        value: type,
        groupValue: appointmentController.consultationType.value,
        onChanged: (val) => appointmentController.consultationType.value = val!,
        title: Row(children: [
          Icon(icon, color: const Color(0xFF199A8E), size: screen.width * 0.05),
          SizedBox(width: screen.width * 0.03),
          Text(title, style: TextStyle(fontSize: screen.width * 0.035)),
        ]),
        activeColor: const Color(0xFF199A8E),
      ),
    );
  }

  Widget _buildDynamicFields(Size screen) {
    switch (appointmentController.consultationType.value) {
      case ConsultationType.pet:
        return Column(children: [
          DropdownButtonFormField<String>(
            value: appointmentController.petType.value.isEmpty
                ? null
                : appointmentController.petType.value,
            items: appointmentController.petTypes
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (v) => appointmentController.petType.value = v ?? '',
            decoration: InputDecoration(
              labelText: "Pet Type *",
              fillColor: Colors.grey[100],
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(screen.width * 0.03),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.pets, color: Color(0xFF199A8E)),
            ),
          ),
          SizedBox(height: screen.height * 0.015),
          TextField(
            controller: petNameController,
            decoration: InputDecoration(
              labelText: "Pet Name *",
              fillColor: Colors.grey[100],
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(screen.width * 0.03),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.pets, color: Color(0xFF199A8E)),
            ),
          ),
        ]);

      case ConsultationType.livestock:
      case ConsultationType.poultry:
        return TextField(
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: "Number of Animals *",
            fillColor: Colors.grey[100],
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(screen.width * 0.03),
              borderSide: BorderSide.none,
            ),
            prefixIcon: const Icon(Icons.numbers, color: Color(0xFF199A8E)),
          ),
          onChanged: (v) => appointmentController.numberOfPatients.value = int.tryParse(v) ?? 1,
        );
    }
  }

  Widget _buildPaymentScreenshotMethod(Size screen) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text("Payment Method",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: screen.width * 0.035)),
      SizedBox(height: screen.height * 0.02),
      Obx(() {
        final hasScreenshot = appointmentController.paymentScreenshotPath.value.isNotEmpty ||
            appointmentController.paymentScreenshotBytes.value != null;

        return Container(
          padding: EdgeInsets.all(screen.width * 0.03),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF199A8E), width: 2),
            borderRadius: BorderRadius.circular(screen.width * 0.03),
          ),
          child: Row(children: [
            const Icon(Icons.photo, color: Color(0xFF199A8E)),
            SizedBox(width: screen.width * 0.03),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(hasScreenshot ? "Screenshot uploaded" : "Upload Payment Screenshot",
                    style: TextStyle(fontSize: screen.width * 0.035)),
                SizedBox(height: screen.height * 0.005),
                Text(
                    hasScreenshot
                        ? "Tap to change or remove the screenshot"
                        : "Please upload a payment screenshot (bank transfer / card receipt)",
                    style: TextStyle(fontSize: screen.width * 0.03, color: Colors.grey[700])),
              ]),
            ),
            const SizedBox(width: 8),
            hasScreenshot
                ? Row(children: [
              IconButton(
                icon: const Icon(Icons.remove_circle, color: Colors.red),
                onPressed: () => appointmentController.clearPaymentScreenshot(),
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Color(0xFF199A8E)),
                onPressed: () => appointmentController.pickPaymentScreenshot(),
              ),
            ])
                : ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF199A8E)),
              onPressed: () => appointmentController.pickPaymentScreenshot(),
              child: const Text('Upload'),
            ),
          ]),
        );
      }),
      SizedBox(height: screen.height * 0.01),
      // Preview (web uses bytes)
      Obx(() {
        final path = appointmentController.paymentScreenshotPath.value;
        final bytes = appointmentController.paymentScreenshotBytes.value;
        if (path.isEmpty && bytes == null) return const SizedBox.shrink();

        return Container(
          margin: EdgeInsets.only(top: screen.height * 0.01),
          height: screen.height * 0.2,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: path.isNotEmpty
                ? Image.file(
              File(path),
              fit: BoxFit.cover,
            )
                : bytes != null
                ? Image.memory(bytes, fit: BoxFit.cover)
                : const SizedBox.shrink(),
          ),
        );
      }),
    ]);
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
        title: Text("Appointment",
            style: TextStyle(
                color: const Color(0xFF199A8E),
                fontWeight: FontWeight.bold,
                fontSize: screen.width * 0.045)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF199A8E)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(screen.width * 0.05),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildOwnerPetFields(screen),
          SizedBox(height: screen.height * 0.025),

          Text("Reason",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: screen.width * 0.035)),
          SizedBox(height: screen.height * 0.02),
          TextField(
            controller: reasonController,
            maxLines: 2,
            decoration: InputDecoration(
              fillColor: Colors.grey[100],
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(screen.width * 0.03),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          SizedBox(height: screen.height * 0.03),

          Text("Payment Detail",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: screen.width * 0.035)),
          _paymentRow("Consultation", "₨ ${total.toInt()}", isBold: true),
          const Divider(),
          _paymentRow("Total", "₨ ${total.toInt()}", isBold: true),

          // Show doctor's account/payment details (EasyPaisa, JazzCash, Bank)
          _buildDoctorAccountDetails(screen),

          SizedBox(height: screen.height * 0.025),
          _buildPaymentScreenshotMethod(screen),

          SizedBox(height: screen.height * 0.03),

          Obx(() => ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF199A8E),
              minimumSize: Size(double.infinity, screen.height * 0.06),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(screen.width * 0.05)),
            ),
            onPressed: appointmentController.isBookingAppointment.value
                ? null
                : () async {
              if (ownerNameController.text.trim().isEmpty) {
                CustomSnackbar.showError("Missing Info", "Enter owner name");
                return;
              }

              if (reasonController.text.trim().isEmpty) {
                CustomSnackbar.showError("Missing Info", "Enter reason");
                return;
              }

              appointmentController.ownerName.value = ownerNameController.text.trim();
              appointmentController.reason.value = reasonController.text.trim();
              appointmentController.selectedPaymentMethod.value = 'Screenshot';

              final success = await appointmentController.bookAppointment(
                doctorId: widget.doctor.id,
                selectedDate: detailVM.selectedDate.value?.toString() ?? '',
                selectedTime: detailVM.selectedTime.value,
                selectedDay: detailVM.selectedDay.value?.day ?? '',
                consultationFee: consultationFee,
              );

              if (success) {
                CustomSnackbar.showSuccess(
                    'Success', 'Appointment booked & paid successfully');
                Get.offAll(() => BottomNavScreen());
              }
            },
            child: appointmentController.isBookingAppointment.value
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text("Pay & Book Appointment",
                style: TextStyle(color: Colors.white)),
          )),
        ]),
      ),
    );
  }
}