import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  String? _error;

  void _setErrorOnce(String message) {
    if (_error == null) {
      setState(() {
        _error = message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;

    final horizontalPadding = w * 0.04; // 4% of width
    final verticalPadding = h * 0.02; // 2% of height
    final gapBetweenCards = w * 0.03; // 3% of width
    final topSpacing = h * 0.02;
    final bottomSpacing = h * 0.03;

    // Card height responsive with sane min/max to prevent overflow
    final double cardHeight = (h * 0.25).clamp(140.0, 220.0) as double;

    // Queries
    final Query usersQuery = FirebaseFirestore.instance.collection('users');
    final Query ordersQuery = FirebaseFirestore.instance.collection('orders');
    final Query appointmentsQuery = FirebaseFirestore.instance.collection('appointments');

    // If doctors are in the same "users" collection with a boolean "isDoctor":
    final Query doctorsQuery = FirebaseFirestore.instance
        .collection('users')
        .where('isDoctor', isEqualTo: true);
    // Products collection
    final Query productsQuery =
    FirebaseFirestore.instance.collection('products');

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0XFF199A8E),
            fontFamily: "bolditalic",
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            setState(() {});
            await Future.delayed(const Duration(milliseconds: 350));
          },
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              verticalPadding,
              horizontalPadding,
              bottomSpacing,
            ),
            children: [
              SizedBox(height: topSpacing),

              // Row 1: Users and Doctors
              Row(
                children: [
                  // Total Users
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: usersQuery.snapshots(),
                      builder: (context, snapshot) {
                        final loading =
                            snapshot.connectionState == ConnectionState.waiting;
                        final value =
                        snapshot.hasData ? snapshot.data!.size : 0;

                        if (snapshot.hasError) {
                          _setErrorOnce(
                            'Failed to load users: ${snapshot.error}',
                          );
                        }

                        return _StatCard(
                          title: 'Total Users',
                          value: value,
                          loading: loading,
                          icon: Icons.group_rounded,
                          gradient: const [
                            Color(0xFF6A8DFF),
                            Color(0xFF8A6BFF),
                          ],
                          accent: const Color(0xFF3D5AFE),
                          height: cardHeight,
                        );
                      },
                    ),
                  ),
                  SizedBox(width: gapBetweenCards),
                  // Total Doctors
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: doctorsQuery.snapshots(),
                      builder: (context, snapshot) {
                        final loading =
                            snapshot.connectionState == ConnectionState.waiting;
                        final value =
                        snapshot.hasData ? snapshot.data!.size : 0;

                        if (snapshot.hasError) {
                          _setErrorOnce(
                            'Failed to load doctors: ${snapshot.error}',
                          );
                        }

                        return _StatCard(
                          title: 'Total Doctors',
                          value: value,
                          loading: loading,
                          icon: Icons.local_hospital_rounded,
                          gradient: const [
                            Color(0xFF2ECC71),
                            Color(0xFF27AE60),
                          ],
                          accent: const Color(0xFF1B5E20),
                          height: cardHeight,
                        );
                      },
                    ),
                  ),
                ],
              ),

              SizedBox(height: gapBetweenCards),

              // Row 2: Products
              Row(
                children: [
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: productsQuery.snapshots(),
                      builder: (context, snapshot) {
                        final loading =
                            snapshot.connectionState == ConnectionState.waiting;
                        final value =
                        snapshot.hasData ? snapshot.data!.size : 0;

                        if (snapshot.hasError) {
                          _setErrorOnce(
                            'Failed to load products: ${snapshot.error}',
                          );
                        }

                        return _StatCard(
                          title: 'Total Products',
                          value: value,
                          loading: loading,
                          icon: Icons.inventory_2_rounded,
                          gradient: const [
                            Color(0xFFFFA726), // orange
                            Color(0xFFFF7043), // deep orange
                          ],
                          accent: const Color(0xFFFF6D00),
                          height: cardHeight,
                        );
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: gapBetweenCards),


              Row(
                children: [
                  // Total Users
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: ordersQuery.snapshots(),
                      builder: (context, snapshot) {
                        final loading =
                            snapshot.connectionState == ConnectionState.waiting;
                        final value =
                        snapshot.hasData ? snapshot.data!.size : 0;

                        if (snapshot.hasError) {
                          _setErrorOnce(
                            'Failed to load Orders: ${snapshot.error}',
                          );
                        }

                        return _StatCard(
                          title: 'Total Orders',
                          value: value,
                          loading: loading,
                          icon: Icons.group_rounded,
                          gradient: const [
                            Color(0xFF199A8E),
                            Color(0xFF3DCF71),
                          ],
                          accent: const Color(0xFF3D5AFE),
                          height: cardHeight,
                        );
                      },
                    ),
                  ),
                  SizedBox(width: gapBetweenCards),
                  // Total Doctors
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: appointmentsQuery.snapshots(),
                      builder: (context, snapshot) {
                        final loading =
                            snapshot.connectionState == ConnectionState.waiting;
                        final value =
                        snapshot.hasData ? snapshot.data!.size : 0;

                        if (snapshot.hasError) {
                          _setErrorOnce(
                            'Failed to load Appointments: ${snapshot.error}',
                          );
                        }

                        return _StatCard(
                          title: 'Total Appointments',
                          value: value,
                          loading: loading,
                          icon: Icons.local_hospital_rounded,
                          gradient: const [
                            Color(0xFF8EC5FC), // light blue
                            Color(0xFFE0C3FC), // soft purple
                          ],
                          accent: const Color(0xFF6A82FB),
                          height: cardHeight,
                        );
                      },
                    ),
                  ),
                ],
              ),

              SizedBox(height: gapBetweenCards),

              if (_error != null) ...[
                SizedBox(height: topSpacing),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withOpacity(0.2)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _error!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => setState(() => _error = null),
                        icon: const Icon(Icons.close, color: Colors.red),
                        tooltip: 'Dismiss',
                      )
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final int value;
  final bool loading;
  final IconData icon;
  final List<Color> gradient;
  final Color accent;
  final double height;

  const _StatCard({
    required this.title,
    required this.value,
    required this.loading,
    required this.icon,
    required this.gradient,
    required this.accent,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = Colors.white;
    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: gradient.last.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            right: -20,
            top: -20,
            child: _Bubble(color: Colors.white.withOpacity(0.12), size: 120),
          ),
          Positioned(
            left: -30,
            bottom: -30,
            child: _Bubble(color: Colors.white.withOpacity(0.08), size: 160),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: textColor.withOpacity(0.95), size: 28),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: TextStyle(
                    color: textColor.withOpacity(0.95),
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    letterSpacing: 0.2,
                  ),
                ),
                const Spacer(),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: loading
                      ? Row(
                    children: [
                      SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor:
                          AlwaysStoppedAnimation<Color>(textColor),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Loading...',
                        style: TextStyle(
                          color: textColor.withOpacity(0.9),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                      : Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$value',
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w900,
                          fontSize: 36,
                          height: 0.9,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.35),
                          ),
                        ),
                        child: Text(
                          'Live Update',
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final Color color;
  final double size;

  const _Bubble({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration:
      BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}