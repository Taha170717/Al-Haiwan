import 'package:flutter/material.dart';

import '../doctors/doctor_list_viewmodel.dart';

class MyOrdersPage extends StatelessWidget {
  final List<Order> orders = [
    Order(
      doctor: Doctor(
        name: "Dr. Marcus Horizon",
        speciality: "Veterinarian",
        image: "assets/images/doc1.png",
        rating: 4.7,
        distance: "1200m",
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
        title: Text("My Orders", style: TextStyle(color: Color(0xFF199A8E), fontFamily: "bolditalic")),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFF199A8E)),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// Section 1: Doctor Appointments
            if (orders.isNotEmpty) ...[
              Text("Doctor Appointments", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              ...orders.map((order) => _buildDoctorOrderCard(order, screen)).toList(),
              SizedBox(height: 20),
            ],

            /// Section 2: Product Orders (Medicines)
            if (productOrders.isNotEmpty) ...[
              Text("Medicine Orders", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
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
      margin: EdgeInsets.only(bottom: 14),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Doctor Info
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  order.doctor.image,
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
                    Text(order.doctor.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(order.doctor.speciality, style: TextStyle(color: Colors.grey)),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star, size: 14, color: Color(0xFF199A8E)),
                        SizedBox(width: 4),
                        Text(order.doctor.rating.toString()),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Divider(),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: Color(0xFF199A8E)),
              SizedBox(width: 8),
              Text("${order.date} | ${order.time}"),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.edit_note, size: 16, color: Color(0xFF199A8E)),
              SizedBox(width: 8),
              Expanded(child: Text(order.reason)),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.payment, size: 16, color: Color(0xFF199A8E)),
              SizedBox(width: 8),
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
      margin: EdgeInsets.only(bottom: 14),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.teal[50],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        children: [
          Image.asset(product.image, width: 60, height: 60, fit: BoxFit.cover),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                SizedBox(height: 4),
                Text("Qty: ${product.quantity}"),
                Text("Total: \$${(product.quantity * product.price).toStringAsFixed(2)}"),
                SizedBox(height: 4),
                Text("Status: ${product.status}", style: TextStyle(color: Colors.deepPurple)),
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
