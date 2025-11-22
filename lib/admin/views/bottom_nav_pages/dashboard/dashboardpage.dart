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

    final horizontalPadding = w * 0.04;
    final verticalPadding = h * 0.02;
    final gapBetweenCards = w * 0.03;
    final topSpacing = h * 0.02;
    final bottomSpacing = h * 0.03;

    final double cardHeight = 160.0;


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
                          icon: Icons.local_hospital_sharp,
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

              // Row 3: Orders and Appointments
              Row(
                children: [
                  // Total Orders
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: ordersQuery.snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return _StatCard(
                            title: 'Total Orders',
                            value: 0,
                            loading: true,
                            icon: Icons.shopping_bag_rounded,
                            gradient: const [Color(0xFF1E88E5), Color(0xFF42A5F5)],
                            accent: const Color(0xFF2196F3),
                            height: 180,
                          );
                        }
                        if (snapshot.hasError) {
                          return _StatCard(
                            title: 'Total Orders',
                            value: 0,
                            loading: false,
                            icon: Icons.shopping_bag_rounded,
                            gradient: const [Color(0xFF1E88E5), Color(0xFF42A5F5)],
                            accent: const Color(0xFF2196F3),
                            height: 180,
                          );
                        }

                        final docs = snapshot.data?.docs ?? [];
                        int pending = 0;
                        int completed = 0;

                        for (final d in docs) {
                          final status = (d['status'] as String?)?.toLowerCase().trim() ?? '';
                          if (status == 'pending' || status == 'processing') pending++;
                          if (status == 'completed' || status == 'delivered') completed++;
                        }

                        return _StatCard(
                          title: 'Total Orders',
                          value: docs.length,
                          loading: false,
                          icon: Icons.shopping_bag_rounded,
                          gradient: const [Color(0xFF1E88E5), Color(0xFF42A5F5)],
                          accent: const Color(0xFF2196F3),
                          height: 180,
                          sub1Label: 'Pending',
                          sub1Value: pending,
                          sub2Label: 'Completed',
                          sub2Value: completed,
                        );
                      },
                    ),
                  ),
                  SizedBox(width: gapBetweenCards),
                  // Total Appointments
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: appointmentsQuery.snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return _StatCard(
                            title: 'Total Bookings',
                            value: 0,
                            loading: true,
                            icon: Icons.event_available_rounded,
                            gradient: const [Color(0xFF43A047), Color(0xFF66BB6A)],
                            accent: const Color(0xFF4CAF50),
                            height: 180,
                          );
                        }
                        if (snapshot.hasError) {
                          return _StatCard(
                            title: 'Total Bookings',
                            value: 0,
                            loading: false,
                            icon: Icons.event_available_rounded,
                            gradient: const [Color(0xFF43A047), Color(0xFF66BB6A)],
                            accent: const Color(0xFF4CAF50),
                            height: 180,
                          );
                        }

                        final docs = snapshot.data?.docs ?? [];
                        int pending = 0;
                        int confirmed = 0;

                        for (final d in docs) {
                          final status = (d['status'] as String?)?.toLowerCase().trim() ?? '';
                          if (status == 'pending') pending++;
                          if (status == 'confirmed' || status == 'approved') confirmed++;
                        }

                        return _StatCard(
                          title: 'Total Bookings',
                          value: docs.length,
                          loading: false,
                          icon: Icons.event_available_rounded,
                          gradient: const [Color(0xFF43A047), Color(0xFF66BB6A)],
                          accent: const Color(0xFF4CAF50),
                          height: 180,
                          sub1Label: 'Pending',
                          sub1Value: pending,
                          sub2Label: 'Confirmed',
                          sub2Value: confirmed,
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
  final String? sub1Label;
  final int? sub1Value;
  final String? sub2Label;
  final int? sub2Value;

  const _StatCard({
    required this.title,
    required this.value,
    required this.loading,
    required this.icon,
    required this.gradient,
    required this.accent,
    required this.height,
    this.sub1Label,
    this.sub1Value,
    this.sub2Label,
    this.sub2Value,
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
                      : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
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

                        ],
                      ),
                      if ((sub1Label != null && sub1Value != null) ||
                          (sub2Label != null && sub2Value != null)) ...[
                        const SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (sub1Label != null && sub1Value != null)
                              _SubCountChip(
                                label: sub1Label!,
                                value: sub1Value!,
                                textColor: textColor,
                              ),
                            SizedBox(
                              height: 10,
                            ),
                            if (sub2Label != null && sub2Value != null) ...[
                              const SizedBox(width: 8),
                              _SubCountChip(
                                label: sub2Label!,
                                value: sub2Value!,
                                textColor: textColor,
                              ),
                            ],
                          ],
                        ),
                      ],
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

class _SubCountChip extends StatelessWidget {
  final String label;
  final int value;
  final Color textColor;

  const _SubCountChip({
    required this.label,
    required this.value,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.20),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.35)),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w700,
          fontSize: 12,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
