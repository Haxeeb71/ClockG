import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/alarm_provider.dart';
import '../models/alarm.dart';
import '../theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';

class AlarmScreen extends StatelessWidget {
  const AlarmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _AlarmView();
  }
}

class _AlarmView extends StatefulWidget {
  const _AlarmView();
  @override
  State<_AlarmView> createState() => _AlarmViewState();
}

class _AlarmViewState extends State<_AlarmView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AlarmProvider>().load();
    });
  }

  String _getNextAlarmInfo(List<AlarmModel> alarms) {
    final enabledAlarms = alarms.where((a) => a.isEnabled).toList();
    if (enabledAlarms.isEmpty) return 'No upcoming alarms scheduled';

    final now = DateTime.now();
    DateTime? earliest;

    for (final a in enabledAlarms) {
      DateTime candidate = DateTime(
        now.year,
        now.month,
        now.day,
        a.time.hour,
        a.time.minute,
      );

      if (a.repeatWeekdays.isEmpty) {
        if (candidate.isBefore(now)) {
          candidate = candidate.add(const Duration(days: 1));
        }
      } else {
        for (int i = 0; i < 7; i++) {
          if (a.repeatWeekdays.contains(candidate.weekday)) {
            if (candidate.isAfter(now)) break;
          }
          candidate = candidate.add(const Duration(days: 1));
        }
      }

      if (earliest == null || candidate.isBefore(earliest)) {
        earliest = candidate;
      }
    }

    if (earliest == null) return 'No upcoming alarms scheduled';

    final diff = earliest.difference(now);
    final hours = diff.inHours;
    final mins = diff.inMinutes % 60;
    final formattedTime = DateFormat('h:mm a').format(earliest);

    if (hours == 0 && mins <= 1) {
      return 'Rings in less than a minute ($formattedTime)';
    } else if (hours == 0) {
      return 'Rings in $mins mins ($formattedTime)';
    } else {
      return 'Rings in $hours hr ${mins > 0 ? '$mins min' : ''} ($formattedTime)';
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AlarmProvider>();
    final alarms = provider.alarms;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final nextAlarmText = _getNextAlarmInfo(alarms);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.alarm, color: AppTheme.cyberYellow, size: 24),
            SizedBox(width: 10),
            Text('Alarm'),
          ],
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [
                            AppTheme.cyberSurfaceElevated,
                            AppTheme.cyberGunmetal,
                          ]
                        : [
                            const Color(0xFFF1F5F9),
                            Colors.white,
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isDark
                        ? AppTheme.cyberBorder
                        : const Color(0xFFE2E8F0),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.cyberYellow.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.access_time_filled_rounded,
                        color: AppTheme.cyberYellow,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'UPCOMING',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                              color: isDark
                                  ? AppTheme.cyberYellow
                                  : const Color(0xFFD97706),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            nextAlarmText,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.9)
                                  : const Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (alarms.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark
                              ? AppTheme.cyberSurfaceElevated
                              : const Color(0xFFF1F5F9),
                          border: Border.all(
                            color: AppTheme.cyberYellow.withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.alarm_off_rounded,
                          size: 56,
                          color: AppTheme.cyberYellow,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'No Alarms Set',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap the button below to schedule your next wake-up or reminder.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? AppTheme.textMuted : Colors.black54,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => _openAlarmEditor(context),
                        icon: const Icon(Icons.add_alarm_rounded),
                        label: const Text('Add New Alarm'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.cyberYellow,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final a = alarms[index];
                    return _AlarmCard(
                      alarm: a,
                      onToggle: (val) {
                        a.isEnabled = val;
                        provider.update(a);
                      },
                      onTap: () => _openAlarmEditor(context, initial: a),
                      onDelete: () => provider.remove(a.id!),
                    );
                  },
                  childCount: alarms.length,
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAlarmEditor(context),
        icon: const Icon(Icons.add, size: 22),
        label: const Text(
          'NEW ALARM',
          style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.5),
        ),
      ),
    );
  }

  Future<void> _openAlarmEditor(BuildContext context, {AlarmModel? initial}) async {
    final provider = context.read<AlarmProvider>();
    final result = await showModalBottomSheet<AlarmModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditAlarmSheet(initial: initial),
    );
    if (result != null) {
      if (initial != null) {
        result.id = initial.id;
        await provider.update(result);
      } else {
        await provider.add(result);
      }
    }
  }
}

