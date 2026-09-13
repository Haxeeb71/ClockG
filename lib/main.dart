import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'screens/alarm_screen.dart';
import 'screens/world_clock_screen.dart';
import 'screens/timer_screen.dart';
import 'screens/stopwatch_screen.dart';
import 'screens/bedtime_screen.dart';
import 'services/db.dart';
import 'services/notifications.dart';
import 'providers/alarm_provider.dart';
import 'providers/timer_provider.dart';
import 'services/navigation.dart';
import 'screens/ringing_screen.dart';

import 'providers/stopwatch_provider.dart';
import 'providers/world_clock_provider.dart';
import 'providers/bedtime_provider.dart';

class _NavIndexProvider extends ChangeNotifier {
  int _index = 0;
  int get index => _index;
  void setIndex(int value) {
    if (value == _index) return;
    _index = value;
    notifyListeners();
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ClockGApp());
}

class ClockGApp extends StatelessWidget {
  const ClockGApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => _NavIndexProvider()),
        Provider(create: (_) => AppDatabase()),
        Provider(create: (_) => NotificationService()),
        ChangeNotifierProxyProvider2<
          AppDatabase,
          NotificationService,
          AlarmProvider
        >(
          create: (_) => AlarmProvider(AppDatabase(), NotificationService()),
          update: (_, db, notifs, prev) => prev ?? AlarmProvider(db, notifs),
        ),
        ChangeNotifierProxyProvider<AppDatabase, TimerProvider>(
          create: (_) => TimerProvider(AppDatabase()),
          update: (_, db, prev) => prev ?? TimerProvider(db),
        ),
        ChangeNotifierProxyProvider<AppDatabase, WorldClockProvider>(
          create: (_) => WorldClockProvider(AppDatabase()),
          update: (_, db, prev) => prev ?? WorldClockProvider(db),
        ),
        ChangeNotifierProvider(create: (_) => StopwatchProvider()),
        ChangeNotifierProxyProvider<NotificationService, BedtimeProvider>(
          create: (_) => BedtimeProvider(NotificationService()),
          update: (_, notifs, prev) => prev ?? BedtimeProvider(notifs),
        ),
      ],
      child: MaterialApp(
        title: 'ClockG',
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.dark,
        navigatorKey: appNavigatorKey,
        home: const _RootScaffold(),
        debugShowCheckedModeBanner: false,
        routes: {
          '/ring': (context) {
            final payload =
                ModalRoute.of(context)?.settings.arguments as String?;
            final id = int.tryParse(payload ?? '');
            return RingingScreen(alarmId: id);
          },
        },
      ),
    );
  }
}

class _RootScaffold extends StatelessWidget {
  const _RootScaffold();

  static const List<Widget> _tabs = <Widget>[
    AlarmScreen(),
    WorldClockScreen(),
    TimerScreen(),
    StopwatchScreen(),
    BedtimeScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<_NavIndexProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: nav.index,
        children: _tabs,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: isDark ? AppTheme.cyberBorder : const Color(0xFFE2E8F0),
              width: 1,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: nav.index,
          onDestinationSelected: nav.setIndex,
          height: 68,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.alarm_outlined),
              selectedIcon: Icon(Icons.alarm),
              label: 'Alarm',
            ),
            NavigationDestination(
              icon: Icon(Icons.public_outlined),
              selectedIcon: Icon(Icons.public),
              label: 'Clock',
            ),
            NavigationDestination(
              icon: Icon(Icons.timer_outlined),
              selectedIcon: Icon(Icons.timer),
              label: 'Timer',
            ),
            NavigationDestination(
              icon: Icon(Icons.timer_10_outlined),
              selectedIcon: Icon(Icons.timer_10),
              label: 'Stopwatch',
            ),
            NavigationDestination(
              icon: Icon(Icons.bedtime_outlined),
              selectedIcon: Icon(Icons.bedtime),
              label: 'Bedtime',
            ),
          ],
        ),
      ),
    );
  }
}
