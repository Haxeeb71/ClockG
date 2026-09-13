import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/stopwatch_provider.dart';
import '../theme/app_theme.dart';

class StopwatchScreen extends StatelessWidget {
  const StopwatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sw = context.watch<StopwatchProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final ms = sw.elapsedMs;
    final minutes = (ms ~/ 60000) % 60;
    final seconds = (ms ~/ 1000) % 60;
    final hundreds = (ms % 1000) ~/ 10;

    String two(int n) => n.toString().padLeft(2, '0');

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.timer_10, color: AppTheme.cyberYellow, size: 24),
            SizedBox(width: 10),
            Text('Stopwatch'),
          ],
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          // Hero Circular Stopwatch Dial
          Center(
            child: SizedBox(
              width: 250,
              height: 250,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(250, 250),
                    painter: _StopwatchDialPainter(
                      elapsedMs: ms,
                      isDark: isDark,
                      accentColor: AppTheme.cyberYellow,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '${two(minutes)}:${two(seconds)}',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1.0,
                              fontFeatures: const [FontFeature.tabularFigures()],
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            '.${two(hundreds)}',
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              fontFeatures: [FontFeature.tabularFigures()],
                              color: AppTheme.cyberYellow,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        sw.isRunning ? 'ACTIVE' : (ms > 0 ? 'PAUSED' : 'READY'),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                          color: sw.isRunning
                              ? AppTheme.accentTeal
                              : (ms > 0 ? AppTheme.accentOrange : AppTheme.textMuted),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Action Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!sw.isRunning && ms == 0) ...[
                  // Initial Start Button
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: sw.start,
                      icon: const Icon(Icons.play_arrow_rounded, size: 28),
                      label: const Text(
                        'START',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 0.8),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.cyberYellow,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 6,
                        shadowColor: AppTheme.cyberYellow.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                ] else if (sw.isRunning) ...[
                  // Lap button
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: sw.lap,
                      icon: const Icon(Icons.flag_rounded, size: 22),
                      label: const Text('LAP', style: TextStyle(fontWeight: FontWeight.w800)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.accentTeal,
                        side: const BorderSide(color: AppTheme.accentTeal, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Pause button
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: sw.pause,
                      icon: const Icon(Icons.pause_rounded, size: 24),
                      label: const Text('PAUSE', style: TextStyle(fontWeight: FontWeight.w800)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentOrange,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                  ),
                ] else ...[
                  // Reset button
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: sw.reset,
                      icon: const Icon(Icons.replay_rounded, size: 22),
                      label: const Text('RESET', style: TextStyle(fontWeight: FontWeight.w800)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isDark ? Colors.white : Colors.black87,
                        side: BorderSide(color: isDark ? AppTheme.cyberBorder : const Color(0xFFCBD5E1)),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Resume button
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: sw.start,
                      icon: const Icon(Icons.play_arrow_rounded, size: 26),
                      label: const Text('RESUME', style: TextStyle(fontWeight: FontWeight.w800)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.cyberYellow,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Laps Table
          Expanded(
            child: _LapsList(laps: sw.laps),
          ),
        ],
      ),
    );
  }
}

class _StopwatchDialPainter extends CustomPainter {
  _StopwatchDialPainter({
    required this.elapsedMs,
    required this.isDark,
    required this.accentColor,
  });

  final int elapsedMs;
  final bool isDark;
  final Color accentColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Dial background
    final bgPaint = Paint()
      ..color = isDark ? const Color(0xFF0D1117) : const Color(0xFFF8FAFC)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius - 4, bgPaint);

    // Rim border
    final rimPaint = Paint()
      ..color = isDark ? AppTheme.cyberBorder : const Color(0xFFCBD5E1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius - 4, rimPaint);

    // Ticks (60 ticks for 60 seconds)
    final tickPaint = Paint()..strokeCap = StrokeCap.round;

    for (int i = 0; i < 60; i++) {
      final angle = i * (math.pi / 30);
      final isMajor = i % 5 == 0;
      final tickLength = isMajor ? 12.0 : 5.0;

      tickPaint.strokeWidth = isMajor ? 2.5 : 1.0;
      tickPaint.color = isMajor
          ? (i == 0 ? accentColor : (isDark ? Colors.white70 : Colors.black87))
          : (isDark ? Colors.white24 : Colors.black26);

      final startX = center.dx + (radius - 8) * math.cos(angle);
      final startY = center.dy + (radius - 8) * math.sin(angle);
      final endX = center.dx + (radius - 8 - tickLength) * math.cos(angle);
      final endY = center.dy + (radius - 8 - tickLength) * math.sin(angle);

      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), tickPaint);
    }

    // Active Needle (Sweeps 60 seconds per revolution)
    final secondsFraction = (elapsedMs % 60000) / 60000.0;
    final needleAngle = (secondsFraction * 2 * math.pi) - (math.pi / 2);

    final needleLength = radius - 20;
    final needlePaint = Paint()
      ..color = accentColor
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    // Glowing needle trail
    final tailOffset = Offset(
      center.dx - 14 * math.cos(needleAngle),
      center.dy - 14 * math.sin(needleAngle),
    );
    final tipOffset = Offset(
      center.dx + needleLength * math.cos(needleAngle),
      center.dy + needleLength * math.sin(needleAngle),
    );

    canvas.drawLine(tailOffset, tipOffset, needlePaint);

    // Needle tip glow
    final glowPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawCircle(tipOffset, 4, glowPaint);

    // Center pin
    final centerPinPaint = Paint()..color = accentColor;
    canvas.drawCircle(center, 5, centerPinPaint);
    final innerCenter = Paint()..color = Colors.black;
    canvas.drawCircle(center, 2, innerCenter);
  }

  @override
  bool shouldRepaint(covariant _StopwatchDialPainter oldDelegate) {
    return oldDelegate.elapsedMs != elapsedMs;
  }
}

