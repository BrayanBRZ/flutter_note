import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meu_app/data/models/backup_snapshot.dart';
import 'package:meu_app/services/backup_service.dart';
import 'package:meu_app/services/firestore_backup_store.dart';
import 'package:meu_app/shared/widgets/app_scaffold.dart';
import 'package:meu_app/shared/widgets/backup_warning_dialog.dart';
import 'package:meu_app/shared/widgets/floating_card.dart';
import 'package:meu_app/shared/widgets/top_bar.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key, this.backupService});

  final BackupService? backupService;

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  late final _service = widget.backupService ?? BackupService();
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _ready = false;
  bool _busy = true;
  bool _register = false;
  bool _checkedBackup = false;
  String? _setupError;
  BackupSnapshot? _backup;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    setState(() {
      _busy = true;
      _setupError = null;
    });
    try {
      await _service.initialize();
      _ready = true;
      if (_service.user != null) {
        _backup = await _service.fetch();
        _checkedBackup = true;
      }
    } catch (error) {
      debugPrint('Não foi possível inicializar o backup: $error');
      if (!_ready) {
        _setupError =
            'O backup na nuvem ainda não está configurado ou disponível. Sua agenda local continua funcionando.';
      } else {
        _notify(_message(error));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _notify(String text) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
    }
  }

  String _message(Object error) {
    if (error is BackupException) return error.message;
    if (error is FirebaseAuthException) {
      return switch (error.code) {
        'invalid-email' => 'Informe um e-mail válido.',
        'weak-password' => 'Use uma senha com pelo menos 6 caracteres.',
        'email-already-in-use' =>
          'Este e-mail já possui uma conta. Use Entrar.',
        'invalid-credential' ||
        'wrong-password' ||
        'user-not-found' => 'E-mail ou senha incorretos.',
        'network-request-failed' => 'Verifique sua conexão e tente novamente.',
        'too-many-requests' => 'Muitas tentativas. Aguarde e tente novamente.',
        'operation-not-allowed' =>
          'O acesso por e-mail e senha precisa ser habilitado no Firebase.',
        _ => 'Não foi possível acessar sua conta. Tente novamente.',
      };
    }
    return 'Não foi possível concluir a operação. Os dados locais foram mantidos.';
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
    } catch (error) {
      _notify(_message(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _authenticate() async {
    if (!_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    await _run(() async {
      await _service.authenticate(
        _email.text,
        _password.text,
        register: _register,
      );
      _password.clear();
      if (mounted) setState(() {});
      _backup = await _service.fetch();
      _checkedBackup = true;
    });
  }

  Future<void> _push() => _run(() async {
    final confirmed = await confirmBackupReplacement(context, restore: false);
    if (!confirmed || !mounted) return;
    _backup = await _service.push();
    _checkedBackup = true;
    _notify('Backup salvo. A nuvem contém o retrato atual da sua agenda.');
  });

  Future<void> _pull() => _run(() async {
    // Fetch before confirmation, and restore exactly the reviewed snapshot.
    final snapshot = await _service.fetch();
    _backup = snapshot;
    _checkedBackup = true;
    if (snapshot == null) {
      _notify(
        'Esta conta ainda não possui um backup. Os dados locais foram mantidos.',
      );
      return;
    }
    if (!mounted) return;
    final confirmed = await confirmBackupReplacement(
      context,
      restore: true,
      snapshot: snapshot,
    );
    if (!confirmed || !mounted) return;
    await _service.restore(snapshot);
    if (!mounted) return;
    // Remove screens that might still hold pre-restore tasks in memory.
    Navigator.pushNamedAndRemoveUntil(context, '/setting', (_) => false);
    _notify('Agenda restaurada com sucesso.');
  });

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_busy,
    child: AppScaffold(
      body: SafeArea(
        child: Column(
          children: [
            const TopBar(screenName: 'Backup', showBackButton: true),
            if (_busy) const LinearProgressIndicator(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Sua agenda na nuvem',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Salve ou recupere atividades, matérias, tags e lembretes. O backup é manual e mantém uma única cópia por conta.',
                    ),
                    const SizedBox(height: 16),
                    if (_setupError != null)
                      FloatingCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text(_setupError!),
                            const SizedBox(height: 12),
                            OutlinedButton(
                              onPressed: _busy ? null : _initialize,
                              child: const Text('Tentar novamente'),
                            ),
                          ],
                        ),
                      )
                    else if (_ready && _service.user == null)
                      _accountForm(context)
                    else if (_ready)
                      _backupActions(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _accountForm(BuildContext context) => FloatingCard(
    padding: const EdgeInsets.all(16),
    child: Form(
      key: _form,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _register ? 'Criar conta' : 'Entrar na conta',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          const Text(
            'Use a mesma conta para recuperar sua agenda em outro aparelho. Entrar ou sair da conta mantém a agenda deste aparelho.',
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _email,
            enabled: !_busy,
            decoration: const InputDecoration(labelText: 'E-mail'),
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            validator: (value) =>
                value == null ||
                    !RegExp(
                      r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                    ).hasMatch(value.trim())
                ? 'Informe um e-mail válido.'
                : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _password,
            enabled: !_busy,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Senha'),
            autofillHints: [
              _register ? AutofillHints.newPassword : AutofillHints.password,
            ],
            validator: (value) => value == null || value.length < 6
                ? 'Use pelo menos 6 caracteres.'
                : null,
            onFieldSubmitted: (_) {
              if (!_busy) _authenticate();
            },
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _busy ? null : _authenticate,
            child: Text(_register ? 'Criar conta' : 'Entrar'),
          ),
          TextButton(
            onPressed: _busy
                ? null
                : () => setState(() => _register = !_register),
            child: Text(_register ? 'Já tenho conta' : 'Criar uma conta'),
          ),
        ],
      ),
    ),
  );

  Widget _backupActions(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      FloatingCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _service.user!.email ?? 'Conta conectada',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Text(
              _backup != null
                  ? 'Último backup: ${DateFormat('dd/MM/yyyy HH:mm').format(_backup!.savedAt.toLocal())}\n${_backup!.taskCount} atividades · ${_backup!.subjectCount} matérias · ${_backup!.tagCount} tags'
                  : _checkedBackup
                  ? 'Esta conta ainda não possui backup.'
                  : 'O backup ainda não foi consultado.',
            ),
            TextButton.icon(
              onPressed: _busy
                  ? null
                  : () => _run(() async {
                      _backup = await _service.fetch();
                      _checkedBackup = true;
                    }),
              icon: const Icon(Icons.refresh),
              label: const Text('Consultar backup'),
            ),
            const Divider(),
            const Text(
              'Trocar de conta mantém a agenda local. Ao salvar, ela será enviada à conta conectada.',
            ),
            TextButton(
              onPressed: _busy
                  ? null
                  : () => _run(() async {
                      await _service.signOut();
                      _backup = null;
                      _checkedBackup = false;
                    }),
              child: const Text('Sair da conta'),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      FilledButton.icon(
        onPressed: _busy ? null : _push,
        icon: const Icon(Icons.cloud_upload_outlined),
        label: const Text('Salvar backup na nuvem'),
      ),
      const SizedBox(height: 8),
      OutlinedButton.icon(
        onPressed: _busy ? null : _pull,
        icon: const Icon(Icons.cloud_download_outlined),
        label: const Text('Restaurar backup da nuvem'),
      ),
      const SizedBox(height: 12),
      const Text(
        'As duas ações precisam de internet. Mudanças feitas depois do último backup ficam apenas neste aparelho até você salvar novamente.',
      ),
    ],
  );
}
