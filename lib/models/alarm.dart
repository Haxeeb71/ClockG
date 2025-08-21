class AlarmModel {
  int? id;
  String label;
  DateTime time;
  List<int> repeatWeekdays; // 1=Mon .. 7=Sun
  String? soundPath;
  bool isEnabled;
  int snoozeMinutes;
  bool gradualVolume;

  AlarmModel({
    this.id,
    required this.label,
    required this.time,
    required this.repeatWeekdays,
    this.soundPath,
    this.isEnabled = true,
    this.snoozeMinutes = 10,
    this.gradualVolume = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'label': label,
      'time': time.millisecondsSinceEpoch,
      'repeatWeekdays': repeatWeekdays.join(','),
      'soundPath': soundPath,
      'isEnabled': isEnabled ? 1 : 0,
      'snoozeMinutes': snoozeMinutes,
      'gradualVolume': gradualVolume ? 1 : 0,
    };
  }

  factory AlarmModel.fromMap(Map<String, dynamic> map) {
    return AlarmModel(
      id: map['id'] as int?,
      label: map['label'] as String,
      time: DateTime.fromMillisecondsSinceEpoch(map['time'] as int),
      repeatWeekdays: (map['repeatWeekdays'] as String)
          .split(',')
          .where((e) => e.isNotEmpty)
          .map((e) => int.parse(e))
          .toList(),
      soundPath: map['soundPath'] as String?,
      isEnabled: (map['isEnabled'] as int) == 1,
      snoozeMinutes: map['snoozeMinutes'] as int,
      gradualVolume: (map['gradualVolume'] as int) == 1,
    );
  }
}


