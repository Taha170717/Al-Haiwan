import 'package:al_haiwan/repository/bottomNav/bottomNavScreen.dart';
import 'package:al_haiwan/repository/bottomNav/bottomNavScreens/home/homescreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'doctor_list_viewmodel.dart'; // Replace with your actual import
import 'doctor_detail_viewmodel.dart'; // Replace with your actual import

enum CardType { Visa, MasterCard, Unknown }

class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();
    for (int i = 0; i < digitsOnly.length; i++) {
      buffer.write(digitsOnly[i]);
      if ((i + 1) % 4 == 0 && i != digitsOnly.length - 1) {
        buffer.write(' ');
      }
    }

    final newText = buffer.toString();
    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}

class AppointmentSummaryView extends StatefulWidget {
  final Doctor doctor;

  AppointmentSummaryView({required this.doctor});

  @override
  _AppointmentSummaryViewState createState() => _AppointmentSummaryViewState();
}

class _AppointmentSummaryViewState extends State<AppointmentSummaryView> {
  final reasonController = TextEditingController();
  final paymentController = TextEditingController();
  final double consultationFee = 800; // Set between 500 - 1200
  final double adminFee = 100;
  CardType cardType = CardType.Unknown;

  @override
  void initState() {
    super.initState();
    paymentController.addListener(() {
      final rawNumber = paymentController.text.replaceAll(' ', '');
      final type = detectCardType(rawNumber);
      setState(() => cardType = type);
    });
  }

  @override
  void dispose() {
    reasonController.dispose();
    paymentController.dispose();
    super.dispose();
  }

  CardType detectCardType(String input) {
    if (input.startsWith('4')) {
      return CardType.Visa;
    } else if (RegExp(r'^(5[1-5]|2[2-7])').hasMatch(input)) {
      return CardType.MasterCard;
    } else {
      return CardType.Unknown;
    }
  }

  Widget _paymentRow(String title, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(title, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Spacer(),
          Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    final detailVM = Get.find<DoctorDetailViewModel>();
    final total = consultationFee + adminFee;

    return Scaffold(
      backgroundColor: Colors.white,
       appBar: AppBar(
         backgroundColor: Colors.white,
      elevation: 0, // Remove shadow when scrolling
      systemOverlayStyle: SystemUiOverlayStyle.dark, // For white background status bar
      title: Text(
        "Appointment",
        style: TextStyle(
          color: Color(0xFF199A8E),
          fontFamily: "bolditalic",
        ),
      ),
      centerTitle: true,
      iconTheme: IconThemeData(color: Color(0xFF199A8E)), // Back arrow color
    ),

    body: SingleChildScrollView(
        padding: EdgeInsets.all(screen.width * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Doctor Info
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[100],
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      widget.doctor.image,
                      width: screen.width * 0.18,
                      height: screen.width * 0.18,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.doctor.name,
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(widget.doctor.speciality, style: TextStyle(color: Colors.grey)),
                        Row(
                          children: [
                            Icon(Icons.star, size: 14, color: Color(0xFF199A8E)),
                            SizedBox(width: 4),
                            Text("${widget.doctor.rating}"),
                            SizedBox(width: 8),
                            Icon(Icons.location_on, size: 14, color: Colors.grey),
                            Text("${widget.doctor.distance}"),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: 20),

            // Date and Time
            Row(
              children: [
                Icon(Icons.calendar_today_outlined, size: 18, color: Color(0xFF199A8E)),
                SizedBox(width: 10),
                Obx(() => Text(
                  "${detailVM.selectedDay.value.day}, ${detailVM.selectedDay.value.date} | ${detailVM.selectedTime.value}",
                  style: TextStyle(fontWeight: FontWeight.w500),
                )),
                Spacer(),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Text("Change", style: TextStyle(color: Colors.blue, fontSize: 12)),
                ),
              ],
            ),
            Divider(height: 30),

            // Reason
            Text("Reason", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 6),
            TextField(
              controller: reasonController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: "e.g. Chest pain, follow-up",
                fillColor: Colors.grey[100],
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 20),

            // Payment Detail
            Text("Payment Detail", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            _paymentRow("Consultation", "₨ ${consultationFee.toInt()}"),
            _paymentRow("Admin Fee", "₨ ${adminFee.toInt()}"),
            _paymentRow("Discount", "-"),
            Divider(),
            _paymentRow("Total", "₨ ${total.toInt()}", isBold: true),
            SizedBox(height: 20),

            // Card Number Field
            Text("Enter Payment Method", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            TextField(
              controller: paymentController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(19), // 16 digits + 3 spaces
                CardNumberInputFormatter(),
              ],
              decoration: InputDecoration(
                hintText: "1234 5678 9012 3456",
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Image.asset(
                    cardType == CardType.Visa
                        ? 'assets/images/Vise.png'
                        : 'assets/images/mastercard.png',
                    height: 20,
                    width: 20,
                  ),
                ),
                fillColor: Colors.white,
                filled: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Color(0xFF199A8E), width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Color(0xFF199A8E), width: 1.5),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Booking Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Total: ₨ ${total.toInt()}",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ElevatedButton(

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF199A8E),
                    padding: EdgeInsets.symmetric(horizontal: 54, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: () {
                    final cardNumber = paymentController.text.replaceAll(' ', '');
                    if (reasonController.text.isEmpty) {
                      Get.snackbar("Missing Info", "Please enter reason for the appointment");
                      return;
                    }
                    if (cardNumber.length != 16) {
                      Get.snackbar("Invalid Card", "Card number must be exactly 16 digits");
                      return;
                    }

                    dialoguescreen(context);
                  },
                  child: Text("Booking",style: TextStyle(color: Colors.white),),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  void dialoguescreen(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,

          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0XFFF5F8FF), // Background color for the circle
                  ),
                  padding: EdgeInsets.all(12), // Adjust padding for proper spacing
                  child: Icon(Icons.check, size: 60, color: Color(0xFF199A8E)), // Green tick
                ),
                SizedBox(height: 16),
                Text(
                  "Payment Success",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  "Your payment has been successful, you can have a consultation session with your trusted doctor",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Get.offAll(() => BottomNavScreen());

                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0XFF199A8E),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    minimumSize: Size(double.infinity, 50),
                  ),
                  child: Text("Go to home", style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

}

