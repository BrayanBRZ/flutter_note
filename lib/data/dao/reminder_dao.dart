import 'package:meu_app/data/models/reminder.dart';
import 'package:sqflite/sqflite.dart';

class ReminderDao {
  ReminderDao(this._database);

  final DatabaseExecutor _database;

  static const String _table = 'reminder';

  Future<int> insert(Reminder reminder) async {
    return _database.insert(_table, reminder.toMap()..remove('id'));
  }

  Future<void> update(Reminder reminder) async {
    final id = reminder.id;
    if (id == null) {
      throw ArgumentError.value(reminder, 'reminder', 'id is required');
    }

    await _database.update(
      _table,
      reminder.toMap()..remove('id'),
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> delete(int id) async {
    await _database.delete(_table, where: 'id = ?', whereArgs: [id]);
  }

  Future<Reminder?> findById(int id) async {
    final result = await _database.query(
      _table,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) return null;

    return Reminder.fromMap(result.first);
  }

  Future<Reminder?> findByTagId(int tagId) async {
    final result = await _database.rawQuery(
      '''
        SELECT reminder.*
        FROM reminder
        INNER JOIN tag ON tag.reminder_id = reminder.id
        WHERE tag.id = ?
        LIMIT 1
      ''',
      [tagId],
    );

    if (result.isEmpty) return null;

    return Reminder.fromMap(result.first);
  }

  Future<List<Reminder>> findAll() async {
    final result = await _database.query(_table, orderBy: 'id');
    return result.map(Reminder.fromMap).toList();
  }
}
