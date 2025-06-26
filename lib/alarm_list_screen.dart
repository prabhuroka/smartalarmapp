import 'package:flutter/material.dart';
import 'alarm_model.dart';
import 'dbservice.dart';
import 'alarm_form_screen.dart';
import 'notification_service.dart';
import 'stats_screen.dart';

class AlarmListScreen extends StatefulWidget {
  const AlarmListScreen({super.key});

  @override
  State<AlarmListScreen> createState() => _AlarmListScreenState();
}

class _AlarmListScreenState extends State<AlarmListScreen> {
  List<Alarm> _alarms = [];

  @override
  void initState() {
    super.initState();
    NotificationService.init();
    _loadAlarms();
  }

  Future<void> _loadAlarms() async {
    final alarms = await DBService().getAlarms();
    setState(() => _alarms = alarms);
  }

  void _toggleAlarm(Alarm alarm) async {
    final updated = Alarm(
      id: alarm.id,
      time: alarm.time,
      category: alarm.category,
      difficulty: alarm.difficulty,
      isEnabled: !alarm.isEnabled,
      sound: alarm.sound,
      createdAt: alarm.createdAt,
    );
    await DBService().updateAlarm(updated);

    final timeParts = alarm.time.split(":");
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    if (updated.isEnabled) {
      await NotificationService.scheduleAlarmNotification(
        id: alarm.id!,
        hour: hour,
        minute: minute,
        message: 'Time to wake up and solve a challenge!',
        sound: updated.sound,
      );
    } else {
      await NotificationService.cancelAlarm(alarm.id!);
    }

    _loadAlarms();
  }

  void _deleteAlarm(int id) async {
    await DBService().deleteAlarm(id);
    await NotificationService.cancelAlarm(id);
    _loadAlarms();
  }

  void _navigateToCreateAlarm() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AlarmFormScreen()),
    );
    _loadAlarms();
  }

  void _navigateToStats() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const StatsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alarms'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: _navigateToStats,
          ),
        ],
      ),
      body: _alarms.isEmpty
          ? const Center(child: Text('No alarms set.'))
          : ListView.builder(
              itemCount: _alarms.length,
              itemBuilder: (context, index) {
                final alarm = _alarms[index];
                return Card(
                  child: ListTile(
                    title: Text('Time: ${alarm.time}'),
                    subtitle: Text(
                      'Difficulty: ${alarm.difficulty} | Category: ${alarm.category} | Sound: ${alarm.sound ?? "Default"}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Switch(
                          value: alarm.isEnabled,
                          onChanged: (_) => _toggleAlarm(alarm),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteAlarm(alarm.id!),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateAlarm,
        child: const Icon(Icons.add),
      ),
    );
  }
}
