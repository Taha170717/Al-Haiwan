import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AdminProducts extends StatefulWidget {
  const AdminProducts({super.key});

  @override
  State<AdminProducts> createState() => _AdminProductsState();
}

class _AdminProductsState extends State<AdminProducts> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Container(child: Center(
        child: Text("Admin Products Page"),
      ),
      ),
    );
  }
}
