import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  String? _error;

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

    // Adjust these queries to match your collections/fields
    final Query usersQuery = FirebaseFirestore.instance.collection('users');
    // If doctors are in the same "users" collection with a boolean "isDoctor":
    final Query doctorsQuery = FirebaseFirestore.instance
        .collection('users')
        .where('isDoctor', isEqualTo: true);
    // If doctors are in a separate collection, use the following instead:
    // final Query doctorsQuery = FirebaseFirestore.instance.collection('doctors');

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
            // With streams, data is live. This just triggers a visual refresh.
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
              Row(
                children: [
                  // Total Users
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: usersQuery.snapshots(),
                      builder: (context, snapshot) {
                        final loading =
                            snapshot.connectionState == ConnectionState.waiting;
                        final value = snapshot.hasData
                            ? snapshot.data!.size
                            : 0;

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
                            Color(0xFF8A6BFF)
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
                        final value = snapshot.hasData
                            ? snapshot.data!.size
                            : 0;

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
                            Color(0xFF20C997)
                          ],
                          accent: const Color(0xFF17A673),
                          height: cardHeight,
                        );
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: bottomSpacing),
              if (_error != null)
                _ErrorCard(
                  message: _error!,
                  onRetry: () async {
                    setState(() => _error = null);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _setErrorOnce(String message) {
    if (_error == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _error = message);
      });
    }
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
    // MediaQuery driven sizes inside the card
    final size = MediaQuery.of(context).size;
    final w = size.width;

    final cardRadius = 20.0;
    final outerPadding = w * 0.04; // responsive padding
    final iconBgOpacity = 0.2;

    // Decorative bubble sizes scaled by card height
    final bigBubbleSize = height * 0.55;
    final smallBubbleSize = height * 0.43;

    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(cardRadius),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -bigBubbleSize * 0.22,
            top: -bigBubbleSize * 0.22,
            child: _Bubble(
              color: Colors.white.withOpacity(0.15),
              size: bigBubbleSize,
            ),
          ),
          Positioned(
            left: -smallBubbleSize * 0.17,
            bottom: -smallBubbleSize * 0.2,
            child: _Bubble(
              color: Colors.white.withOpacity(0.12),
              size: smallBubbleSize,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(outerPadding.clamp(12.0, 18.0)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _IconBadge(icon: icon, bg: Colors.white.withOpacity(iconBgOpacity)),
                const Spacer(),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: height * 0.035),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  transitionBuilder: (child, anim) =>
                      FadeTransition(opacity: anim, child: child),
                  child: loading
                      ? _Skeleton(
                    key: const ValueKey('skeleton'),
                    width: (w * 0.16).clamp(48.0, 84.0),
                    height: (height * 0.2).clamp(26.0, 38.0),
                    radius: 8,
                  )
                      : Text(
                    '$value',
                    key: ValueKey(value),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: (height * 0.2).clamp(24.0, 36.0),
                      fontWeight: FontWeight.w900,
                      height: 1.0,
                    ),
                  ),
                ),
                SizedBox(height: height * 0.02),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: (w * 0.025).clamp(8.0, 12.0),
                    vertical: (height * 0.035).clamp(6.0, 8.0),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white24, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.trending_up_rounded, color: Colors.white, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Live Firestore',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.95),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
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
      width: size,
      height: size,
      decoration:
      BoxDecoration(color: color, shape: BoxShape.circle, boxShadow: [
        BoxShadow(color: color.withOpacity(0.2), blurRadius: 12, spreadRadius: 2)
      ]),
    );
  }
}

class _IconBadge extends StatelessWidget {
  final IconData icon;
  final Color bg;
  const _IconBadge({required this.icon, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:
      BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.all(10),
      child: Icon(icon, color: Colors.white, size: 22),
    );
  }
}

class _Skeleton extends StatefulWidget {
  final double width;
  final double height;
  final double radius;

  const _Skeleton({
    super.key,
    required this.width,
    required this.height,
    this.radius = 10,
  });

  @override
  State<_Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<_Skeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
  AnimationController(vsync: this, duration: const Duration(seconds: 1))
    ..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 0.4, end: 1.0).animate(_c),
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.45),
          borderRadius: BorderRadius.circular(widget.radius),
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _ErrorCard({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    // Responsive paddings using MediaQuery
    final size = MediaQuery.of(context).size;
    final pad = (size.width * 0.035).clamp(10.0, 16.0);

    return Container(
      padding: EdgeInsets.all(pad),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        border: Border.all(color: Colors.red.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: Colors.red.shade400),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.red.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
