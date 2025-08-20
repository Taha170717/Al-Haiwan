import 'package:flutter/material.dart';

import '../doctors/doctor_list_viewmodel.dart';

class MyOrdersPage extends StatelessWidget {
  final List<Order> orders = [
    Order(
      doctor: Doctor(
        id: "doc1",
        name: "Dr. Marcus Horizon",
        specialty: "Veterinarian", // Updated from speciality to specialty
        profileImageUrl: "assets/images/doc1.png", // Updated from image to profileImageUrl
        rating: 4.7,
        experience: "5 years",
        location: "1200m away", // Updated from distance to location
        isVerified: true,
        consultationFee: 800,
        about: "Experienced veterinarian",
        availableDays: [],
        availableTimeSlots: [], fullName: '', email: '', phoneNumber: '', clinicName: '', registrationNumber: '',
      ),
      date: "21 May, 2025",
      time: "10:00 AM",
      reason: "Dog checkup",
      status: "Completed",
      paid: true,
    ),
  ];

  final List<ProductOrder> productOrders = [
    ProductOrder(
      name: "Pet Antibiotic - 250mg",
      quantity: 2,
      price: 150.0,
      image: "assets/images/panadol.png",
      status: "Delivered",
    ),
    ProductOrder(
      name: "Vitamin Supplements",
      quantity: 1,
      price: 80.0,
      image: "assets/images/obh.png",
      status: "Shipped",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text("My Orders", style: TextStyle(
          color: Color(0xFF199A8E),
          fontFamily: "bolditalic",
          fontSize: screen.width * 0.045, // Added responsive font size
        )),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFF199A8E)),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(screen.width * 0.04), // Made padding responsive
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Section 1: Doctor Appointments
            if (orders.isNotEmpty) ...[
              Text("Doctor Appointments", style: TextStyle(
                  fontSize: screen.width * 0.045, // Added responsive font size
                  fontWeight: FontWeight.bold
              )),
              SizedBox(height: screen.height * 0.012), // Made spacing responsive
              ...orders.map((order) => _buildDoctorOrderCard(order, screen)).toList(),
              SizedBox(height: screen.height * 0.025), // Made spacing responsive
            ],

            /// Section 2: Product Orders (Medicines)
            if (productOrders.isNotEmpty) ...[
              Text("Medicine Orders", style: TextStyle(
                  fontSize: screen.width * 0.045, // Added responsive font size
                  fontWeight: FontWeight.bold
              )),
              SizedBox(height: screen.height * 0.012), // Made spacing responsive
              ...productOrders.map((product) => _buildProductCard(product, screen)).toList(),
            ],
          ],
        ),
      ),
    );
  }

  /// Doctor Appointment Card
  Widget _buildDoctorOrderCard(Order order, Size screen) {
    return Container(
      margin: EdgeInsets.only(bottom: screen.height * 0.017), // Made margin responsive
      padding: EdgeInsets.all(screen.width * 0.03), // Made padding responsive
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(screen.width * 0.03), // Made border radius responsive
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Doctor Info
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(screen.width * 0.025), // Made border radius responsive
                child: Image.asset(
                  order.doctor.profileImageUrl, // Updated property name
                  width: screen.width * 0.18,
                  height: screen.width * 0.18,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: screen.width * 0.03), // Made spacing responsive
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order.doctor.name, style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: screen.width * 0.04 // Added responsive font size
                    )),
                    Text(order.doctor.specialty, style: TextStyle( // Updated property name
                        color: Colors.grey,
                        fontSize: screen.width * 0.035 // Added responsive font size
                    )),
                    SizedBox(height: screen.height * 0.005), // Made spacing responsive
                    Row(
                      children: [
                        Icon(Icons.star, size: screen.width * 0.035, color: Color(0xFF199A8E)), // Made icon size responsive
                        SizedBox(width: screen.width * 0.01), // Made spacing responsive
                        Text(order.doctor.rating.toString(), style: TextStyle(
                            fontSize: screen.width * 0.035 // Added responsive font size
                        )),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: screen.height * 0.012), // Made spacing responsive
          Divider(),
          Row(
            children: [
              Icon(Icons.calendar_today, size: screen.width * 0.035, color: Color(0xFF199A8E)), // Made icon size responsive
              SizedBox(width: screen.width * 0.03), // Made spacing responsive
              Text("${order.date} | ${order.time}"),
            ],
          ),
          SizedBox(height: screen.height * 0.008), // Made spacing responsive
          Row(
            children: [
              Icon(Icons.edit_note, size: screen.width * 0.035, color: Color(0xFF199A8E)), // Made icon size responsive
              SizedBox(width: screen.width * 0.03), // Made spacing responsive
              Expanded(child: Text(order.reason)),
            ],
          ),
          SizedBox(height: screen.height * 0.008), // Made spacing responsive
          Row(
            children: [
              Icon(Icons.payment, size: screen.width * 0.035, color: Color(0xFF199A8E)), // Made icon size responsive
              SizedBox(width: screen.width * 0.03), // Made spacing responsive
              Text(order.paid ? "Paid" : "Pending", style: TextStyle(color: order.paid ? Colors.green : Colors.red)),
              Spacer(),
              Text(order.status, style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  /// Product Order Card
  Widget _buildProductCard(ProductOrder product, Size screen) {
    return Container(
      margin: EdgeInsets.only(bottom: screen.height * 0.017), // Made margin responsive
      padding: EdgeInsets.all(screen.width * 0.03), // Made padding responsive
      decoration: BoxDecoration(
        color: Colors.teal[50],
        borderRadius: BorderRadius.circular(screen.width * 0.03), // Made border radius responsive
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        children: [
          Image.asset(product.image,
              width: screen.width * 0.15, // Made image size responsive
              height: screen.width * 0.15, // Made image size responsive
              fit: BoxFit.cover
          ),
          SizedBox(width: screen.width * 0.03), // Made spacing responsive
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: screen.width * 0.038 // Added responsive font size
                )),
                SizedBox(height: screen.height * 0.005), // Made spacing responsive
                Text("Qty: ${product.quantity}", style: TextStyle(
                    fontSize: screen.width * 0.035 // Added responsive font size
                )),
                Text("Total: \$${(product.quantity * product.price).toStringAsFixed(2)}", style: TextStyle(
                    fontSize: screen.width * 0.035 // Added responsive font size
                )),
                SizedBox(height: screen.height * 0.005), // Made spacing responsive
                Text("Status: ${product.status}", style: TextStyle(
                    color: Colors.deepPurple,
                    fontSize: screen.width * 0.035 // Added responsive font size
                )),
              ],
            ),
          )
        ],
      ),
    );
  }
}

/// Doctor Appointment Model
class Order {
  final Doctor doctor;
  final String date;
  final String time;
  final String reason;
  final String status;
  final bool paid;

  Order({
    required this.doctor,
    required this.date,
    required this.time,
    required this.reason,
    required this.status,
    required this.paid,
  });
}

/// Product Order Model
class ProductOrder {
  final String name;
  final int quantity;
  final double price;
  final String image;
  final String status;

  ProductOrder({
    required this.name,
    required this.quantity,
    required this.price,
    required this.image,
    required this.status,
  });
}
