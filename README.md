# clockG

A Flutter app replicating Google Clock features: Alarm, World Clock, Timer, Stopwatch, and Bedtime — with a cyberpunk yellow theme.

## Features
- Alarm: repeat, labels, custom sound, snooze, gradual volume
- World Clock: add cities, timezone/DST aware
- Timer: multiple timers, pause/reset
- Stopwatch: laps, 10ms precision
- Bedtime: schedule, gentle wake, reminders

## Tech
- Flutter + Dart, Provider
- SQLite (sqflite)
- flutter_local_notifications, timezone

## Build
```bash
flutter pub get
flutter run
# Release APKs
flutter build apk --release --split-per-abi
```

## License
MIT — see `LICENSE`.
