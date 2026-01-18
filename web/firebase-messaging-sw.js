// Replace with your Firebase app's config if needed. When using Flutter Web with firebase_options.dart
// the actual firebase config is embedded in the compiled script. This service worker is required by
// firebase_messaging on web to receive background messages.

importScripts('https://www.gstatic.com/firebasejs/9.6.1/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/9.6.1/firebase-messaging-compat.js');

// Initialize the Firebase app in the service worker by passing in the config.
// If you have a firebaseConfig object, paste it here. Example:
// firebase.initializeApp({ apiKey: '...', authDomain: '...', projectId: '...', messagingSenderId: '...', appId: '...' });

// If your build injects config elsewhere, you can try initialize by reading from self or skip initialization
// and rely on the compat APIs to handle it.

try {
  // If firebase is available, get messaging
  const messaging = firebase.messaging();

  messaging.onBackgroundMessage(function(payload) {
    console.log('[firebase-messaging-sw.js] Received background message ', payload);
    // Customize notification here
    const notificationTitle = payload.notification?.title || payload.data?.title || 'Background Message Title';
    const notificationOptions = {
      body: payload.notification?.body || payload.data?.body || payload.data?.message || 'Background Message body.',
      // icon: '/firebase-logo.png'
    };

    return self.registration.showNotification(notificationTitle, notificationOptions);
  });
} catch (e) {
  console.log('Error initializing firebase messaging in service worker:', e);
}

