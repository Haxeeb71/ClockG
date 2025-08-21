import 'package:flutter/foundation.dart';
import '../models/alarm.dart';
import '../services/db.dart';
import '../services/notifications.dart';

class AlarmProvider extends ChangeNotifier {
  AlarmProvider(this._db, this._notifications);

  final AppDatabase _db;
  final NotificationService _notifications;

  List<AlarmModel> _alarms = [];
  List<AlarmModel> get alarms => List.unmodifiable(_alarms);

  Future<void> load() async {
    _alarms = await _db.getAlarms();
    notifyListeners();
  }

  Future<void> add(AlarmModel alarm) async {
    final id = await _db.insertAlarm(alarm);
    alarm.id = id;
    _alarms.add(alarm);
    notifyListeners();
    await _notifications.scheduleAlarm(alarm);
  }

  Future<void> update(AlarmModel alarm) async {
    await _db.updateAlarm(alarm);
    final idx = _alarms.indexWhere((a) => a.id == alarm.id);
    if (idx != -1) {
      _alarms[idx] = alarm;
      notifyListeners();
    }
    await _notifications.cancelAlarm(alarm.id!);
    await _notifications.scheduleAlarm(alarm);
  }

  Future<void> remove(int id) async {
    await _db.deleteAlarm(id);
    _alarms.removeWhere((a) => a.id == id);
    notifyListeners();
    await _notifications.cancelAlarm(id);
  }
}


