import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/alarm_provider.dart';
import '../models/alarm.dart';
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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AlarmProvider>();
    final alarms = provider.alarms;
    return Scaffold(
      appBar: AppBar(title: const Text('Alarms')),
      body: alarms.isEmpty
          ? const Center(child: Text('No alarms yet'))
          : ListView.builder(
              itemCount: alarms.length,
              itemBuilder: (context, index) {
                final a = alarms[index];
                final time = DateFormat('hh:mm a').format(a.time);
                final repeat = a.repeatWeekdays.isEmpty
                    ? 'One-time'
                    : 'Repeats: ${a.repeatWeekdays.join(',')}';
                return Dismissible(
                  key: ValueKey(a.id),
                  background: Container(color: Colors.red),
                  onDismissed: (_) => provider.remove(a.id!),
                  child: ListTile(
                    leading: Switch(
                      value: a.isEnabled,
                      onChanged: (v) {
                        a.isEnabled = v;
                        provider.update(a);
                      },
                    ),
                    title: Text(time),
                    subtitle: Text('${a.label} • $repeat'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      final edited = await showDialog<AlarmModel>(
                        context: context,
                        builder: (_) => _EditAlarmDialog(initial: a),
                      );
                      if (edited != null) {
                        edited.id = a.id;
                        await provider.update(edited);
                      }
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final created = await showDialog<AlarmModel>(
            context: context,
            builder: (_) => const _EditAlarmDialog(),
          );
          if (created != null) {
            await provider.add(created);
          }
        },
        child: const Icon(Icons.add_alarm),
      ),
    );
  }
}

class _EditAlarmDialog extends StatefulWidget {
  const _EditAlarmDialog({this.initial});
  final AlarmModel? initial;

  @override
  State<_EditAlarmDialog> createState() => _EditAlarmDialogState();
}

class _EditAlarmDialogState extends State<_EditAlarmDialog> {
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
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initial == null ? 'New alarm' : 'Edit alarm'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('Time: ${_time.format(context)}'),
              trailing: const Icon(Icons.schedule),
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: _time,
                );
                if (picked != null) setState(() => _time = picked);
              },
            ),
            TextField(
              controller: _label,
              decoration: const InputDecoration(labelText: 'Label'),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              children: List.generate(7, (i) {
                final weekday = i + 1; // 1..7
                const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                final selected = _repeat.contains(weekday);
                return FilterChip(
                  label: Text(names[i]),
                  selected: selected,
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
            const SizedBox(height: 8),
            ListTile(
              title: Text(
                _soundPath == null
                    ? 'Choose sound'
                    : _soundPath!.split('/').last,
              ),
              leading: const Icon(Icons.music_note),
              onTap: () async {
                final res = await FilePicker.platform.pickFiles(
                  type: FileType.audio,
                );
                if (res != null && res.files.single.path != null) {
                  setState(() => _soundPath = res.files.single.path);
                }
              },
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Snooze (min)'),
                Expanded(
                  child: Slider(
                    min: 5,
                    max: 30,
                    divisions: 5,
                    value: _snooze.toDouble(),
                    label: '$_snooze',
                    onChanged: (v) => setState(() => _snooze = v.toInt()),
                  ),
                ),
              ],
            ),
            SwitchListTile(
              value: _gradual,
              onChanged: (v) => setState(() => _gradual = v),
              title: const Text('Gradually increase volume'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
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
          child: const Text('Save'),
        ),
      ],
    );
  }
}
