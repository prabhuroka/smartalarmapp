import 'package:flutter/material.dart';
import 'alarm_log_model.dart';
import 'dbservice.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  int total = 0;
  int dismissed = 0;
  int timedOut = 0;
  double avgAttempts = 0;
  double avgDuration = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final logs = await DBService().getAllLogs();
    if (logs.isEmpty) return;

    setState(() {
      total = logs.length;
      timedOut = logs.where((l) => l.timedOut).length;
      dismissed = total - timedOut;
      avgAttempts = logs.map((l) => l.attempts).reduce((a, b) => a + b) / total;
      final completed = logs.where((l) => !l.timedOut).toList();
      avgDuration = completed.isEmpty
          ? 0
          : completed.map((l) => l.durationSeconds).reduce((a, b) => a + b) /
              completed.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Alarms: $total'),
            Text('Dismissed Successfully: $dismissed'),
            Text('Timed Out: $timedOut'),
            Text('Average Attempts: ${avgAttempts.toStringAsFixed(1)}'),
            Text(
                'Average Dismissal Time: ${avgDuration.toStringAsFixed(1)} seconds'),
          ],
        ),
      ),
    );
  }
}
