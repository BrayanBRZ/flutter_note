import 'dart:convert';

import 'package:meu_app/data/enums/regularity.dart';

/// A complete agenda, including IDs and SQLite's next-ID counters.
class BackupSnapshot {
  BackupSnapshot._(this.savedAt, this.tables, this.sequences);

  static const version = 1;
  static const tableNames = ['reminder', 'subject', 'tag', 'task'];
  final DateTime savedAt;
  final Map<String, List<Map<String, Object?>>> tables;
  final List<Map<String, Object?>> sequences;

  int get taskCount => tables['task']!.length;
  int get subjectCount => tables['subject']!.length;
  int get tagCount => tables['tag']!.length;

  Map<String, Object?> toMap() => {
    'version': version,
    'savedAt': savedAt.toUtc().toIso8601String(),
    'tables': tables,
    'sequences': sequences,
  };

  String encode() => jsonEncode(toMap());

  factory BackupSnapshot.decode(String value) =>
      BackupSnapshot.fromMap(jsonDecode(value));

  factory BackupSnapshot.fromMap(Object? value) {
    const invalid = FormatException('O backup é inválido ou incompatível.');
    if (value is! Map || value['version'] != version) throw invalid;
    final date = value['savedAt'];
    final savedAt = date is String ? DateTime.tryParse(date) : null;
    final source = value['tables'];
    if (savedAt == null || source is! Map) throw invalid;

    final tables = <String, List<Map<String, Object?>>>{};
    for (final name in tableNames) {
      final rows = source[name];
      if (rows is! List) throw invalid;
      final ids = <int>{};
      tables[name] = rows
          .map((row) {
            if (row is! Map || row.keys.any((key) => key is! String)) {
              throw invalid;
            }
            final record = Map<String, Object?>.from(row);
            final fields = switch (name) {
              'reminder' => {
                'id': int,
                'regularity': String,
                'regular_time': String,
                'remind_before': int,
                'is_active': int,
              },
              'subject' => {'id': int, 'title': String},
              'tag' => {
                'id': int,
                'title': String,
                'color': int,
                'reminder_id': int,
                'is_default': int,
              },
              _ => {
                'id': int,
                'title': String,
                'regularity': String,
                'target_date': String,
                'tag_id': int,
                'subject_id': int,
                'reminder_id': int,
                'description': String,
              },
            };
            const nullable = {'subject_id', 'reminder_id', 'description'};
            if (record.length != fields.length) throw invalid;
            for (final entry in fields.entries) {
              if (!record.containsKey(entry.key)) throw invalid;
              final cell = record[entry.key];
              if (name == 'task' &&
                  nullable.contains(entry.key) &&
                  cell == null) {
                continue;
              }
              if ((entry.value == int && cell is! int) ||
                  (entry.value == String && cell is! String)) {
                throw invalid;
              }
            }
            final id = record['id'] as int;
            if (id <= 0 || !ids.add(id)) throw invalid;
            if (record.containsKey('title') &&
                (record['title'] as String).trim().isEmpty) {
              throw invalid;
            }
            if (record.containsKey('regularity') &&
                !Regularity.values.any((r) => r.name == record['regularity'])) {
              throw invalid;
            }
            for (final field in ['regular_time', 'target_date']) {
              if (record.containsKey(field) &&
                  DateTime.tryParse(record[field] as String) == null) {
                throw invalid;
              }
            }
            for (final field in ['is_active', 'is_default']) {
              if (record.containsKey(field) &&
                  record[field] != 0 &&
                  record[field] != 1) {
                throw invalid;
              }
            }
            if (name == 'reminder' && (record['remind_before'] as int) < 0) {
              throw invalid;
            }
            return Map<String, Object?>.unmodifiable(record);
          })
          .toList(growable: false);
    }
    if (tables['tag']!.isEmpty) throw invalid;

    final rawSequences = value['sequences'];
    if (rawSequences is! List) throw invalid;
    final sequenceNames = <String>{};
    final sequences = rawSequences
        .map((row) {
          if (row is! Map ||
              row.length != 2 ||
              !tableNames.contains(row['name']) ||
              row['seq'] is! int ||
              (row['seq'] as int) < 0 ||
              !sequenceNames.add(row['name'] as String)) {
            throw invalid;
          }
          final name = row['name'] as String;
          final seq = row['seq'] as int;
          if (tables[name]!.any((r) => (r['id'] as int) > seq)) throw invalid;
          return Map<String, Object?>.unmodifiable({'name': name, 'seq': seq});
        })
        .toList(growable: false);
    for (final name in tableNames) {
      if (tables[name]!.isNotEmpty && !sequenceNames.contains(name)) {
        throw invalid;
      }
    }
    return BackupSnapshot._(
      savedAt,
      Map.unmodifiable({
        for (final entry in tables.entries)
          entry.key: List<Map<String, Object?>>.unmodifiable(entry.value),
      }),
      List.unmodifiable(sequences),
    );
  }
}
