import 'package:al_haiwan/repository/bottomNav/bottomNavScreens/profile/profile_viewmodal.dart';
import 'package:al_haiwan/repository/screens/login/loginpage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Profilescreen extends StatelessWidget {
  final ProfileViewModel controller = Get.put(ProfileViewModel());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0XFF199A8E),
      body: Column(
        children: [
          SizedBox(height: 80),
          CircleAvatar(
            radius: 40,
            backgroundImage: AssetImage('assets/images/user.png'),
          ),
          SizedBox(height: 10),
          Obx(() => Text(
            controller.name.value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          )),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat('Heart rate', '215bpm', Icons.favorite),
                _buildStat('Calories', '756cal', Icons.local_fire_department),
                _buildStat('Weight', '103lbs', Icons.fitness_center),
              ],
            ),
          ),
          SizedBox(height: 30),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  _buildOption(context, Icons.bookmark_border, 'My Saved', onTap: () {
                    // TODO: Add navigation
                  }),
                  _buildOption(context, Icons.calendar_today, 'Appointment', onTap: () {
                    // TODO: Add navigation
                  }),
                  _buildOption(context, Icons.credit_card, 'Payment Method', onTap: () {
                    // TODO: Add navigation
                  }),
                  _buildOption(context, Icons.help_outline, 'FAQs', onTap: () {
                    // TODO: Add navigation
                  }),
                  _buildOption(context, Icons.logout, 'Logout',
                      iconColor: Colors.red,
                      textColor: Colors.red,
                      onTap: () {
                        _showLogoutDialog(context);
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => Loginpage()),
                              (Route<dynamic> route) => false,
                        );

                      }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        SizedBox(height: 5),
        Text(value, style: TextStyle(color: Colors.white, fontSize: 16)),
        Text(label, style: TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _buildOption(
      BuildContext context,
      IconData icon,
      String title, {
        Color iconColor = const Color(0XFF199A8E),
        Color textColor = Colors.black,
        required VoidCallback onTap,
      }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(title, style: TextStyle(color: textColor)),
      trailing: Icon(Icons.chevron_right, color: Colors.grey),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logout Icon in circle
                Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFEFF9F8),
                  ),
                  child: Icon(Icons.logout, color: Color(0xFF199A8E), size: 32),
                ),
                SizedBox(height: 20),
                // Text
                Text(
                  "Are you sure to log out of your account?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 20),
                // Logout button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close dialog
                      // Add logout logic here
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF199A8E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text("Log Out", style: TextStyle(fontSize: 16,color: Colors.white)),
                  ),
                ),
                SizedBox(height: 10),
                // Cancel button
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                  },
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                      color: Color(0xFF199A8E),
                      fontWeight: FontWeight.w600,
                    ),
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
