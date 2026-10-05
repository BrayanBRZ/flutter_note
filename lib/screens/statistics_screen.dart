import 'package:flutter/material.dart';
import 'package:meu_app/data/models/task.dart';
import 'package:meu_app/services/task_service.dart';
import 'package:meu_app/shared/widgets/app_scaffold.dart';
import 'package:meu_app/shared/widgets/bottom_nav.dart';
import 'package:meu_app/shared/widgets/floating_card.dart';
import 'package:meu_app/shared/widgets/top_bar.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key, this.taskService});
  final TaskService? taskService;
  @override
  State<StatisticsScreen> createState() => StatisticsScreenState();
}

class StatisticsScreenState extends State<StatisticsScreen> {
  late final _service = widget.taskService ?? TaskService();
  late Future<List<Task>> _future;
  @override
  void initState() {
    super.initState();
    _future = _service.findAll();
  }

  @override
  Widget build(BuildContext context) => AppScaffold(
    body: SafeArea(
      child: Column(
        children: [
          const TopBar(
            screenName: 'Estatísticas',
            showBackButton: true,
            backTooltip: 'Voltar às Configurações',
          ),
          Expanded(
            child: FutureBuilder<List<Task>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: FilledButton(
                      onPressed: () => setState(() {
                        _future = _service.findAll();
                      }),
                      child: const Text('Tentar carregar novamente'),
                    ),
                  );
                }
                final tasks = snapshot.data!;
                final today = DateUtils.dateOnly(DateTime.now());
                final lateTasks = tasks
                    .where((task) => task.normalizedDate.isBefore(today))
                    .length;
                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  children: [
                    Text(
                      'Sua rotina em números',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    _statCard(
                      context,
                      'Total de atividades',
                      tasks.length,
                      Icons.assignment_outlined,
                    ),
                    const SizedBox(height: 16),
                    _statCard(
                      context,
                      'Futuras',
                      tasks.length - lateTasks,
                      Icons.event_outlined,
                    ),
                    const SizedBox(height: 16),
                    _statCard(
                      context,
                      'Atrasadas',
                      lateTasks,
                      Icons.warning_amber_rounded,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    ),
    bottomNavigationBar: const BottomNav(currentIndex: 3),
  );

  Widget _statCard(
    BuildContext context,
    String label,
    int value,
    IconData icon,
  ) => FloatingCard(
    padding: const EdgeInsets.all(20),
    child: Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.onSurface),
        const SizedBox(width: 16),
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.titleMedium),
        ),
        const SizedBox(width: 8),
        Text('$value', style: Theme.of(context).textTheme.headlineMedium),
      ],
    ),
  );
}
