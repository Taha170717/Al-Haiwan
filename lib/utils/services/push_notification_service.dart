import 'dart:ui';

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;

class PushNotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  /// Initialize FCM and request permissions
  static Future<void> initializeFCM() async {
    try {
      // Request permission for notifications.
      // On web, call requestPermission directly. On mobile guard Platform checks with kIsWeb.
      if (kIsWeb) {
        await _firebaseMessaging.requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
          sound: true,
        );
      } else {
        // Running on mobile platforms; guard Platform.* calls safely
        try {
          if (Platform.isIOS) {
            await _firebaseMessaging.requestPermission(
              alert: true,
              announcement: false,
              badge: true,
              carPlay: false,
              criticalAlert: false,
              provisional: false,
              sound: true,
            );
          } else if (Platform.isAndroid) {
            // For Android 13 and above, request permission
            await _firebaseMessaging.requestPermission(
              alert: true,
              announcement: false,
              badge: true,
              carPlay: false,
              criticalAlert: false,
              provisional: false,
              sound: true,
            );
          }
        } catch (e) {
          // In case Platform.* is unavailable, fall back to generic request
          await _firebaseMessaging.requestPermission(
            alert: true,
            announcement: false,
            badge: true,
            carPlay: false,
            criticalAlert: false,
            provisional: false,
            sound: true,
          );
        }
      }

      // Get and store FCM token
      await getFCMToken();

      // Register background message handler
      try {
        FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      } catch (e) {
        if (kDebugMode) print('[v0] onBackgroundMessage registration failed or not supported: $e');
      }

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (kDebugMode) {
          print('[v0] Foreground message received: ${message.notification?.title}');
        }
        handleForegroundMessage(message);
      });

      // Handle terminated app messages
      FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
        if (message != null) {
          if (kDebugMode) {
            print('[v0] App opened from terminated state with message');
          }
          handleTerminatedMessage(message);
        }
      });

      // Handle background messages
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        if (kDebugMode) {
          print('[v0] Background message tapped: ${message.notification?.title}');
        }
        handleBackgroundMessageTap(message);
      });
    } catch (e) {
      if (kDebugMode) {
        print('[v0] Error initializing FCM: $e');
      }
    }
  }

  /// Get FCM token for a user
  static Future<String?> getFCMToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      if (kDebugMode) {
        print('[v0] FCM Token obtained: $token');
      }
      // Save token to Firestore so server functions can send notifications
      if (token != null) {
        try {
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            final uid = user.uid;
            final db = FirebaseFirestore.instance;
            await db.collection('users').doc(uid).collection('fcmTokens').doc(token).set({
              'token': token,
              'platform': _platformName(),
              'createdAt': FieldValue.serverTimestamp(),
            });

            // also add under doctors/{uid}/fcmTokens if doctor doc exists
            try {
              final docRef = db.collection('doctors').doc(uid);
              final docSnap = await docRef.get();
              if (docSnap.exists) {
                await docRef.collection('fcmTokens').doc(token).set({
                  'token': token,
                  'platform': _platformName(),
                  'createdAt': FieldValue.serverTimestamp(),
                });
              }
            } catch (e) {
              if (kDebugMode) print('[v0] failed to write token to doctors subcollection: $e');
            }
          }
        } catch (e) {
          if (kDebugMode) print('[v0] Error saving FCM token to Firestore: $e');
        }
      }
      return token;
    } catch (e) {
      if (kDebugMode) {
        print('[v0] Error getting FCM token: $e');
      }
      return null;
    }
  }

  /// Handle messages received while app is in foreground
  static void handleForegroundMessage(RemoteMessage message) {
    if (message.notification != null) {
      if (kDebugMode) {
        print('[v0] Foreground - Title: ${message.notification!.title}');
        print('[v0] Foreground - Body: ${message.notification!.body}');
      }
      // Show notification UI or update app state
      _showNotificationSnackbar(
        title: message.notification!.title ?? 'New Notification',
        body: message.notification!.body ?? '',
      );
    }
  }

  /// Handle messages that open the app from terminated state
  static void handleTerminatedMessage(RemoteMessage message) {
    if (kDebugMode) {
      print('[v0] Terminated - Title: ${message.notification!.title}');
    }
    // Navigate to specific screen if needed
    _navigateToScreen(message.data);
  }

  /// Handle message tap from background
  static void handleBackgroundMessageTap(RemoteMessage message) {
    if (kDebugMode) {
      print('[v0] Message tapped - Title: ${message.notification!.title}');
    }
    _navigateToScreen(message.data);
  }

  /// Show notification snackbar when app is in foreground
  static void _showNotificationSnackbar({
    required String title,
    required String body,
  }) {
    Get.snackbar(
      title,
      body,
      duration: const Duration(seconds: 3),
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF199A8E),
      colorText: Colors.white,
      margin: const EdgeInsets.all(12),
      borderRadius: 8,
    );
  }

  /// Navigate to specific screen based on notification data
  static void _navigateToScreen(Map<String, dynamic> data) {
    // Handle navigation based on data
    if (data.containsKey('appointmentId')) {
      // Navigate to appointment details screen
      if (kDebugMode) {
        print('[v0] Navigating to appointment: ${data['appointmentId']}');
      }
    }
  }

  static String _platformName() {
    try {
      if (kIsWeb) return 'web';
      return Platform.operatingSystem;
    } catch (e) {
      return 'unknown';
    }
  }
}

/// Top-level background message handler required by firebase_messaging
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you need to use Firebase in the background handler ensure it's initialized.
  // Note: avoid heavy processing here; use it to show a notification or schedule work.
  print('[v0] Background message received: ${message.messageId}');
}
