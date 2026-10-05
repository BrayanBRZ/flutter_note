import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:meu_app/data/models/backup_snapshot.dart';
import 'package:meu_app/services/firestore_backup_store.dart';

import 'backup_fixture.dart';

void main() {
  FirestoreBackupStore store(
    Future<http.Response> Function(http.Request) handler,
  ) => FirestoreBackupStore(
    projectId: 'agenda-test',
    userId: 'test-user',
    idToken: () async => 'test-token',
    clientFactory: () => MockClient(handler),
  );

  test('push replaces the same document, including removed records', () async {
    Map<String, dynamic>? document;
    final remote = store((request) async {
      expect(request.headers['Authorization'], 'Bearer test-token');
      expect(
        request.url.path,
        '/v1/projects/agenda-test/databases/(default)/documents/users/test-user/backups/current',
      );
      expect(request.url.queryParameters, isEmpty); // no updateMask or merge
      if (request.method == 'PATCH') {
        document = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response(jsonEncode(document), 200);
      }
      return document == null
          ? http.Response('{}', 404)
          : http.Response(jsonEncode(document), 200);
    });
    expect(await remote.load(), isNull);
    await remote.save(sampleSnapshot());
    expect((await remote.load())!.taskCount, 1);
    final empty = jsonDecode(sampleSnapshot().encode()) as Map<String, dynamic>;
    empty['tables']['task'] = [];
    await remote.save(BackupSnapshot.fromMap(empty));
    expect((await remote.load())!.taskCount, 0);
    expect(document!['fields'].keys, unorderedEquals(['snapshot', 'savedAt']));
  });

  test(
    'invalid remote snapshot and denied access never produce restore data',
    () async {
      final corrupt = store(
        (_) async =>
            http.Response('{"fields":{"snapshot":{"stringValue":"{}"}}}', 200),
      );
      await expectLater(corrupt.load(), throwsA(isA<BackupException>()));
      final denied = store((_) async => http.Response('{}', 403));
      await expectLater(denied.load(), throwsA(isA<BackupException>()));
    },
  );

  test('offline requests fail without queuing any write', () async {
    var requests = 0;
    final remote = store((_) async {
      requests++;
      throw http.ClientException('offline');
    });
    await expectLater(
      remote.save(sampleSnapshot()),
      throwsA(isA<BackupException>()),
    );
    expect(requests, 1);
  });

  test('oversized snapshots are rejected before sending to Firebase', () async {
    var requested = false;
    final remote = store((_) async {
      requested = true;
      return http.Response('{}', 200);
    });
    await expectLater(
      remote.save(
        sampleSnapshot(
          description: 'á' * FirestoreBackupStore.maxSnapshotBytes,
        ),
      ),
      throwsA(isA<BackupException>()),
    );
    expect(requested, isFalse);
  });
}
