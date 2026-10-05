import 'package:meu_app/data/constants/default_tags.dart';
import 'package:meu_app/data/models/tag.dart';
import 'package:sqflite/sqflite.dart';

class TagDao {
  TagDao(this._database);

  final DatabaseExecutor _database;

  static const String _table = 'tag';

  Future<int> insert(Tag tag) async {
    if (tag.reminderId == null) {
      throw ArgumentError.value(tag, 'tag', 'reminderId is required');
    }

    final values = tag.toMap()
      ..remove('id')
      ..['is_default'] = 0;

    return _database.insert(_table, values);
  }

  Future<void> delete(int id) async {
    final tag = await findById(id);
    if (tag == null) return;
    final remaining = await _database.query(
      _table,
      columns: ['id'],
      where: 'id != ?',
      whereArgs: [id],
      orderBy:
          'CASE WHEN id = ${DefaultTags.commonId} THEN 0 ELSE 1 END, is_default DESC, id',
      limit: 1,
    );
    if (remaining.isEmpty) {
      throw StateError('Mantenha ao menos uma tag para suas atividades.');
    }
    // Reassign before deleting: the database's fixed default may be this tag.
    await _database.update(
      'task',
      {'tag_id': remaining.first['id']},
      where: 'tag_id = ?',
      whereArgs: [id],
    );

    await _database.delete(_table, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> update(Tag tag) async {
    final id = tag.id;
    if (id == null) {
      throw ArgumentError.value(tag, 'tag', 'id is required');
    }

    final currentTag = await findById(id);
    if (currentTag == null) return;

    final values = tag.toMap()
      ..remove('id')
      ..remove('reminder_id')
      ..['is_default'] = currentTag.isDefault ? 1 : 0;

    await _database.update(_table, values, where: 'id = ?', whereArgs: [id]);
  }

  Future<Tag?> findById(int id) async {
    final result = await _database.query(
      _table,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) return null;

    return Tag.fromMap(result.first);
  }

  Future<List<Tag>> findAll() async {
    final result = await _database.query(
      _table,
      orderBy: 'is_default DESC, title COLLATE NOCASE',
    );
    return result.map(Tag.fromMap).toList();
  }
}
