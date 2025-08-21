import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/timer.dart';
import '../services/db.dart';

class TimerProvider extends ChangeNotifier {
  TimerProvider(this._db);
  final AppDatabase _db;

  final Map<int, Timer> _tickers = {};
  final List<RunningTimerModel> _timers = [];

  List<RunningTimerModel> get timers => List.unmodifiable(_timers);

  Future<void> load() async {
    final stored = await _db.getTimers();
    _timers
      ..clear()
      ..addAll(stored);
    notifyListeners();
    for (final t in _timers.where((t) => t.isRunning)) {
      _startTicker(t);
    }
  }

  Future<void> add(RunningTimerModel timer) async {
    final id = await _db.insertTimer(timer);
    timer.id = id;
    _timers.add(timer);
    notifyListeners();
    if (timer.isRunning) _startTicker(timer);
  }

  Future<void> update(RunningTimerModel timer) async {
    await _db.updateTimer(timer);
    final idx = _timers.indexWhere((e) => e.id == timer.id);
    if (idx != -1) {
      _timers[idx] = timer;
      notifyListeners();
    }
  }

  Future<void> remove(int id) async {
    await _db.deleteTimer(id);
    _tickers[id]?.cancel();
    _tickers.remove(id);
    _timers.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  void start(RunningTimerModel timer) {
    timer.isRunning = true;
    _startTicker(timer);
    update(timer);
  }

  void pause(RunningTimerModel timer) {
    timer.isRunning = false;
    _tickers[timer.id!]?.cancel();
    _tickers.remove(timer.id!);
    update(timer);
  }

  void reset(RunningTimerModel timer) {
    timer.remainingMillis = timer.totalMillis;
    update(timer);
  }

  void extend(RunningTimerModel timer, int millis) {
    timer.remainingMillis += millis;
    update(timer);
  }

  void _startTicker(RunningTimerModel timer) {
    _tickers[timer.id!] = Timer.periodic(const Duration(milliseconds: 100), (t) {
      if (!timer.isRunning) return;
      timer.remainingMillis -= 100;
      if (timer.remainingMillis <= 0) {
        timer.remainingMillis = 0;
        timer.isRunning = false;
        t.cancel();
      }
      notifyListeners();
    });
  }
}


