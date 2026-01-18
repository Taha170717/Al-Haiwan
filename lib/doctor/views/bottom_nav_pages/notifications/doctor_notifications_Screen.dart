import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../controller/doctor_notifications_controller.dart';

class DoctorNotificationsScreen extends StatefulWidget {
  const DoctorNotificationsScreen({Key? key}) : super(key: key);

  @override
  _DoctorNotificationsScreenState createState() => _DoctorNotificationsScreenState();
}

class _DoctorNotificationsScreenState extends State<DoctorNotificationsScreen> {
  late DoctorNotificationsController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(DoctorNotificationsController());
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF199A8E),
        title: Text('Notifications',
            style: TextStyle(
              color: Colors.white,
              fontSize: screen.width * 0.045,
              fontWeight: FontWeight.bold,
            )),
        elevation: 0,
        actions: [
          Obx(() {
            if (controller.unreadCount.value > 0) {
              return Padding(
                padding: EdgeInsets.all(screen.width * 0.03),
                child: TextButton(
                  onPressed: controller.markAllAsRead,
                  child: Text(
                    'Mark All Read',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screen.width * 0.03,
                    ),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: Obx(() {
        final hasError = controller.listenerError.value.isNotEmpty;
        final notifs = controller.notifications;

        if (notifs.isEmpty && !hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.notifications_off_outlined, size: screen.width * 0.15, color: Colors.grey[300]),
                SizedBox(height: screen.height * 0.02),
                Text('No Notifications', style: TextStyle(fontSize: screen.width * 0.04, fontWeight: FontWeight.bold, color: Colors.grey[600])),
                SizedBox(height: screen.height * 0.01),
                Text('You\'ll see appointment requests here', style: TextStyle(fontSize: screen.width * 0.035, color: Colors.grey[500])),
                SizedBox(height: 16),
                TextButton.icon(onPressed: () async { await controller.listenToNotifications(); await controller.fetchUnreadCount(); }, icon: const Icon(Icons.refresh), label: const Text('Retry listening / refresh'))
              ],
            ),
          );
        }

        return Column(
          children: [
            if (hasError)
              Container(
                width: double.infinity,
                color: Colors.red.shade50,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text('Listener error: ${controller.listenerError.value}', style: TextStyle(color: Colors.red[800]))),
                    IconButton(onPressed: () async { await controller.listenToNotifications(); await controller.fetchUnreadCount(); }, icon: const Icon(Icons.refresh, color: Colors.red))
                  ],
                ),
              ),

            Container(
              width: double.infinity,
              color: Colors.grey[50],
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Notifications: ${notifs.length}  •  Unread: ${controller.unreadCount.value}'),
                  TextButton(onPressed: () async { await controller.listenToNotifications(); await controller.fetchUnreadCount(); }, child: const Text('Refresh')),
                ],
              ),
            ),

            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.fetchUnreadCount,
                child: ListView.separated(
                  padding: EdgeInsets.all(screen.width * 0.04),
                  separatorBuilder: (_, __) => SizedBox(height: screen.height * 0.01),
                  itemCount: notifs.length,
                  itemBuilder: (context, index) {
                    final notification = notifs[index];
                    final isRead = (notification['read'] ?? false) as bool;
                    final createdAtRaw = notification['createdAt'];
                    final createdAt = _parseCreatedAt(createdAtRaw);
                    final notificationId = notification['id'] ?? '';

                    return _buildNotificationTile(screen, notification, isRead, createdAt, notificationId);
                  },
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildNotificationTile(Size screen, Map<String, dynamic> notification, bool isRead, DateTime? createdAt, String notificationId) {
    return Container(
      margin: EdgeInsets.only(bottom: screen.height * 0.015),
      decoration: BoxDecoration(
        color: isRead ? Colors.white : const Color.fromRGBO(25, 154, 142, 0.05),
        borderRadius: BorderRadius.circular(screen.width * 0.03),
        border: Border.all(color: isRead ? Colors.grey[300]! : const Color(0xFF199A8E), width: isRead ? 1 : 2),
        boxShadow: [BoxShadow(color: const Color.fromRGBO(0, 0, 0, 0.05), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            if (!isRead && notificationId.isNotEmpty) await controller.markAsRead(notificationId);
            _showNotificationDetails(context, notification, MediaQuery.of(context).size);
          },
          borderRadius: BorderRadius.circular(screen.width * 0.03),
          child: Padding(
            padding: EdgeInsets.all(screen.width * 0.04),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(width: screen.width * 0.12, height: screen.width * 0.12, decoration: const BoxDecoration(color: Color(0xFF199A8E), shape: BoxShape.circle), child: const Icon(Icons.calendar_month, color: Colors.white)),
                SizedBox(width: screen.width * 0.03),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(notification['title'] ?? 'New Appointment', style: TextStyle(fontSize: screen.width * 0.04, fontWeight: FontWeight.bold)),
                  SizedBox(height: screen.height * 0.005),
                  Text(notification['patientName'] ?? 'Unknown', style: TextStyle(fontSize: screen.width * 0.035, color: const Color(0xFF199A8E), fontWeight: FontWeight.w600)),
                ])),
                if (!isRead) Container(width: screen.width * 0.025, height: screen.width * 0.025, decoration: const BoxDecoration(color: Color(0xFF199A8E), shape: BoxShape.circle)),
              ]),
              SizedBox(height: screen.height * 0.01),
              Text(notification['body'] ?? 'New appointment request', style: TextStyle(fontSize: screen.width * 0.032, color: Colors.grey[700]), maxLines: 2, overflow: TextOverflow.ellipsis),
              SizedBox(height: screen.height * 0.01),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(_formatTime(createdAt), style: TextStyle(fontSize: screen.width * 0.03, color: Colors.grey[500])),
                Row(children: [
                  TextButton.icon(onPressed: notificationId.isNotEmpty ? () => controller.markAsRead(notificationId) : null, icon: Icon(isRead ? Icons.done_all : Icons.done, size: screen.width * 0.04), label: Text(isRead ? 'Read' : 'Mark Read'), style: TextButton.styleFrom(foregroundColor: const Color(0xFF199A8E))),
                  TextButton.icon(onPressed: notificationId.isNotEmpty ? () => controller.deleteNotification(notificationId) : null, icon: Icon(Icons.delete_outline, size: screen.width * 0.04), label: const Text('Delete'), style: TextButton.styleFrom(foregroundColor: Colors.red)),
                ])
              ])
            ]),
          ),
        ),
      ),
    );
  }

  DateTime? _parseCreatedAt(dynamic raw) {
    if (raw == null) return null;
    try {
      if (raw is String) return DateTime.tryParse(raw);
      if (raw is Timestamp) return raw.toDate();
      if (raw is int) return DateTime.fromMillisecondsSinceEpoch(raw);
      if (raw is double) return DateTime.fromMillisecondsSinceEpoch(raw.toInt());
    } catch (_) {}
    return null;
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) return 'Just now';
    final now = DateTime.now();
    final difference = now.difference(dt);
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return DateFormat('MMM d').format(dt);
  }

  void _showNotificationDetails(BuildContext context, Map<String, dynamic> notification, Size screen) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(screen.width * 0.05))),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: EdgeInsets.all(screen.width * 0.04),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Center(child: Container(width: screen.width * 0.1, height: screen.height * 0.005, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
                  SizedBox(height: screen.height * 0.02),
                  Text('Appointment Details', style: TextStyle(fontSize: screen.width * 0.045, fontWeight: FontWeight.bold)),
                  SizedBox(height: screen.height * 0.02),
                  _buildDetailRow('Patient Name', notification['patientName']?.toString() ?? 'N/A', screen),
                  _buildDetailRow('Consultation Type', notification['consultationType']?.toString() ?? 'N/A', screen),
                  _buildDetailRow('Date', notification['appointmentDate']?.toString() ?? 'N/A', screen),
                  _buildDetailRow('Time', notification['appointmentTime']?.toString() ?? 'N/A', screen),
                  _buildDetailRow('Consultation Fee', 'Rs. ${notification['consultationFee']?.toString() ?? '0'}', screen),
                  SizedBox(height: screen.height * 0.02),
                  ElevatedButton(onPressed: () => Navigator.pop(context), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF199A8E), minimumSize: Size(double.infinity, screen.height * 0.06), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(screen.width * 0.03))), child: Text('Close', style: TextStyle(color: Colors.white, fontSize: screen.width * 0.04)))
                ]),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, Size screen) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: screen.height * 0.01),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: TextStyle(fontSize: screen.width * 0.035, color: Colors.grey[600])), Text(value, style: TextStyle(fontSize: screen.width * 0.035, fontWeight: FontWeight.w600, color: Colors.black))]),
    );
  }
}
