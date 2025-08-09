import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import 'add_products.dart';

class AdminProducts extends StatefulWidget {
  const AdminProducts({super.key});

  @override
  State<AdminProducts> createState() => _AdminProductsState();
}

class _AdminProductsState extends State<AdminProducts> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Products',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0XFF199A8E),
            fontFamily: "bolditalic",
          ),
        ),
        centerTitle: false,
      ),
      backgroundColor: Colors.white,
      body: Container(child: Center(
        child: Text("Admin Products Page"),
      ),
      ),
      floatingActionButton: FloatingActionButton(onPressed: (){
        Get.to(()=>  AddProducts());
      },
        backgroundColor: const Color(0XFF199A8E),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        isExtended: true,
        elevation: 5,
        focusElevation: 5,
        highlightElevation: 5,
        hoverElevation: 5,
        focusColor: Colors.white,
        hoverColor: Colors.white,
        splashColor: Colors.white,
        focusNode: FocusNode(),
        autofocus: false,
        enableFeedback: true,
        clipBehavior: Clip.hardEdge,
      tooltip: 'Add Product',
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
