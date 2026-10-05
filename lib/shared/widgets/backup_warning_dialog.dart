import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meu_app/data/models/backup_snapshot.dart';

Future<bool> confirmBackupReplacement(
  BuildContext context, {
  required bool restore,
  BackupSnapshot? snapshot,
}) async =>
    await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.warning_amber_rounded,
          color: Theme.of(context).colorScheme.error,
        ),
        title: Text(
          restore
              ? 'Substituir a agenda deste aparelho?'
              : 'Substituir o backup na nuvem?',
        ),
        content: SingleChildScrollView(
          child: Text(
            restore
                ? 'Todas as atividades, matérias, tags e lembretes deste aparelho serão apagados e substituídos pelo backup${snapshot == null ? '' : ' de ${DateFormat('dd/MM/yyyy HH:mm').format(snapshot.savedAt.toLocal())}'}.'
                      '\n\nAlterações locais que não estão nesse backup serão perdidas. Esta ação não pode ser desfeita.'
                : 'A agenda atual deste aparelho substituirá completamente o backup desta conta, incluindo atividades, matérias, tags e lembretes.'
                      '\n\nItens removidos localmente também sairão do backup. A cópia anterior não será mantida.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              restore ? 'Substituir dados locais' : 'Substituir backup',
            ),
          ),
        ],
      ),
    ) ??
    false;
