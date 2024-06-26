import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_app/src/notifications/notifications.dart';

class CloudMessagingUtils {
  static Future<void> init() async {
    FirebaseMessaging.onBackgroundMessage(_onBackGroundMessage);

    /// Update the iOS foreground notification presentation options to allow
    /// heads up notifications.
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen((event) => _onMessage(event));
  }

  static Future<String?> getToken() => FirebaseMessaging.instance.getToken();

  static Future<void> _onBackGroundMessage(RemoteMessage message) {
    ReceivedNotification receivedNotification = ReceivedNotification(
      title: message.notification?.title,
      body: message.notification?.body,
      payload: json.encode({
        "type": "cloud_message_background",
        "id": Notifications.instance.notificationId,
        "data": message.data,
      }),
    );
    return Notifications.instance.showNotification(receivedNotification);
  }

  static Future<void> _onMessage(RemoteMessage message) {
    ReceivedNotification receivedNotification = ReceivedNotification(
      title: message.notification?.title,
      body: message.notification?.body,
      payload: json.encode({
        "type": "cloud_message",
        "id": Notifications.instance.notificationId,
        "data": message.data,
      }),
    );
    return Notifications.instance.showNotification(receivedNotification);
  }
}
