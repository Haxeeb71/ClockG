# ClockG

A stunning, futuristic Flutter clock application replicating Google Clock features with an electric **Cyberpunk Neo-Minimalist** aesthetic (Cyber Yellow `#FFD300`, Neon Teal `#00FFC6`, Deep OLED Black `#0A0D12`, and dark layered surfaces).

## Key Features

- **Alarm**:
  - Dynamic "Next Alarm" countdown banner (e.g. *"Rings in 6 hr 45 min"*).
  - High-impact digital typography with AM/PM badges.
  - Interactive weekday indicator pills (`M T W T F S S`) with glowing active indicators.
  - Redesigned bottom sheet editor with time picker preview, weekday chips, custom snooze slider, sound picker, and gradual volume toggle.
- **World Clock**:
  - Exquisite custom-painted Analog + Digital Local Clock with a sweeping second hand and GMT offset.
  - World city cards with day/night indicator icons (Sun vs. Moon), relative time differences (`+5 HRS`, `YESTERDAY`), and timezone codes.
  - Searchable directory of 30+ major global cities with 1-tap addition.
- **Timer**:
  - Hero circular countdown progress ring with a glowing runner head and neon sweep arc.
  - Big tactile controls (Start, Pause, Reset, and `+1:00` quick extend).
  - Quick 1-tap preset chips (1m, 3m, 5m, 10m, 15m, 25m Pomodoro, 30m).
  - Secondary timer cards with mini circular progress rings.
- **Stopwatch**:
  - 60-second hybrid sweeping analog dial with high-frequency millisecond digital readout.
  - Large tactile action buttons (Start, Pause, Resume, Lap, Reset).
  - Persistent state across tab navigation.
  - Pro lap table with split deltas and automatic highlighting of the fastest (green) and slowest (red) laps.
- **Bedtime**:
  - Celestial sleep schedule card with automatic sleep duration calculation (*"8 hr 00 min of sleep"*).
  - Dual interactive Bedtime (Moon) and Wake (Sunrise) schedule cards.
  - Gentle Wake and Bedtime Reminder routine toggles.
  - Sleep consistency health tips.
- **Ringing Alarm**:
  - Concentric pulsing glowing radar wave rings around the alarm bell.
  - Huge glowing cyber time display with dedicated Snooze and Dismiss actions.

## Tech Stack

- Flutter 3 + Dart (Null Safety)
- State Management: `Provider` with lifted multi-provider architecture and `IndexedStack`
- Database: SQLite via `sqflite`
- Notifications: `flutter_local_notifications` with timezone & exact alarm scheduling
- Audio: `audioplayers` with gradual volume fade-in

## Build
```bash
flutter pub get
flutter run
# Release APKs
flutter build apk --release --split-per-abi
```

## License
MIT — see `LICENSE`.

## Screenshots



<table width="100%">
  <tr>
    <td width="1%"><img src="https://github.com/user-attachments/assets/def7d004-ae14-44da-80d5-eacb46a32e87"/></td>
     <td width="1%"><img src="https://github.com/user-attachments/assets/e353ba1b-3981-4b0a-861e-9bd5a4f3db5e"/></td>
     <td width="1%"><img src="https://github.com/user-attachments/assets/8bd15840-ddbd-443a-9a0f-d234404e0c07"/></td>
    <td width="1%"><img src="https://github.com/user-attachments/assets/d6051db6-9f9f-49d6-b46d-43f5a345507a"/></td>
  </tr>

<tr>
   <td width="1%"><img src="https://github.com/user-attachments/assets/03b4257c-dded-4d36-8210-da51d5e8509a"/></td>
     <td width="1%"><img src="https://github.com/user-attachments/assets/426407cf-f26d-47e3-81b7-a90974d77641"/></td>
     <td width="1%"><img src="https://github.com/user-attachments/assets/523433db-8038-486c-a2eb-9f8142822640"/></td>
     <td width="1%"><img src="https://github.com/user-attachments/assets/71c953ed-9ed8-4422-91d9-d712f3b78857"/></td>
  </tr>

  <tr>
   <td width="1%"><img src="https://github.com/user-attachments/assets/bb05c1dd-fa7c-44c6-8d13-53732d311dd4"/></td>
     <td width="1%"><img src="https://github.com/user-attachments/assets/e342e299-a84e-4a6b-bd7e-d149649f714f"/></td>
  </tr>
    
  
    
 
</table>
