import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/doctor_appointment_controller.dart';

class DoctorAppointmentsScreen extends StatelessWidget {
  final DoctorAppointmentsController controller = Get.put(DoctorAppointmentsController());

   DoctorAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Center(child: Text('Appointments', style: TextStyle(fontWeight: FontWeight.w600,fontFamily: 'bolditalic', color: Color(0xFF199A8E)))),
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey[800],
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: Container(
            color: Colors.white,
            child: Obx(() => Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => controller.selectedTab.value = 0,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: controller.selectedTab.value == 0
                                ? Colors.blue[600]!
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                      child: Text(
                        'Pending (${controller.pendingAppointments.length})',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: controller.selectedTab.value == 0
                              ? Colors.blue[600]
                              : Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => controller.selectedTab.value = 1,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: controller.selectedTab.value == 1
                                ? Colors.green[600]!
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                      child: Text(
                        'Confirmed (${controller.confirmedAppointments.length})',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: controller.selectedTab.value == 1
                              ? Colors.green[600]
                              : Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => controller.selectedTab.value = 2,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: controller.selectedTab.value == 2
                                ? Colors.purple[600]!
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                      child: Text(
                        'Completed (${controller.completedAppointments.length})',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: controller.selectedTab.value == 2
                              ? Colors.purple[600]
                              : Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )),
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.blue[600]),
                SizedBox(height: 16),
                Text('Loading appointments...', style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          );
        }

        final appointments = controller.selectedTab.value == 0
            ? controller.pendingAppointments
            : controller.selectedTab.value == 1
            ? controller.confirmedAppointments
            : controller.completedAppointments;

        if (appointments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    controller.selectedTab.value == 0
                        ? Icons.pending_actions
                        : controller.selectedTab.value == 1
                        ? Icons.check_circle_outline
                        : Icons.task_alt,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  controller.selectedTab.value == 0
                      ? 'No pending appointments'
                      : controller.selectedTab.value == 1
                      ? 'No confirmed appointments'
                      : 'No completed appointments',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.grey[600]),
                ),
                SizedBox(height: 8),
                Text(
                  controller.selectedTab.value == 0
                      ? 'New appointment requests will appear here'
                      : controller.selectedTab.value == 1
                      ? 'Confirmed appointments will appear here'
                      : 'Completed appointments will appear here',
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => controller.fetchAppointments(),
          color: Colors.blue[600],
          child: ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final appointment = appointments[index];
              return _buildAppointmentCard(context, appointment);
            },
          ),
        );
      }),
    );
  }

  Widget _buildAppointmentCard(BuildContext context, Map<String, dynamic> appointment) {
    final isPending = appointment['status'] == 'pending';
    final isConfirmed = appointment['status'] == 'confirmed';
    final isCompleted = appointment['status'] == 'completed';

    final statusColor = isPending ? Colors.orange : isConfirmed ? Colors.green : Colors.purple;

    return Container(
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.pets, color: Colors.blue[600], size: 24),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment['ownerName'] ?? 'Unknown Owner',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey[800]),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Pet: ${appointment['petName'] ?? 'Unknown Pet'}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor[50],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor[200]!),
                  ),
                  child: Text(
                    appointment['status'].toString().toUpperCase(),
                    style: TextStyle(
                      color: statusColor[700],
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  _buildDetailRow(Icons.pets, 'Consultation Type', appointment['consultationType']),
                  _buildDetailRow(Icons.calendar_today, 'Date', '${appointment['selectedDay']}, ${appointment['selectedDate']?.toString().split(' ')[0]}'),
                  _buildDetailRow(Icons.access_time, 'Time', appointment['selectedTime']),
                  _buildDetailRow(Icons.attach_money, 'Fee', 'Rs. ${appointment['consultationFee']}'),
                  _buildDetailRow(Icons.payment, 'Payment', appointment['paymentMethod']),
                  if (appointment['reason'] != null &&
                      appointment['reason'].toString().trim().isNotEmpty)
                    _buildDetailRow(
                        Icons.info_outline, 'Reason', appointment['reason']),
                ],
              ),
            ),
            SizedBox(height: 10),
            if (appointment['paymentScreenshotUrl'] != null) ...[
              Text(
                'Payment Screenshot',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[800]),
              ),
              SizedBox(height: 12),
              GestureDetector(
                onTap: () => _showImageDialog(context, appointment['paymentScreenshotUrl']),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.25,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: appointment['paymentScreenshotUrl'],
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[100],
                        child: Center(
                          child: CircularProgressIndicator(color: Colors.blue[600]),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[100],
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline, color: Colors.grey[400], size: 32),
                              SizedBox(height: 8),
                              Text('Failed to load image', style: TextStyle(color: Colors.grey[500])),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],

            if (isPending) ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => controller.approveAppointment(appointment['id'], appointment['userId']),
                      icon: Icon(Icons.check_circle, size: 20),
                      label: Text('Approve', style: TextStyle(fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[600],
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showRejectDialog(context, appointment['id'], appointment['userId']),
                      icon: Icon(Icons.cancel, size: 20),
                      label: Text('Reject', style: TextStyle(fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[600],
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ] else if (isConfirmed) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => controller.completeAppointment(appointment['id'], appointment['userId']),
                  icon: Icon(Icons.task_alt, size: 20),
                  label: Text('Mark as Completed', style: TextStyle(fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                ),
              ),
            ] else if (isCompleted) ...[
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.purple[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.purple[200]!),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: Colors.purple[600], size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Appointment Completed',
                      style: TextStyle(
                        color: Colors.purple[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String? value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey[700]),
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'N/A',
              style: TextStyle(color: Colors.grey[800]),
            ),
          ),
        ],
      ),
    );
  }

  void _showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      'Payment Screenshot',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    Spacer(),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.7,
                ),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => Container(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 200,
                    child: Center(child: Icon(Icons.error, size: 48)),
                  ),
                ),
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showRejectDialog(BuildContext context, String appointmentId, String userId) {
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Reject Appointment', style: TextStyle(fontWeight: FontWeight.w600)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Please provide a reason for rejection:', style: TextStyle(color: Colors.grey[700])),
            SizedBox(height: 16),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Enter reason for rejection...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.blue[600]!),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.trim().isNotEmpty) {
                controller.rejectAppointment(appointmentId, userId, reasonController.text.trim());
                Navigator.pop(context);
              } else {
                Get.snackbar('Error', 'Please provide a reason for rejection');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Reject'),
          ),
        ],
      ),
    );
  }
}