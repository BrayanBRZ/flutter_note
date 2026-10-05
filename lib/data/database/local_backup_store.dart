import 'package:meu_app/data/models/backup_snapshot.dart';
import 'package:sqflite/sqflite.dart';

class LocalBackupStore {
  LocalBackupStore(this.database);

  final Database database;

  Future<BackupSnapshot> capture() => database.transaction((txn) async {
    final tables = <String, Object?>{};
    for (final name in BackupSnapshot.tableNames) {
      tables[name] = await txn.query(name, orderBy: 'id');
    }
    return BackupSnapshot.fromMap({
      'version': BackupSnapshot.version,
      'savedAt': DateTime.now().toUtc().toIso8601String(),
      'tables': tables,
      'sequences': await txn.query('sqlite_sequence', orderBy: 'name'),
    });
  });

  Future<void> restore(BackupSnapshot snapshot) async {
    // Parse again before touching the database; reject unsupported snapshots.
    final validated = BackupSnapshot.fromMap(snapshot.toMap());
    await database.transaction((txn) async {
      // Delete children first, including the tag-reminder deletion trigger.
      for (final name in ['task', 'tag', 'subject', 'reminder']) {
        await txn.delete(name);
      }
      // Insert parents first and preserve all relationships and original IDs.
      for (final name in BackupSnapshot.tableNames) {
        for (final row in validated.tables[name]!) {
          await txn.insert(name, row);
        }
      }
      await txn.delete('sqlite_sequence');
      for (final row in validated.sequences) {
        await txn.insert('sqlite_sequence', row);
      }
      if ((await txn.rawQuery('PRAGMA foreign_key_check')).isNotEmpty) {
        throw const FormatException('O backup contém vínculos inválidos.');
      }
      // Any constraint/insert failure rolls back every deletion and insertion.
    });
  }
}
