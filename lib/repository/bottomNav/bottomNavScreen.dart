import 'package:al_haiwan/repository/bottomNav/bottomNavScreens/cart/cartscreen.dart';
import 'package:al_haiwan/repository/bottomNav/bottomNavScreens/categories/categoryscreen.dart';
import 'package:al_haiwan/repository/bottomNav/bottomNavScreens/doctors/doctorscreen.dart';
import 'package:al_haiwan/repository/bottomNav/bottomNavScreens/home/homescreen.dart';
import 'package:flutter/material.dart';

class BottomNavScreen extends StatefulWidget {
  const BottomNavScreen({super.key});

  @override
  State<BottomNavScreen> createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  int currentIndex = 0;
  List<Widget> pages = [
    HomeScreen(),
    Doctorscreen(),
    Categoryscreen(),
    Cartscreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: _buildNavIcon('assets/images/home.png', 0),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: _buildNavIcon('assets/images/consult.png', 1),
            label: 'Doctors',
          ),
          BottomNavigationBarItem(
            icon: _buildNavIcon('assets/images/category.png', 2),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: _buildNavIcon('assets/images/cart.png', 3),
            label: 'Cart',
          ),
        ],
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        selectedItemColor: Color(0XFF199A8E),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            currentIndex = index;

          });
        },
      ),
    );
  }

  Widget _buildNavIcon(String assetPath, int index) {
    return ColorFiltered(
      colorFilter: ColorFilter.mode(
        currentIndex == index ? Color(0XFF199A8E) : Colors.grey,
        BlendMode.srcIn,
      ),
      child: Image.asset(assetPath, width: 24, height: 24),
    );
  }
}