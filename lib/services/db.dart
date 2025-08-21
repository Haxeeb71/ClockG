import 'dart:async';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/alarm.dart';
import '../models/timer.dart';
import '../models/world_city.dart';

class AppDatabase {
  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, 'clockg.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE alarms (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            label TEXT NOT NULL,
            time INTEGER NOT NULL,
            repeatWeekdays TEXT NOT NULL,
            soundPath TEXT,
            isEnabled INTEGER NOT NULL,
            snoozeMinutes INTEGER NOT NULL,
            gradualVolume INTEGER NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE timers (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            label TEXT NOT NULL,
            totalMillis INTEGER NOT NULL,
            remainingMillis INTEGER NOT NULL,
            isRunning INTEGER NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE world_cities (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            timezone TEXT NOT NULL
          )
        ''');
      },
    );
  }

  // Alarms
  Future<List<AlarmModel>> getAlarms() async {
    final db = await database;
    final rows = await db.query('alarms', orderBy: 'time ASC');
    return rows.map((e) => AlarmModel.fromMap(e)).toList();
  }

  Future<AlarmModel?> getAlarmById(int id) async {
    final db = await database;
    final rows = await db.query('alarms', where: 'id=?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return AlarmModel.fromMap(rows.first);
  }

  Future<int> insertAlarm(AlarmModel alarm) async {
    final db = await database;
    return db.insert('alarms', alarm.toMap());
  }

  Future<void> updateAlarm(AlarmModel alarm) async {
    final db = await database;
    await db.update('alarms', alarm.toMap(), where: 'id=?', whereArgs: [alarm.id]);
  }

  Future<void> deleteAlarm(int id) async {
    final db = await database;
    await db.delete('alarms', where: 'id=?', whereArgs: [id]);
  }

  // Timers
  Future<List<RunningTimerModel>> getTimers() async {
    final db = await database;
    final rows = await db.query('timers', orderBy: 'id DESC');
    return rows.map((e) => RunningTimerModel.fromMap(e)).toList();
  }

  Future<int> insertTimer(RunningTimerModel timer) async {
    final db = await database;
    return db.insert('timers', timer.toMap());
    
  }

  Future<void> updateTimer(RunningTimerModel timer) async {
    final db = await database;
    await db.update('timers', timer.toMap(), where: 'id=?', whereArgs: [timer.id]);
  }

  Future<void> deleteTimer(int id) async {
    final db = await database;
    await db.delete('timers', where: 'id=?', whereArgs: [id]);
  }

  // World Clock
  Future<List<WorldCity>> getWorldCities() async {
    final db = await database;
    final rows = await db.query('world_cities', orderBy: 'name ASC');
    return rows.map((e) => WorldCity.fromMap(e)).toList();
  }

  Future<int> insertWorldCity(WorldCity city) async {
    final db = await database;
    return db.insert('world_cities', city.toMap());
  }

  Future<void> deleteWorldCity(int id) async {
    final db = await database;
    await db.delete('world_cities', where: 'id=?', whereArgs: [id]);
  }
}