class _AlarmCard extends StatelessWidget {
  const _AlarmCard({
    required this.alarm,
    required this.onToggle,
    required this.onTap,
    required this.onDelete,
  });

  final AlarmModel alarm;
  final ValueChanged<bool> onToggle;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final timeStr = DateFormat('h:mm').format(alarm.time);
    final period = DateFormat('a').format(alarm.time);

    return Dismissible(
      key: ValueKey(alarm.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.only(right: 24),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: AppTheme.accentRed.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'DELETE',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.delete_outline_rounded, color: Colors.white, size: 26),
          ],
        ),
      ),
      onDismissed: (_) => onDelete(),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.cyberGunmetal : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: alarm.isEnabled
                ? AppTheme.cyberYellow.withValues(alpha: isDark ? 0.35 : 0.6)
                : (isDark ? AppTheme.cyberBorder : const Color(0xFFE2E8F0)),
            width: alarm.isEnabled ? 1.5 : 1.0,
          ),
          boxShadow: [
            if (alarm.isEnabled && isDark)
              BoxShadow(
                color: AppTheme.cyberYellow.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        timeStr,
                        style: TextStyle(
                          fontSize: 44,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1.0,
                          fontFeatures: const [FontFeature.tabularFigures()],
                          color: alarm.isEnabled
                              ? (isDark ? Colors.white : const Color(0xFF0F172A))
                              : (isDark ? AppTheme.textMuted.withValues(alpha: 0.6) : Colors.black38),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: alarm.isEnabled
                              ? AppTheme.cyberYellow.withValues(alpha: 0.2)
                              : (isDark ? AppTheme.cyberSurfaceElevated : const Color(0xFFF1F5F9)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          period,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            color: alarm.isEnabled
                                ? (isDark ? AppTheme.cyberYellow : const Color(0xFFB45309))
                                : (isDark ? AppTheme.textMuted : Colors.black45),
                          ),
                        ),
                      ),
                      const Spacer(),
                      Switch(
                        value: alarm.isEnabled,
                        onChanged: onToggle,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        alarm.label.toUpperCase(),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: isDark ? AppTheme.textMuted : const Color(0xFF64748B),
                        ),
                      ),
                      if (alarm.gradualVolume) ...[
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.graphic_eq_rounded,
                          size: 16,
                          color: AppTheme.accentTeal,
                        ),
                      ],
                      if (alarm.soundPath != null) ...[
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.music_note_rounded,
                          size: 16,
                          color: AppTheme.accentCyan,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 14),
                  _WeekdayIndicatorRow(
                    repeatWeekdays: alarm.repeatWeekdays,
                    isAlarmEnabled: alarm.isEnabled,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WeekdayIndicatorRow extends StatelessWidget {
  const _WeekdayIndicatorRow({
    required this.repeatWeekdays,
    required this.isAlarmEnabled,
  });

  final List<int> repeatWeekdays;
  final bool isAlarmEnabled;

  @override
  Widget build(BuildContext context) {
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: List.generate(7, (i) {
        final weekday = i + 1; // 1=Mon .. 7=Sun
        final isSelected = repeatWeekdays.contains(weekday);

        return Container(
          width: 26,
          height: 26,
          margin: const EdgeInsets.only(right: 6),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected
                ? (isAlarmEnabled
                    ? AppTheme.cyberYellow
                    : (isDark ? AppTheme.cyberSurfaceElevated : const Color(0xFFE2E8F0)))
                : Colors.transparent,
            border: Border.all(
              color: isSelected
                  ? Colors.transparent
                  : (isDark ? AppTheme.cyberBorder : const Color(0xFFCBD5E1)),
              width: 1,
            ),
          ),
          child: Text(
            days[i],
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: isSelected
                  ? (isAlarmEnabled
                      ? Colors.black
                      : (isDark ? AppTheme.textMuted : Colors.black54))
                  : (isDark ? AppTheme.textMuted.withValues(alpha: 0.6) : Colors.black38),
            ),
          ),
        );
      }),
    );
  }
}

class _EditAlarmSheet extends StatefulWidget {
  const _EditAlarmSheet({this.initial});
  final AlarmModel? initial;

