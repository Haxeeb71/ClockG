class WorldCity {
  int? id;
  String name;
  String timezone; // e.g. 'Europe/London'

  WorldCity({this.id, required this.name, required this.timezone});

  Map<String, dynamic> toMap() => {'id': id, 'name': name, 'timezone': timezone};
  factory WorldCity.fromMap(Map<String, dynamic> map) => WorldCity(
        id: map['id'] as int?,
        name: map['name'] as String,
        timezone: map['timezone'] as String,
      );
}


