import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;
import '../models/world_city.dart';
import '../services/db.dart';

class WorldClockProvider extends ChangeNotifier {
  WorldClockProvider(this._db) {
    tzdata.initializeTimeZones();
  }

  final AppDatabase _db;

  final List<WorldCity> _cities = [];
  List<WorldCity> get cities => List.unmodifiable(_cities);

  Timer? _ticker;
  DateTime _now = DateTime.now();
  DateTime get now => _now;

  Future<void> load() async {
    final stored = await _db.getWorldCities();
    _cities
      ..clear()
      ..addAll(stored);
    _startTicker();
    notifyListeners();
  }

  Future<void> addCity(WorldCity city) async {
    final id = await _db.insertWorldCity(city);
    city.id = id;
    _cities.add(city);
    notifyListeners();
  }

  Future<void> removeCity(int id) async {
    await _db.deleteWorldCity(id);
    _cities.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  DateTime timeInCity(WorldCity city) {
    final loc = tz.getLocation(city.timezone);
    return tz.TZDateTime.from(_now, loc);
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(milliseconds: 200), (_) {
      _now = DateTime.now();
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}
