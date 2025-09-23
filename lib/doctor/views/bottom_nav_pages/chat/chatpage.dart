import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Chatpage extends StatefulWidget {
  const Chatpage({super.key});

  @override
  State<Chatpage> createState() => _ChatpageState();
}

class _ChatpageState extends State<Chatpage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Container(child: Center(
        child: Text("Chat Page"),
      ),
      ),
    );
  }
}
