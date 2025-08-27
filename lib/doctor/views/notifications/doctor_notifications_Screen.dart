import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../models/notification_model.dart';

class DoctorNotificationsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    final isTablet = screen.width > 600;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: TextStyle(
            color: Color(0xFF199A8E),
            fontWeight: FontWeight.bold,
            fontSize: screen.width * (isTablet ? 0.035 : 0.045),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFF199A8E)),
        actions: [
          IconButton(
            icon: Icon(Icons.mark_email_read, color: Color(0xFF199A8E)),
            onPressed: () => _markAllAsRead(user?.uid),
          ),
        ],
      ),
      body: user == null
          ? Center(
        child: Text(
          'Please login to view notifications',
          style: TextStyle(
            fontSize: screen.width * (isTablet ? 0.03 : 0.04),
            color: Colors.grey,
          ),
        ),
      )
          : StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('userId', isEqualTo: user.uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF199A8E)),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading notifications',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: screen.width * (isTablet ? 0.03 : 0.04),
                ),
              ),
            );
          }

          final notifications = snapshot.data?.docs.map((doc) =>
              NotificationModel.fromFirestore(
                  doc.data() as Map<String, dynamic>, doc.id)
          ).toList() ?? [];

          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: screen.width * 0.2,
                    color: Colors.grey[300],
                  ),
                  SizedBox(height: screen.height * 0.02),
                  Text(
                    'No notifications found.',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: screen.width * (isTablet ? 0.03 : 0.04),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(screen.width * 0.04),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return _buildNotificationCard(context, screen, notification, isTablet);
            },
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, Size screen, NotificationModel notification, bool isTablet) {
    return Container(
      margin: EdgeInsets.only(bottom: screen.height * 0.015),
      padding: EdgeInsets.all(screen.width * 0.04),
      decoration: BoxDecoration(
        color: notification.isRead ? Colors.white : Color(0xFF199A8E).withOpacity(0.05),
        borderRadius: BorderRadius.circular(screen.width * 0.03),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: notification.isRead ? Colors.grey[200]! : Color(0xFF199A8E).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getNotificationIcon(notification.type),
                color: Color(0xFF199A8E),
                size: screen.width * (isTablet ? 0.04 : 0.05),
              ),
              SizedBox(width: screen.width * 0.03),
              Expanded(
                child: Text(
                  notification.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: screen.width * (isTablet ? 0.03 : 0.04),
                    color: notification.isRead ? Colors.black87 : Color(0xFF199A8E),
                  ),
                ),
              ),
              if (!notification.isRead)
                Container(
                  width: screen.width * 0.025,
                  height: screen.width * 0.025,
                  decoration: BoxDecoration(
                    color: Color(0xFF199A8E),
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
          SizedBox(height: screen.height * 0.01),
          Text(
            notification.body,
            style: TextStyle(
              fontSize: screen.width * (isTablet ? 0.025 : 0.035),
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
          SizedBox(height: screen.height * 0.01),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDateTime(notification.createdAt),
                style: TextStyle(
                  fontSize: screen.width * (isTablet ? 0.02 : 0.025),
                  color: Colors.grey[500],
                ),
              ),
              if (!notification.isRead)
                GestureDetector(
                  onTap: () => _markAsRead(notification.id),
                  child: Text(
                    'Mark as read',
                    style: TextStyle(
                      fontSize: screen.width * (isTablet ? 0.02 : 0.025),
                      color: Color(0xFF199A8E),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'appointment_update':
        return Icons.calendar_today;
      case 'payment_update':
        return Icons.payment;
      case 'general':
        return Icons.info;
      default:
        return Icons.notifications;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  Future<void> _markAsRead(String notificationId) async {
    try {
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      Get.snackbar('Error', 'Failed to mark notification as read');
    }
  }

  Future<void> _markAllAsRead(String? userId) async {
    if (userId == null) return;

    try {
      final batch = FirebaseFirestore.instance.batch();
      final notifications = await FirebaseFirestore.instance
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      for (var doc in notifications.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();
      Get.snackbar('Success', 'All notifications marked as read');
    } catch (e) {
      Get.snackbar('Error', 'Failed to mark all notifications as read');
    }
  }
}