import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _local = FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const String _channelId = 'app_notifications';
  static const String _channelName = 'App Notifications';
  static const String _channelDescription = 'Notifications for appointments and messages';

  // Returns a stable platform identifier. Avoids calling Platform on web where it's unsupported.
  String _platformName() {
    try {
      if (kIsWeb) return 'web';
      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
          return 'android';
        case TargetPlatform.iOS:
          return 'ios';
        case TargetPlatform.linux:
          return 'linux';
        case TargetPlatform.macOS:
          return 'macos';
        case TargetPlatform.windows:
          return 'windows';
        case TargetPlatform.fuchsia:
        default:
          return 'unknown';
      }
    } catch (e) {
      return 'unknown';
    }
  }

  Future<void> init() async {
    // Initialize local notifications
    final AndroidInitializationSettings androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initSettings = InitializationSettings(
      android: androidInit,
      iOS: DarwinInitializationSettings(),
    );

    await _local.initialize(initSettings, onDidReceiveNotificationResponse: (payload) {
      // handle interaction when user taps notification (foreground)
      // payload can be a JSON string with navigation info
      // You can integrate deep links/navigation here.
    });

    // Create Android channel (required for Android 8+)
    final AndroidNotificationChannel channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
    );

    try {
      await _local.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);
    } catch (e) {
      // ignore - platform might not support
    }

    // Request permission for iOS/macOS
    await _fcm.requestPermission(alert: true, badge: true, sound: true);

    // Get initial token and save
    try {
      final token = await _fcm.getToken();
      if (token != null) {
        await _saveTokenToFirestore(token);
      }
    } catch (e) {
      print('Failed to get FCM token: $e');
    }

    // When auth state changes, ensure token is saved for the logged-in user
    FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user != null) {
        try {
          final token = await _fcm.getToken();
          if (token != null) await _saveTokenToFirestore(token);
        } catch (e) {
          print('Failed to save token on auth change: $e');
        }
      }
    });

    // Monitor token refresh
    _fcm.onTokenRefresh.listen((newToken) async {
      await _saveTokenToFirestore(newToken);
    });

    // Foreground message handler -> show local notification
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showLocalNotification(message);
    });

    // Optionally handle messages that open the app
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Handle navigation based on message.data
      print('onMessageOpenedApp: ${message.data}');
    });
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    try {
      final notification = message.notification;
      final title = notification?.title ?? message.data['title'] ?? '';
      final body = notification?.body ?? message.data['body'] ?? message.data['message'] ?? '';

      final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
      );

      final NotificationDetails platformDetails = NotificationDetails(android: androidDetails);

      await _local.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title,
        body,
        platformDetails,
        payload: message.data.isNotEmpty ? message.data.toString() : null,
      );
    } catch (e) {
      print('Failed to show local notification: $e');
    }
  }

  /// Public method to show a local notification with a title and body.
  Future<void> showNotification({required String title, required String body}) async {
    try {
      final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
      );

      final NotificationDetails platformDetails = NotificationDetails(android: androidDetails);

      await _local.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title,
        body,
        platformDetails,
        payload: null,
      );
    } catch (e) {
      print('showNotification failed: $e');
    }
  }

  Future<void> _saveTokenToFirestore(String token) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final uid = user.uid;
      final tokenDoc = _db.collection('users').doc(uid).collection('fcmTokens').doc(token);

      await tokenDoc.set({
        'token': token,
        'platform': _platformName(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Also try to write under doctors/{uid}/fcmTokens for convenience if doctor doc exists
      try {
        final docRef = _db.collection('doctors').doc(uid);
        final docSnap = await docRef.get();
        if (docSnap.exists) {
          await docRef.collection('fcmTokens').doc(token).set({
            'token': token,
            'platform': _platformName(),
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      } catch (e) {
        // ignore doctor write failures
      }

      print('Saved FCM token for user $uid');
    } catch (e) {
      print('Error saving FCM token to Firestore: $e');
    }
  }

  /// Public helper to force-save the token for the current authenticated user
  Future<void> saveTokenForCurrentUser() async {
    try {
      final token = await _fcm.getToken();
      if (token != null) await _saveTokenToFirestore(token);
    } catch (e) {
      print('saveTokenForCurrentUser failed: $e');
    }
  }
}
