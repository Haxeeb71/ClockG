import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/world_clock_provider.dart';
import '../services/db.dart';
import '../models/world_city.dart';

class WorldClockScreen extends StatelessWidget {
  const WorldClockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WorldClockProvider(AppDatabase())..load(),
      child: const _WorldClockView(),
    );
  }
}

class _WorldClockView extends StatelessWidget {
  const _WorldClockView();

  @override
  Widget build(BuildContext context) {
    final wc = context.watch<WorldClockProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('World Clock'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final city = await showDialog<WorldCity>(
                context: context,
                builder: (_) => const _AddCityDialog(),
              );
              if (city != null) {
                await wc.addCity(city);
              }
            },
          )
        ],
      ),
      body: wc.cities.isEmpty
          ? const Center(child: Text('Add cities to view times'))
          : ListView.builder(
              itemCount: wc.cities.length,
              itemBuilder: (_, i) {
                final c = wc.cities[i];
                final t = wc.timeInCity(c);
                return Dismissible(
                  key: ValueKey(c.id),
                  background: Container(color: Colors.red),
                  onDismissed: (_) => wc.removeCity(c.id!),
                  child: ListTile(
                    title: Text(c.name),
                    subtitle: Text('${t.toLocal()}'),
                  ),
                );
              },
            ),
    );
  }
}

class _AddCityDialog extends StatefulWidget {
  const _AddCityDialog();
  @override
  State<_AddCityDialog> createState() => _AddCityDialogState();
}

class _AddCityDialogState extends State<_AddCityDialog> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _tz = TextEditingController(text: 'Europe/London');
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add City'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: _name, decoration: const InputDecoration(labelText: 'City name')),
          TextField(controller: _tz, decoration: const InputDecoration(labelText: 'Timezone (Area/City)')),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            final name = _name.text.trim();
            final tz = _tz.text.trim();
            if (name.isEmpty || tz.isEmpty) return;
            Navigator.pop(context, WorldCity(name: name, timezone: tz));
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}


