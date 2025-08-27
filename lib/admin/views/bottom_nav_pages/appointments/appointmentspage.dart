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

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Confirmed Appointments',
          style: TextStyle(
            fontSize: isTablet ? 24 : 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.teal[700],
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: () => controller.refreshAppointments(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Statistics Cards
          Container(
            padding: EdgeInsets.all(isTablet ? 20 : 16),
            child: Obx(() => Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Appointments',
                    controller.getTotalAppointments().toString(),
                    Icons.calendar_today,
                    Colors.blue,
                    isTablet,
                  ),
                ),
                SizedBox(width: isTablet ? 16 : 12),
                Expanded(
                  child: _buildStatCard(
                    'Total Revenue',
                    'PKR ${controller.getTotalRevenue().toStringAsFixed(0)}',
                    Icons.attach_money,
                    Colors.green,
                    isTablet,
                  ),
                ),
              ],
            )),
          ),

          // Search and Filter Bar
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 20 : 16,
              vertical: isTablet ? 12 : 8,
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    onChanged: controller.updateSearchQuery,
                    decoration: InputDecoration(
                      hintText: 'Search by owner, pet, doctor, or problem...',
                      prefixIcon: Icon(Icons.search, color: Colors.teal[600]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.teal[600]!, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 16 : 12,
                        vertical: isTablet ? 16 : 12,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: isTablet ? 16 : 12),
                Expanded(
                  flex: 1,
                  child: Obx(() => DropdownButtonFormField<String>(
                    value: controller.selectedFilter.value,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 16 : 12,
                        vertical: isTablet ? 16 : 12,
                      ),
                    ),
                    items: [
                      DropdownMenuItem(value: 'all', child: Text('All')),
                      DropdownMenuItem(value: 'today', child: Text('Today')),
                      DropdownMenuItem(value: 'thisWeek', child: Text('This Week')),
                      DropdownMenuItem(value: 'thisMonth', child: Text('This Month')),
                    ],
                    onChanged: (value) => controller.updateFilter(value!),
                  )),
                ),
              ],
            ),
          ),

          // Appointments List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.teal[600]!),
                  ),
                );
              }

              if (controller.filteredAppointments.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: isTablet ? 80 : 60,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: isTablet ? 20 : 16),
                      Text(
                        'No confirmed appointments found',
                        style: TextStyle(
                          fontSize: isTablet ? 20 : 16,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 20 : 16,
                  vertical: isTablet ? 12 : 8,
                ),
                itemCount: controller.filteredAppointments.length,
                itemBuilder: (context, index) {
                  final appointment = controller.filteredAppointments[index];
                  return _buildAppointmentCard(appointment, isTablet, context);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: isTablet ? 28 : 24),
              Spacer(),
            ],
          ),
          SizedBox(height: isTablet ? 12 : 8),
          Text(
            value,
            style: TextStyle(
              fontSize: isTablet ? 24 : 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: isTablet ? 8 : 4),
          Text(
            title,
            style: TextStyle(
              fontSize: isTablet ? 14 : 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard(AppointmentModel appointment, bool isTablet, BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 16 : 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 20 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 12 : 8,
                    vertical: isTablet ? 6 : 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(appointment.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    appointment.status.toUpperCase(),
                    style: TextStyle(
                      color: _getStatusColor(appointment.status),
                      fontSize: isTablet ? 12 : 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Spacer(),
                Text(
                  'PKR ${appointment.consultationFee?.toStringAsFixed(0) ?? '0'}',
                  style: TextStyle(
                    fontSize: isTablet ? 18 : 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[600],
                  ),
                ),
              ],
            ),

            SizedBox(height: isTablet ? 16 : 12),

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
                      ),
                      SizedBox(height: isTablet ? 12 : 8),
                      _buildInfoRow(
                        Icons.pets,
                        'Pet',
                        appointment.petName,
                        isTablet,
                      ),
                      SizedBox(height: isTablet ? 12 : 8),
                      _buildInfoRow(
                        Icons.local_hospital,
                        'Doctor',
                        appointment.doctorName ?? 'Unknown',
                        isTablet,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: isTablet ? 20 : 16),
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
                      ),
                      SizedBox(height: isTablet ? 12 : 8),
                      _buildInfoRow(
                        Icons.access_time,
                        'Time',
                        appointment.selectedTime,
                        isTablet,
                      ),
                      SizedBox(height: isTablet ? 12 : 8),
                      _buildInfoRow(
                        Icons.payment,
                        'Payment',
                        appointment.paymentMethod,
                        isTablet,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: isTablet ? 16 : 12),

            // Problem Description
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(isTablet ? 16 : 12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Problem Description:',
                    style: TextStyle(
                      fontSize: isTablet ? 14 : 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: isTablet ? 8 : 4),
                  Text(
                    appointment.problem,
                    style: TextStyle(
                      fontSize: isTablet ? 16 : 14,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ),

            // Payment Screenshot (if available)
            if (appointment.paymentScreenshotUrl != null && appointment.paymentScreenshotUrl!.isNotEmpty)
              Column(
                children: [
                  SizedBox(height: isTablet ? 16 : 12),
                  Row(
                    children: [
                      Icon(Icons.receipt, size: isTablet ? 20 : 16, color: Colors.grey[600]),
                      SizedBox(width: isTablet ? 8 : 6),
                      Text(
                        'Payment Screenshot',
                        style: TextStyle(
                          fontSize: isTablet ? 14 : 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      Spacer(),
                      TextButton(
                        onPressed: () => _showPaymentScreenshot(context, appointment.paymentScreenshotUrl!),
                        child: Text(
                          'View',
                          style: TextStyle(
                            color: Colors.teal[600],
                            fontSize: isTablet ? 14 : 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, bool isTablet) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: isTablet ? 18 : 16, color: Colors.grey[600]),
        SizedBox(width: isTablet ? 8 : 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: isTablet ? 12 : 10,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: isTablet ? 16 : 14,
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
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.9,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppBar(
                title: Text('Payment Screenshot'),
                backgroundColor: Colors.teal[700],
                foregroundColor: Colors.white,
                automaticallyImplyLeading: false,
                actions: [
                  IconButton(
                    icon: Icon(Icons.close),
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
                            Icon(Icons.error, size: 48, color: Colors.red),
                            SizedBox(height: 16),
                            Text('Failed to load image'),
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
