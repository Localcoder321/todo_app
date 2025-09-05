import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/src/core/constants.dart';
import 'package:todo_app/src/feature/calendar/data/models/event_model.dart';

class EventsLocalDatasource {
  EventsLocalDatasource._();
  static final instance = EventsLocalDatasource._();
  Database? _db;

  Future<void> init() async {
    if (_db != null) return;
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, 'calendar_events.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, ver) async {
        await db.execute('''
          CREATE TABLE events (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT NOT NULL,
            title TEXT NOT NULL,
            subtitle TEXT,
            note TEXT,
            priority INTEGER NOT NULL,
            start_time TEXT,
            end_time TEXT
          );''');
        await db.execute(
          'CREATE INDEX IF NOT EXISTS ids_events_date ON events(date);',
        );
      },
    );
  }

  Database get db => _db!;

  Future<int> insert(EventModel e) async =>
      await db.insert('events', e.toMap());
  Future<int> update(EventModel e) async =>
      await db.update('events', e.toMap(), where: 'id=?', whereArgs: [e.id]);
  Future<int> delete(int id) async =>
      await db.delete('events', where: 'id=?', whereArgs: [id]);
  Future<List<EventModel>> eventsOn(DateTime date) async {
    final ymd = formatYmd(date);
    final rows = await db.query(
      'events',
      where: 'date=?',
      whereArgs: [ymd],
      orderBy: 'priority DESC, id DESC',
    );
    return rows.map((r) => EventModel.fromMap(r)).toList();
  }

  Future<Map<String, int>> eventCountsForMonth(int year, int month) async {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 0);
    final rows = await db.rawQuery(
      '''
      SELECT date, COUNT(*) as c FROM events
      WHERE date BETWEEN ? AND ?
      GROUP BY date
    ''',
      [formatYmd(start), formatYmd(end)],
    );
    return {for (final r in rows) (r['date'] as String): (r['c'] as int)};
  }

  Future<List<EventModel>> eventsInRange(DateTime from, DateTime to) async {
    final rows = await db.query(
      'events',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [formatYmd(from), formatYmd(to)],
      orderBy: 'date ASC, priority DESC',
    );
    return rows.map((r) => EventModel.fromMap(r)).toList();
  }
}
