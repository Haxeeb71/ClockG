import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:clockg/theme/app_theme.dart';
import 'package:clockg/providers/stopwatch_provider.dart';
import 'package:provider/provider.dart';
import 'package:clockg/screens/stopwatch_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('AppTheme defines cyber colors and dark theme', () {
    final dark = AppTheme.dark();
    expect(dark.scaffoldBackgroundColor, AppTheme.cyberBlack);
    expect(dark.colorScheme.primary, AppTheme.cyberYellow);
    expect(dark.colorScheme.secondary, AppTheme.accentTeal);

    final light = AppTheme.light();
    expect(light.brightness, Brightness.light);
  });

  testWidgets('StopwatchScreen renders controls and stopwatch dial', (WidgetTester tester) async {
    final stopwatchProvider = StopwatchProvider();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: ChangeNotifierProvider<StopwatchProvider>.value(
          value: stopwatchProvider,
          child: const StopwatchScreen(),
        ),
      ),
    );

    expect(find.text('Stopwatch'), findsOneWidget);
    expect(find.text('START'), findsOneWidget);
    expect(find.text('00:00'), findsOneWidget);
    expect(find.text('.00'), findsOneWidget);
    expect(find.text('READY'), findsOneWidget);

    // Tap start
    await tester.tap(find.text('START'));
    await tester.pump();

    expect(stopwatchProvider.isRunning, isTrue);
    expect(find.text('PAUSE'), findsOneWidget);
    expect(find.text('LAP'), findsOneWidget);

    // Tap lap
    await tester.tap(find.text('LAP'));
    await tester.pump();

    expect(stopwatchProvider.laps.length, 1);
    expect(find.text('LAP'), findsOneWidget);
    expect(find.text('SPLIT'), findsOneWidget);

    // Tap pause
    await tester.tap(find.text('PAUSE'));
    await tester.pump();

    expect(stopwatchProvider.isRunning, isFalse);
    expect(find.text('RESUME'), findsOneWidget);
    expect(find.text('RESET'), findsOneWidget);

    // Tap reset
    await tester.tap(find.text('RESET'));
    await tester.pump();

    expect(stopwatchProvider.elapsedMs, 0);
    expect(stopwatchProvider.laps.isEmpty, isTrue);
    expect(find.text('START'), findsOneWidget);
  });
}
