import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notifications.dart';

class BedtimeProvider extends ChangeNotifier {
  BedtimeProvider(this._notifications);
  final NotificationService _notifications;

  TimeOfDay _bedtime = const TimeOfDay(hour: 23, minute: 0);
  TimeOfDay _wake = const TimeOfDay(hour: 7, minute: 0);
  bool _gentle = true;
  bool _reminder = true;

  TimeOfDay get bedtime => _bedtime;
  TimeOfDay get wake => _wake;
  bool get gentle => _gentle;
  bool get reminder => _reminder;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _bedtime = TimeOfDay(
      hour: prefs.getInt('bed_hour') ?? 23,
      minute: prefs.getInt('bed_min') ?? 0,
    );
    _wake = TimeOfDay(
      hour: prefs.getInt('wake_hour') ?? 7,
      minute: prefs.getInt('wake_min') ?? 0,
    );
    _gentle = prefs.getBool('gentle') ?? true;
    _reminder = prefs.getBool('reminder') ?? true;
    notifyListeners();
    await schedule();
  }

  Future<void> setBedtime(TimeOfDay t) async {
    _bedtime = t;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('bed_hour', t.hour);
    await prefs.setInt('bed_min', t.minute);
    await schedule();
  }

  Future<void> setWake(TimeOfDay t) async {
    _wake = t;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('wake_hour', t.hour);
    await prefs.setInt('wake_min', t.minute);
    await schedule();
  }

  Future<void> setGentle(bool v) async {
    _gentle = v;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('gentle', v);
    await schedule();
  }

  Future<void> setReminder(bool v) async {
    _reminder = v;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('reminder', v);
    await schedule();
  }

  Future<void> schedule() async {
    // TODO: set dedicated notifications for bedtime reminder and gentle wake
    await _notifications.init();
  }
}
