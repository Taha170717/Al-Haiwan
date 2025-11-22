import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DoctorDashboard extends StatefulWidget {
  const DoctorDashboard({super.key});

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  String? _error;
  final String? _currentDoctorId = FirebaseAuth.instance.currentUser?.uid;

  void _setErrorOnce(String message) {
    if (_error == null) {
      setState(() {
        _error = message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentDoctorId == null) {
      return const Scaffold(
        body: Center(
          child: Text('Please login to continue'),
        ),
      );
    }

    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;

    final horizontalPadding = w * 0.04;
    final verticalPadding = h * 0.02;
    final gapBetweenCards = w * 0.03;
    final topSpacing = h * 0.02;
    final bottomSpacing = h * 0.03;

    final double cardHeight = 160;

    // Query for doctor's appointments
    final Query appointmentsQuery = FirebaseFirestore.instance
        .collection('appointments')
        .where('doctorId', isEqualTo: _currentDoctorId);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'My Dashboard',
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
          child: StreamBuilder<QuerySnapshot>(
            stream: appointmentsQuery.snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Color(0XFF199A8E),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }

              final docs = snapshot.data?.docs ?? [];
              
              // Calculate statistics
              int totalAppointments = docs.length;
              int pending = 0;
              int confirmed = 0;
              int completed = 0;
              int cancelled = 0;
              double totalRevenue = 0.0;

              for (final doc in docs) {
                final data = doc.data() as Map<String, dynamic>;
                final status = (data['status'] as String?)?.toLowerCase().trim() ?? '';
                
                if (status == 'pending') {
                  pending++;
                } else if (status == 'confirmed' || status == 'approved' || status == 'paymentVerified') {
                  confirmed++;
                } else if (status == 'completed') {
                  completed++;
                  // Add to revenue only for completed appointments
                  final fee = data['consultationFee'];
                  if (fee != null) {
                    totalRevenue += (fee is int) ? fee.toDouble() : (fee as double);
                  }
                } else if (status == 'cancelled' || status == 'rejected') {
                  cancelled++;
                }
              }

              return ListView(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  verticalPadding,
                  horizontalPadding,
                  bottomSpacing,
                ),
                children: [
                  SizedBox(height: topSpacing),

                  // Row 1: Total Appointments and Revenue
                  Row(
                    children: [
                      // Total Appointments
                      Expanded(
                        child: _StatCard(
                          title: 'Total Appointments',
                          value: totalAppointments,
                          loading: false,
                          icon: Icons.event_note_rounded,
                          gradient: const [
                            Color(0xFF6A8DFF),
                            Color(0xFF8A6BFF),
                          ],
                          accent: const Color(0xFF3D5AFE),
                          height: cardHeight,
                        ),
                      ),
                      SizedBox(width: gapBetweenCards),
                      // Total Revenue
                      Expanded(
                        child: _RevenueCard(
                          title: 'Total Revenue',
                          value: totalRevenue,
                          loading: false,
                          icon: Icons.attach_money_rounded,
                          gradient: const [
                            Color(0xFF2ECC71),
                            Color(0xFF27AE60),
                          ],
                          accent: const Color(0xFF1B5E20),
                          height: cardHeight,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: gapBetweenCards),

                  // Row 2: Pending and Confirmed
                  Row(
                    children: [
                      // Pending Appointments
                      Expanded(
                        child: _StatCard(
                          title: 'Pending',
                          value: pending,
                          loading: false,
                          icon: Icons.hourglass_empty_rounded,
                          gradient: const [
                            Color(0xFFFFA726),
                            Color(0xFFFF7043),
                          ],
                          accent: const Color(0xFFFF6D00),
                          height: cardHeight,
                        ),
                      ),
                      SizedBox(width: gapBetweenCards),
                      // Confirmed Appointments
                      Expanded(
                        child: _StatCard(
                          title: 'Confirmed',
                          value: confirmed,
                          loading: false,
                          icon: Icons.check_circle_rounded,
                          gradient: const [
                            Color(0xFF1E88E5),
                            Color(0xFF42A5F5),
                          ],
                          accent: const Color(0xFF2196F3),
                          height: cardHeight,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: gapBetweenCards),

                  // Row 3: Completed and Cancelled
                  Row(
                    children: [
                      // Completed Appointments
                      Expanded(
                        child: _StatCard(
                          title: 'Completed',
                          value: completed,
                          loading: false,
                          icon: Icons.task_alt_rounded,
                          gradient: const [
                            Color(0xFF43A047),
                            Color(0xFF66BB6A),
                          ],
                          accent: const Color(0xFF4CAF50),
                          height: cardHeight,
                        ),
                      ),
                      SizedBox(width: gapBetweenCards),
                      // Cancelled Appointments
                      Expanded(
                        child: _StatCard(
                          title: 'Cancelled',
                          value: cancelled,
                          loading: false,
                          icon: Icons.cancel_rounded,
                          gradient: const [
                            Color(0xFFE53935),
                            Color(0xFFEF5350),
                          ],
                          accent: const Color(0xFFD32F2F),
                          height: cardHeight,
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
              );
            },
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: textColor.withOpacity(0.95), size: 32),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: textColor.withOpacity(0.95),
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    loading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(textColor),
                            ),
                          )
                        : Text(
                            '$value',
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.w900,
                              fontSize: 25,
                              height: 1,
                            ),
                          ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RevenueCard extends StatelessWidget {
  final String title;
  final double value;
  final bool loading;
  final IconData icon;
  final List<Color> gradient;
  final Color accent;
  final double height;

  const _RevenueCard({
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: textColor.withOpacity(0.95), size: 32),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: textColor.withOpacity(0.95),
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    loading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(textColor),
                            ),
                          )
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'PKR ',
                                style: TextStyle(
                                  color: textColor.withOpacity(0.9),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  height: 1.8,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  value.toStringAsFixed(0),
                                  style: TextStyle(
                                    color: textColor,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 25,
                                    height: 1,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                  ],
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
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
