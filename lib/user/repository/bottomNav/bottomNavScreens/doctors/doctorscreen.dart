import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/verified_doctor_controller.dart';
import 'DoctorDetailView.dart';
import '../../../../models/doctor_list_viewmodel.dart';

class VerifiedDoctorsScreen extends StatelessWidget {
  final VerifiedDoctorsController controller = Get.put(VerifiedDoctorsController());

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Responsive dimensions
    final padding = screenWidth * 0.04;
    final cardMargin = screenWidth * 0.03;
    final imageSize = screenWidth * 0.18;
    final titleFontSize = screenWidth * 0.045;
    final subtitleFontSize = screenWidth * 0.035;
    final iconSize = screenWidth * 0.04;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Verified Doctors',
          style: TextStyle(
            color: const Color(0xFF199A8E),
            fontSize: screenWidth * 0.055,
            fontWeight: FontWeight.bold,
            fontFamily: 'bolditalic',

          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF199A8E)),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, size: iconSize * 1.2),
            onPressed: () => controller.refreshDoctors(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF199A8E)),
                ),
                SizedBox(height: screenHeight * 0.02),
                Text(
                  'Loading verified doctors...',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: subtitleFontSize,
                  ),
                ),
              ],
            ),
          );
        }

        if (controller.hasError.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: screenWidth * 0.15,
                  color: Colors.red[300],
                ),
                SizedBox(height: screenHeight * 0.02),
                Text(
                  'Oops! Something went wrong',
                  style: TextStyle(
                    fontSize: titleFontSize * 0.9,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: padding * 2),
                  child: Text(
                    controller.errorMessage.value,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: subtitleFontSize,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),
                ElevatedButton(
                  onPressed: () => controller.refreshDoctors(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF199A8E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(screenWidth * 0.03),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: padding * 2,
                      vertical: padding * 0.8,
                    ),
                  ),
                  child: Text(
                    'Try Again',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: subtitleFontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        if (controller.verifiedDoctors.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.medical_services_outlined,
                  size: screenWidth * 0.2,
                  color: Colors.grey[400],
                ),
                SizedBox(height: screenHeight * 0.02),
                Text(
                  'No Verified Doctors Found',
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),
                Text(
                  'Please check back later',
                  style: TextStyle(
                    fontSize: subtitleFontSize,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.refreshDoctors(),
          color: const Color(0xFF199A8E),
          child: ListView.builder(
            padding: EdgeInsets.all(padding),
            itemCount: controller.verifiedDoctors.length,
            itemBuilder: (context, index) {
              final doctor = controller.verifiedDoctors[index];
              return _buildDoctorCard(
                context,
                doctor,
                screenWidth,
                padding,
                cardMargin,
                imageSize,
                titleFontSize,
                subtitleFontSize,
                iconSize,
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildDoctorCard(
      BuildContext context,
      Doctor doctor,
      double screenWidth,
      double padding,
      double cardMargin,
      double imageSize,
      double titleFontSize,
      double subtitleFontSize,
      double iconSize,
      ) {
    return Container(
      margin: EdgeInsets.only(bottom: cardMargin),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(screenWidth * 0.04),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(screenWidth * 0.04),
          onTap: () {
            Get.to(() => DoctorDetailView(doctor: doctor, doctorId: doctor.id));
          },
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: Row(
              children: [
                Container(
                  width: imageSize,
                  height: imageSize,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(imageSize * 0.2),
                    border: Border.all(
                      color: const Color(0xFF199A8E).withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(imageSize * 0.2),
                    child: doctor.profileImageUrl.isNotEmpty
                        ? Image.network(
                      doctor.profileImageUrl,
                      width: imageSize,
                      height: imageSize,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildDefaultAvatar(imageSize, doctor.name);
                      },
                    )
                        : _buildDefaultAvatar(imageSize, doctor.name),
                  ),
                ),
                SizedBox(width: padding),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              doctor.fullName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: titleFontSize * 0.9,
                                color: Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.02,
                              vertical: screenWidth * 0.01,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(screenWidth * 0.02),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.verified,
                                  size: iconSize * 0.8,
                                  color: Colors.green,
                                ),
                                SizedBox(width: 2),
                                Text(
                                  'Verified',
                                  style: TextStyle(
                                    fontSize: subtitleFontSize * 0.8,
                                    color: Colors.green,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenWidth * 0.01),

                      Text(
                        doctor.specialty,
                        style: TextStyle(
                          color: const Color(0xFF199A8E),
                          fontSize: subtitleFontSize,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: screenWidth * 0.02),

                      Row(
                        children: [
                          Icon(
                            Icons.work_outline,
                            size: iconSize,
                            color: Colors.grey[600],
                          ),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              doctor.experience,
                              style: TextStyle(
                                fontSize: subtitleFontSize,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenWidth * 0.01),

                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: iconSize,
                            color: Colors.grey[600],
                          ),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              doctor.clinicAddress,
                              style: TextStyle(
                                fontSize: subtitleFontSize,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar(double size, String name) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF199A8E), Color(0xFF17C3B2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size * 0.2),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'D',
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
