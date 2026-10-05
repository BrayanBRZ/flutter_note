import 'package:flutter/material.dart';
import 'package:meu_app/shared/widgets/floating_card.dart';

class BottomNav extends StatelessWidget {
  const BottomNav({super.key, required this.currentIndex});
  final int? currentIndex;
  static const _routes = ['/home', '/history', '/subject', '/setting'];
  static const _labels = ['Início', 'Atividades', 'Matérias', 'Configurações'];
  static const _icons = [
    Icons.home_rounded,
    Icons.history_rounded,
    Icons.menu_book_rounded,
    Icons.settings_rounded,
  ];

  void _navigate(BuildContext context, int index) {
    if (index != currentIndex) {
      Navigator.pushReplacementNamed(context, _routes[index]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: FloatingCard(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            children: [
              for (final index in [0, 1]) _item(context, index),
              Expanded(
                child: Center(
                  heightFactor: 1,
                  child: IconButton.filled(
                    tooltip: 'Criar atividade',
                    style: IconButton.styleFrom(
                      backgroundColor: scheme.primary,
                      foregroundColor: scheme.onPrimary,
                    ),
                    onPressed: () =>
                        Navigator.pushNamed(context, '/task/create'),
                    icon: const Icon(Icons.add_rounded, size: 28),
                  ),
                ),
              ),
              for (final index in [2, 3]) _item(context, index),
            ],
          ),
        ),
      ),
    );
  }

  Widget _item(BuildContext context, int index) {
    final scheme = Theme.of(context).colorScheme;
    final selected = currentIndex == index;
    return Expanded(
      child: Center(
        heightFactor: 1,
        child: Semantics(
          selected: selected,
          child: IconButton(
            tooltip: _labels[index],
            style: IconButton.styleFrom(
              backgroundColor: selected
                  ? scheme.primaryContainer
                  : Colors.transparent,
              foregroundColor: selected
                  ? scheme.onPrimaryContainer
                  : scheme.onSurfaceVariant,
            ),
            onPressed: () => _navigate(context, index),
            icon: Icon(_icons[index]),
          ),
        ),
      ),
    );
  }
}
