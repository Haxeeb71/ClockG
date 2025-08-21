import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bedtime_provider.dart';
import '../services/notifications.dart';

class BedtimeScreen extends StatelessWidget {
  const BedtimeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BedtimeProvider(NotificationService())..load(),
      child: const _BedtimeView(),
    );
  }
}

class _BedtimeView extends StatelessWidget {
  const _BedtimeView();

  @override
  Widget build(BuildContext context) {
    final bt = context.watch<BedtimeProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Bedtime')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text('Bedtime: ${bt.bedtime.format(context)}'),
              trailing: const Icon(Icons.schedule),
              onTap: () async {
                final picked = await showTimePicker(context: context, initialTime: bt.bedtime);
                if (picked != null) bt.setBedtime(picked);
              },
            ),
            ListTile(
              title: Text('Wake: ${bt.wake.format(context)}'),
              trailing: const Icon(Icons.wb_twilight),
              onTap: () async {
                final picked = await showTimePicker(context: context, initialTime: bt.wake);
                if (picked != null) bt.setWake(picked);
              },
            ),
            SwitchListTile(
              title: const Text('Gentle wake (fade-in volume)'),
              value: bt.gentle,
              onChanged: bt.setGentle,
            ),
            SwitchListTile(
              title: const Text('Bedtime reminder'),
              value: bt.reminder,
              onChanged: bt.setReminder,
            ),
          ],
        ),
      ),
    );
  }
}


