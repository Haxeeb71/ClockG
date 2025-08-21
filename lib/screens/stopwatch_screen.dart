import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/stopwatch_provider.dart';

class StopwatchScreen extends StatelessWidget {
  const StopwatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StopwatchProvider(),
      child: Builder(
        builder: (context) {
          final sw = context.watch<StopwatchProvider>();
          String two(int n) => n.toString().padLeft(2, '0');
          final ms = sw.elapsedMs;
          final minutes = (ms ~/ 60000) % 60;
          final seconds = (ms ~/ 1000) % 60;
          final hundreds = (ms % 1000) ~/ 10;
          return Scaffold(
            appBar: AppBar(title: const Text('Stopwatch')),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${two(minutes)}:${two(seconds)}.${two(hundreds)}',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: sw.isRunning ? sw.pause : sw.start,
                      child: Text(sw.isRunning ? 'Pause' : 'Start'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: sw.reset,
                      child: const Text('Reset'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: sw.isRunning || sw.elapsedMs > 0
                          ? sw.lap
                          : null,
                      child: const Text('Lap'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: sw.laps.length,
                    itemBuilder: (context, index) {
                      final lapMs = sw.laps[index];
                      final m = (lapMs ~/ 60000) % 60;
                      final s = (lapMs ~/ 1000) % 60;
                      final h = (lapMs % 1000) ~/ 10;
                      return ListTile(
                        leading: Text('#${sw.laps.length - index}'),
                        title: Text('${two(m)}:${two(s)}.${two(h)}'),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
