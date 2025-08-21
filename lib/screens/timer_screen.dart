import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/timer_provider.dart';
import '../services/db.dart';
import '../models/timer.dart';

class TimerScreen extends StatelessWidget {
  const TimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TimerProvider(AppDatabase())..load(),
      child: const _TimersView(),
    );
  }
}

class _TimersView extends StatefulWidget {
  const _TimersView();
  @override
  State<_TimersView> createState() => _TimersViewState();
}

class _TimersViewState extends State<_TimersView> {
  @override
  Widget build(BuildContext context) {
    final tp = context.watch<TimerProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Timers')),
      body: tp.timers.isEmpty
          ? const Center(child: Text('No timers'))
          : ListView.builder(
              itemCount: tp.timers.length,
              itemBuilder: (context, i) {
                final t = tp.timers[i];
                String two(int n) => n.toString().padLeft(2, '0');
                final ms = t.remainingMillis;
                final minutes = (ms ~/ 60000) % 60;
                final seconds = (ms ~/ 1000) % 60;
                return Dismissible(
                  key: ValueKey(t.id),
                  background: Container(color: Colors.red),
                  onDismissed: (_) => tp.remove(t.id!),
                  child: ListTile(
                    title: Text(t.label),
                    subtitle: Text('${two(minutes)}:${two(seconds)}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(t.isRunning ? Icons.pause : Icons.play_arrow),
                          onPressed: () => t.isRunning ? tp.pause(t) : tp.start(t),
                        ),
                        IconButton(
                          icon: const Icon(Icons.restart_alt),
                          onPressed: () => tp.reset(t),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final created = await showDialog<RunningTimerModel>(
            context: context,
            builder: (_) => const _NewTimerDialog(),
          );
          if (created != null) {
            await tp.add(created);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _NewTimerDialog extends StatefulWidget {
  const _NewTimerDialog();
  @override
  State<_NewTimerDialog> createState() => _NewTimerDialogState();
}

class _NewTimerDialogState extends State<_NewTimerDialog> {
  final TextEditingController _label = TextEditingController(text: 'Timer');
  Duration _duration = const Duration(minutes: 1);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New Timer'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: _label, decoration: const InputDecoration(labelText: 'Label')),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: Text('Duration: ${_duration.inMinutes} min')),
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: () => setState(() {
                  _duration -= const Duration(minutes: 1);
                  if (_duration.inMinutes < 1) _duration = const Duration(minutes: 1);
                }),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => setState(() => _duration += const Duration(minutes: 1)),
              ),
            ],
          )
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            final label = _label.text.trim().isEmpty ? 'Timer' : _label.text.trim();
            final total = _duration.inMilliseconds;
            Navigator.pop(
              context,
              RunningTimerModel(label: label, totalMillis: total, remainingMillis: total, isRunning: true),
            );
          },
          child: const Text('Start'),
        )
      ],
    );
  }
}


