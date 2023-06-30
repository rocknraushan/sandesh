

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PermissionManager{
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  void initializeNotifications() {
    var initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
    // var initializationSettingsIOS = IOSInitializationSettings();
    var initializationSettings = InitializationSettings(android: initializationSettingsAndroid);

    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void requestNotificationPermission(BuildContext context) async {
    bool? result = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestPermission();

    if (result == false) {
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title:const Text('Notification Permission'),
          content: const Text('Please enable notification permission in the device settings.'),
          actions: [
            ElevatedButton(
              child: const Text('OK'),
              onPressed: (){
                requestNotificationPermission(context);
                Navigator.of(context).pop();
              }
            ),
          ],
        ),
      );
    }
  }



}