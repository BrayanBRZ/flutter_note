import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meu_app/data/models/backup_snapshot.dart';
import 'package:meu_app/screens/backup_screen.dart';
import 'package:meu_app/services/backup_service.dart';
import 'package:meu_app/shared/app_theme.dart';
import 'package:meu_app/shared/appearance.dart';

import 'backup_fixture.dart';

class TestUser extends Fake implements User {
  @override
  String get email => 'aluno@example.com';
}

class TestBackupService extends BackupService {
  int uploads = 0;
  BackupSnapshot? restored;
  final snapshot = sampleSnapshot();

  @override
  User get user => TestUser();
  @override
  Future<void> initialize() async {}
  @override
  Future<BackupSnapshot?> fetch() async => snapshot;
  @override
  Future<BackupSnapshot> push() async {
    uploads++;
    return snapshot;
  }

  @override
  Future<void> restore(BackupSnapshot snapshot) async {
    restored = snapshot;
  }
}

void main() {
  Future<void> open(WidgetTester tester, TestBackupService service) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(AppPalette.standard, Brightness.light),
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => BackupScreen(backupService: service),
                ),
              ),
              child: const Text('Abrir backup'),
            ),
          ),
        ),
        routes: {
          '/setting': (_) =>
              const Scaffold(body: Text('Configurações restauradas')),
        },
      ),
    );
    await tester.tap(find.text('Abrir backup'));
    await tester.pumpAndSettle();
  }

  testWidgets('canceling upload never calls the backup service', (
    tester,
  ) async {
    final service = TestBackupService();
    await open(tester, service);
    expect(find.byTooltip('Voltar'), findsOneWidget);
    await tester.ensureVisible(find.text('Salvar backup na nuvem'));
    await tester.tap(find.text('Salvar backup na nuvem'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    expect(service.uploads, 0);
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(service.uploads, 0);
    await tester.tap(find.text('Salvar backup na nuvem'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    await tester.tap(find.text('Substituir backup'));
    await tester.pumpAndSettle();
    expect(service.uploads, 1);
    expect(service.restored, isNull);
  });

  testWidgets(
    'pull only restores after confirmation and removes stale routes',
    (tester) async {
      final service = TestBackupService();
      await open(tester, service);
      await tester.ensureVisible(find.text('Restaurar backup da nuvem'));
      await tester.tap(find.text('Restaurar backup da nuvem'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      expect(service.restored, isNull);
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      expect(service.restored, isNull);
      await tester.tap(find.text('Restaurar backup da nuvem'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      await tester.tap(find.text('Substituir dados locais'));
      await tester.pumpAndSettle();
      expect(service.restored, same(service.snapshot));
      expect(find.text('Configurações restauradas'), findsOneWidget);
      expect(find.byType(BackupScreen), findsNothing);
      final context = tester.element(find.text('Configurações restauradas'));
      expect(Navigator.canPop(context), isFalse);
    },
  );
}
