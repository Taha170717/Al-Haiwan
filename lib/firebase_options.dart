// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDbj1wB0u1jAkNAAvffUloGhFLBBeZPc58',
    appId: '1:662228895986:web:e87a71702002eb80bb286b',
    messagingSenderId: '662228895986',
    projectId: 'alhewan-cool-project',
    authDomain: 'alhewan-cool-project.firebaseapp.com',
    storageBucket: 'alhewan-cool-project.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB5XXgzVhg1Ws6um2dM0_-CzZG_Sv6ISjs',
    appId: '1:662228895986:android:65caf70d55dfcbbabb286b',
    messagingSenderId: '662228895986',
    projectId: 'alhewan-cool-project',
    storageBucket: 'alhewan-cool-project.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAReAHymzoq20vIlJpA16-Lc0SFEGlUzUQ',
    appId: '1:662228895986:ios:42346ea1004a4bc2bb286b',
    messagingSenderId: '662228895986',
    projectId: 'alhewan-cool-project',
    storageBucket: 'alhewan-cool-project.firebasestorage.app',
    iosBundleId: 'com.example.alHaiwan',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAReAHymzoq20vIlJpA16-Lc0SFEGlUzUQ',
    appId: '1:662228895986:ios:42346ea1004a4bc2bb286b',
    messagingSenderId: '662228895986',
    projectId: 'alhewan-cool-project',
    storageBucket: 'alhewan-cool-project.firebasestorage.app',
    iosBundleId: 'com.example.alHaiwan',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDbj1wB0u1jAkNAAvffUloGhFLBBeZPc58',
    appId: '1:662228895986:web:7777d8489f5e951bbb286b',
    messagingSenderId: '662228895986',
    projectId: 'alhewan-cool-project',
    authDomain: 'alhewan-cool-project.firebaseapp.com',
    storageBucket: 'alhewan-cool-project.firebasestorage.app',
  );
}
