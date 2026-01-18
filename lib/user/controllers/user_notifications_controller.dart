import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class UserNotificationsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  var unreadCount = 0.obs;
  var notifications = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    listenToNotifications();
  }

  void listenToNotifications() {
    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      _firestore
          .collection('user_notifications')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .listen((snapshot) {
        notifications.value = snapshot.docs.map((doc) {
          final data = doc.data();
          return {...data, 'id': doc.id};
        }).toList();

        unreadCount.value = snapshot.docs
            .where((doc) => (doc.data() as Map<String, dynamic>)['isRead'] != true)
            .length;

        if (kDebugMode) {
          print('[v0] User notifications updated: ${notifications.length}, unread: ${unreadCount.value}');
        }
      });
    }
  }

  @override
  void onClose() {
    unreadCount.close();
    notifications.close();
    super.onClose();
  }
}
