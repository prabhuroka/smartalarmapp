import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'question_screen.dart';

class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();
  static GlobalKey<NavigatorState>? navigatorKey;

  static Future<void> init({GlobalKey<NavigatorState>? key}) async {
    navigatorKey = key;

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOSInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iOSInit,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final payload = response.payload ?? '9';

        if (navigatorKey?.currentState == null) return;

        navigatorKey!.currentState?.push(
          MaterialPageRoute(
            builder: (_) => QuestionScreen(
              category: payload,
              difficulty: 'easy',
              onCorrect: () => navigatorKey?.currentState?.pop(),
              onSnooze: () => navigatorKey?.currentState?.pop(),
            ),
          ),
        );
      },
    );

    tz.initializeTimeZones();
  }

  static Future<void> scheduleAlarmNotification({
    required int id,
    required int hour,
    required int minute,
    required String message,
    String? sound,
    String? category,
  }) async {
    final scheduledTime = _nextInstanceOfTime(hour, minute);

    final androidDetails = AndroidNotificationDetails(
      'alarm_channel',
      'Alarm Notifications',
      channelDescription: 'Triggers cognitive alarm challenges',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: sound != null && sound != 'default'
          ? RawResourceAndroidNotificationSound(sound)
          : null,
      enableVibration: true,
    );

    final iOSDetails = const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await _notifications.zonedSchedule(
  id,
  'Wake Up!',
  message,
  scheduledTime,
  NotificationDetails(android: androidDetails, iOS: iOSDetails),
  androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
  matchDateTimeComponents: DateTimeComponents.time,
  payload: category,
);
print("Alarm scheduled for $hour:$minute with id $id");


  }

  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  static Future<void> cancelAlarm(int id) async {
    await _notifications.cancel(id);
  }
}
