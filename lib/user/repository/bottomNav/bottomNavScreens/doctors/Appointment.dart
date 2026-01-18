import 'package:flutter/foundation.dart';
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

  Widget _buildStripeMethod(Size screen) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text("Payment Method",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: screen.width * 0.035)),
      SizedBox(height: screen.height * 0.02),
      Container(
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF199A8E), width: 2),
          borderRadius: BorderRadius.circular(screen.width * 0.03),
        ),
        child: ListTile(
          leading: const Icon(Icons.credit_card, color: Color(0xFF199A8E)),
          title: const Text("Pay with Card (Stripe)"),
          trailing: const Icon(Icons.lock, color: Color(0xFF199A8E)),
        ),
      ),
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

          SizedBox(height: screen.height * 0.025),
          _buildStripeMethod(screen),

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
              appointmentController.selectedPaymentMethod.value = 'Stripe';

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