  @override
  State<_EditAlarmSheet> createState() => _EditAlarmSheetState();
}

class _EditAlarmSheetState extends State<_EditAlarmSheet> {
  late TimeOfDay _time;
  final TextEditingController _label = TextEditingController();
  final Set<int> _repeat = {};
  int _snooze = 10;
  bool _gradual = true;
  String? _soundPath;

  @override
  void initState() {
    super.initState();
    final now = TimeOfDay.now();
    _time = widget.initial != null
        ? TimeOfDay(
            hour: widget.initial!.time.hour,
            minute: widget.initial!.time.minute,
          )
        : now;
    _label.text = widget.initial?.label ?? 'Alarm';
    _repeat.addAll(widget.initial?.repeatWeekdays ?? []);
    _snooze = widget.initial?.snoozeMinutes ?? 10;
    _gradual = widget.initial?.gradualVolume ?? true;
    _soundPath = widget.initial?.soundPath;
  }

  @override
  void dispose() {
    _label.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final formattedTime = _time.format(context);

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
                Text(
                  widget.initial == null ? 'Set New Alarm' : 'Edit Alarm',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: _time,
                );
                if (picked != null) setState(() => _time = picked);
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.cyberSurfaceElevated : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.cyberYellow.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      formattedTime,
                      style: const TextStyle(
                        fontSize: 52,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1.5,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.edit_rounded, size: 14, color: AppTheme.cyberYellow),
                        SizedBox(width: 4),
                        Text(
                          'Tap to change time',
                          style: TextStyle(
                            color: AppTheme.cyberYellow,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _label,
              decoration: const InputDecoration(
                labelText: 'Alarm Label',
                prefixIcon: Icon(Icons.label_outline_rounded),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'REPEAT DAYS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
                color: AppTheme.textMuted,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(7, (i) {
                final weekday = i + 1;
                const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                final selected = _repeat.contains(weekday);

                return FilterChip(
                  label: Text(names[i]),
                  selected: selected,
                  selectedColor: AppTheme.cyberYellow,
                  checkmarkColor: Colors.black,
                  onSelected: (v) => setState(() {
                    if (v) {
                      _repeat.add(weekday);
                    } else {
                      _repeat.remove(weekday);
                    }
                  }),
                );
              }),
            ),
            const SizedBox(height: 20),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isDark ? AppTheme.cyberBorder : const Color(0xFFE2E8F0),
                  width: 1,
                ),
              ),
              leading: const Icon(Icons.music_note_rounded, color: AppTheme.accentTeal),
              title: const Text('Alarm Sound'),
              subtitle: Text(
                _soundPath == null
                    ? 'Default Cyber Tone'
                    : _soundPath!.split('/').last,
                style: const TextStyle(color: AppTheme.textMuted),
              ),
              trailing: const Icon(Icons.folder_open_rounded),
              onTap: () async {
                final res = await FilePicker.platform.pickFiles(
                  type: FileType.audio,
                );
                if (res != null && res.files.single.path != null) {
                  setState(() => _soundPath = res.files.single.path);
                }
              },
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
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
                      const Text(
                        'Snooze Duration',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '$_snooze min',
                        style: const TextStyle(
                          color: AppTheme.cyberYellow,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    min: 5,
                    max: 30,
                    divisions: 5,
                    value: _snooze.toDouble(),
                    onChanged: (v) => setState(() => _snooze = v.toInt()),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isDark ? AppTheme.cyberBorder : const Color(0xFFE2E8F0),
                  width: 1,
                ),
              ),
              value: _gradual,
              onChanged: (v) => setState(() => _gradual = v),
              title: const Text('Gradually Increase Volume'),
              subtitle: const Text(
                'Gently raises volume over 10 seconds',
                style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final now = DateTime.now();
                      final dt = DateTime(
                        now.year,
                        now.month,
                        now.day,
                        _time.hour,
                        _time.minute,
                      );
                      final model = AlarmModel(
                        label: _label.text.trim().isEmpty ? 'Alarm' : _label.text.trim(),
                        time: dt,
                        repeatWeekdays: _repeat.toList()..sort(),
                        soundPath: _soundPath,
                        isEnabled: true,
                        snoozeMinutes: _snooze,
                        gradualVolume: _gradual,
                      );
                      Navigator.pop(context, model);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.cyberYellow,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Save Alarm',
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
