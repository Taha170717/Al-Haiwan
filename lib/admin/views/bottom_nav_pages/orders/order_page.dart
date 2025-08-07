import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AdminOrders extends StatefulWidget {
  const AdminOrders({super.key});

  @override
  State<AdminOrders> createState() => _AdminOrdersState();
}

class _AdminOrdersState extends State<AdminOrders> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Container(child: Center(
        child: Text("Admin Orders Page"),
      ),
      ),
    );
  }
}
