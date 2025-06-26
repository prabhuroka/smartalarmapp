import 'package:flutter/material.dart';
import 'alarm_list_screen.dart';
import 'notification_service.dart';
import 'dbservice.dart';
import 'package:workmanager/workmanager.dart';
import 'question_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    return Future.value(true);
  });
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DBService().database;
  await NotificationService.init(); // Moved after DB
  await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  runApp(const SmartAlarmApp());
}

class SmartAlarmApp extends StatelessWidget {
  const SmartAlarmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Alarm',
      navigatorKey: navigatorKey,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: const AlarmListScreen(),
      
    );
  }
}
