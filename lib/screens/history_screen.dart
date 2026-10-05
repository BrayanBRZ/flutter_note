import 'package:flutter/material.dart';
import 'package:meu_app/data/models/tag.dart';
import 'package:meu_app/data/models/task.dart';
import 'package:meu_app/services/tag_service.dart';
import 'package:meu_app/services/task_service.dart';
import 'package:meu_app/shared/widgets/app_scaffold.dart';
import 'package:meu_app/shared/widgets/bottom_nav.dart';
import 'package:meu_app/shared/widgets/task_card.dart';
import 'package:meu_app/shared/widgets/top_bar.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<(List<Task>, Map<int, Tag>)> _future;
  bool _overdue = false;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<(List<Task>, Map<int, Tag>)> _load() async {
    final tasks = await TaskService().findAll();
    final tags = await TagService().findAll();
    return (tasks, {for (final tag in tags) tag.id!: tag});
  }

  @override
  Widget build(BuildContext context) => AppScaffold(
    body: SafeArea(
      child: Column(
        children: [
          const TopBar(screenName: 'Atividades'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SegmentedButton<bool>(
              expandedInsets: EdgeInsets.zero,
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: false, label: Text('Futuras')),
                ButtonSegment(value: true, label: Text('Atrasadas')),
              ],
              selected: {_overdue},
              onSelectionChanged: (values) =>
                  setState(() => _overdue = values.single),
            ),
          ),
          Expanded(
            child: FutureBuilder<(List<Task>, Map<int, Tag>)>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: FilledButton(
                      onPressed: () => setState(() {
                        _future = _load();
                      }),
                      child: const Text('Tentar carregar novamente'),
                    ),
                  );
                }
                final (all, tags) = snapshot.data!;
                final today = DateUtils.dateOnly(DateTime.now());
                final tasks =
                    all
                        .where(
                          (task) =>
                              task.normalizedDate.isBefore(today) == _overdue,
                        )
                        .toList()
                      ..sort(
                        (a, b) => _overdue
                            ? b.normalizedDate.compareTo(a.normalizedDate)
                            : a.normalizedDate.compareTo(b.normalizedDate),
                      );
                return TaskCard(tasks: tasks, tagsById: tags);
              },
            ),
          ),
        ],
      ),
    ),
    bottomNavigationBar: const BottomNav(currentIndex: 1),
  );
}
