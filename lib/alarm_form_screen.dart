import 'package:flutter/material.dart';
import 'alarm_model.dart';
import 'dbservice.dart';
import 'alarm_log_model.dart';
import 'package:intl/intl.dart';
import 'notification_service.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'dart:io';

class AlarmFormScreen extends StatefulWidget {
const AlarmFormScreen({super.key});

@override
State createState() => _AlarmFormScreenState();
}

class _AlarmFormScreenState extends State {
bool _initializing = true;
TimeOfDay? _selectedTime;
String _difficulty = 'easy';
String _category = '9';
String _sound = 'default';

final _categories = {
'9': 'General Knowledge',
'17': 'Science & Nature',
'18': 'Computers',
'23': 'History',
'27': 'Animals',
};

final _sounds = {
'default': 'Default',
'tone1': 'Tone 1',
'tone2': 'Tone 2',
'tone3': 'Tone 3',
};

Future _pickTime() async {
final now = TimeOfDay.now();
final picked = await showTimePicker(context: context, initialTime: now);
if (picked != null) setState(() => _selectedTime = picked);
}

Future _calculateSmartDifficulty(String categoryId) async {
final logs = await DBService().getAllLogs();
final relevant = logs.where((log) => !log.timedOut).toList();
if (relevant.isEmpty) return 'easy';

double avgAttempts =
    relevant.map((e) => e.attempts).reduce((a, b) => a + b) / relevant.length;

if (avgAttempts <= 1.2) return 'hard';
if (avgAttempts <= 2.5) return 'medium';
return 'easy';

}

Future _recommendBestCategory() async {
final logs = await DBService().getAllLogs();
final completed = logs.where((l) => !l.timedOut).toList();
if (completed.isEmpty) return '9';

final grouped = <String, List<AlarmLog>>{};
for (final c in _categories.keys) {
  grouped[c] = completed.where((log) => log.alarmId.toString().startsWith(c)).toList();
}

grouped.removeWhere((key, list) => list.isEmpty);

if (grouped.isEmpty) return '9';

final best = grouped.entries.reduce((a, b) {
  double aRate = a.value.where((l) => !l.timedOut).length / a.value.length;
  double bRate = b.value.where((l) => !l.timedOut).length / b.value.length;
  return aRate >= bRate ? a : b;
});

return best.key;

}

Future _recommendWakeTime() async {
final logs = await DBService().getAllLogs();
final times = logs.where((log) => !log.timedOut).map((log) => log.triggerTime);
if (times.isEmpty) return TimeOfDay(hour: 7, minute: 0);

final hourFrequency = List<int>.filled(24, 0);
for (final t in times) {
  hourFrequency[t.hour]++;
}
final bestHour = hourFrequency.indexOf(hourFrequency.reduce((a, b) => a > b ? a : b));
return TimeOfDay(hour: bestHour, minute: 0);

}

Future _initSmartDefaults() async {
final bestCategory = await _recommendBestCategory();
final recommendedTime = await _recommendWakeTime();
setState(() {
_category = bestCategory;
_selectedTime = recommendedTime;
_initializing = false;
});
}

Future _ensureExactAlarmPermission() async {
if (Platform.isAndroid) {
final intent = AndroidIntent(
action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
);
await intent.launch();
return false;
}
return true;
}

void _saveAlarm() async {
if (_selectedTime == null) return;
final smartDiff = await _calculateSmartDifficulty(_category);
final formattedTime = _selectedTime!.format(context);

final alarm = Alarm(
  time: formattedTime,
  category: _category,
  difficulty: smartDiff,
  isEnabled: true,
  sound: _sound,
  createdAt: DateTime.now(),
);

final id = await DBService().insertAlarm(alarm);

final canSchedule = await _ensureExactAlarmPermission();
if (!canSchedule) {
  if (!mounted) return;
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Permission Required'),
      content: const Text('Please enable "Allow exact alarms" in system settings and come back to re-save the alarm.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
      ],
    ),
  );
  return;
}

await NotificationService.scheduleAlarmNotification(
  id: id,
  hour: _selectedTime!.hour,
  minute: _selectedTime!.minute,
  message: 'Time to solve your alarm!',
  sound: _sound,
  category: _category,
);

Navigator.pop(context);

}

@override
void initState() {
super.initState();
_initSmartDefaults();
}

@override
Widget build(BuildContext context) {
if (_initializing) {
return const Scaffold(
body: Center(child: CircularProgressIndicator()),
);
}
return Scaffold(
appBar: AppBar(title: const Text('Create Alarm')),
body: Padding(
padding: const EdgeInsets.all(16.0),
child: FutureBuilder(
future: _calculateSmartDifficulty(_category),
builder: (context, snapshot) {
final predicted = snapshot.data ?? _difficulty;
return Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
ElevatedButton(
onPressed: _pickTime,
child: Text(_selectedTime == null ? 'Pick Alarm Time' : 'Time: ${_selectedTime!.format(context)}'),
),
const SizedBox(height: 20),
DropdownButtonFormField(
value: _category,
items: _categories.entries
.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
.toList(),
onChanged: (val) => setState(() => _category = val!),
decoration: const InputDecoration(labelText: 'Category'),
),
const SizedBox(height: 10),
FutureBuilder(
future: _recommendBestCategory(),
builder: (context, snap) {
if (snap.connectionState == ConnectionState.done && snap.hasData && _categories.containsKey(snap.data)) {
return Text(
'Recommended Category: ${_categories[snap.data]!}',
style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
);
}
return const SizedBox.shrink();
},
),
const SizedBox(height: 20),
DropdownButtonFormField(
value: _sound,
items: _sounds.entries
.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
.toList(),
onChanged: (val) => setState(() => _sound = val!),
decoration: const InputDecoration(labelText: 'Alarm Sound'),
),
const SizedBox(height: 10),
Text('Predicted Difficulty: $predicted', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
const SizedBox(height: 20),
SizedBox(
width: double.infinity,
child: ElevatedButton(
onPressed: _saveAlarm,
child: const Text('Save Alarm (Smart Difficulty)'),
),
),
],
);
},
),
),
);
}
}

