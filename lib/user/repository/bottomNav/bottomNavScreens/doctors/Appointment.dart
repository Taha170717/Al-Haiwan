import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../bottomNavScreen.dart';
import 'doctor_detail_viewmodel.dart';
import 'doctor_list_viewmodel.dart';

enum PaymentMethod { CreditCard, EasyPaisa, JazzCash, BankAccount }

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
  final accountNumberController = TextEditingController();
  final phoneNumberController = TextEditingController();

  PaymentMethod selectedPaymentMethod = PaymentMethod.CreditCard;
  double consultationFee = 800;
  final double adminFee = 100;

  @override
  void initState() {
    super.initState();
    consultationFee = widget.doctor.consultationFee;
  }

  @override
  void dispose() {
    reasonController.dispose();
    paymentController.dispose();
    accountNumberController.dispose();
    phoneNumberController.dispose();
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

  Widget _buildPaymentMethodSelector(Size screen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Select Payment Method", style: TextStyle(fontWeight: FontWeight.bold, fontSize: screen.width * 0.035)),
        SizedBox(height: screen.height * 0.02),

        _buildPaymentOption(
          screen,
          PaymentMethod.CreditCard,
          "Credit/Debit Card",
          Icons.credit_card,
          Colors.blue,
        ),
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
          color: selectedPaymentMethod == method ? Color(0xFF199A8E) : Colors.grey[300]!,
          width: selectedPaymentMethod == method ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(screen.width * 0.03),
      ),
      child: CheckboxListTile(
        value: selectedPaymentMethod == method,
        onChanged: (bool? value) {
          if (value == true) {
            setState(() {
              selectedPaymentMethod = method;
            });
          }
        },
        title: Row(
          children: [
            Icon(icon, color: color, size: screen.width * 0.05),
            SizedBox(width: screen.width * 0.03),
            Text(title, style: TextStyle(fontSize: screen.width * 0.035)),
          ],
        ),
        activeColor: Color(0xFF199A8E),
        controlAffinity: ListTileControlAffinity.trailing,
      ),
    );
  }

  Widget _buildPaymentInputFields(Size screen) {
    switch (selectedPaymentMethod) {
      case PaymentMethod.CreditCard:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Card Number", style: TextStyle(fontWeight: FontWeight.bold, fontSize: screen.width * 0.035)),
            SizedBox(height: screen.height * 0.01),
            TextField(
              controller: paymentController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(19),
                CardNumberInputFormatter(),
              ],
              decoration: InputDecoration(
                hintText: "1234 5678 9012 3456",
                hintStyle: TextStyle(fontSize: screen.width * 0.032),
                prefixIcon: Icon(Icons.credit_card, size: screen.width * 0.05),
                fillColor: Colors.white,
                filled: true,
                contentPadding: EdgeInsets.symmetric(
                    horizontal: screen.width * 0.03,
                    vertical: screen.height * 0.02
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(screen.width * 0.03),
                  borderSide: BorderSide(color: Color(0xFF199A8E), width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(screen.width * 0.03),
                  borderSide: BorderSide(color: Color(0xFF199A8E), width: 1.5),
                ),
              ),
            ),
          ],
        );

      case PaymentMethod.EasyPaisa:
      case PaymentMethod.JazzCash:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Phone Number", style: TextStyle(fontWeight: FontWeight.bold, fontSize: screen.width * 0.035)),
            SizedBox(height: screen.height * 0.01),
            TextField(
              controller: phoneNumberController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: "03XX XXXXXXX",
                hintStyle: TextStyle(fontSize: screen.width * 0.032),
                prefixIcon: Icon(Icons.phone, size: screen.width * 0.05),
                fillColor: Colors.white,
                filled: true,
                contentPadding: EdgeInsets.symmetric(
                    horizontal: screen.width * 0.03,
                    vertical: screen.height * 0.02
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(screen.width * 0.03),
                  borderSide: BorderSide(color: Color(0xFF199A8E), width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(screen.width * 0.03),
                  borderSide: BorderSide(color: Color(0xFF199A8E), width: 1.5),
                ),
              ),
            ),
          ],
        );

      case PaymentMethod.BankAccount:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Account Number", style: TextStyle(fontWeight: FontWeight.bold, fontSize: screen.width * 0.035)),
            SizedBox(height: screen.height * 0.01),
            TextField(
              controller: accountNumberController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Enter account number",
                hintStyle: TextStyle(fontSize: screen.width * 0.032),
                prefixIcon: Icon(Icons.account_balance, size: screen.width * 0.05),
                fillColor: Colors.white,
                filled: true,
                contentPadding: EdgeInsets.symmetric(
                    horizontal: screen.width * 0.03,
                    vertical: screen.height * 0.02
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(screen.width * 0.03),
                  borderSide: BorderSide(color: Color(0xFF199A8E), width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(screen.width * 0.03),
                  borderSide: BorderSide(color: Color(0xFF199A8E), width: 1.5),
                ),
              ),
            ),
          ],
        );
    }
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
                                widget.doctor.clinicAddress,
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
                  "${detailVM.selectedDay.value.day}, ${detailVM.selectedDay.value.date} | ${detailVM.selectedTime.value}",
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
            _paymentRow("Admin Fee", "₨ ${adminFee.toInt()}", isBold: true),
            _paymentRow("Discount", "-"),
            Divider(),
            _paymentRow("Total", "₨ ${total.toInt()}", isBold: true),
            SizedBox(height: screen.height * 0.025),

            _buildPaymentMethodSelector(screen),
            SizedBox(height: screen.height * 0.02),
            _buildPaymentInputFields(screen),
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
                ElevatedButton(
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
                  onPressed: () {
                    if (reasonController.text.isEmpty) {
                      Get.snackbar("Missing Info", "Please enter reason for the appointment");
                      return;
                    }

                    String paymentValidation = _validatePaymentInput();
                    if (paymentValidation.isNotEmpty) {
                      Get.snackbar("Invalid Payment Info", paymentValidation);
                      return;
                    }

                    _showSuccessDialog(context, screen);
                  },
                  child: Text(
                      "Booking",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: screen.width * 0.035
                      )
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _validatePaymentInput() {
    switch (selectedPaymentMethod) {
      case PaymentMethod.CreditCard:
        final cardNumber = paymentController.text.replaceAll(' ', '');
        if (cardNumber.length != 16) {
          return "Card number must be exactly 16 digits";
        }
        break;
      case PaymentMethod.EasyPaisa:
      case PaymentMethod.JazzCash:
        if (phoneNumberController.text.isEmpty || phoneNumberController.text.length < 11) {
          return "Please enter a valid phone number";
        }
        break;
      case PaymentMethod.BankAccount:
        if (accountNumberController.text.isEmpty) {
          return "Please enter account number";
        }
        break;
    }
    return "";
  }

  void _showSuccessDialog(BuildContext context, Size screen) {
    showDialog(
      context: context,
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
                    color: Color(0XFFF5F8FF),
                  ),
                  padding: EdgeInsets.all(screen.width * 0.03),
                  child: Icon(
                      Icons.check,
                      size: screen.width * 0.1,
                      color: Color(0xFF199A8E)
                  ),
                ),
                SizedBox(height: screen.height * 0.02),
                Text(
                  "Payment Success",
                  style: TextStyle(
                      fontSize: screen.width * 0.045,
                      fontWeight: FontWeight.bold
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: screen.height * 0.01),
                Text(
                  "Your payment has been successful, you can have a consultation session with your trusted doctor",
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
