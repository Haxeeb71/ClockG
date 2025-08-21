import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;
import '../models/alarm.dart';
import 'navigation.dart';

class NotificationService {
  NotificationService();
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    tzdata.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: android);
    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (resp) async {
        final nav = appNavigatorKey.currentState;
        if (nav == null) return;
        nav.pushNamed('/ring', arguments: resp.payload);
      },
    );
    _initialized = true;
  }

  Future<void> scheduleAlarm(AlarmModel alarm) async {
    await init();

    if (!alarm.isEnabled) return;

    final androidDetails = AndroidNotificationDetails(
      'alarm_channel',
      'Alarms',
      channelDescription: 'Alarm notifications',
      importance: Importance.max,
      priority: Priority.max,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
      playSound: true,
      audioAttributesUsage: AudioAttributesUsage.alarm,
    );

    final details = NotificationDetails(android: androidDetails);

    // Next fire time considering repeat weekdays
    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduled = tz.TZDateTime.from(alarm.time, tz.local);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    if (alarm.repeatWeekdays.isEmpty) {
      await _plugin.zonedSchedule(
        alarm.id ?? Random().nextInt(1 << 31),
        alarm.label,
        'Alarm',
        scheduled,
        details,
        androidAllowWhileIdle: true,
        payload: (alarm.id ?? 0).toString(),
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    } else {
      // Schedule next matching weekday only
      tz.TZDateTime candidate = scheduled;
      for (int i = 0; i < 7; i++) {
        final weekday = candidate.weekday; // 1..7
        if (alarm.repeatWeekdays.contains(weekday)) break;
        candidate = candidate.add(const Duration(days: 1));
      }
      await _plugin.zonedSchedule(
        alarm.id ?? Random().nextInt(1 << 31),
        alarm.label,
        'Repeating Alarm',
        candidate,
        details,
        androidAllowWhileIdle: true,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        payload: (alarm.id ?? 0).toString(),
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  Future<void> cancelAlarm(int id) async {
    await init();
    await _plugin.cancel(id);
  }
}


