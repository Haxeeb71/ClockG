class RunningTimerModel {
  int? id;
  String label;
  int totalMillis;
  int remainingMillis;
  bool isRunning;

  RunningTimerModel({
    this.id,
    required this.label,
    required this.totalMillis,
    required this.remainingMillis,
    this.isRunning = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'label': label,
      'totalMillis': totalMillis,
      'remainingMillis': remainingMillis,
      'isRunning': isRunning ? 1 : 0,
    };
  }

  factory RunningTimerModel.fromMap(Map<String, dynamic> map) {
    return RunningTimerModel(
      id: map['id'] as int?,
      label: map['label'] as String,
      totalMillis: map['totalMillis'] as int,
      remainingMillis: map['remainingMillis'] as int,
      isRunning: (map['isRunning'] as int) == 1,
    );
  }
}


