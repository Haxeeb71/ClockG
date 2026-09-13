import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bedtime_provider.dart';
import '../theme/app_theme.dart';

class BedtimeScreen extends StatefulWidget {
  const BedtimeScreen({super.key});

  @override
  State<BedtimeScreen> createState() => _BedtimeScreenState();
}

class _BedtimeScreenState extends State<BedtimeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<BedtimeProvider>().load();
    });
  }

  String _calculateSleepDuration(TimeOfDay bed, TimeOfDay wake) {
    int bedMinutes = bed.hour * 60 + bed.minute;
    int wakeMinutes = wake.hour * 60 + wake.minute;

    int diff = wakeMinutes - bedMinutes;
    if (diff <= 0) {
      diff += 24 * 60; // Crosses midnight
    }

    final hours = diff ~/ 60;
    final mins = diff % 60;

    if (mins == 0) {
      return '$hours hr';
    }
    return '$hours hr $mins min';
  }

  @override
  Widget build(BuildContext context) {
    final bt = context.watch<BedtimeProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sleepDuration = _calculateSleepDuration(bt.bedtime, bt.wake);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.bedtime, color: AppTheme.cyberYellow, size: 24),
            SizedBox(width: 10),
            Text('Bedtime'),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero Sleep Duration Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [
                          const Color(0xFF0F172A),
                          const Color(0xFF020617),
                        ]
                      : [
                          const Color(0xFF1E293B),
                          const Color(0xFF0F172A),
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppTheme.accentTeal.withValues(alpha: 0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accentTeal.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.accentTeal.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.nightlight_round, size: 14, color: AppTheme.accentTeal),
                            SizedBox(width: 6),
                            Text(
                              'SLEEP SCHEDULE',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1,
                                color: AppTheme.accentTeal,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.stars_rounded, color: AppTheme.cyberYellow, size: 20),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    sleepDuration,
                    style: const TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1.0,
                      color: Colors.white,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'of planned sleep based on your bedtime and wake goals.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.7),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Dual Schedule Cards (Bedtime & Wake)
            Row(
              children: [
                Expanded(
                  child: _TimeTargetCard(
                    title: 'BEDTIME',
                    icon: Icons.nightlight_round,
                    iconColor: const Color(0xFF38BDF8),
                    time: bt.bedtime,
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: bt.bedtime,
                      );
                      if (picked != null) bt.setBedtime(picked);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TimeTargetCard(
                    title: 'WAKE UP',
                    icon: Icons.wb_twilight_rounded,
                    iconColor: AppTheme.cyberYellow,
                    time: bt.wake,
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: bt.wake,
                      );
                      if (picked != null) bt.setWake(picked);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Section Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                'ROUTINE & HABITS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: isDark ? AppTheme.textMuted : const Color(0xFF64748B),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Routine Options
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppTheme.cyberGunmetal : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? AppTheme.cyberBorder : const Color(0xFFE2E8F0),
                ),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    secondary: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.cyberYellow.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.graphic_eq_rounded, color: AppTheme.cyberYellow, size: 22),
                    ),
                    title: const Text(
                      'Gentle Wake',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: const Text(
                      'Gradually fades in alarm volume to wake you smoothly.',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                    ),
                    value: bt.gentle,
                    onChanged: bt.setGentle,
                  ),
                  Divider(
                    height: 1,
                    color: isDark ? AppTheme.cyberBorder : const Color(0xFFF1F5F9),
                  ),
                  SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    secondary: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.accentTeal.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.notifications_active_rounded, color: AppTheme.accentTeal, size: 22),
                    ),
                    title: const Text(
                      'Bedtime Reminder',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: const Text(
                      'Get notified 15 minutes before your scheduled bedtime.',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                    ),
                    value: bt.reminder,
                    onChanged: bt.setReminder,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Sleep Health Tip Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.cyberSurfaceElevated : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? AppTheme.cyberBorder : const Color(0xFFE2E8F0),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb_outline_rounded, color: AppTheme.cyberYellow, size: 24),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Sleep Consistency',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Going to bed and waking up at consistent times each day helps align your natural circadian rhythms and optimizes deep sleep cycles.',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? AppTheme.textMuted : const Color(0xFF475569),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
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

class _TimeTargetCard extends StatelessWidget {
  const _TimeTargetCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.time,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final Color iconColor;
  final TimeOfDay time;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final formatted = time.format(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.cyberGunmetal : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? AppTheme.cyberBorder : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                    color: isDark ? AppTheme.textMuted : const Color(0xFF64748B),
                  ),
                ),
                Icon(icon, color: iconColor, size: 20),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              formatted,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                fontFeatures: const [FontFeature.tabularFigures()],
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 4),
            const Row(
              children: [
                Icon(Icons.edit_rounded, size: 12, color: AppTheme.cyberYellow),
                SizedBox(width: 4),
                Text(
                  'Change time',
                  style: TextStyle(
                    color: AppTheme.cyberYellow,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
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
