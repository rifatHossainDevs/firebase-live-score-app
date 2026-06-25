import 'package:firebase_messaging/firebase_messaging.dart';

class FcmUtils {
  static Future<void> initialized() async {
    /// Request for Permission
    await FirebaseMessaging.instance.requestPermission(
      sound: true,
      criticalAlert: true,
      announcement: true,
      alert: true,
    );

    /// Handle Notification
    /// Foreground - App is visible and running
    /// Background - App is running, but not visible/minimize
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print(message.notification?.title);
      print(message.notification?.body);
      print(message.data);

      if (message.data['route'] != null) {
        /// navigate to the specific route
      }
    });

    /// Terminated - Dead
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundNotification);
  }

  /// Get Firebase token
  /// send to backend login (usually)
  static Future<String?> getFcmToken() async {
    return FirebaseMessaging.instance.getToken();
  }

  static void onRefreshToken() {
    FirebaseMessaging.instance.onTokenRefresh.listen((String? newToken) {
      // TODO: Send to backend api
    });
  }
}

Future<void> _handleBackgroundNotification(RemoteMessage message) async {}
