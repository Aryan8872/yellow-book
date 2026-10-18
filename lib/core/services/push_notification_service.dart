import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Top-level handler for background FCM messages (must be top-level, not a method)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Background handler — Firebase is already initialised by the main isolate
  debugPrint('[FCM] Background message: ${message.messageId}');
}

/// Service that initialises Firebase Cloud Messaging and local notification
/// channels. Call [init] once from [main] after Firebase.initializeApp().
class PushNotificationService {
  static final PushNotificationService _instance = PushNotificationService._();
  factory PushNotificationService() => _instance;
  PushNotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const _channelId = 'offernepal_deals';
  static const _channelName = 'Offers & Deals';
  static const _channelDesc = 'Notifications for new deals and promotions from OfferNepal';

  /// Call once from main(), after Firebase.initializeApp()
  Future<void> init() async {
    // Register background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Request permissions (iOS + Android 13+)
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      announcement: false,
      carPlay: false,
    );

    // Subscribe to the global broadcast topic
    await _messaging.subscribeToTopic('offers_nepal_deals');

    // Initialise local notifications
    await _initLocalNotifications();

    // Foreground message handler
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    // Notification tap handler when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageTapped);

    // Check if app was opened by a notification
    final initial = await _messaging.getInitialMessage();
    if (initial != null) _onMessageTapped(initial);
  }

  Future<void> _initLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false, // already requested above
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);
    await _localNotifications.initialize(initSettings);

    // Create high-importance channel on Android
    if (Platform.isAndroid) {
      const channel = AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDesc,
        importance: Importance.high,
        enableVibration: true,
        playSound: true,
      );
      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }
  }

  void _onForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  void _onMessageTapped(RemoteMessage message) {
    debugPrint('[FCM] Notification tapped: ${message.data}');
    // Deep-link handling: the offerId is passed in data payload
    // Navigation is handled via app_links which picks up the FCM data URL
  }

  /// Returns the FCM registration token for the current device (for debugging)
  Future<String?> getToken() => _messaging.getToken();
}
