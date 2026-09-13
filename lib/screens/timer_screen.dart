import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/timer_provider.dart';
import '../models/timer.dart';
import '../theme/app_theme.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<TimerProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final tp = context.watch<TimerProvider>();
    final timers = tp.timers;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.timer, color: AppTheme.cyberYellow, size: 24),
            SizedBox(width: 10),
            Text('Timer'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppTheme.cyberYellow, size: 28),
            tooltip: 'New Timer',
            onPressed: () => _openNewTimerSheet(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: timers.isEmpty
          ? _EmptyTimerView(
              onAddPressed: () => _openNewTimerSheet(context),
              onPresetSelected: (label, duration) async {
                final total = duration.inMilliseconds;
                await tp.add(RunningTimerModel(
                  label: label,
                  totalMillis: total,
                  remainingMillis: total,
                  isRunning: true,
                ));
              },
            )
          : CustomScrollView(
              slivers: [
                // Hero Active Timer
                SliverToBoxAdapter(
                  child: _HeroTimerCard(
                    timer: timers.first,
                    onStart: () => tp.start(timers.first),
                    onPause: () => tp.pause(timers.first),
                    onReset: () => tp.reset(timers.first),
                    onExtend: () => tp.extend(timers.first, 60000), // +1 min
                    onDelete: () => tp.remove(timers.first.id!),
                  ),
                ),
                // Quick Presets Bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'QUICK START PRESETS',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                            color: isDark ? AppTheme.textMuted : const Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _QuickPresetChip(
                                label: '1 min',
                                duration: const Duration(minutes: 1),
                                onSelect: (d) => _startPreset(tp, '1 min Timer', d),
                              ),
                              _QuickPresetChip(
                                label: '3 min',
                                duration: const Duration(minutes: 3),
                                onSelect: (d) => _startPreset(tp, '3 min Timer', d),
                              ),
                              _QuickPresetChip(
                                label: '5 min',
                                duration: const Duration(minutes: 5),
                                onSelect: (d) => _startPreset(tp, '5 min Timer', d),
                              ),
                              _QuickPresetChip(
                                label: '10 min',
                                duration: const Duration(minutes: 10),
                                onSelect: (d) => _startPreset(tp, '10 min Timer', d),
                              ),
                              _QuickPresetChip(
                                label: '25 min (Pomodoro)',
                                duration: const Duration(minutes: 25),
                                onSelect: (d) => _startPreset(tp, 'Pomodoro', d),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Additional Timers Section
                if (timers.length > 1) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                      child: Text(
                        'OTHER TIMERS (${timers.length - 1})',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          color: isDark ? AppTheme.textMuted : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final t = timers[index + 1];
                          return _SecondaryTimerCard(
                            timer: t,
                            onToggle: () => t.isRunning ? tp.pause(t) : tp.start(t),
                            onReset: () => tp.reset(t),
                            onDelete: () => tp.remove(t.id!),
                          );
                        },
                        childCount: timers.length - 1,
                      ),
                    ),
                  ),
                ] else
                  const SliverToBoxAdapter(child: SizedBox(height: 90)),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openNewTimerSheet(context),
        icon: const Icon(Icons.add, size: 22),
        label: const Text('NEW TIMER', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }

  void _startPreset(TimerProvider tp, String label, Duration duration) {
    final total = duration.inMilliseconds;
    tp.add(RunningTimerModel(
      label: label,
      totalMillis: total,
      remainingMillis: total,
      isRunning: true,
    ));
  }

  Future<void> _openNewTimerSheet(BuildContext context) async {
    final tp = context.read<TimerProvider>();
    final created = await showModalBottomSheet<RunningTimerModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _NewTimerSheet(),
    );
    if (created != null) {
      await tp.add(created);
    }
  }
}

class _EmptyTimerView extends StatelessWidget {
  const _EmptyTimerView({
    required this.onAddPressed,
    required this.onPresetSelected,
  });

