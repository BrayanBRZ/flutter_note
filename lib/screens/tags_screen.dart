import 'package:flutter/material.dart';
import 'package:meu_app/data/models/tag.dart';
import 'package:meu_app/services/tag_service.dart';
import 'package:meu_app/shared/widgets/action_button.dart';
import 'package:meu_app/shared/widgets/app_scaffold.dart';
import 'package:meu_app/shared/widgets/bottom_nav.dart';
import 'package:meu_app/shared/widgets/floating_card.dart';
import 'package:meu_app/shared/widgets/tag_indicator.dart';
import 'package:meu_app/shared/widgets/top_bar.dart';

class TagsScreen extends StatefulWidget {
  const TagsScreen({super.key, this.tagService});
  final TagService? tagService;
  @override
  State<TagsScreen> createState() => _TagsScreenState();
}

class _TagsScreenState extends State<TagsScreen> {
  late final _service = widget.tagService ?? TagService();
  late Future<List<Tag>> _future;
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

  Future<void> _delete(Tag tag) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir tag'),
        content: Text(
          'Deseja excluir "${tag.title}"? '
          'As atividades com esta tag passarão para outra tag disponível.',
        ),
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
      await _service.delete(tag);
      _reload();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error is StateError
                  ? error.message.toString()
                  : 'Não foi possível excluir a tag.',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => AppScaffold(
    body: SafeArea(
      child: Column(
        children: [
          const TopBar(
            screenName: 'Tags',
            showBackButton: true,
            backTooltip: 'Voltar às Configurações',
          ),
          Expanded(
            child: FutureBuilder<List<Tag>>(
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
                final tags = snapshot.data!;
                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  children: [
                    FloatingCard(
                      child: Column(
                        children: [
                          for (final tag in tags)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  TagIndicator(color: tag.color, size: 20),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          tag.title,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.titleMedium,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          tag.isDefault
                                              ? 'Padrão'
                                              : 'Personalizada',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: 'Editar ${tag.title}',
                                    onPressed: () async {
                                      await Navigator.pushNamed(
                                        context,
                                        '/tags/form',
                                        arguments: tag,
                                      );
                                      _reload();
                                    },
                                    icon: const Icon(
                                      Icons.edit_outlined,
                                      size: 20,
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: 'Excluir ${tag.title}',
                                    onPressed: () => _delete(tag),
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (tags.isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(24),
                              child: Text('Nenhuma tag cadastrada.'),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ActionButton(
                      label: 'Adicionar tag',
                      icon: Icons.add_rounded,
                      onPressed: () async {
                        await Navigator.pushNamed(context, '/tags/form');
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
    bottomNavigationBar: const BottomNav(currentIndex: 3),
  );
}
