import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:photo_view/photo_view.dart';

class DoctorDetailPage extends StatefulWidget {
  final Map<String, dynamic> doctorData;
  final String doctorId;

  const DoctorDetailPage({
    super.key,
    required this.doctorData,
    required this.doctorId,
  });

  @override
  State<DoctorDetailPage> createState() => _DoctorDetailPageState();
}

class _DoctorDetailPageState extends State<DoctorDetailPage> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;
    final isDesktop = screenWidth > 1024;
    final isLargeDesktop = screenWidth > 1440;

    final maxContentWidth = isLargeDesktop ? 1000.0 : (isDesktop ? 800.0 : screenWidth);
    final horizontalPadding = isDesktop ? screenWidth * 0.1 : screenWidth * 0.05;

    return Scaffold(
      backgroundColor: Colors.grey[50]!,
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
          'Doctor Details',
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
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: screenWidth * 0.05,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(isDesktop ? 32 : 24),
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
                  ),
                  child: isDesktop
                      ? Row(
                    children: [
                      _buildProfilePicture(isDesktop, screenWidth),
                      SizedBox(width: 32),
                      Expanded(
                        child: _buildDoctorHeader(isDesktop, isTablet),
                      ),
                    ],
                  )
                      : Column(
                    children: [
                      _buildProfilePicture(isDesktop, screenWidth),
                      SizedBox(height: 24),
                      _buildDoctorHeader(isDesktop, isTablet),
                    ],
                  ),
                ),

                SizedBox(height: isDesktop ? 32 : 24),

                if (isDesktop)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            _buildBasicInfoSection(isDesktop, isTablet),
                            SizedBox(height: 24),
                            _buildProfessionalDetailsSection(isDesktop, isTablet),
                          ],
                        ),
                      ),
                      SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          children: [
                            _buildDocumentsSection(isDesktop, isTablet),
                            SizedBox(height: 24),
                            _buildActionSection(isDesktop, isTablet),
                          ],
                        ),
                      ),
                    ],
                  )
                else
                  Column(
                    children: [
                      _buildBasicInfoSection(isDesktop, isTablet),
                      SizedBox(height: 24),
                      _buildProfessionalDetailsSection(isDesktop, isTablet),
                      SizedBox(height: 24),
                      _buildDocumentsSection(isDesktop, isTablet),
                      SizedBox(height: 24),
                      _buildActionSection(isDesktop, isTablet),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePicture(bool isDesktop, double screenWidth) {
    final profileSize = isDesktop ? 120.0 : (screenWidth > 600 ? 100.0 : 80.0);

    return Container(
      width: profileSize,
      height: profileSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: widget.doctorData['isVerified'] == true
              ? [Colors.green.withOpacity(0.2), Colors.green.withOpacity(0.1)]
              : [Colors.orange.withOpacity(0.2), Colors.orange.withOpacity(0.1)],
        ),
        border: Border.all(
          color: widget.doctorData['isVerified'] == true ? Colors.green : Colors.orange,
          width: 4,
        ),
        boxShadow: [
          BoxShadow(
            color: (widget.doctorData['isVerified'] == true ? Colors.green : Colors.orange).withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 3,
          ),
        ],
      ),
      child: ClipOval(
        child: widget.doctorData['documents']?['profilePicture'] != null
            ? Image.network(
          widget.doctorData['documents']['profilePicture'],
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
                color: Colors.grey,
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
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildDoctorHeader(bool isDesktop, bool isTablet) {
    return Column(
      crossAxisAlignment: isDesktop ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Text(
          widget.doctorData['basicInfo']?['fullName'] ?? 'Unknown Doctor',
          style: TextStyle(
            fontSize: isDesktop ? 32 : (isTablet ? 28 : 24),
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          textAlign: isDesktop ? TextAlign.left : TextAlign.center,
        ),
        SizedBox(height: 8),
        Text(
          widget.doctorData['professionalDetails']?['specialization'] ?? 'General Veterinarian',
          style: TextStyle(
            fontSize: isDesktop ? 20 : (isTablet ? 18 : 16),
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
          textAlign: isDesktop ? TextAlign.left : TextAlign.center,
        ),
        SizedBox(height: 16),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 20 : 16,
            vertical: isDesktop ? 12 : 10,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.doctorData['isVerified'] == true
                  ? [Colors.green.withOpacity(0.15), Colors.green.withOpacity(0.05)]
                  : [Colors.orange.withOpacity(0.15), Colors.orange.withOpacity(0.05)],
            ),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: widget.doctorData['isVerified'] == true ? Colors.green : Colors.orange,
              width: 2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.doctorData['isVerified'] == true ? Icons.verified : Icons.pending,
                size: isDesktop ? 24 : (isTablet ? 22 : 20),
                color: widget.doctorData['isVerified'] == true ? Colors.green : Colors.orange,
              ),
              SizedBox(width: 8),
              Text(
                widget.doctorData['isVerified'] == true ? 'Verified Doctor' : 'Pending Verification',
                style: TextStyle(
                  fontSize: isDesktop ? 18 : (isTablet ? 16 : 14),
                  fontWeight: FontWeight.w700,
                  color: widget.doctorData['isVerified'] == true ? Colors.green : Colors.orange,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfoSection(bool isDesktop, bool isTablet) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isDesktop ? 28 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Basic Information',
            style: TextStyle(
              fontSize: isDesktop ? 24 : (isTablet ? 22 : 20),
              fontWeight: FontWeight.bold,
              color: const Color(0xFF199A8E),
            ),
          ),
          SizedBox(height: isDesktop ? 20 : 16),
          // Enhanced info rows with better spacing for web
          ...widget.doctorData['basicInfo']?.entries.map<Widget>((entry) {
            return Padding(
              padding: EdgeInsets.only(bottom: isDesktop ? 16 : 12),
              child: _buildInfoRow(
                _getIconForField(entry.key),
                _formatFieldName(entry.key),
                entry.value?.toString() ?? 'Not specified',
                isDesktop,
                isTablet,
              ),
            );
          }).toList() ?? [],
        ],
      ),
    );
  }

  Widget _buildProfessionalDetailsSection(bool isDesktop, bool isTablet) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isDesktop ? 28 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Professional Details',
            style: TextStyle(
              fontSize: isDesktop ? 24 : (isTablet ? 22 : 20),
              fontWeight: FontWeight.bold,
              color: const Color(0xFF199A8E),
            ),
          ),
          SizedBox(height: isDesktop ? 20 : 16),
          ...widget.doctorData['professionalDetails']?.entries.map<Widget>((entry) {
            return Padding(
              padding: EdgeInsets.only(bottom: isDesktop ? 16 : 12),
              child: _buildInfoRow(
                _getIconForField(entry.key),
                _formatFieldName(entry.key),
                entry.value?.toString() ?? 'Not specified',
                isDesktop,
                isTablet,
              ),
            );
          }).toList() ?? [],
        ],
      ),
    );
  }

  Widget _buildDocumentsSection(bool isDesktop, bool isTablet) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isDesktop ? 28 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Documents',
            style: TextStyle(
              fontSize: isDesktop ? 24 : (isTablet ? 22 : 20),
              fontWeight: FontWeight.bold,
              color: const Color(0xFF199A8E),
            ),
          ),
          SizedBox(height: isDesktop ? 20 : 16),
          // Enhanced document display for web
          ...widget.doctorData['documents']?.entries.where((entry) => entry.key != 'profilePicture').map<Widget>((entry) {
            return Padding(
              padding: EdgeInsets.only(bottom: isDesktop ? 16 : 12),
              child: _buildDocumentRow(
                _getIconForField(entry.key),
                _formatFieldName(entry.key),
                entry.value?.toString() ?? 'Not provided',
                isDesktop,
                isTablet,
              ),
            );
          }).toList() ?? [],
        ],
      ),
    );
  }

  Widget _buildActionSection(bool isDesktop, bool isTablet) {
    if (widget.doctorData['isVerified'] == true) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(isDesktop ? 28 : 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.withOpacity(0.1), Colors.green.withOpacity(0.05)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.green.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(
              Icons.verified_user,
              size: isDesktop ? 64 : (isTablet ? 56 : 48),
              color: Colors.green,
            ),
            SizedBox(height: 16),
            Text(
              'Doctor Verified',
              style: TextStyle(
                fontSize: isDesktop ? 24 : (isTablet ? 22 : 20),
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'This doctor has been successfully verified and approved.',
              style: TextStyle(
                fontSize: isDesktop ? 18 : (isTablet ? 16 : 14),
                color: Colors.green[700],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isDesktop ? 28 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Enhanced action buttons for web
          SizedBox(
            width: double.infinity,
            height: isDesktop ? 60 : (isTablet ? 56 : 50),
            child: Container(
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
                onPressed: () => _approveDoctor(),
                icon: Icon(
                  Icons.check_circle,
                  size: isDesktop ? 28 : (isTablet ? 24 : 22),
                ),
                label: Text(
                  'Approve Doctor',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: isDesktop ? 20 : (isTablet ? 18 : 16),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: isDesktop ? 20 : 16),
          SizedBox(
            width: double.infinity,
            height: isDesktop ? 60 : (isTablet ? 56 : 50),
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.red, Color(0xFFE57373)],
                ),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () => _rejectDoctor(),
                icon: Icon(
                  Icons.cancel,
                  size: isDesktop ? 28 : (isTablet ? 24 : 22),
                ),
                label: Text(
                  'Reject Application',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: isDesktop ? 20 : (isTablet ? 18 : 16),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, bool isDesktop, bool isTablet) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(isDesktop ? 12 : 10),
          decoration: BoxDecoration(
            color: const Color(0xFF199A8E).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: isDesktop ? 24 : (isTablet ? 22 : 20),
            color: const Color(0xFF199A8E),
          ),
        ),
        SizedBox(width: isDesktop ? 20 : 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: isDesktop ? 18 : (isTablet ? 16 : 14),
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: isDesktop ? 17 : (isTablet ? 15 : 13),
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentRow(IconData icon, String label, String value, bool isDesktop, bool isTablet) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(isDesktop ? 12 : 10),
          decoration: BoxDecoration(
            color: const Color(0xFF199A8E).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: isDesktop ? 24 : (isTablet ? 22 : 20),
            color: const Color(0xFF199A8E),
          ),
        ),
        SizedBox(width: isDesktop ? 20 : 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: isDesktop ? 18 : (isTablet ? 16 : 14),
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 4),
              if (value.startsWith('http'))
                GestureDetector(
                  onTap: () => _viewDocument(value),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 16 : 12,
                      vertical: isDesktop ? 12 : 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF199A8E), Color(0xFF17C3B2)],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.visibility,
                          size: isDesktop ? 20 : (isTablet ? 18 : 16),
                          color: Colors.white,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'View Document',
                          style: TextStyle(
                            fontSize: isDesktop ? 16 : (isTablet ? 14 : 12),
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Text(
                  value,
                  style: TextStyle(
                    fontSize: isDesktop ? 17 : (isTablet ? 15 : 13),
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w400,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getIconForField(String fieldName) {
    switch (fieldName.toLowerCase()) {
      case 'fullname':
      case 'fathername':
      case 'gender':
        return Icons.person_outline;
      case 'dateofbirth':
        return Icons.cake_outlined;
      case 'contactnumber':
        return Icons.phone_outlined;
      case 'email':
        return Icons.email_outlined;
      case 'currentaddress':
      case 'clinicaddress':
        return Icons.home_outlined;
      case 'registrationnumber':
        return Icons.badge_outlined;
      case 'clinicname':
        return Icons.local_hospital_outlined;
      case 'cliniccontact':
        return Icons.phone_in_talk_outlined;
      case 'specialization':
        return Icons.star_outline;
      case 'experience':
        return Icons.history_edu_outlined;
      case 'about':
        return Icons.info_outline;
      case 'consultationfee':
        return Icons.attach_money_outlined;
      case 'profilepicture':
        return Icons.image_outlined;
      case 'cnic':
        return Icons.credit_card;
      case 'pmdc':
        return Icons.assignment;
      default:
        return Icons.description_outlined;
    }
  }

  String _formatFieldName(String fieldName) {
    // Replace camelCase with spaces and capitalize each word
    String spacedName = fieldName.replaceAllMapped(RegExp(r'(?<=[a-z])(?=[A-Z])'), (match) => ' ');
    String capitalizedName = spacedName.split(' ').map((word) {
      if (word.isNotEmpty) {
        return word[0].toUpperCase() + word.substring(1).toLowerCase();
      }
      return '';
    }).join(' ');

    return capitalizedName;
  }

  void _viewDocument(String url) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(MediaQuery.of(context).size.width > 600 ? 24 : 20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF199A8E), Color(0xFF17C3B2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Document Preview',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: MediaQuery.of(context).size.width > 600 ? 20 : 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: MediaQuery.of(context).size.width > 600 ? 28 : 24,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(MediaQuery.of(context).size.width > 600 ? 24 : 16),
                child: PhotoView(
                  imageProvider: NetworkImage(url),
                  minScale: PhotoViewComputedScale.contained * 0.8,
                  maxScale: PhotoViewComputedScale.covered * 4,
                  initialScale: PhotoViewComputedScale.contained,
                  backgroundDecoration: BoxDecoration(
                    color: Colors.grey[100],
                  ),
                  loadingBuilder: (context, event) => Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.grey[50]!, Colors.grey[100]!],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFF199A8E).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const CircularProgressIndicator(
                              color: Color(0xFF199A8E),
                              strokeWidth: 3,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Loading document...',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Please wait while we fetch the document',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  errorBuilder: (context, error, stackTrace) => Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.red[50]!, Colors.red[100]!],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.red[100],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Colors.red[600],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Failed to load document',
                            style: TextStyle(
                              color: Colors.red[700],
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'The document could not be displayed',
                            style: TextStyle(
                              color: Colors.red[600],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF199A8E), Color(0xFF17C3B2)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () => _launchUrl(url),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.open_in_new, color: Colors.white, size: 18),
                                      SizedBox(width: 8),
                                      Text(
                                        'Open in Browser',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar(
          'Error',
          'Could not open document URL',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to open document: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  Future<void> _approveDoctor() async {
    // Simulate approval process
    Get.snackbar(
      'Success',
      'Doctor has been approved successfully!',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
    );
  }

  Future<void> _rejectDoctor() async {
    // Simulate rejection process
    Get.snackbar(
      'Success',
      'Doctor application has been rejected.',
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
    );
  }
}
