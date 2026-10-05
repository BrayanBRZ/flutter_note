import 'package:flutter/material.dart';
import 'package:meu_app/data/models/tag.dart';
import 'package:meu_app/data/models/task.dart';
import 'package:meu_app/services/tag_service.dart';
import 'package:meu_app/services/task_service.dart';
import 'package:meu_app/shared/formatters.dart';
import 'package:meu_app/shared/widgets/action_button.dart';
import 'package:meu_app/shared/widgets/app_scaffold.dart';
import 'package:meu_app/shared/widgets/bottom_nav.dart';
import 'package:meu_app/shared/widgets/floating_card.dart';
import 'package:meu_app/shared/widgets/tag_indicator.dart';
import 'package:meu_app/shared/widgets/top_bar.dart';

class TaskDetailScreen extends StatefulWidget {
  const TaskDetailScreen({super.key, this.tagService, this.taskService});
  final TagService? tagService;
  final TaskService? taskService;
  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late final _tagService = widget.tagService ?? TagService();
  late final _taskService = widget.taskService ?? TaskService();
  late Task _task;
  late Future<Tag?> _tagFuture;
  bool _initialized = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _task = ModalRoute.of(context)!.settings.arguments as Task;
    _tagFuture = _tagService.findById(_task.tagId);
    _initialized = true;
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir atividade'),
        content: const Text('Deseja excluir esta atividade?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Excluir',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _taskService.delete(_task);
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível excluir a atividade.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final days = _task.normalizedDate
        .difference(DateUtils.dateOnly(DateTime.now()))
        .inDays;
    final label = days < 0
        ? 'Vencida há ${days.abs()} dia${days.abs() == 1 ? '' : 's'}'
        : days == 0
        ? 'Vence hoje'
        : '$days dia${days == 1 ? '' : 's'} restante${days == 1 ? '' : 's'}';
    return AppScaffold(
      body: SafeArea(
        child: Column(
          children: [
            const TopBar(screenName: 'Detalhes', showBackButton: true),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FloatingCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FutureBuilder<Tag?>(
                            future: _tagFuture,
                            builder: (context, snapshot) =>
                                snapshot.data == null
                                ? const SizedBox.shrink()
                                : Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: Row(
                                      children: [
                                        TagIndicator(
                                          color: snapshot.data!.color,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            snapshot.data!.title,
                                            style: theme.textTheme.bodySmall,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                          ),
                          Text(
                            _task.title,
                            style: theme.textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 24),
                          Text('Descrição', style: theme.textTheme.titleMedium),
                          const SizedBox(height: 8),
                          Text(
                            _task.hasDescription
                                ? _task.description!
                                : 'Sem descrição.',
                          ),
                          const SizedBox(height: 24),
                          _InfoRow(
                            icon: Icons.calendar_month_outlined,
                            label: formatDate(_task.targetDate),
                          ),
                          const SizedBox(height: 12),
                          _InfoRow(
                            icon: Icons.repeat_rounded,
                            label: regularityLabel(_task.regularity),
                          ),
                          if (_task.reminderId != null) ...[
                            const SizedBox(height: 12),
                            const _InfoRow(
                              icon: Icons.notifications_active_outlined,
                              label: 'Lembrete personalizado',
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    FloatingCard(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Icon(
                            days < 0
                                ? Icons.warning_amber_rounded
                                : Icons.schedule,
                            color: days < 0
                                ? theme.colorScheme.error
                                : theme.colorScheme.onSurface,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              label,
                              style: theme.textTheme.titleMedium!.copyWith(
                                color: days < 0
                                    ? theme.colorScheme.error
                                    : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    ActionButton(
                      label: 'Editar atividade',
                      icon: Icons.edit_outlined,
                      onPressed: () => Navigator.pushNamed(
                        context,
                        '/task/edit',
                        arguments: _task,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ActionButton(
                      label: 'Excluir atividade',
                      icon: Icons.delete_outline,
                      onPressed: _delete,
                      outlined: true,
                      destructive: true,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNav(currentIndex: null),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label});
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 20),
      const SizedBox(width: 8),
      Expanded(child: Text(label)),
    ],
  );
}
