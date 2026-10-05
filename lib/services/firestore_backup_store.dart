import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:meu_app/data/models/backup_snapshot.dart';

class BackupException implements Exception {
  const BackupException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Direct server requests: no cached restores or deferred offline uploads.
class FirestoreBackupStore {
  FirestoreBackupStore({
    required this.projectId,
    required this.userId,
    required this.idToken,
    http.Client Function()? clientFactory,
  }) : clientFactory = clientFactory ?? http.Client.new;

  final String projectId;
  final String userId;
  final Future<String?> Function() idToken;
  final http.Client Function() clientFactory;
  static const maxSnapshotBytes = 900 * 1024;

  Uri get _uri => Uri.https(
    'firestore.googleapis.com',
    '/v1/projects/$projectId/databases/(default)/documents/users/$userId/backups/current',
  );

  Future<void> save(BackupSnapshot snapshot) async {
    final encoded = snapshot.encode();
    // Leave room for document metadata below Firestore's 1 MiB limit.
    if (utf8.encode(encoded).length > maxSnapshotBytes) {
      throw const BackupException(
        'A agenda ultrapassou o limite desta versão de backup (900 KiB).',
      );
    }
    await _request(
      'PATCH',
      body: jsonEncode({
        'fields': {
          'snapshot': {'stringValue': encoded},
          'savedAt': {
            'timestampValue': snapshot.savedAt.toUtc().toIso8601String(),
          },
        },
      }),
    );
  }

  Future<BackupSnapshot?> load() async {
    final response = await _request('GET', allowMissing: true);
    if (response.statusCode == 404) return null;
    try {
      final document = jsonDecode(response.body) as Map<String, dynamic>;
      final value = document['fields']['snapshot']['stringValue'] as String;
      return BackupSnapshot.decode(value);
    } catch (_) {
      throw const BackupException(
        'O backup na nuvem é inválido ou incompatível. Os dados locais foram mantidos.',
      );
    }
  }

  Future<http.Response> _request(
    String method, {
    String? body,
    bool allowMissing = false,
  }) async {
    final client = clientFactory();
    try {
      final token = await idToken().timeout(const Duration(seconds: 20));
      if (token == null) {
        throw const BackupException('Entre na sua conta novamente.');
      }
      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=utf-8',
      };
      final response =
          await (method == 'PATCH'
                  ? client.patch(_uri, headers: headers, body: body)
                  : client.get(_uri, headers: headers))
              .timeout(const Duration(seconds: 30));
      if (response.statusCode >= 200 && response.statusCode < 300 ||
          allowMissing && response.statusCode == 404) {
        return response;
      }
      throw BackupException(switch (response.statusCode) {
        401 => 'Sua sessão expirou. Entre na conta novamente.',
        403 =>
          'A conta não tem acesso ao backup. Verifique as regras do Firebase.',
        429 => 'O serviço atingiu seu limite. Tente novamente mais tarde.',
        _ => 'O Firebase não concluiu a operação. Tente novamente.',
      });
    } on TimeoutException {
      throw BackupException(
        method == 'PATCH'
            ? 'Não foi possível confirmar o envio. Verifique sua conexão e consulte o backup antes de tentar novamente.'
            : 'A consulta demorou demais. Verifique sua conexão e tente novamente.',
      );
    } on http.ClientException {
      throw const BackupException(
        'Não foi possível acessar a nuvem. Verifique sua conexão e tente novamente.',
      );
    } finally {
      client.close();
    }
  }
}
