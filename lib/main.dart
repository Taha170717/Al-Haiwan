import 'package:al_haiwan/user/controllers/auth_controller.dart';
import 'package:al_haiwan/user/repository/screens/splash/splashscreen.dart';
import 'package:al_haiwan/user/repository/user_service.dart';
import 'package:al_haiwan/utils/services/push_notification_service.dart';
import 'package:al_haiwan/utils/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_storage/get_storage.dart';
import 'admin/controllers/admin_appointment_controller.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// Top-level background handler required for firebase_messaging
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you want to handle background messages, initialize any plugins if necessary.
  // For example, you could log or pass the message to a background notification handler.
  print('Handling a background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await GetStorage.init();
  // flutter_stripe removed: using screenshot-based payment flow handled in the
  // appointment controller and ImageKit service. If you later re-add
  // a different payment plugin, initialize it here.

  // Initialize Firebase Messaging permissions and handlers
  await _initFirebaseMessaging();

  // Initialize local & push notification handling (registers token and shows local notifications)
  await NotificationService().init();
  // Keep existing push listener initialization for backward compatibility
  await PushNotificationService.initializeFCM();

  Get.put(AuthController());
  Get.put(UserService());
  Get.put(AdminAppointmentController());

  runApp(const MyApp());
}

/// Initialize permissions and handlers for FCM across platforms.
Future<void> _initFirebaseMessaging() async {
  final messaging = FirebaseMessaging.instance;

  // Set background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  try {
    // Request permissions (iOS & web; on Android this will handle Android 13+ POST_NOTIFICATIONS)
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('FCM permission status: ${settings.authorizationStatus}');

    // For iOS: show notifications when app is in foreground
    await messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // On web, ensure a service worker exists (we add a template at web/firebase-messaging-sw.js in the repo).
    if (kIsWeb) {
      // Attempt to get token to trigger registration flow in the browser
      try {
        String? token = await messaging.getToken();
        print('FCM web token: $token');
      } catch (e) {
        print('Error getting FCM web token: $e');
      }
    }

    // Listen for foreground messages and let your NotificationService display them locally
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received a foreground message: ${message.messageId}');

      final notification = message.notification;
      final title = notification?.title ?? message.data['title'] ?? '';
      final body = notification?.body ?? message.data['body'] ?? message.data['message'] ?? '';

      // Delegates to your existing NotificationService which you already initialize in main.
      // Use dynamic invocation to avoid static analyzer issues if NotificationService signature changes.
      try {
        (NotificationService() as dynamic).showNotification(title: title, body: body);
      } catch (e) {
        print('NotificationService.showNotification failed (dynamic call): $e');
      }
    });
  } catch (e) {
    print('Error initializing Firebase Messaging: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Al-Haiwan',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto',
      ),
      home:  SplashScreen(),
      debugShowCheckedModeBanner: false,
      defaultTransition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
