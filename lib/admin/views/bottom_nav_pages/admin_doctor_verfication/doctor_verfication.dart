import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import 'doctor_verfication_detail.dart';

class AdminDoctorVerificationPage extends StatefulWidget {
  const AdminDoctorVerificationPage({super.key});

  @override
  State<AdminDoctorVerificationPage> createState() => _AdminDoctorVerificationPageState();
}

class _AdminDoctorVerificationPageState extends State<AdminDoctorVerificationPage> {
  String selectedFilter = 'all'; // all, verified, pending
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  // Add counters for doctor statistics
  int totalDoctors = 0;
  int verifiedDoctors = 0;
  int pendingDoctors = 0;

  // Method to calculate doctor counts
  void _calculateDoctorCounts(List<QueryDocumentSnapshot> docs) {
    totalDoctors = docs.length;
    verifiedDoctors = 0;
    pendingDoctors = 0;

    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final isVerified = data['isVerified'] ?? false;

      if (isVerified) {
        verifiedDoctors++;
      } else {
        pendingDoctors++;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;
    final isDesktop = screenWidth > 1024;
    final isLargeDesktop = screenWidth > 1440;

    final maxContentWidth = isLargeDesktop ? 1200.0 : (isDesktop ? 900.0 : screenWidth);
    final horizontalPadding = isDesktop ? screenWidth * 0.1 : screenWidth * 0.05;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF199A8E), Color(0xFF17C3B2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          'Doctor Verification Management',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: isDesktop ? 24 : (isTablet ? 22 : 18),
          ),
        ),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        toolbarHeight: isDesktop ? 70 : (isTablet ? 65 : 56),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxContentWidth),
          child: Column(
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('doctor_verification_requests')
                      .orderBy('submittedAt', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    // Calculate doctor counts when data is available
                    if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                      _calculateDoctorCounts(snapshot.data!.docs);
                    } else {
                      totalDoctors = 0;
                      verifiedDoctors = 0;
                      pendingDoctors = 0;
                    }

                    return Column(
                      children: [
                        // Move filter chips here so they can access the counts
                        Container(
                          padding: EdgeInsets.fromLTRB(
                              horizontalPadding,
                              screenHeight * 0.025,
                              horizontalPadding,
                              screenHeight * 0.025),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF199A8E), Color(0xFF17C3B2)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: isDesktop ? 600 : double.infinity,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 20,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: TextField(
                                controller: searchController,
                                onChanged: (value) {
                                  setState(() {
                                    searchQuery = value.toLowerCase();
                                  });
                                },
                                decoration: InputDecoration(
                                  hintText: 'Search doctors by name...',
                                  hintStyle: TextStyle(color: Colors.grey[500]),
                                  prefixIcon: Container(
                                    padding: const EdgeInsets.all(12),
                                    child: Icon(Icons.search,
                                        color: const Color(0xFF199A8E),
                                        size: isDesktop
                                            ? 28
                                            : (isTablet ? 26 : 24)),
                                  ),
                                  suffixIcon: searchQuery.isNotEmpty
                                      ? IconButton(
                                          onPressed: () {
                                            searchController.clear();
                                            setState(() {
                                              searchQuery = '';
                                            });
                                          },
                                          icon: Icon(
                                            Icons.clear,
                                            color: Colors.grey,
                                            size: isDesktop
                                                ? 26
                                                : (isTablet ? 24 : 22),
                                          ),
                                        )
                                      : null,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: screenWidth * 0.05,
                                      vertical: isDesktop
                                          ? 20
                                          : screenHeight * 0.022),
                                ),
                                style: TextStyle(
                                    fontSize:
                                        isDesktop ? 20 : (isTablet ? 18 : 16)),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.fromLTRB(horizontalPadding, 0,
                              horizontalPadding, screenHeight * 0.02),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF199A8E), Color(0xFF17C3B2)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(30),
                              bottomRight: Radius.circular(30),
                            ),
                          ),
                          child: isDesktop
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildFilterChip('All', 'all', Icons.people,
                                        null, screenWidth, isTablet, isDesktop),
                                    SizedBox(width: screenWidth * 0.03),
                                    _buildFilterChip(
                                        'Verified',
                                        'verified',
                                        Icons.verified_user,
                                        Colors.green,
                                        screenWidth,
                                        isTablet,
                                        isDesktop),
                                    SizedBox(width: screenWidth * 0.03),
                                    _buildFilterChip(
                                        'Pending',
                                        'pending',
                                        Icons.pending_actions,
                                        Colors.orange,
                                        screenWidth,
                                        isTablet,
                                        isDesktop),
                                  ],
                                )
                              : isTablet
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        _buildFilterChip(
                                            'All',
                                            'all',
                                            Icons.people,
                                            null,
                                            screenWidth,
                                            isTablet,
                                            isDesktop),
                                        _buildFilterChip(
                                            'Verified',
                                            'verified',
                                            Icons.verified_user,
                                            Colors.green,
                                            screenWidth,
                                            isTablet,
                                            isDesktop),
                                        _buildFilterChip(
                                            'Pending',
                                            'pending',
                                            Icons.pending_actions,
                                            Colors.orange,
                                            screenWidth,
                                            isTablet,
                                            isDesktop),
                                      ],
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Expanded(
                                          child: _buildFilterChip(
                                              'All',
                                              'all',
                                              Icons.people,
                                              null,
                                              screenWidth,
                                              isTablet,
                                              isDesktop),
                                        ),
                                        SizedBox(width: screenWidth * 0.02),
                                        Expanded(
                                          child: _buildFilterChip(
                                              'Verified',
                                              'verified',
                                              Icons.verified_user,
                                              Colors.green,
                                              screenWidth,
                                              isTablet,
                                              isDesktop),
                                        ),
                                        SizedBox(width: screenWidth * 0.02),
                                        Expanded(
                                          child: _buildFilterChip(
                                              'Pending',
                                              'pending',
                                              Icons.pending_actions,
                                              Colors.orange,
                                              screenWidth,
                                              isTablet,
                                              isDesktop),
                                        ),
                                      ],
                                    ),
                        ),

                        // Main content area
                        Expanded(
                          child: _buildMainContent(snapshot, horizontalPadding,
                              screenWidth, screenHeight, isTablet, isDesktop),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, IconData icon, Color? statusColor, double screenWidth, bool isTablet, bool isDesktop) {
    final isSelected = selectedFilter == value;

    // Get count based on filter type
    int count = 0;
    switch (value) {
      case 'all':
        count = totalDoctors;
        break;
      case 'verified':
        count = verifiedDoctors;
        break;
      case 'pending':
        count = pendingDoctors;
        break;
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? screenWidth * 0.025 : screenWidth * 0.03,
            vertical: isDesktop ? 16 : (isTablet ? 12 : 8)),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ] : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: isDesktop ? 22 : (isTablet ? 20 : 16),
              color: isSelected
                  ? (statusColor ?? const Color(0xFF199A8E))
                  : Colors.white,
            ),
            SizedBox(width: screenWidth * 0.01),
            Text(
              isDesktop || isTablet ? '$label ($count)' : label,
              style: TextStyle(
                color: isSelected
                    ? (statusColor ?? const Color(0xFF199A8E))
                    : Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: isDesktop ? 18 : (isTablet ? 16 : 12),
              ),
            ),
            // Show count badge for mobile
            if (!isDesktop && !isTablet && count > 0) ...[
              SizedBox(width: screenWidth * 0.01),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (statusColor ?? const Color(0xFF199A8E))
                      : Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF199A8E),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(
      AsyncSnapshot<QuerySnapshot> snapshot,
      double horizontalPadding,
      double screenWidth, double screenHeight, bool isTablet, bool isDesktop) {
    if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
      // Filter doctors based on selected filter and search query
      final filteredDocs = snapshot.data!.docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final isVerified = data['isVerified'] ?? false;
        final fullName =
            data['basicInfo']?['fullName']?.toString().toLowerCase() ?? '';

        // Apply search filter
        if (searchQuery.isNotEmpty && !fullName.contains(searchQuery)) {
          return false;
        }

        // Apply status filter
        switch (selectedFilter) {
          case 'verified':
            return isVerified;
          case 'pending':
            return !isVerified;
          default:
            return true;
        }
      }).toList();

      if (filteredDocs.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child:
                    Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
              ),
              const SizedBox(height: 16),
              Text(
                'No doctors match your criteria',
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                'Try adjusting your search or filters',
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: screenWidth * 0.05,
        ),
        itemCount: filteredDocs.length,
        itemBuilder: (context, index) {
          final doc = filteredDocs[index];
          final data = doc.data() as Map<String, dynamic>;
          return _buildDoctorCard(
              data, doc.id, screenWidth, screenHeight, isTablet, isDesktop);
        },
      );
    } else if (snapshot.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child:
                  Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading doctors',
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Please try again later',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    } else if (snapshot.connectionState == ConnectionState.waiting) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(screenWidth * 0.05),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF199A8E).withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: CircularProgressIndicator(
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Color(0xFF199A8E)),
                strokeWidth: isTablet ? 4 : 3,
              ),
            ),
            SizedBox(height: screenHeight * 0.025),
            Text(
              'Loading doctors...',
              style: TextStyle(
                fontSize: isTablet ? 18 : 16,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    } else {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child:
                  Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
            ),
            const SizedBox(height: 16),
            Text(
              'No doctors found',
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'No verification requests yet',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildDoctorCard(Map<String, dynamic> data, String docId, double screenWidth, double screenHeight, bool isTablet, bool isDesktop) {
    final basicInfo = data['basicInfo'] ?? {};
    final professionalDetails = data['professionalDetails'] ?? {};
    final documents = data['documents'] ?? {};
    final isVerified = data['isVerified'] ?? false;
    final verificationStatus = data['verificationStatus'] ?? 'pending';
    final submittedAt = data['submittedAt'] as Timestamp?;

    return Container(
      margin: EdgeInsets.only(bottom: screenHeight * 0.025),
      constraints: BoxConstraints(
        maxWidth: isDesktop ? 800 : double.infinity,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
        ],
        border: Border.all(
          color: isVerified
              ? Colors.green.withOpacity(0.3)
              : Colors.orange.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(isDesktop ? screenWidth * 0.04 : screenWidth * 0.06),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            isDesktop || isTablet
                ? Row(
              children: [
                _buildProfileSection(documents, isVerified, screenWidth, isTablet, isDesktop),
                SizedBox(width: screenWidth * 0.05),
                Expanded(
                  child: _buildDoctorInfo(basicInfo, professionalDetails, isVerified, screenWidth, isTablet, isDesktop),
                ),
              ],
            )
                : Column(
              children: [
                Row(
                  children: [
                    _buildProfileSection(documents, isVerified, screenWidth, isTablet, isDesktop),
                    SizedBox(width: screenWidth * 0.05),
                    Expanded(
                      child: _buildDoctorInfo(basicInfo, professionalDetails, isVerified, screenWidth, isTablet, isDesktop),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.03),
            Container(
              padding: EdgeInsets.all(isDesktop ? screenWidth * 0.03 : screenWidth * 0.05),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.grey[50] ?? Colors.grey.shade50, Colors.grey[100] ?? Colors.grey.shade100],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200] ?? Colors.grey.shade200, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(Icons.business, 'Clinic', professionalDetails['clinicName'] ?? 'Not specified', screenWidth, isTablet, isDesktop),
                  SizedBox(height: screenHeight * 0.015),
                  _buildInfoRow(Icons.phone, 'Contact', basicInfo['contactNumber'] ?? 'Not specified', screenWidth, isTablet, isDesktop),
                  SizedBox(height: screenHeight * 0.015),
                  _buildInfoRow(Icons.email, 'Email', basicInfo['email'] ?? 'Not specified', screenWidth, isTablet, isDesktop),
                  SizedBox(height: screenHeight * 0.015),
                  _buildInfoRow(Icons.badge, 'Registration', professionalDetails['registrationNumber'] ?? 'Not specified', screenWidth, isTablet, isDesktop),
                  SizedBox(height: screenHeight * 0.015),
                  _buildInfoRow(
                      Icons.attach_money,
                      'Consultation Fee',
                      professionalDetails['consultationFee']?.toString() ??
                          'Not specified',
                      screenWidth,
                      isTablet,
                      isDesktop),
                  if (submittedAt != null) ...[
                    SizedBox(height: screenHeight * 0.015),
                    _buildInfoRow(Icons.schedule, 'Submitted', _formatDate(submittedAt.toDate()), screenWidth, isTablet, isDesktop),
                  ],
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.025),
            isDesktop || isTablet
                ? Row(
              children: _buildActionButtons(isVerified, data, docId, screenWidth, isTablet, isDesktop),
            )
                : Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: _buildViewDetailsButton(data, docId, screenWidth, isTablet, isDesktop),
                ),
                if (!isVerified) ...[
                  SizedBox(height: screenHeight * 0.015),
                  SizedBox(
                    width: double.infinity,
                    child: _buildApproveButton(docId, data, screenWidth, isTablet, isDesktop),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(Map<String, dynamic> documents, bool isVerified, double screenWidth, bool isTablet, bool isDesktop) {
    final profileSize = isDesktop ? screenWidth * 0.08 : (isTablet ? screenWidth * 0.12 : screenWidth * 0.2);

    return Stack(
      children: [
        Container(
          width: profileSize,
          height: profileSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: isVerified
                  ? [Colors.green.withOpacity(0.2), Colors.green.withOpacity(0.1)]
                  : [Colors.orange.withOpacity(0.2), Colors.orange.withOpacity(0.1)],
            ),
            border: Border.all(
              color: isVerified ? Colors.green : Colors.orange,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: (isVerified ? Colors.green : Colors.orange).withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipOval(
            child: documents['profilePicture'] != null
                ? Image.network(
              documents['profilePicture'],
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.grey[300]!, Colors.grey[200]!],
                    ),
                  ),
                  child: Icon(
                      Icons.person,
                      size: profileSize * 0.5,
                      color: Colors.grey
                  ),
                );
              },
            )
                : Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.grey[300]!, Colors.grey[200]!],
                ),
              ),
              child: Icon(
                  Icons.person,
                  size: profileSize * 0.5,
                  color: Colors.grey
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            padding: EdgeInsets.all(screenWidth * 0.01),
            decoration: BoxDecoration(
              color: isVerified ? Colors.green : Colors.orange,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 5,
                ),
              ],
            ),
            child: Icon(
              isVerified ? Icons.verified : Icons.pending,
              size: isDesktop ? 20 : (isTablet ? 18 : 16),
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDoctorInfo(Map<String, dynamic> basicInfo, Map<String, dynamic> professionalDetails, bool isVerified, double screenWidth, bool isTablet, bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          basicInfo['fullName'] ?? 'Unknown Doctor',
          style: TextStyle(
            fontSize: isDesktop ? 28 : (isTablet ? 24 : 20),
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
        SizedBox(height: screenWidth * 0.015),
        Text(
          professionalDetails['specialization'] ?? 'General Veterinarian',
          style: TextStyle(
            fontSize: isDesktop ? 20 : (isTablet ? 18 : 16),
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        SizedBox(height: screenWidth * 0.03),
        Container(
          padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04,
              vertical: isDesktop ? 12 : screenWidth * 0.02
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isVerified
                  ? [Colors.green.withOpacity(0.15), Colors.green.withOpacity(0.05)]
                  : [Colors.orange.withOpacity(0.15), Colors.orange.withOpacity(0.05)],
            ),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: isVerified ? Colors.green : Colors.orange,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isVerified ? Icons.verified : Icons.pending,
                size: isDesktop ? 22 : (isTablet ? 20 : 18),
                color: isVerified ? Colors.green : Colors.orange,
              ),
              SizedBox(width: screenWidth * 0.015),
              Flexible(
                child: Text(
                  isVerified ? 'Verified' : 'Pending Approval',
                  style: TextStyle(
                    fontSize: isDesktop ? 17 : (isTablet ? 15 : 13),
                    fontWeight: FontWeight.w700,
                    color: isVerified ? Colors.green : Colors.orange,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildActionButtons(bool isVerified, Map<String, dynamic> data, String docId, double screenWidth, bool isTablet, bool isDesktop) {
    List<Widget> buttons = [
      Expanded(
        child: _buildViewDetailsButton(data, docId, screenWidth, isTablet, isDesktop),
      ),
    ];

    if (!isVerified) {
      buttons.addAll([
        SizedBox(width: screenWidth * 0.04),
        Expanded(
          child: _buildApproveButton(docId, data, screenWidth, isTablet, isDesktop),
        ),
      ]);
    }

    return buttons;
  }

  Widget _buildViewDetailsButton(Map<String, dynamic> data, String docId, double screenWidth, bool isTablet, bool isDesktop) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF199A8E), Color(0xFF17C3B2)],
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF199A8E).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () => _viewDoctorDetails(data, docId),
        icon: Icon(
            Icons.visibility,
            size: isDesktop ? 24 : (isTablet ? 22 : 20)
        ),
        label: Text(
            'View Details',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: isDesktop ? 18 : (isTablet ? 16 : 14),
            )
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.symmetric(vertical: isDesktop ? 18 : screenWidth * 0.035),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }

  Widget _buildApproveButton(String docId, Map<String, dynamic> data, double screenWidth, bool isTablet, bool isDesktop) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.green, Color(0xFF4CAF50)],
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () => _approveDoctor(docId, data),
        icon: Icon(
            Icons.check_circle,
            size: isDesktop ? 24 : (isTablet ? 22 : 20)
        ),
        label: Text(
            'Approve',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: isDesktop ? 18 : (isTablet ? 16 : 14),
            )
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.symmetric(vertical: isDesktop ? 18 : screenWidth * 0.035),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, double screenWidth, bool isTablet, bool isDesktop) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(isDesktop ? screenWidth * 0.015 : screenWidth * 0.02),
          decoration: BoxDecoration(
            color: const Color(0xFF199A8E).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
              icon,
              size: isDesktop ? 22 : (isTablet ? 20 : 18),
              color: const Color(0xFF199A8E)
          ),
        ),
        SizedBox(width: screenWidth * 0.03),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: isDesktop ? 19 : (isTablet ? 17 : 15),
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: isDesktop ? 19 : (isTablet ? 17 : 15),
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _viewDoctorDetails(Map<String, dynamic> data, String docId) {
    // Navigate to detailed view page
    Get.to(() => DoctorDetailPage(doctorData: data, doctorId: docId));
  }

  void _approveDoctor(String docId, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.check_circle, color: Colors.green),
            ),
            const SizedBox(width: 12),
            const Text('Approve Doctor'),
          ],
        ),
        content: Text('Are you sure you want to approve ${data['basicInfo']?['fullName'] ?? 'this doctor'}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Colors.green, Color(0xFF4CAF50)]),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _updateDoctorVerification(docId, data['userId']);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
              ),
              child: const Text('Approve', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateDoctorVerification(String docId, String? userId) async {
    try {
      // Update verification request
      await FirebaseFirestore.instance
          .collection('doctor_verification_requests')
          .doc(docId)
          .update({
        'isVerified': true,
        'verificationStatus': 'approved',
        'approvedAt': FieldValue.serverTimestamp(),
      });

      // Update user document
      if (userId != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({
          'isVerified': true,
          'verificationStatus': 'approved',
        });
      }

      Get.snackbar(
        'Success',
        'Doctor has been approved successfully!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        borderRadius: 10,
        margin: const EdgeInsets.all(16),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to approve doctor: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        borderRadius: 10,
        margin: const EdgeInsets.all(16),
      );
    }
  }
}
