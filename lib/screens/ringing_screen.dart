import 'package:flutter/material.dart';
import '../services/audio.dart';
import '../services/db.dart';
import '../models/alarm.dart';
import '../theme/app_theme.dart';
import 'package:intl/intl.dart';

class RingingScreen extends StatefulWidget {
  const RingingScreen({super.key, this.alarmId});
  final int? alarmId;

  @override
  State<RingingScreen> createState() => _RingingScreenState();
}

class _RingingScreenState extends State<RingingScreen> with SingleTickerProviderStateMixin {
  final AudioService _audio = AudioService();
  final AppDatabase _db = AppDatabase();
  AlarmModel? _alarm;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    () async {
      if (widget.alarmId != null) {
        _alarm = await _db.getAlarmById(widget.alarmId!);
      }
      final path = _alarm?.soundPath ?? '';
      await _audio.playPath(path, gradual: _alarm?.gradualVolume ?? true).catchError((_) {});
      if (mounted) setState(() {});
    }();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _audio.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final timeStr = DateFormat('h:mm').format(now);
    final period = DateFormat('a').format(now);
    final dateStr = DateFormat('EEEE, MMMM d').format(now);

    return Scaffold(
      backgroundColor: AppTheme.cyberBlack,
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Ambient pulsing background glow rings
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, _) {
                return CustomPaint(
                  size: const Size(double.infinity, double.infinity),
                  painter: _PulseRingsPainter(progress: _pulseController.value),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top Date & Alarm Label
                  Column(
                    children: [
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.cyberYellow.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppTheme.cyberYellow.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.alarm_on_rounded, color: AppTheme.cyberYellow, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              (_alarm?.label ?? 'ALARM').toUpperCase(),
                              style: const TextStyle(
                                color: AppTheme.cyberYellow,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.5,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        dateStr,
                        style: const TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  // Center Clock & Ringing Graphic
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.cyberGunmetal,
                          border: Border.all(
                            color: AppTheme.cyberYellow,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.cyberYellow.withValues(alpha: 0.35),
                              blurRadius: 36,
                              spreadRadius: 8,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.alarm_rounded,
                          size: 72,
                          color: AppTheme.cyberYellow,
                        ),
                      ),
                      const SizedBox(height: 36),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            timeStr,
                            style: const TextStyle(
                              fontSize: 68,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -2,
                              color: Colors.white,
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            period,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.cyberYellow,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Bottom Action Buttons
                  Column(
                    children: [
                      // Snooze Button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.snooze_rounded, size: 22),
                          label: Text(
                            'SNOOZE (${_alarm?.snoozeMinutes ?? 10} MIN)',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1,
                              fontSize: 15,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: AppTheme.cyberBorder, width: 1.5),
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      // Dismiss Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close_rounded, size: 24),
                          label: const Text(
                            'DISMISS ALARM',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                              fontSize: 16,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.cyberYellow,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            elevation: 8,
                            shadowColor: AppTheme.cyberYellow.withValues(alpha: 0.4),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PulseRingsPainter extends CustomPainter {
  _PulseRingsPainter({required this.progress});
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 - 40);

    for (int i = 0; i < 3; i++) {
      final ringProgress = (progress + (i / 3.0)) % 1.0;
      final radius = 70.0 + (ringProgress * 150.0);
      final opacity = (1.0 - ringProgress).clamp(0.0, 1.0) * 0.3;

      final paint = Paint()
        ..color = AppTheme.cyberYellow.withValues(alpha: opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _PulseRingsPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
