import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'alarm_model.dart';
import 'alarm_log_model.dart';

class DBService {
  static final DBService _instance = DBService._();
  static Database? _db;

  DBService._();

  factory DBService() => _instance;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'alarms.db');

    return openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE alarms (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        time TEXT,
        category TEXT,
        difficulty TEXT,
        is_enabled INTEGER,
        sound TEXT,
        created_at TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE alarm_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        alarm_id INTEGER,
        trigger_time TEXT,
        dismissed_time TEXT,
        attempts INTEGER,
        timed_out INTEGER,
        snooze_count INTEGER,
        duration_seconds INTEGER
      );
    ''');
  }

  Future<int> insertAlarm(Alarm alarm) async {
    final db = await database;
    return await db.insert('alarms', alarm.toMap());
  }

  Future<void> updateAlarm(Alarm alarm) async {
    final db = await database;
    await db.update('alarms', alarm.toMap(), where: 'id = ?', whereArgs: [alarm.id]);
  }

  Future<void> deleteAlarm(int id) async {
    final db = await database;
    await db.delete('alarms', where: 'id = ?', whereArgs: [id]);
  }

// In dbservice.dart
Future<List<Alarm>> getAlarms() async {
  final db = await database;
  final result = await db.query('alarms');
  return result.map((map) => Alarm.fromMap(map)).toList();
}

// Add this missing method
Future<List<AlarmLog>> getAllLogs() async {
  final db = await database;
  final result = await db.query('alarm_logs');
  return result.map((map) => AlarmLog.fromMap(map)).toList();
}
}