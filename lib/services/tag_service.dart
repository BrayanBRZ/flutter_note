import 'package:meu_app/data/dao/reminder_dao.dart';
import 'package:meu_app/data/dao/tag_dao.dart';
import 'package:meu_app/data/database/connection.dart';
import 'package:meu_app/data/models/reminder.dart';
import 'package:meu_app/data/models/tag.dart';
import 'package:sqflite/sqflite.dart';

class TagService {
  TagService({Database? database}) : _database = database;

  final Database? _database;
  Future<Database> get _connection async =>
      _database ?? await Connection.instance.database;

  Future<List<Tag>> findAll() async {
    final database = await _connection;
    return TagDao(database).findAll();
  }

  Future<Tag?> findById(int id) async {
    final database = await _connection;
    return TagDao(database).findById(id);
  }

  Future<Reminder?> findReminder(Tag tag) async {
    final database = await _connection;
    final reminderId = tag.reminderId;
    if (reminderId == null) return null;
    return ReminderDao(database).findById(reminderId);
  }

  Future<int> create(Tag tag, Reminder reminder) async {
    final database = await _connection;
    final reminderDao = ReminderDao(database);
    final tagDao = TagDao(database);

    final reminderId = await reminderDao.insert(reminder);
    try {
      return await tagDao.insert(_tagWithReminder(tag, reminderId));
    } catch (_) {
      await reminderDao.delete(reminderId);
      rethrow;
    }
  }

  Future<void> update(Tag tag, Reminder reminder) async {
    final database = await _connection;
    final reminderId = tag.reminderId;
    if (reminderId == null) {
      throw ArgumentError.value(tag, 'tag', 'reminderId is required');
    }

    await database.transaction((transaction) async {
      await TagDao(transaction).update(tag);
      await ReminderDao(
        transaction,
      ).update(_reminderWithId(reminder, reminderId));
    });
  }

  Future<void> delete(Tag tag) async {
    final database = await _connection;
    await database.transaction(
      (transaction) => TagDao(transaction).delete(tag.id!),
    );
  }

  Tag _tagWithReminder(Tag tag, int reminderId) {
    return Tag(
      id: tag.id,
      title: tag.title,
      color: tag.color,
      reminderId: reminderId,
      isDefault: tag.isDefault,
    );
  }

  Reminder _reminderWithId(Reminder reminder, int id) {
    return Reminder(
      id: id,
      regularity: reminder.regularity,
      regularTime: reminder.regularTime,
      remindBefore: reminder.remindBefore,
      isActive: reminder.isActive,
    );
  }
}
