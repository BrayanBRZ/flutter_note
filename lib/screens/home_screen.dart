import 'package:flutter/material.dart';
import 'package:meu_app/data/models/tag.dart';
import 'package:meu_app/data/models/task.dart';
import 'package:meu_app/services/tag_service.dart';
import 'package:meu_app/services/task_service.dart';
import 'package:meu_app/shared/appearance.dart';
import 'package:meu_app/shared/calendar_viewport.dart';
import 'package:meu_app/shared/widgets/app_scaffold.dart';
import 'package:meu_app/shared/widgets/bottom_nav.dart';
import 'package:meu_app/shared/widgets/calendar.dart';
import 'package:meu_app/shared/widgets/task_card.dart';
import 'package:meu_app/shared/widgets/top_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.taskService, this.tagService, this.now});
  final TaskService? taskService;
  final TagService? tagService;
  final DateTime Function()? now;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final _taskService = widget.taskService ?? TaskService();
  late final _tagService = widget.tagService ?? TagService();
  late Future<_TaskData> _future;
  late DateTime _selectedDay;
  late DateTime _focusedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = (widget.now ?? DateTime.now)();
    _focusedDay = _selectedDay;
    _future = _loadData();
  }

  Future<_TaskData> _loadData() async {
    final tasks = await _taskService.findAll();
    final tags = await _tagService.findAll();
    return _TaskData(tasks, {for (final tag in tags) tag.id!: tag});
  }

  void _today() => setState(() {
    _selectedDay = (widget.now ?? DateTime.now)();
    _focusedDay = _selectedDay;
  });

  @override
  Widget build(BuildContext context) {
    final appearance = AppearanceScope.of(context);
    final viewport = CalendarViewport.forPage(_focusedDay, appearance.period);
    return AppScaffold(
      body: SafeArea(
        child: Column(
          children: [
            const TopBar(screenName: 'Minha agenda'),
            Expanded(
              child: FutureBuilder<_TaskData>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Não foi possível carregar as atividades.',
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            FilledButton(
                              onPressed: () => setState(() {
                                _future = _loadData();
                              }),
                              child: const Text('Tentar novamente'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  final data = snapshot.data!;
                  final tasks = viewport.tasksFrom(data.tasks);
                  return RefreshIndicator(
                    onRefresh: () async {
                      final next = _loadData();
                      setState(() {
                        _future = next;
                      });
                      await next;
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Calendar(
                            tasks: data.tasks,
                            tagsById: data.tagsById,
                            period: appearance.period,
                            focusedDay: _focusedDay,
                            selectedDay: _selectedDay,
                            onDaySelected: (day) =>
                                setState(() => _selectedDay = day),
                            onPageChanged: (day) =>
                                setState(() => _focusedDay = day),
                            onPeriodChanged: (period) => reportPreferenceSave(
                              context,
                              appearance.setPeriod(period),
                            ),
                            onToday: _today,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Atividades do período',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${tasks.length} atividade${tasks.length == 1 ? '' : 's'} na sua agenda',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 16),
                          GroupedAgenda(
                            tasks: tasks,
                            tagsById: data.tagsById,
                            selectedDay: _selectedDay,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 0),
    );
  }
}

class _TaskData {
  const _TaskData(this.tasks, this.tagsById);
  final List<Task> tasks;
  final Map<int, Tag> tagsById;
}
