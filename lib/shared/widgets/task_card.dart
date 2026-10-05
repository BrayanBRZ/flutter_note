import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meu_app/data/models/tag.dart';
import 'package:meu_app/data/models/task.dart';
import 'package:meu_app/shared/widgets/floating_card.dart';
import 'package:meu_app/shared/widgets/tag_indicator.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({super.key, required this.tasks, this.tagsById = const {}});
  final List<Task> tasks;
  final Map<int, Tag> tagsById;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
    child: FloatingCard(
      child: tasks.isEmpty
          ? const EmptyAgenda(message: 'Nenhuma atividade nesta lista')
          : ListView.separated(
              padding: const EdgeInsets.all(8),
              itemCount: tasks.length,
              separatorBuilder: (_, _) =>
                  const Divider(indent: 16, endIndent: 16),
              itemBuilder: (context, index) => TaskTile(
                task: tasks[index],
                tag: tagsById[tasks[index].tagId],
                showDate: true,
              ),
            ),
    ),
  );
}

class GroupedAgenda extends StatelessWidget {
  const GroupedAgenda({
    super.key,
    required this.tasks,
    required this.selectedDay,
    this.tagsById = const {},
  });
  final List<Task> tasks;
  final DateTime selectedDay;
  final Map<int, Tag> tagsById;

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return const FloatingCard(
        child: EmptyAgenda(message: 'Nenhuma atividade neste período'),
      );
    }
    final grouped = <DateTime, List<Task>>{};
    for (final task in tasks) {
      grouped.putIfAbsent(task.normalizedDate, () => []).add(task);
    }
    final dates = grouped.keys.toList()..sort();
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        for (final day in dates)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: FloatingCard(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    key: ValueKey(
                      'agenda-day-${DateFormat('yyyy-MM-dd').format(day)}',
                    ),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: DateUtils.isSameDay(day, selectedDay)
                          ? scheme.primaryContainer
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                      border: DateUtils.isSameDay(day, selectedDay)
                          ? Border.all(color: scheme.outline)
                          : null,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Semantics(
                          header: true,
                          selected: DateUtils.isSameDay(day, selectedDay),
                          child: Text(
                            DateFormat(
                              "EEEE, d 'de' MMMM",
                              'pt_BR',
                            ).format(day),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${grouped[day]!.length} atividade${grouped[day]!.length == 1 ? '' : 's'}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  for (final task in grouped[day]!)
                    TaskTile(task: task, tag: tagsById[task.tagId]),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class TaskTile extends StatelessWidget {
  const TaskTile({
    super.key,
    required this.task,
    this.tag,
    this.showDate = false,
  });
  final Task task;
  final Tag? tag;
  final bool showDate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = DateUtils.dateOnly(DateTime.now());
    final daysLeft = task.normalizedDate.difference(today).inDays;
    final label = daysLeft < 0
        ? 'Vencida há ${daysLeft.abs()} dia${daysLeft.abs() == 1 ? '' : 's'}'
        : daysLeft == 0
        ? 'Vence hoje'
        : '$daysLeft dia${daysLeft == 1 ? '' : 's'} restante${daysLeft == 1 ? '' : 's'}';
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () =>
            Navigator.pushNamed(context, '/task/detail', arguments: task),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.assignment_outlined,
                  color: theme.colorScheme.onSurface,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(task.title, style: theme.textTheme.titleMedium),
                    if (tag != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          TagIndicator(color: tag!.color),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              tag!.title,
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          daysLeft < 0
                              ? Icons.warning_amber_rounded
                              : Icons.schedule,
                          size: 16,
                          color: daysLeft < 0
                              ? theme.colorScheme.error
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${showDate ? '${task.formattedDate} · ' : ''}$label',
                            style: theme.textTheme.bodySmall!.copyWith(
                              color: daysLeft < 0
                                  ? theme.colorScheme.error
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EmptyAgenda extends StatelessWidget {
  const EmptyAgenda({super.key, required this.message});
  final String message;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.event_available_outlined,
          size: 32,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(height: 12),
        Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        Text(
          'Use o botão + para adicionar uma atividade.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    ),
  );
}
