import 'package:meu_app/data/database/schema.dart';
import 'package:meu_app/data/database/seeders.dart';
import 'package:meu_app/data/models/backup_snapshot.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<Database> createBackupDatabase() async {
  sqfliteFfiInit();
  return databaseFactoryFfi.openDatabase(
    inMemoryDatabasePath,
    options: OpenDatabaseOptions(
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
      version: 1,
      onCreate: (db, _) async {
        for (final sql in [
          ...Schema.createTables,
          ...Seeders.initialInserts,
          ...Schema.createTriggers,
        ]) {
          await db.execute(sql);
        }
      },
    ),
  );
}

BackupSnapshot sampleSnapshot({String description = 'Revisar capítulo 3'}) =>
    BackupSnapshot.fromMap({
      'version': 1,
      'savedAt': '2026-10-05T15:00:00.000Z',
      'tables': {
        'reminder': [
          {
            'id': 3,
            'regularity': 'single',
            'regular_time': '1970-01-01T12:00:00.000',
            'remind_before': 30,
            'is_active': 1,
          },
          {
            'id': 9,
            'regularity': 'weekly',
            'regular_time': '1970-01-01T08:00:00.000',
            'remind_before': 60,
            'is_active': 0,
          },
        ],
        'subject': [
          {'id': 7, 'title': 'Matemática'},
        ],
        'tag': [
          {
            'id': 4,
            'title': 'Prova',
            'color': 4280391411,
            'reminder_id': 3,
            'is_default': 0,
          },
        ],
        'task': [
          {
            'id': 12,
            'title': 'Estudar equações',
            'regularity': 'weekly',
            'target_date': '2026-10-09T14:30:00.000',
            'tag_id': 4,
            'subject_id': 7,
            'reminder_id': 9,
            'description': description,
          },
        ],
      },
      'sequences': [
        {'name': 'reminder', 'seq': 9},
        {'name': 'subject', 'seq': 7},
        {'name': 'tag', 'seq': 4},
        {'name': 'task', 'seq': 42},
      ],
    });
