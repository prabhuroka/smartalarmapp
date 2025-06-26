class AlarmLog {
  final int? id;
  final int alarmId;
  final DateTime triggerTime;
  final DateTime? dismissedTime;
  final int attempts;
  final bool timedOut;
  final int snoozeCount;
  final int durationSeconds;

  AlarmLog({
    this.id,
    required this.alarmId,
    required this.triggerTime,
    this.dismissedTime,
    required this.attempts,
    required this.timedOut,
    required this.snoozeCount,
    required this.durationSeconds,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'alarm_id': alarmId,
        'trigger_time': triggerTime.toIso8601String(),
        'dismissed_time': dismissedTime?.toIso8601String(),
        'attempts': attempts,
        'timed_out': timedOut ? 1 : 0,
        'snooze_count': snoozeCount,
        'duration_seconds': durationSeconds,
      };

  static AlarmLog fromMap(Map<String, dynamic> map) => AlarmLog(
        id: map['id'],
        alarmId: map['alarm_id'],
        triggerTime: DateTime.parse(map['trigger_time']),
        dismissedTime: map['dismissed_time'] != null
            ? DateTime.parse(map['dismissed_time'])
            : null,
        attempts: map['attempts'],
        timedOut: map['timed_out'] == 1,
        snoozeCount: map['snooze_count'],
        durationSeconds: map['duration_seconds'],
      );
}
