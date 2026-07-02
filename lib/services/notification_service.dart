import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';

/// Top-level background message handler.
/// Must be annotated with @pragma('vm:entry-point') so it is not optimized away.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log("Handling a background message: ${message.messageId}");
  log("Title: ${message.notification?.title}");
  log("Body: ${message.notification?.body}");
  if (message.data.isNotEmpty) {
    log("Data: ${message.data}");
  }
}

class NotificationService {
  // Singleton pattern
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    // 1. Request notification permissions from the user
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      log('🔔 FCM: User granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      log('🔔 FCM: User granted provisional permission');
    } else {
      log('🔔 FCM: User declined or has not accepted permission');
    }

    // 2. Fetch the FCM registration token (critical for local testing)
    try {
      String? token = await _firebaseMessaging.getToken();
      log("=================== FCM REGISTRATION TOKEN ===================");
      log(token ?? "Failed to retrieve FCM Token");
      log("==============================================================");
    } catch (e) {
      log("❌ FCM: Error retrieving FCM token: $e");
    }

    // 3. Register the background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 4. Handle foreground messages (when the app is open and running)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log("🔔 FCM: Received message in FOREGROUND: ${message.messageId}");
      if (message.notification != null) {
        log("Title: ${message.notification?.title}");
        log("Body: ${message.notification?.body}");
        // Note: In foreground, Flutter does not show a heads-up banner automatically on Android.
        // You can integrate 'flutter_local_notifications' here if you want foreground banners.
      }
    });

    // 5. Handle when the app is opened from a notification (while in background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log("🔔 FCM: App opened from BACKGROUND notification: ${message.messageId}");
      // Handle navigation here if the notification contains custom click actions / payloads
    });

    // 6. Handle when the app is opened from a notification (while completely terminated)
    RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      log("🔔 FCM: App opened from TERMINATED notification: ${initialMessage.messageId}");
      // Handle navigation here
    }
  }
}
