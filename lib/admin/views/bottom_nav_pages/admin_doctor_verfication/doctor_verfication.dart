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

  static const Color primaryColor = Color(0xFF199A8E);
  static const Color secondaryColor = Color(0xFF147E75);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // Custom header with gradient and curved bottom
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [primaryColor, secondaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.18),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(28, 56, 28, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  'Doctor Verification',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 32,
                    letterSpacing: 0.7,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        offset: const Offset(0, 3),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Subtitle
                Text(
                  'Manage doctor verification requests',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 24),

                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
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
                      prefixIcon: Icon(Icons.search, color: primaryColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    ),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 24),

                // Filter Chips
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildFilterChip('All', 'all'),
                    _buildFilterChip('Verified', 'verified'),
                    _buildFilterChip('Pending', 'pending'),
                  ],
                ),
              ],
            ),
          ),

          // Expanded list area
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('doctor_verification_requests')
                  .orderBy('submittedAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading doctors',
                          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No doctors found',
                          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                // Filter doctors based on selected filter and search query
                final filteredDocs = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final isVerified = data['isVerified'] ?? false;
                  final fullName = data['basicInfo']?['fullName']?.toString().toLowerCase() ?? '';

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
                        Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No doctors match your criteria',
                          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    final doc = filteredDocs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    return _buildDoctorCard(data, doc.id);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = selectedFilter == value;
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : primaryColor,
          fontWeight: FontWeight.w700,
          fontSize: 14,
          letterSpacing: 0.3,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          selectedFilter = value;
        });
      },
      backgroundColor: Colors.white,
      selectedColor: primaryColor,
      checkmarkColor: Colors.white,
      elevation: 3,
      shadowColor: Colors.black26,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      labelPadding: const EdgeInsets.symmetric(horizontal: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    );
  }

  Widget _buildDoctorCard(Map<String, dynamic> data, String docId) {
    final basicInfo = data['basicInfo'] ?? {};
    final professionalDetails = data['professionalDetails'] ?? {};
    final documents = data['documents'] ?? {};
    final isVerified = data['isVerified'] ?? false;
    final submittedAt = data['submittedAt'] as Timestamp?;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Profile Picture with border and shadow
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isVerified ? Colors.green.shade600 : Colors.orange.shade700,
                      width: 3.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
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
                          color: Colors.grey[200],
                          child: const Icon(Icons.person, size: 44, color: Colors.grey),
                        );
                      },
                    )
                        : Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.person, size: 44, color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                // Name and Status
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        basicInfo['fullName'] ?? 'Unknown Doctor',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Colors.black87,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        professionalDetails['specialization'] ?? 'General Veterinarian',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Verification Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: isVerified ? Colors.green.shade100 : Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isVerified ? Colors.green.shade600 : Colors.orange.shade700,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (isVerified ? Colors.green : Colors.orange).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isVerified ? Icons.verified : Icons.pending,
                              size: 18,
                              color: isVerified ? Colors.green.shade700 : Colors.orange.shade700,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isVerified ? 'Verified' : 'Pending',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isVerified ? Colors.green.shade700 : Colors.orange.shade700,
                                letterSpacing: 0.2,
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
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(Icons.business, 'Clinic', professionalDetails['clinicName'] ?? 'Not specified'),
                  const SizedBox(height: 12),
                  _buildInfoRow(Icons.phone, 'Contact', basicInfo['contactNumber'] ?? 'Not specified'),
                  const SizedBox(height: 12),
                  _buildInfoRow(Icons.email, 'Email', basicInfo['email'] ?? 'Not specified'),
                  const SizedBox(height: 12),
                  _buildInfoRow(Icons.badge, 'Registration', professionalDetails['registrationNumber'] ?? 'Not specified'),
                  if (submittedAt != null) ...[
                    const SizedBox(height: 12),
                    _buildInfoRow(Icons.schedule, 'Submitted', _formatDate(submittedAt.toDate())),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _viewDoctorDetails(data, docId),
                    icon: const Icon(Icons.visibility, size: 20),
                    label: const Text('View Details'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 6,
                      shadowColor: primaryColor.withOpacity(0.6),
                    ),
                  ),
                ),
                if (!isVerified) ...[
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _approveDoctor(docId, data),
                      icon: const Icon(Icons.check_circle, size: 20),
                      label: const Text('Approve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 6,
                        shadowColor: Colors.green.shade600.withOpacity(0.6),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: primaryColor),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[800],
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _viewDoctorDetails(Map<String, dynamic> data, String docId) {
    Get.to(() => DoctorDetailPage(doctorData: data, doctorId: docId));
  }

  void _approveDoctor(String docId, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Approve Doctor'),
        content: Text('Are you sure you want to approve ${data['basicInfo']?['fullName'] ?? 'this doctor'}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _updateDoctorVerification(docId, data['userId']);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateDoctorVerification(String docId, String userId) async {
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
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
        duration: const Duration(seconds: 3),
        animationDuration: const Duration(milliseconds: 400),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to approve doctor: $e',
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
        duration: const Duration(seconds: 4),
        animationDuration: const Duration(milliseconds: 400),
      );
    }
  }
}
