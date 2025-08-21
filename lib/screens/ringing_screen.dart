import 'package:flutter/material.dart';
import '../services/audio.dart';
import '../services/db.dart';
import '../models/alarm.dart';

class RingingScreen extends StatefulWidget {
  const RingingScreen({super.key, this.alarmId});
  final int? alarmId;

  @override
  State<RingingScreen> createState() => _RingingScreenState();
}

class _RingingScreenState extends State<RingingScreen> {
  final AudioService _audio = AudioService();
  final AppDatabase _db = AppDatabase();
  AlarmModel? _alarm;

  @override
  void initState() {
    super.initState();
    () async {
      if (widget.alarmId != null) {
        _alarm = await _db.getAlarmById(widget.alarmId!);
      }
      final path = _alarm?.soundPath ?? '';
      await _audio.playPath(path, gradual: _alarm?.gradualVolume ?? true)
          .catchError((_) {});
      if (mounted) setState(() {});
    }();
  }

  @override
  void dispose() {
    _audio.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.alarm, size: 96, color: Colors.white),
            const SizedBox(height: 24),
            Text(_alarm?.label ?? 'Alarm', style: const TextStyle(color: Colors.white, fontSize: 28)),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Dismiss'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Snooze'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}


