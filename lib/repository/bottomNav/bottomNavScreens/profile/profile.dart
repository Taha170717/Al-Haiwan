import 'package:al_haiwan/repository/bottomNav/bottomNavScreens/profile/profile_viewmodal.dart';
import 'package:al_haiwan/repository/screens/login/loginpage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Profilescreen extends StatelessWidget {
  final ProfileViewModel controller = Get.put(ProfileViewModel());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF199A8E),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 80),
              const CircleAvatar(
                radius: 40,
                backgroundImage: AssetImage('assets/images/user.png'),
              ),
              const SizedBox(height: 10),
              Obx(() => Text(
                controller.name.value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              )),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: const [
                    _StatWidget(label: 'Heart rate', value: '215bpm', icon: Icons.favorite),
                    _StatWidget(label: 'Calories', value: '756cal', icon: Icons.local_fire_department),
                    _StatWidget(label: 'Weight', value: '103lbs', icon: Icons.fitness_center),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: const BoxDecoration(
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
                    _buildOption(
                      context,
                      Icons.logout,
                      'Logout',
                      iconColor: Colors.red,
                      textColor: Colors.red,
                      onTap: () => _showLogoutDialog(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOption(
      BuildContext context,
      IconData icon,
      String title, {
        Color iconColor = const Color(0xFF199A8E),
        Color textColor = Colors.black,
        required VoidCallback onTap,
      }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(title, style: TextStyle(color: textColor)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFEFF9F8),
                  ),
                  child: const Icon(Icons.logout, color: Color(0xFF199A8E), size: 32),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Are you sure to log out of your account?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close dialog
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => Loginpage()),
                            (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF199A8E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text("Log Out", style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
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

class _StatWidget extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatWidget({
    Key? key,
    required this.label,
    required this.value,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 5),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 16)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}