  final VoidCallback onAddPressed;
  final void Function(String label, Duration duration) onPresetSelected;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? AppTheme.cyberSurfaceElevated : const Color(0xFFF1F5F9),
              border: Border.all(
                color: AppTheme.cyberYellow.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.hourglass_empty_rounded,
              size: 64,
              color: AppTheme.cyberYellow,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Active Timers',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pick a quick preset or customize your own countdown timer.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppTheme.textMuted : Colors.black54,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'QUICK PRESETS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: isDark ? AppTheme.textMuted : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              _PresetCard(label: '1 Minute', duration: const Duration(minutes: 1), onTap: onPresetSelected),
              _PresetCard(label: '3 Minutes', duration: const Duration(minutes: 3), onTap: onPresetSelected),
              _PresetCard(label: '5 Minutes', duration: const Duration(minutes: 5), onTap: onPresetSelected),
              _PresetCard(label: '10 Minutes', duration: const Duration(minutes: 10), onTap: onPresetSelected),
              _PresetCard(label: '15 Minutes', duration: const Duration(minutes: 15), onTap: onPresetSelected),
              _PresetCard(label: '25 Min (Pomodoro)', duration: const Duration(minutes: 25), onTap: onPresetSelected),
              _PresetCard(label: '30 Minutes', duration: const Duration(minutes: 30), onTap: onPresetSelected),
              _PresetCard(label: '1 Hour', duration: const Duration(hours: 1), onTap: onPresetSelected),
            ],
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: onAddPressed,
            icon: const Icon(Icons.add),
            label: const Text('Custom Timer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.cyberYellow,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ],
      ),
    );
  }
}

class _PresetCard extends StatelessWidget {
  const _PresetCard({
    required this.label,
    required this.duration,
    required this.onTap,
  });

