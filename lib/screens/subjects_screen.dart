import 'package:flutter/material.dart';
import 'package:meu_app/data/models/subject.dart';
import 'package:meu_app/services/subject_service.dart';
import 'package:meu_app/shared/widgets/action_button.dart';
import 'package:meu_app/shared/widgets/app_scaffold.dart';
import 'package:meu_app/shared/widgets/bottom_nav.dart';
import 'package:meu_app/shared/widgets/floating_card.dart';
import 'package:meu_app/shared/widgets/top_bar.dart';

class SubjectScreen extends StatefulWidget {
  const SubjectScreen({super.key});
  @override
  State<SubjectScreen> createState() => SubjectScreenState();
}

class SubjectScreenState extends State<SubjectScreen> {
  final _service = SubjectService();
  late Future<List<Subject>> _future;
  @override
  void initState() {
    super.initState();
    _future = _service.findAll();
  }

  void _reload() {
    if (mounted) {
      setState(() {
        _future = _service.findAll();
      });
    }
  }

  Future<void> _delete(Subject subject) async {
    if (subject.id == null) return;
    try {
      await _service.delete(subject.id!);
      _reload();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível excluir a matéria.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => AppScaffold(
    body: SafeArea(
      child: Column(
        children: [
          const TopBar(screenName: 'Matérias'),
          Expanded(
            child: FutureBuilder<List<Subject>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: FilledButton(
                      onPressed: _reload,
                      child: const Text('Tentar carregar novamente'),
                    ),
                  );
                }
                final subjects = snapshot.data!;
                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  children: [
                    FloatingCard(
                      child: subjects.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.all(24),
                              child: Text(
                                'Nenhuma matéria cadastrada.',
                                textAlign: TextAlign.center,
                              ),
                            )
                          : Column(
                              children: [
                                for (final subject in subjects)
                                  ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    leading: const Icon(
                                      Icons.menu_book_outlined,
                                    ),
                                    title: Text(
                                      subject.title,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium,
                                    ),
                                    trailing: IconButton(
                                      tooltip: 'Excluir matéria',
                                      icon: const Icon(Icons.delete_outline),
                                      onPressed: () => _delete(subject),
                                    ),
                                  ),
                              ],
                            ),
                    ),
                    const SizedBox(height: 16),
                    ActionButton(
                      label: 'Adicionar matéria',
                      icon: Icons.add_rounded,
                      onPressed: () async {
                        await Navigator.pushNamed(context, '/subject/add');
                        _reload();
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    ),
    bottomNavigationBar: const BottomNav(currentIndex: 2),
  );
}
