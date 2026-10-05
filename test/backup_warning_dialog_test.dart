import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meu_app/shared/widgets/backup_warning_dialog.dart';

void main() {
  for (final restore in [false, true]) {
    testWidgets(
      '${restore ? 'pull' : 'push'} requires explicit confirmation and allows cancellation',
      (tester) async {
        bool? confirmed;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => TextButton(
                  onPressed: () async {
                    confirmed = await confirmBackupReplacement(
                      context,
                      restore: restore,
                    );
                  },
                  child: const Text('Abrir'),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Abrir'));
        await tester.pumpAndSettle();
        expect(find.byType(AlertDialog), findsOneWidget);
        expect(confirmed, isNull);
        await tester.tapAt(const Offset(5, 5));
        await tester.pumpAndSettle();
        expect(find.byType(AlertDialog), findsOneWidget);
        await tester.tap(find.text('Cancelar'));
        await tester.pumpAndSettle();
        expect(confirmed, isFalse);
        await tester.tap(find.text('Abrir'));
        await tester.pumpAndSettle();
        await tester.tap(
          find.text(restore ? 'Substituir dados locais' : 'Substituir backup'),
        );
        await tester.pumpAndSettle();
        expect(confirmed, isTrue);
      },
    );
  }
}