  final String label;
  final Duration duration;
  final void Function(String label, Duration duration) onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () => onTap(label, duration),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.cyberGunmetal : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppTheme.cyberBorder : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.play_arrow_rounded, size: 18, color: AppTheme.cyberYellow),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroTimerCard extends StatelessWidget {
  const _HeroTimerCard({
    required this.timer,
    required this.onStart,
    required this.onPause,
    required this.onReset,
    required this.onExtend,
    required this.onDelete,
  });

  final RunningTimerModel timer;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onReset;
  final VoidCallback onExtend;
  final VoidCallback onDelete;

  String _formatTime(int ms) {
    final totalSec = (ms / 1000).ceil();
    final hours = totalSec ~/ 3600;
    final minutes = (totalSec % 3600) ~/ 60;
    final seconds = totalSec % 60;

    String two(int n) => n.toString().padLeft(2, '0');

    if (hours > 0) {
      return '${two(hours)}:${two(minutes)}:${two(seconds)}';
    }
    return '${two(minutes)}:${two(seconds)}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = timer.totalMillis > 0
        ? (timer.remainingMillis / timer.totalMillis).clamp(0.0, 1.0)
        : 0.0;
    final timeStr = _formatTime(timer.remainingMillis);
    final isFinished = timer.remainingMillis <= 0;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [AppTheme.cyberGunmetal, AppTheme.cyberSurfaceElevated]
              : [Colors.white, const Color(0xFFF8FAFC)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: timer.isRunning
              ? AppTheme.cyberYellow.withValues(alpha: 0.4)
              : (isDark ? AppTheme.cyberBorder : const Color(0xFFE2E8F0)),
          width: 1.5,
        ),
        boxShadow: [
          if (timer.isRunning && isDark)
            BoxShadow(
              color: AppTheme.cyberYellow.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: timer.isRunning
                      ? AppTheme.cyberYellow.withValues(alpha: 0.2)
                      : (isDark ? AppTheme.cyberSurfaceElevated : const Color(0xFFE2E8F0)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      timer.isRunning ? Icons.play_arrow_rounded : Icons.pause_rounded,
                      size: 14,
                      color: timer.isRunning ? AppTheme.cyberYellow : AppTheme.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      timer.isRunning ? 'RUNNING' : (isFinished ? 'COMPLETED' : 'PAUSED'),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: timer.isRunning ? (isDark ? AppTheme.cyberYellow : const Color(0xFFB45309)) : AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, size: 20, color: AppTheme.textMuted),
                onPressed: onDelete,
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Circular Progress Dial
          SizedBox(
            width: 220,
            height: 220,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(220, 220),
                  painter: _TimerProgressPainter(
                    progress: progress,
                    isDark: isDark,
                    isRunning: timer.isRunning,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      timeStr,
                      style: TextStyle(
                        fontSize: 44,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1.0,
                        fontFeatures: const [FontFeature.tabularFigures()],
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      timer.label.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: AppTheme.accentTeal,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Tactile Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Reset Button
              IconButton.filledTonal(
                iconSize: 26,
                padding: const EdgeInsets.all(14),
                onPressed: onReset,
                icon: const Icon(Icons.replay_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: isDark ? AppTheme.cyberSurfaceElevated : const Color(0xFFE2E8F0),
                  foregroundColor: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(width: 20),
              // Play/Pause Main FAB
              InkWell(
                onTap: timer.isRunning ? onPause : onStart,
                borderRadius: BorderRadius.circular(32),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.cyberYellow, Color(0xFFFFE55C)],
                    ),
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.cyberYellow.withValues(alpha: 0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        timer.isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        color: Colors.black,
                        size: 28,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        timer.isRunning ? 'PAUSE' : 'START',
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),
              // +1 Min Button
              IconButton.filledTonal(
                iconSize: 26,
                padding: const EdgeInsets.all(14),
                onPressed: onExtend,
                icon: const Icon(Icons.add_rounded),
                tooltip: 'Add 1 minute',
                style: IconButton.styleFrom(
                  backgroundColor: isDark ? AppTheme.cyberSurfaceElevated : const Color(0xFFE2E8F0),
                  foregroundColor: AppTheme.cyberYellow,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimerProgressPainter extends CustomPainter {
  _TimerProgressPainter({
    required this.progress,
    required this.isDark,
    required this.isRunning,
  });

  final double progress;
  final bool isDark;
  final bool isRunning;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;

    // Track Background
    final trackPaint = Paint()
      ..color = isDark ? AppTheme.cyberSurfaceElevated : const Color(0xFFE2E8F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;
    canvas.drawCircle(center, radius, trackPaint);

    if (progress > 0) {
      // Gradient active sweep
      final sweepAngle = 2 * math.pi * progress;
      final arcPaint = Paint()
        ..color = AppTheme.cyberYellow
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        sweepAngle,
        false,
        arcPaint,
      );

      // Glowing runner head
      if (isRunning) {
        final headAngle = -math.pi / 2 + sweepAngle;
        final headX = center.dx + radius * math.cos(headAngle);
        final headY = center.dy + radius * math.sin(headAngle);

        final glowPaint = Paint()
          ..color = AppTheme.cyberYellow.withValues(alpha: 0.5)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
        canvas.drawCircle(Offset(headX, headY), 8, glowPaint);

        final tipPaint = Paint()..color = Colors.white;
        canvas.drawCircle(Offset(headX, headY), 5, tipPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TimerProgressPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isRunning != isRunning;
  }
}

class _QuickPresetChip extends StatelessWidget {
  const _QuickPresetChip({
    required this.label,
    required this.duration,
    required this.onSelect,
  });

  final String label;
  final Duration duration;
  final ValueChanged<Duration> onSelect;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(label),
        avatar: const Icon(Icons.add, size: 16, color: AppTheme.cyberYellow),
        backgroundColor: isDark ? AppTheme.cyberGunmetal : Colors.white,
        side: BorderSide(
          color: isDark ? AppTheme.cyberBorder : const Color(0xFFCBD5E1),
        ),
        onPressed: () => onSelect(duration),
      ),
    );
  }
}

class _SecondaryTimerCard extends StatelessWidget {
  const _SecondaryTimerCard({
    required this.timer,
    required this.onToggle,
    required this.onReset,
    required this.onDelete,
  });

  final RunningTimerModel timer;
  final VoidCallback onToggle;
  final VoidCallback onReset;
  final VoidCallback onDelete;

  String _formatTime(int ms) {
    final totalSec = (ms / 1000).ceil();
    final m = (totalSec ~/ 60) % 60;
    final s = totalSec % 60;
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(m)}:${two(s)}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = timer.totalMillis > 0
        ? (timer.remainingMillis / timer.totalMillis).clamp(0.0, 1.0)
        : 0.0;

    return Dismissible(
      key: ValueKey(timer.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.only(right: 24),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: AppTheme.accentRed.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.cyberGunmetal : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? AppTheme.cyberBorder : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          children: [
            // Mini circular progress
            SizedBox(
              width: 38,
              height: 38,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 3.5,
                    backgroundColor: isDark ? AppTheme.cyberSurfaceElevated : const Color(0xFFE2E8F0),
                    color: AppTheme.cyberYellow,
                  ),
                  Icon(
                    timer.isRunning ? Icons.timer_outlined : Icons.pause_circle_outline,
                    size: 18,
                    color: timer.isRunning ? AppTheme.cyberYellow : AppTheme.textMuted,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    timer.label,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                  Text(
                    _formatTime(timer.remainingMillis),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(timer.isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded),
              color: AppTheme.cyberYellow,
              onPressed: onToggle,
            ),
            IconButton(
              icon: const Icon(Icons.replay_rounded, size: 20),
              color: AppTheme.textMuted,
              onPressed: onReset,
            ),
          ],
        ),
      ),
    );
  }
}

class _NewTimerSheet extends StatefulWidget {
  const _NewTimerSheet();

  @override
  State<_NewTimerSheet> createState() => _NewTimerSheetState();
}

class _NewTimerSheetState extends State<_NewTimerSheet> {
  final TextEditingController _label = TextEditingController(text: 'Timer');
  int _hours = 0;
  int _minutes = 5;
  int _seconds = 0;

  @override
  void dispose() {
    _label.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        top: 20,
        left: 20,
        right: 20,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cyberGunmetal : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: isDark ? AppTheme.cyberBorder : const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.cyberBorder : const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Create Timer',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Stepper controls for Hours, Minutes, Seconds
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.cyberSurfaceElevated : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.cyberYellow.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _NumberStepper(
                    value: _hours,
                    unit: 'HOURS',
                    max: 23,
                    onChanged: (v) => setState(() => _hours = v),
                  ),
                  const Text(':', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800)),
                  _NumberStepper(
                    value: _minutes,
                    unit: 'MINS',
                    max: 59,
                    onChanged: (v) => setState(() => _minutes = v),
                  ),
                  const Text(':', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800)),
                  _NumberStepper(
                    value: _seconds,
                    unit: 'SECS',
                    max: 59,
                    onChanged: (v) => setState(() => _seconds = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _label,
              decoration: const InputDecoration(
                labelText: 'Timer Label',
                prefixIcon: Icon(Icons.label_outline_rounded),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final totalMs = (_hours * 3600 + _minutes * 60 + _seconds) * 1000;
                      if (totalMs <= 0) return;
                      final label = _label.text.trim().isEmpty ? 'Timer' : _label.text.trim();
                      Navigator.pop(
                        context,
                        RunningTimerModel(
                          label: label,
                          totalMillis: totalMs,
                          remainingMillis: totalMs,
                          isRunning: true,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.cyberYellow,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text(
                      'Start Timer',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NumberStepper extends StatelessWidget {
  const _NumberStepper({
    required this.value,
    required this.unit,
    required this.max,
    required this.onChanged,
  });

  final int value;
  final String unit;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(
          icon: const Icon(Icons.keyboard_arrow_up_rounded, size: 28),
          onPressed: () => onChanged((value + 1) > max ? 0 : value + 1),
        ),
        Text(
          value.toString().padLeft(2, '0'),
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w800,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
        Text(
          unit,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
            color: AppTheme.textMuted,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 28),
          onPressed: () => onChanged((value - 1) < 0 ? max : value - 1),
        ),
      ],
    );
  }
}
