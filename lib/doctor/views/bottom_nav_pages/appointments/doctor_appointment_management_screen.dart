import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../controller/doctor_appointment_controller.dart';
import 'package:al_haiwan/utils/custom_snackbar.dart';

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
            child: Obx(() {
              // Horizontal scrollable tab bar to avoid overflow on small screens
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildScrollTab('Pending', 0, controller.pendingAppointments.length, Colors.blue[600]!),
                    _buildScrollTab('Confirmed', 1, controller.confirmedAppointments.length, Colors.green[600]!),
                    _buildScrollTab('Completed', 2, controller.completedAppointments.length, Colors.purple[600]!),
                    _buildScrollTab('Rejected', 3, controller.rejectedAppointments.length, Colors.red[600]!),
                  ],
                ),
              );
            }),
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
            : controller.selectedTab.value == 2
            ? controller.completedAppointments
            : controller.rejectedAppointments;

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
                        : controller.selectedTab.value == 2
                        ? Icons.task_alt
                        : Icons.cancel,
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
                      : controller.selectedTab.value == 2
                      ? 'No completed appointments'
                      : 'No rejected appointments',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.grey[600]),
                ),
                SizedBox(height: 8),
                Text(
                  controller.selectedTab.value == 0
                      ? 'New appointment requests will appear here'
                      : controller.selectedTab.value == 1
                      ? 'Confirmed appointments will appear here'
                      : controller.selectedTab.value == 2
                      ? 'Completed appointments will appear here'
                      : 'Rejected appointments will appear here',
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
    final isRejected = appointment['status'] == 'rejected';

    // For rejected appointments, render a compact card showing only essential info + reason
    if (isRejected) {
      // get reason and timestamp safely
      final reason = appointment['doctorNotes'] ?? appointment['reason'] ?? 'No reason provided';
      String rejectedAtText = '';
      final ra = appointment['rejectedAt'];
      try {
        if (ra != null) {
          if (ra is Map && ra['_seconds'] != null) {
            // Possibly a serialized timestamp map
            final seconds = ra['_seconds'];
            final dt = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
            rejectedAtText = '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}';
          } else if (ra is int) {
            final dt = DateTime.fromMillisecondsSinceEpoch(ra);
            rejectedAtText = '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}';
          } else if (ra is Timestamp) {
            final dt = ra.toDate();
            rejectedAtText = '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}';
          } else if (ra is DateTime) {
            final dt = ra as DateTime;
            rejectedAtText = '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}';
          }
        }
      } catch (e) {
        rejectedAtText = '';
      }

      return Container(
        margin: EdgeInsets.only(bottom: 8),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.red[50]!),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 4, offset: Offset(0,1))],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.cancel, color: Colors.red[600], size: 20),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appointment['ownerName'] ?? 'Unknown Owner',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.grey[800]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Pet: ${appointment['petName'] ?? 'Unknown'}',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Reason: $reason',
                    style: TextStyle(fontSize: 13, color: Colors.grey[800]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (rejectedAtText.isNotEmpty) ...[
                    SizedBox(height: 6),
                    Text(
                      rejectedAtText,
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.visibility, color: Colors.grey[600]),
              onPressed: () {
                // show full details dialog
                showDialog(
                  context: context,
                  builder: (_) => Dialog(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Appointment Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          SizedBox(height: 12),
                          Text('Owner: ${appointment['ownerName'] ?? 'Unknown'}'),
                          Text('Pet: ${appointment['petName'] ?? 'Unknown'}'),
                          SizedBox(height: 8),
                          Text('Reason for rejection:'),
                          Text(reason, style: TextStyle(fontWeight: FontWeight.w600)),
                          SizedBox(height: 12),
                          if (appointment['paymentScreenshotUrl'] != null)
                            OutlinedButton.icon(
                              onPressed: () => _showImageDialog(context, appointment['paymentScreenshotUrl']),
                              icon: Icon(Icons.image, color: Colors.grey[700]),
                              label: Text('View Payment Screenshot', style: TextStyle(color: Colors.grey[800])),
                            ),
                          SizedBox(height: 8),
                          Text('Status: ${appointment['status'] ?? ''}'),
                          SizedBox(height: 8),
                          Text('ID: ${appointment['id'] ?? ''}', style: TextStyle(fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      );
    }

    final statusColor = isPending ? Colors.orange : isConfirmed ? Colors.green : Colors.purple;

    return Container(
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
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
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showImageDialog(context, appointment['paymentScreenshotUrl']),
                  icon: Icon(Icons.image, color: Colors.grey[700]),
                  label: Text('View Payment Screenshot', style: TextStyle(color: Colors.grey[800])),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              SizedBox(height: 12),
            ],

            // Reviews for this appointment
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('reviews').where('appointmentId', isEqualTo: appointment['id']).snapshots(),
              builder: (context, snap) {
                if (!snap.hasData || (snap.data?.docs.isEmpty ?? true)) return SizedBox();
                final docs = snap.data!.docs;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Reviews', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[800])),
                    SizedBox(height: 8),
                    ...docs.map((d) {
                      final data = d.data() as Map<String, dynamic>;
                      final rating = data['rating']?.toString() ?? '';
                      final comment = data['comment'] ?? '';
                      // Prefer userName from the review document if present and non-empty.
                      // If missing, fall back to the appointment.ownerName (readable), then to userId, then 'User'.
                      String reviewer = 'User';
                      try {
                        final rn = data['userName'];
                        if (rn is String && rn.trim().isNotEmpty) {
                          reviewer = rn.trim();
                        } else if (appointment.containsKey('ownerName') && (appointment['ownerName'] as String?)?.trim().isNotEmpty == true) {
                          reviewer = appointment['ownerName'];
                        } else if (data['userId'] != null) {
                          reviewer = data['userId'].toString();
                        }
                      } catch (_) {
                        reviewer = (data['userId'] ?? 'User').toString();
                      }
                      return Container(
                        margin: EdgeInsets.only(bottom: 8),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8)),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(radius: 16, backgroundColor: Colors.grey[200], child: Icon(Icons.person, size: 16, color: Colors.grey[600])),
                            SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [Text(reviewer, style: TextStyle(fontWeight: FontWeight.w600)), SizedBox(width: 8), if (rating.isNotEmpty) Text('• $rating/5', style: TextStyle(color: Colors.orange[700]))]),
                                  if ((comment as String).isNotEmpty) SizedBox(height: 6),
                                  if ((comment as String).isNotEmpty) Text(comment, style: TextStyle(color: Colors.grey[800])),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                );
              },
            ),

            SizedBox(height: 10),
            if (isPending) ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final success = await controller.approveAppointment(appointment['id'], appointment['userId']);
                        if (success) {
                          CustomSnackbar.showSuccess('Success', 'Appointment approved successfully!', context: context);
                        } else {
                          CustomSnackbar.showError('Error', 'Failed to approve appointment.', context: context);
                        }
                      },
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
                  onPressed: () async {
                    final success = await controller.completeAppointment(appointment['id'], appointment['userId']);
                    if (success) {
                      CustomSnackbar.showSuccess('Success', 'Appointment marked as completed!', context: context);
                    } else {
                      CustomSnackbar.showError('Error', 'Failed to mark appointment as completed.', context: context);
                    }
                  },
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
              SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showPrescriptionDialog(context, appointment['id'], appointment['doctorId'] ?? '', appointment['userId'] ?? ''),
                  icon: Icon(Icons.receipt_long, color: Color(0xFF199A8E)),
                  label: Text('Send Prescription', style: TextStyle(color: Color(0xFF199A8E), fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
              SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showPrescriptionDialog(context, appointment['id'], appointment['doctorId'] ?? '', appointment['userId'] ?? ''),
                  icon: Icon(Icons.receipt_long, color: Color(0xFF199A8E)),
                  label: Text('Send Prescription', style: TextStyle(color: Color(0xFF199A8E), fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
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
      )
    );
  }

  void _showRejectDialog(BuildContext context, String appointmentId, String userId) {
    final TextEditingController reasonController = TextEditingController();
    final parentContext = context; // capture scaffold context for SnackBars

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
            onPressed: () async {
              if (reasonController.text.trim().isNotEmpty) {
                final success = await controller.rejectAppointment(appointmentId, userId, reasonController.text.trim());
                Navigator.pop(parentContext);
                if (success) {
                  CustomSnackbar.showSuccess('Rejected', 'Appointment rejected with reason provided', context: parentContext);
                } else {
                  CustomSnackbar.showError('Error', 'Failed to reject appointment.', context: parentContext);
                }
              } else {
                CustomSnackbar.showError('Required', 'Please provide a reason for rejection', context: parentContext);
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

  void _showPrescriptionDialog(BuildContext context, String appointmentId, String doctorId, String userId) {
    final TextEditingController prescriptionCtrl = TextEditingController();
    final parentContext = context;
    bool submitting = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: Text('Send Prescription', style: TextStyle(fontWeight: FontWeight.w600)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: prescriptionCtrl,
                  maxLines: 6,
                  decoration: InputDecoration(hintText: 'Type prescription here...'),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
              ElevatedButton(
                onPressed: submitting
                    ? null
                    : () async {
                        final text = prescriptionCtrl.text.trim();
                        if (text.isEmpty) {
                          CustomSnackbar.showError('Required', 'Please type a prescription before sending', context: parentContext);
                          return;
                        }
                        try {
                          setState(() => submitting = true);
                          await FirebaseFirestore.instance.collection('prescriptions').add({
                            'appointmentId': appointmentId,
                            'doctorId': doctorId,
                            'userId': userId,
                            'prescription': text,
                            'createdAt': FieldValue.serverTimestamp(),
                          });

                          Navigator.pop(parentContext);
                          CustomSnackbar.showSuccess('Sent', 'Prescription sent to user', context: parentContext);
                        } catch (e) {
                          CustomSnackbar.showError('Error', 'Failed to send prescription: ${e.toString()}', context: parentContext);
                        } finally {
                          setState(() => submitting = false);
                        }
                      },
                child: submitting ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text('Send'),
              ),
            ],
          ),
        );
      },
    );
  }

  // Helper to render a compact scrollable tab
  Widget _buildScrollTab(String label, int tabIndex, int count, Color activeColor) {
    return Obx(() {
      final selected = controller.selectedTab.value == tabIndex;
      return GestureDetector(
        onTap: () => controller.selectedTab.value = tabIndex,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: selected ? activeColor : Colors.transparent, width: 3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$label ($count)',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: selected ? activeColor : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
