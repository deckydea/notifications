import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:notifications/firebase/firebase_options.dart';
import 'package:notifications/util/notification_utils.dart';


///There are a few things to keep in mind about background message handler:
// It must not be an anonymous function.
// It must be a top-level function (e.g. not a class method which requires initialization).
// When using Flutter version 3.3.0 or higher, the message handler must be annotated
// with @pragma('vm:entry-point') right above the function declaration
// (otherwise it may be removed during tree shaking for release mode).
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log("Handling a background message: ${message.messageId}");
  NotificationUtils.showNotification(remoteMessage: message);
}

//TODO: Need to update
class FirebaseUtils {
  static const String _tag = "FIREBASE SERVICE";

  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  static String? _firebaseId;

  static String get firebaseId => _firebaseId ?? '';

  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) => onMessageOpenedApp(message: message));

    FirebaseMessaging.onMessage.listen((RemoteMessage message) =>  handleMessageData(message: message));

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    await _loadToken();

    _initialized = true;
  }

  static Future<void> onMessageOpenedApp({required RemoteMessage message}) async {
    log("onMessageOpenedApp", name: _tag);
  }

  static Future<void> handleMessageData({required RemoteMessage message}) async {
    log("handleMessageData", name: _tag);
    //TODO: Handle this message
    log("Title: ${message.notification?.title}", name: _tag);
    log("Body: ${message.notification?.body}", name: _tag);
    log("Payload: ${message.data}");

    NotificationUtils.showNotification(remoteMessage: message);
  }

  //Load FCM Token
  static Future<void> _loadToken() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    _firebaseMessaging.getToken().then((token) => _setFirebaseToken(token));
  }

  static Future<void> _setFirebaseToken(String? token) async {
    if (token == null || token == '') return;
    _firebaseId = token;
    log("Token: $token", name: _tag);
  }
}