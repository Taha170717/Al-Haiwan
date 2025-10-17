import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../doctor/models/appointment_model.dart';
import '../../../controllers/admin_appointment_controller.dart';

class AdminAppointmentsScreen extends StatelessWidget {
  final AdminAppointmentController controller = Get.put(AdminAppointmentController());

  AdminAppointmentsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;
    final isDesktop = screenWidth > 1024;
    final isLargeDesktop = screenWidth > 1440;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF199A8E).withOpacity(0.05),
              Colors.white,
              Colors.grey[50]!,
            ],
          ),
        ),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFFFFFF),
                    Color(0xFFFFFFFF).withOpacity(0.8),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF199A8E).withOpacity(0.3),
                    spreadRadius: 0,
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 24 : isTablet ? 20 : 16,
                    vertical: isDesktop ? 20 : isTablet ? 16 : 12,
                  ),
                  child: Row(
                    children: [
                      if (!isDesktop)

                      Expanded(
                        child: Center(
                          child: Column(
                            children: [
                              Text(
                                'Confirmed Appointments',
                                style: TextStyle(
                                  fontSize: isLargeDesktop ? 32 : isDesktop ? 28 : isTablet ? 24 : 20,
                                  fontFamily: 'bolditalic',
                                  color: Color(0xFF199A8E),
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Manage and track all confirmed appointments',
                                style: TextStyle(
                                  fontSize: isDesktop ? 16 : isTablet ? 14 : 12,
                                  color: Color(0xFF199A8E).withOpacity(0.9),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.refresh, color: Color(0xFF199A8E), size: isDesktop ? 28 : isTablet ? 26 : 24),
                          onPressed: () => controller.refreshAppointments(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Expanded(
              child: Center(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: isLargeDesktop ? 1400 : isDesktop ? 1200 : double.infinity,
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(isDesktop ? 24 : isTablet ? 20 : 16),
                        child: Obx(() => Row(
                          children: [
                            Expanded(
                              child: _buildEnhancedStatCard(
                                'Total Appointments',
                                controller.getTotalAppointments().toString(),
                                Icons.calendar_today_rounded,
                                [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                                isTablet,
                                isDesktop,
                                isLargeDesktop,
                              ),
                            ),
                            SizedBox(width: isDesktop ? 20 : isTablet ? 16 : 12),
                            Expanded(
                              child: _buildEnhancedStatCard(
                                'Total Revenue',
                                'PKR ${controller.getTotalRevenue().toStringAsFixed(0)}',
                                Icons.trending_up_rounded,
                                [Color(0xFF059669), Color(0xFF10B981)],
                                isTablet,
                                isDesktop,
                                isLargeDesktop,
                              ),
                            ),
                          ],
                        )),
                      ),

                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isDesktop ? 24 : isTablet ? 20 : 16,
                          vertical: isDesktop ? 16 : isTablet ? 12 : 8,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Container(
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      spreadRadius: 0,
                                      blurRadius: 20,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: TextField(
                                  onChanged: controller.updateSearchQuery,
                                  decoration: InputDecoration(
                                    hintText: 'Search by owner, pet, doctor, or problem...',
                                    hintStyle: TextStyle(
                                      fontSize: isDesktop ? 16 : isTablet ? 15 : 14,
                                      color: Colors.grey[500],
                                    ),
                                    prefixIcon: Container(
                                      margin: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Color(0xFF199A8E).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(Icons.search_rounded, color: Color(0xFF199A8E), size: isDesktop ? 24 : isTablet ? 22 : 20),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(color: Color(0xFF199A8E), width: 2),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: isDesktop ? 20 : isTablet ? 16 : 12,
                                      vertical: isDesktop ? 20 : isTablet ? 18 : 16,
                                    ),
                                  ),
                                  style: TextStyle(
                                    fontSize: isDesktop ? 16 : isTablet ? 15 : 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: isDesktop ? 20 : isTablet ? 16 : 12),
                            Expanded(
                              flex: 1,
                              child: Container(
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      spreadRadius: 0,
                                      blurRadius: 20,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Obx(() => DropdownButtonFormField<String>(
                                  value: controller.selectedFilter.value,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(color: Color(0xFF199A8E), width: 2),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: isDesktop ? 20 : isTablet ? 16 : 12,
                                      vertical: isDesktop ? 20 : isTablet ? 18 : 16,
                                    ),
                                  ),
                                  style: TextStyle(
                                    fontSize: isDesktop ? 16 : isTablet ? 15 : 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  items: [
                                    DropdownMenuItem(value: 'all', child: Text('All ')),
                                    DropdownMenuItem(value: 'today', child: Text('Today')),
                                    DropdownMenuItem(value: 'thisWeek', child: Text('This Week')),
                                    //DropdownMenuItem(value: 'thisMonth', child: Text('This Month')),
                                  ],
                                  onChanged: (value) => controller.updateFilter(value!),
                                )),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Appointments List
                      Expanded(
                        child: Obx(() {
                          if (controller.isLoading.value) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(isDesktop ? 24 : isTablet ? 20 : 16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color(0xFF199A8E).withOpacity(0.1),
                                          spreadRadius: 0,
                                          blurRadius: 30,
                                          offset: Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF199A8E)),
                                      strokeWidth: isDesktop ? 4 : 3,
                                    ),
                                  ),
                                  SizedBox(height: isDesktop ? 24 : isTablet ? 20 : 16),
                                  Text(
                                    'Loading appointments...',
                                    style: TextStyle(
                                      fontSize: isDesktop ? 18 : isTablet ? 16 : 14,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          if (controller.filteredAppointments.isEmpty) {
                            return Center(
                              child: Container(
                                padding: EdgeInsets.all(isDesktop ? 48 : isTablet ? 40 : 32),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      spreadRadius: 0,
                                      blurRadius: 30,
                                      offset: Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(isDesktop ? 24 : isTablet ? 20 : 16),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0xFF199A8E).withOpacity(0.1),
                                            Color(0xFF199A8E).withOpacity(0.05),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Icon(
                                        Icons.calendar_today_outlined,
                                        size: isLargeDesktop ? 80 : isDesktop ? 70 : isTablet ? 60 : 50,
                                        color: Color(0xFF199A8E),
                                      ),
                                    ),
                                    SizedBox(height: isDesktop ? 24 : isTablet ? 20 : 16),
                                    Text(
                                      'No confirmed appointments found',
                                      style: TextStyle(
                                        fontSize: isLargeDesktop ? 24 : isDesktop ? 22 : isTablet ? 20 : 18,
                                        color: Colors.grey[800],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Appointments will appear here once they are confirmed',
                                      style: TextStyle(
                                        fontSize: isDesktop ? 16 : isTablet ? 14 : 12,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          return ListView.builder(
                            padding: EdgeInsets.symmetric(
                              horizontal: isDesktop ? 24 : isTablet ? 20 : 16,
                              vertical: isDesktop ? 16 : isTablet ? 12 : 8,
                            ),
                            itemCount: controller.filteredAppointments.length,
                            itemBuilder: (context, index) {
                              final appointment = controller.filteredAppointments[index];
                              return _buildEnhancedAppointmentCard(appointment, isTablet, isDesktop, isLargeDesktop, context);
                            },
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedStatCard(String title, String value, IconData icon, List<Color> gradientColors, bool isTablet, bool isDesktop, bool isLargeDesktop) {
    return Container(
      padding: EdgeInsets.all(isLargeDesktop ? 32 : isDesktop ? 28 : isTablet ? 24 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.white.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 30,
            offset: Offset(0, 10),
          ),
          BoxShadow(
            color: gradientColors[0].withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 20,
            offset: Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(isDesktop ? 16 : isTablet ? 14 : 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradientColors,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: gradientColors[0].withOpacity(0.3),
                      spreadRadius: 0,
                      blurRadius: 15,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: isLargeDesktop ? 32 : isDesktop ? 30 : isTablet ? 28 : 24),
              ),
              Spacer(),
            ],
          ),
          SizedBox(height: isDesktop ? 20 : isTablet ? 16 : 12),
          Text(
            value,
            style: TextStyle(
              fontSize: isLargeDesktop ? 36 : isDesktop ? 32 : isTablet ? 28 : 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: isDesktop ? 12 : isTablet ? 8 : 4),
          Text(
            title,
            style: TextStyle(
              fontSize: isLargeDesktop ? 18 : isDesktop ? 16 : isTablet ? 15 : 13,
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedAppointmentCard(AppointmentModel appointment, bool isTablet, bool isDesktop, bool isLargeDesktop, BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: isDesktop ? 24 : isTablet ? 20 : 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.white.withOpacity(0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 30,
            offset: Offset(0, 10),
          ),
          BoxShadow(
            color: Color(0xFF199A8E).withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 20,
            offset: Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(isLargeDesktop ? 32 : isDesktop ? 28 : isTablet ? 24 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 20 : isTablet ? 16 : 12,
                    vertical: isDesktop ? 10 : isTablet ? 8 : 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _getStatusColor(appointment.status),
                        _getStatusColor(appointment.status).withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: _getStatusColor(appointment.status).withOpacity(0.3),
                        spreadRadius: 0,
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    appointment.status.toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isLargeDesktop ? 14 : isDesktop ? 13 : isTablet ? 12 : 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 20 : isTablet ? 16 : 12,
                    vertical: isDesktop ? 10 : isTablet ? 8 : 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.green[600]!,
                        Colors.green[500]!,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.3),
                        spreadRadius: 0,
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.money, color: Colors.white, size: isDesktop ? 20 : isTablet ? 18 : 16),
                      Text(
                        'PKR ${appointment.consultationFee?.toStringAsFixed(0) ?? '0'}',
                        style: TextStyle(
                          fontSize: isLargeDesktop ? 18 : isDesktop ? 16 : isTablet ? 14 : 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: isDesktop ? 24 : isTablet ? 20 : 16),

            // Main Info with enhanced styling
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildEnhancedInfoRow(
                        Icons.person_rounded,
                        'Owner',
                        appointment.ownerName,
                        Colors.blue,
                        isTablet,
                        isDesktop,
                        isLargeDesktop,
                      ),
                      SizedBox(height: isDesktop ? 20 : isTablet ? 16 : 12),
                      _buildEnhancedInfoRow(
                        Icons.pets_rounded,
                        'Pet',
                        appointment.petName,
                        Colors.orange,
                        isTablet,
                        isDesktop,
                        isLargeDesktop,
                      ),
                      SizedBox(height: isDesktop ? 20 : isTablet ? 16 : 12),
                      _buildEnhancedInfoRow(
                        Icons.local_hospital_rounded,
                        'Doctor',
                        appointment.doctorName ?? 'Unknown',
                        Color(0xFF199A8E),
                        isTablet,
                        isDesktop,
                        isLargeDesktop,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: isDesktop ? 32 : isTablet ? 24 : 20),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildEnhancedInfoRow(
                        Icons.calendar_today_rounded,
                        'Date',
                        DateFormat('MMM dd, yyyy').format(appointment.selectedDate.toDate()),
                        Colors.purple,
                        isTablet,
                        isDesktop,
                        isLargeDesktop,
                      ),
                      SizedBox(height: isDesktop ? 20 : isTablet ? 16 : 12),
                      _buildEnhancedInfoRow(
                        Icons.access_time_rounded,
                        'Time',
                        appointment.selectedTime,
                        Colors.indigo,
                        isTablet,
                        isDesktop,
                        isLargeDesktop,
                      ),
                      SizedBox(height: isDesktop ? 20 : isTablet ? 16 : 12),
                      _buildEnhancedInfoRow(
                        Icons.payment_rounded,
                        'Payment',
                        appointment.paymentMethod,
                        Colors.green,
                        isTablet,
                        isDesktop,
                        isLargeDesktop,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: isDesktop ? 24 : isTablet ? 20 : 16),

            Container(
              width: double.infinity,
              padding: EdgeInsets.all(isDesktop ? 24 : isTablet ? 20 : 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF199A8E).withOpacity(0.05),
                    Color(0xFF199A8E).withOpacity(0.02),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Color(0xFF199A8E).withOpacity(0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Color(0xFF199A8E).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.description_rounded, color: Color(0xFF199A8E), size: isDesktop ? 20 : isTablet ? 18 : 16),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Problem Description',
                        style: TextStyle(
                          fontSize: isLargeDesktop ? 18 : isDesktop ? 17 : isTablet ? 16 : 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF199A8E),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isDesktop ? 16 : isTablet ? 12 : 8),
                  Text(
                    appointment.problem,
                    style: TextStyle(
                      fontSize: isLargeDesktop ? 18 : isDesktop ? 17 : isTablet ? 16 : 14,
                      color: Colors.grey[800],
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            if (appointment.paymentScreenshotUrl != null && appointment.paymentScreenshotUrl!.isNotEmpty)
              Column(
                children: [
                  SizedBox(height: isDesktop ? 24 : isTablet ? 20 : 16),
                  Container(
                    padding: EdgeInsets.all(isDesktop ? 20 : isTablet ? 16 : 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF199A8E).withOpacity(0.08),
                          Color(0xFF199A8E).withOpacity(0.04),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Color(0xFF199A8E).withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF199A8E), Color(0xFF199A8E).withOpacity(0.8)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.receipt_rounded, size: isDesktop ? 24 : isTablet ? 20 : 16, color: Colors.white),
                        ),
                        SizedBox(width: isDesktop ? 16 : isTablet ? 12 : 8),
                        Expanded(
                          child: Text(
                            'Payment Screenshot Available',
                            style: TextStyle(
                              fontSize: isLargeDesktop ? 18 : isDesktop ? 17 : isTablet ? 16 : 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF199A8E),
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF199A8E), Color(0xFF199A8E).withOpacity(0.8)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF199A8E).withOpacity(0.3),
                                spreadRadius: 0,
                                blurRadius: 10,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () => _showPaymentScreenshot(context, appointment.paymentScreenshotUrl!),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              shadowColor: Colors.transparent,
                              padding: EdgeInsets.symmetric(
                                horizontal: isDesktop ? 24 : isTablet ? 20 : 16,
                                vertical: isDesktop ? 16 : isTablet ? 14 : 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.visibility_rounded, size: isDesktop ? 20 : isTablet ? 18 : 16),
                                SizedBox(width: 8),
                                Text(
                                  'View',
                                  style: TextStyle(
                                    fontSize: isDesktop ? 16 : isTablet ? 14 : 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedInfoRow(IconData icon, String label, String value, Color color, bool isTablet, bool isDesktop, bool isLargeDesktop) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(isDesktop ? 12 : isTablet ? 10 : 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withOpacity(0.8)],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                spreadRadius: 0,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, size: isDesktop ? 20 : isTablet ? 18 : 16, color: Colors.white),
        ),
        SizedBox(width: isDesktop ? 16 : isTablet ? 12 : 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: isLargeDesktop ? 14 : isDesktop ? 13 : isTablet ? 12 : 10,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
              SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: isLargeDesktop ? 18 : isDesktop ? 17 : isTablet ? 16 : 14,
                  color: Colors.grey[800],
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, bool isTablet, bool isDesktop, bool isLargeDesktop) {
    return Container(
      padding: EdgeInsets.all(isLargeDesktop ? 28 : isDesktop ? 24 : isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 2,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(isDesktop ? 12 : isTablet ? 10 : 8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: isLargeDesktop ? 32 : isDesktop ? 30 : isTablet ? 28 : 24),
              ),
              Spacer(),
            ],
          ),
          SizedBox(height: isDesktop ? 16 : isTablet ? 12 : 8),
          Text(
            value,
            style: TextStyle(
              fontSize: isLargeDesktop ? 32 : isDesktop ? 28 : isTablet ? 24 : 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: isDesktop ? 12 : isTablet ? 8 : 4),
          Text(
            title,
            style: TextStyle(
              fontSize: isLargeDesktop ? 16 : isDesktop ? 15 : isTablet ? 14 : 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard(AppointmentModel appointment, bool isTablet, bool isDesktop, bool isLargeDesktop, BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: isDesktop ? 20 : isTablet ? 16 : 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.12),
            spreadRadius: 2,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isLargeDesktop ? 28 : isDesktop ? 24 : isTablet ? 20 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 16 : isTablet ? 12 : 8,
                    vertical: isDesktop ? 8 : isTablet ? 6 : 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(appointment.status).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Text(
                    appointment.status.toUpperCase(),
                    style: TextStyle(
                      color: _getStatusColor(appointment.status),
                      fontSize: isLargeDesktop ? 14 : isDesktop ? 13 : isTablet ? 12 : 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 16 : isTablet ? 12 : 8,
                    vertical: isDesktop ? 8 : isTablet ? 6 : 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Text(
                    'PKR ${appointment.consultationFee?.toStringAsFixed(0) ?? '0'}',
                    style: TextStyle(
                      fontSize: isLargeDesktop ? 20 : isDesktop ? 18 : isTablet ? 16 : 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[600],
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: isDesktop ? 20 : isTablet ? 16 : 12),

            // Main Info
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(
                        Icons.person,
                        'Owner',
                        appointment.ownerName,
                        isTablet,
                        isDesktop,
                        isLargeDesktop,
                      ),
                      SizedBox(height: isDesktop ? 16 : isTablet ? 12 : 8),
                      _buildInfoRow(
                        Icons.pets,
                        'Pet',
                        appointment.petName,
                        isTablet,
                        isDesktop,
                        isLargeDesktop,
                      ),
                      SizedBox(height: isDesktop ? 16 : isTablet ? 12 : 8),
                      _buildInfoRow(
                        Icons.local_hospital,
                        'Doctor',
                        appointment.doctorName ?? 'Unknown',
                        isTablet,
                        isDesktop,
                        isLargeDesktop,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: isDesktop ? 24 : isTablet ? 20 : 16),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(
                        Icons.calendar_today,
                        'Date',
                        DateFormat('MMM dd, yyyy').format(appointment.selectedDate.toDate()),
                        isTablet,
                        isDesktop,
                        isLargeDesktop,
                      ),
                      SizedBox(height: isDesktop ? 16 : isTablet ? 12 : 8),
                      _buildInfoRow(
                        Icons.access_time,
                        'Time',
                        appointment.selectedTime,
                        isTablet,
                        isDesktop,
                        isLargeDesktop,
                      ),
                      SizedBox(height: isDesktop ? 16 : isTablet ? 12 : 8),
                      _buildInfoRow(
                        Icons.payment,
                        'Payment',
                        appointment.paymentMethod,
                        isTablet,
                        isDesktop,
                        isLargeDesktop,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: isDesktop ? 20 : isTablet ? 16 : 12),

            // Problem Description
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(isDesktop ? 20 : isTablet ? 16 : 12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Problem Description:',
                    style: TextStyle(
                      fontSize: isLargeDesktop ? 16 : isDesktop ? 15 : isTablet ? 14 : 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: isDesktop ? 12 : isTablet ? 8 : 4),
                  Text(
                    appointment.problem,
                    style: TextStyle(
                      fontSize: isLargeDesktop ? 18 : isDesktop ? 17 : isTablet ? 16 : 14,
                      color: Colors.grey[800],
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            // Payment Screenshot (if available)
            if (appointment.paymentScreenshotUrl != null && appointment.paymentScreenshotUrl!.isNotEmpty)
              Column(
                children: [
                  SizedBox(height: isDesktop ? 20 : isTablet ? 16 : 12),
                  Container(
                    padding: EdgeInsets.all(isDesktop ? 16 : isTablet ? 12 : 8),
                    decoration: BoxDecoration(
                      color: Color(0xFF199A8E).withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Color(0xFF199A8E).withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.receipt, size: isDesktop ? 24 : isTablet ? 20 : 16, color: Color(0xFF199A8E)),
                        SizedBox(width: isDesktop ? 12 : isTablet ? 8 : 6),
                        Text(
                          'Payment Screenshot',
                          style: TextStyle(
                            fontSize: isLargeDesktop ? 16 : isDesktop ? 15 : isTablet ? 14 : 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF199A8E),
                          ),
                        ),
                        Spacer(),
                        ElevatedButton(
                          onPressed: () => _showPaymentScreenshot(context, appointment.paymentScreenshotUrl!),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF199A8E),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: isDesktop ? 20 : isTablet ? 16 : 12,
                              vertical: isDesktop ? 12 : isTablet ? 10 : 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'View',
                            style: TextStyle(
                              fontSize: isDesktop ? 16 : isTablet ? 14 : 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, bool isTablet, bool isDesktop, bool isLargeDesktop) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(isDesktop ? 8 : isTablet ? 6 : 4),
          decoration: BoxDecoration(
            color: Color(0xFF199A8E).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: isDesktop ? 20 : isTablet ? 18 : 16, color: Color(0xFF199A8E)),
        ),
        SizedBox(width: isDesktop ? 12 : isTablet ? 8 : 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: isLargeDesktop ? 14 : isDesktop ? 13 : isTablet ? 12 : 10,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: isLargeDesktop ? 18 : isDesktop ? 17 : isTablet ? 16 : 14,
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'paymentverified':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _showPaymentScreenshot(BuildContext context, String imageUrl) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1024;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isDesktop ? 800 : MediaQuery.of(context).size.width * 0.9,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppBar(
                title: Text('Payment Screenshot',
                  style: TextStyle(
                    fontSize: isDesktop ? 20 : 18,
                  ),
                ),
                backgroundColor: Color(0xFF199A8E),
                foregroundColor: Colors.white,
                automaticallyImplyLeading: false,
                actions: [
                  IconButton(
                    icon: Icon(Icons.close, size: isDesktop ? 28 : 24),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              Expanded(
                child: InteractiveViewer(
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF199A8E)),
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error, size: isDesktop ? 64 : 48, color: Colors.red),
                            SizedBox(height: 16),
                            Text('Failed to load image',
                              style: TextStyle(
                                fontSize: isDesktop ? 18 : 16,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
