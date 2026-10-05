import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:meu_app/data/database/local_backup_store.dart';
import 'package:meu_app/data/models/backup_snapshot.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'backup_fixture.dart';

void main() {
  late Database database;
  late LocalBackupStore local;

  setUp(() async {
    database = await createBackupDatabase();
    local = LocalBackupStore(database);
  });
  tearDown(() async => database.close());

  test(
    'restore replaces every table, relationships and next-ID counters',
    () async {
      await database.insert('subject', {'title': 'Somente local'});
      await database.insert('task', {
        'title': 'Apagar esta atividade',
        'regularity': 'single',
        'target_date': '2026-10-07T10:00:00.000',
        'tag_id': 1,
      });
      final backup = sampleSnapshot();
      await local.restore(backup);
      final restored = await local.capture();
      expect(restored.tables, backup.tables);
      expect(restored.sequences, backup.sequences);
      expect(await database.rawQuery('PRAGMA foreign_key_check'), isEmpty);
      final nextId = await database.insert('task', {
        'title': 'Nova atividade',
        'regularity': 'single',
        'target_date': '2026-10-10T10:00:00.000',
        'tag_id': 4,
      });
      expect(nextId, 43);
    },
  );

  test('constraint failure rolls back all deletions and ID counters', () async {
    await local.restore(sampleSnapshot());
    final before = await local.capture();
    final invalid = jsonDecode(before.encode()) as Map<String, dynamic>;
    invalid['tables']['task'][0]['subject_id'] = 999;
    final corrupt = BackupSnapshot.fromMap(invalid);
    await expectLater(
      local.restore(corrupt),
      throwsA(isA<DatabaseException>()),
    );
    final after = await local.capture();
    expect(after.tables, before.tables);
    expect(after.sequences, before.sequences);
  });

  test(
    'restoring an agenda without activities removes existing activities',
    () async {
      await local.restore(sampleSnapshot());
      final empty =
          jsonDecode(sampleSnapshot().encode()) as Map<String, dynamic>;
      empty['tables']['task'] = [];
      await local.restore(BackupSnapshot.fromMap(empty));
      expect(await database.query('task'), isEmpty);
      expect((await database.query('tag')).single['id'], 4);
    },
  );

  test(
    'snapshot rejects incompatible versions, missing tables and invalid dates',
    () {
      final source =
          jsonDecode(sampleSnapshot().encode()) as Map<String, dynamic>;
      source['version'] = 2;
      expect(() => BackupSnapshot.fromMap(source), throwsFormatException);
      source['version'] = 1;
      source['tables'].remove('reminder');
      expect(() => BackupSnapshot.fromMap(source), throwsFormatException);
      final invalidDate =
          jsonDecode(sampleSnapshot().encode()) as Map<String, dynamic>;
      invalidDate['tables']['task'][0]['target_date'] = 'invalid';
      expect(() => BackupSnapshot.fromMap(invalidDate), throwsFormatException);
    },
  );
}
