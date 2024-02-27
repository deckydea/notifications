import 'dart:developer';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

//TODO: Need to update
class NotificationUtils {
  static const String _tag = "NOTIFICATION";

  static const String _channelId = "DEFAULT_CHANNEL1";
  static const String _channelName = "Notification";
  static const String _channelDescription = "Notification channel description";

  static const String notificationSoundName = "notification";

  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  static void initialize() {
    if (_initialized) return;

    AndroidInitializationSettings androidInitializationSettings = const AndroidInitializationSettings("@mipmap/ic_launcher");
    DarwinInitializationSettings iOSInitializationSettings = const DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    InitializationSettings initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iOSInitializationSettings,
    );

    _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onReceiveNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: onDidReceiveBackgroundNotificationResponse,
    );

    _initialized = true;
  }

  static Future<void> requestPermission() async {
    if (Platform.isIOS) {
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true, provisional: true);
    } else if (Platform.isAndroid) {
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
  }

  static void onDidReceiveBackgroundNotificationResponse(NotificationResponse response)  {
    debugPrint("[$_tag] onDidReceiveBackgroundNotificationResponse");
  }

  static void onReceiveNotificationResponse(NotificationResponse response)  {
    debugPrint("[$_tag] onReceiveNotificationResponse");
  }

  static Future<void> showNotification({required RemoteMessage remoteMessage}) async {
    log("showNotification", name: _tag);

    AndroidNotificationDetails androidNotificationDetails = const AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound(notificationSoundName),
      playSound: true,
    );

    DarwinNotificationDetails iOSNotificationDetails = const DarwinNotificationDetails(sound: "$notificationSoundName.wav");
    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iOSNotificationDetails,
    );

    String title = "";
    String body = "";
    if(remoteMessage.data.isNotEmpty){
      title = remoteMessage.data["title"];
      body = remoteMessage.data["body"];
    }

    String encodedPayload = "";
    await _flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      notificationDetails,
      payload: encodedPayload,
    );
  }
}
