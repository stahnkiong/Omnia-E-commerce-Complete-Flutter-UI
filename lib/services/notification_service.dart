import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

/// Top-level background message handler.
/// Must be annotated with @pragma('vm:entry-point') so it is not optimized away.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log("Handling a background message: ${message.messageId}");
  try {
    await Hive.initFlutter();
    await _saveNotification(message);
  } catch (e) {
    log("❌ FCM Background: Error initializing Hive/saving notification: $e");
  }
}

Future<void> _saveNotification(RemoteMessage message) async {
  final notification = message.notification;
  if (notification != null) {
    try {
      final box = await Hive.openBox('notifications');
      final notificationData = {
        'title': notification.title ?? '',
        'body': notification.body ?? '',
        'delivered_at': DateTime.now().toIso8601String(),
        'is_read': false,
      };

      if (message.messageId != null) {
        // Prevent duplicate logs by using the messageId as key
        await box.put(message.messageId, notificationData);
      } else {
        await box.add(notificationData);
      }
      log("🔔 FCM: Saved notification to Hive: ${notification.title}");
    } catch (e) {
      log("❌ FCM: Error saving notification to Hive: $e");
    }
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
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      log("🔔 FCM: Received message in FOREGROUND: ${message.messageId}");
      await _saveNotification(message);
    });

    // 5. Handle when the app is opened from a notification (while in background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      log("🔔 FCM: App opened from BACKGROUND notification: ${message.messageId}");
      await _saveNotification(message);
    });

    // 6. Handle when the app is opened from a notification (while completely terminated)
    RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      log("🔔 FCM: App opened from TERMINATED notification: ${initialMessage.messageId}");
      await _saveNotification(initialMessage);
    }
  }
}