class _LapsList extends StatelessWidget {
  const _LapsList({required this.laps});
  final List<int> laps;

  String _formatMs(int ms) {
    final m = (ms ~/ 60000) % 60;
    final s = (ms ~/ 1000) % 60;
    final h = (ms % 1000) ~/ 10;
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(m)}:${two(s)}.${two(h)}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (laps.isEmpty) {
      return Center(
        child: Text(
          'No laps recorded',
          style: TextStyle(color: isDark ? AppTheme.textMuted : Colors.black45),
        ),
      );
    }

    // Calculate lap splits:
    // laps[0] is most recent total elapsed time
    // laps[last] is first lap total elapsed time
    final lapSplits = <int>[];
    for (int i = 0; i < laps.length; i++) {
      if (i == laps.length - 1) {
        lapSplits.add(laps[i]);
      } else {
        lapSplits.add(laps[i] - laps[i + 1]);
      }
    }

    int? fastestIndex;
    int? slowestIndex;
    if (lapSplits.length >= 2) {
      int minSplit = lapSplits.first;
      int maxSplit = lapSplits.first;
      fastestIndex = 0;
      slowestIndex = 0;

      for (int i = 1; i < lapSplits.length; i++) {
        if (lapSplits[i] < minSplit) {
          minSplit = lapSplits[i];
          fastestIndex = i;
        }
        if (lapSplits[i] > maxSplit) {
          maxSplit = lapSplits[i];
          slowestIndex = i;
        }
      }
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cyberGunmetal : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppTheme.cyberBorder : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        children: [
          // Table header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                const SizedBox(
                  width: 50,
                  child: Text(
                    'LAP',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ),
                const Expanded(
                  child: Text(
                    'SPLIT',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ),
                const Text(
                  'OVERALL',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: isDark ? AppTheme.cyberBorder : const Color(0xFFE2E8F0),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: laps.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: isDark ? AppTheme.cyberBorder.withValues(alpha: 0.5) : const Color(0xFFF1F5F9),
              ),
              itemBuilder: (context, i) {
                final lapNum = laps.length - i;
                final overallStr = _formatMs(laps[i]);
                final splitStr = _formatMs(lapSplits[i]);
                final isFastest = fastestIndex == i;
                final isSlowest = slowestIndex == i;

                Color? splitColor;
                if (isFastest) splitColor = AppTheme.accentTeal;
                if (isSlowest) splitColor = AppTheme.accentRed;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 50,
                        child: Text(
                          '#${lapNum.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            Text(
                              splitStr,
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: splitColor ?? (isDark ? Colors.white : const Color(0xFF0F172A)),
                                fontFeatures: const [FontFeature.tabularFigures()],
                              ),
                            ),
                            if (isFastest) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.accentTeal.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'BEST',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.accentTeal,
                                  ),
                                ),
                              ),
                            ],
                            if (isSlowest) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.accentRed.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'SLOWEST',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.accentRed,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Text(
                        overallStr,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppTheme.textMuted : const Color(0xFF64748B),
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
