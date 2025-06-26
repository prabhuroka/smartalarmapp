class Alarm {
  final int? id;
  final String time;
  final String category;
  final String difficulty;
  final bool isEnabled;
  final String? sound;
  final DateTime createdAt;

  Alarm({
    this.id,
    required this.time,
    required this.category,
    required this.difficulty,
    required this.isEnabled,
    required this.sound,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'time': time,
        'category': category,
        'difficulty': difficulty,
        'is_enabled': isEnabled ? 1 : 0,
        'sound': sound,
        'created_at': createdAt.toIso8601String(),
      };

  static Alarm fromMap(Map<String, dynamic> map) => Alarm(
        id: map['id'],
        time: map['time'],
        category: map['category'],
        difficulty: map['difficulty'],
        isEnabled: map['is_enabled'] == 1,
        sound: map['sound'],
        createdAt: DateTime.parse(map['created_at']),
      );
}
