import 'dart:convert';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:meu_app/data/database/local_backup_store.dart';
import 'package:meu_app/firebase_options.dart';
import 'package:meu_app/services/firestore_backup_store.dart';

import 'backup_fixture.dart';

// Explicit opt-in: creates disposable accounts and documents, then removes them.
// Never operates on an existing user's account or on the device's real database.
void main() {
  test(
    'live Firebase: complete snapshots, SQL restore and account isolation',
    () async {
      final options = DefaultFirebaseOptions.web;
      final client = http.Client();
      final accounts = <Map<String, dynamic>>[];
      final db = await createBackupDatabase();
      final local = LocalBackupStore(db);
      String? documentUrl;
      var testDocumentWritten = false;
      try {
        Future<Map<String, dynamic>> authCall(
          String method,
          Map<String, Object?> body,
        ) async {
          final response = await client
              .post(
                Uri.https(
                  'identitytoolkit.googleapis.com',
                  '/v1/accounts:$method',
                  {'key': options.apiKey},
                ),
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode(body),
              )
              .timeout(const Duration(seconds: 30));
          expect(
            response.statusCode,
            200,
            reason: 'Firebase Authentication $method',
          );
          return jsonDecode(response.body) as Map<String, dynamic>;
        }

        for (var i = 0; i < 2; i++) {
          final random = Random.secure();
          final suffix =
              '${DateTime.now().microsecondsSinceEpoch}-${random.nextInt(1000000)}';
          final email = 'backup-validation-$suffix@example.invalid';
          final password = base64UrlEncode(
            List.generate(24, (_) => random.nextInt(256)),
          );
          final account = await authCall('signUp', {
            'email': email,
            'password': password,
            'returnSecureToken': true,
          });
          accounts.add(account);
        }
        final owner = accounts.first;
        final remote = FirestoreBackupStore(
          projectId: options.projectId,
          userId: owner['localId'] as String,
          idToken: () async => owner['idToken'] as String,
        );
        documentUrl =
            'https://firestore.googleapis.com/v1/projects/${options.projectId}/databases/(default)/documents/users/${owner['localId']}/backups/current';
        expect(await remote.load(), isNull);

        await local.restore(sampleSnapshot());
        await remote.save(await local.capture());
        testDocumentWritten = true;
        final first = (await remote.load())!;
        expect(first.tables, sampleSnapshot().tables);

        await db.delete('task');
        final second = await local.capture();
        await remote.save(second);
        expect((await remote.load())!.taskCount, 0);

        await db.insert('subject', {
          'title': 'Somente no dispositivo de teste',
        });
        await db.insert('task', {
          'title': 'Alteração local',
          'regularity': 'single',
          'target_date': '2026-10-10T10:00:00.000',
          'tag_id': 4,
        });
        await local.restore((await remote.load())!);
        expect((await local.capture()).tables, second.tables);

        final otherUser = await client
            .get(
              Uri.parse(documentUrl),
              headers: {'Authorization': 'Bearer ${accounts.last['idToken']}'},
            )
            .timeout(const Duration(seconds: 30));
        expect(otherUser.statusCode, 403);
        final guest = await client
            .get(Uri.parse(documentUrl))
            .timeout(const Duration(seconds: 30));
        expect(guest.statusCode, 403);
      } finally {
        try {
          if (testDocumentWritten &&
              documentUrl != null &&
              accounts.isNotEmpty) {
            final deleted = await client
                .delete(
                  Uri.parse(documentUrl),
                  headers: {
                    'Authorization': 'Bearer ${accounts.first['idToken']}',
                  },
                )
                .timeout(const Duration(seconds: 30));
            expect(
              deleted.statusCode,
              200,
              reason: 'Remove only the disposable test backup',
            );
          }
        } finally {
          for (final account in accounts) {
            final deleted = await client
                .post(
                  Uri.https(
                    'identitytoolkit.googleapis.com',
                    '/v1/accounts:delete',
                    {'key': options.apiKey},
                  ),
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode({'idToken': account['idToken']}),
                )
                .timeout(const Duration(seconds: 30));
            expect(
              deleted.statusCode,
              200,
              reason: 'Remove only the disposable test account',
            );
          }
          await db.close();
          client.close();
        }
      }
    },
    skip: !const bool.fromEnvironment('RUN_FIREBASE_LIVE_TEST'),
    timeout: const Timeout(Duration(minutes: 3)),
  );
}
