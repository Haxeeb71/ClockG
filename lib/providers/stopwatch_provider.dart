import 'dart:async';
import 'package:flutter/foundation.dart';

class StopwatchProvider extends ChangeNotifier {
  int _elapsedMs = 0;
  int get elapsedMs => _elapsedMs;
  final List<int> _laps = [];
  List<int> get laps => List.unmodifiable(_laps);
  Timer? _ticker;
  bool _running = false;
  bool get isRunning => _running;

  void start() {
    if (_running) return;
    _running = true;
    _ticker = Timer.periodic(const Duration(milliseconds: 10), (_) {
      _elapsedMs += 10;
      notifyListeners();
    });
    notifyListeners();
  }

  void pause() {
    _running = false;
    _ticker?.cancel();
    notifyListeners();
  }

  void reset() {
    _ticker?.cancel();
    _running = false;
    _elapsedMs = 0;
    _laps.clear();
    notifyListeners();
  }

  void lap() {
    _laps.insert(0, _elapsedMs);
    notifyListeners();
  }
}
