import 'package:flutter/material.dart';
import 'package:meu_app/shared/appearance.dart';
import 'package:meu_app/shared/widgets/app_scaffold.dart';
import 'package:meu_app/shared/widgets/bottom_nav.dart';
import 'package:meu_app/shared/widgets/floating_card.dart';
import 'package:meu_app/shared/widgets/top_bar.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appearance = AppearanceScope.of(context);
    final vertical = MediaQuery.textScalerOf(context).scale(1) > 1.3;
    return AppScaffold(
      body: SafeArea(
        child: Column(
          children: [
            const TopBar(screenName: 'Configurações'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Sua aparência',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Escolha o visual que combina com a sua rotina.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 16),
                    FloatingCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Paleta',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          SegmentedButton<AppPalette>(
                            direction: vertical
                                ? Axis.vertical
                                : Axis.horizontal,
                            expandedInsets: vertical ? null : EdgeInsets.zero,
                            showSelectedIcon: false,
                            segments: const [
                              ButtonSegment(
                                value: AppPalette.standard,
                                label: Text('Padrão'),
                              ),
                              ButtonSegment(
                                value: AppPalette.monochrome,
                                label: Text('Monocromática'),
                              ),
                            ],
                            selected: {appearance.palette},
                            onSelectionChanged: (values) =>
                                reportPreferenceSave(
                                  context,
                                  appearance.setPalette(values.single),
                                ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Aparência',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          SegmentedButton<Brightness>(
                            direction: vertical
                                ? Axis.vertical
                                : Axis.horizontal,
                            expandedInsets: vertical ? null : EdgeInsets.zero,
                            showSelectedIcon: false,
                            segments: const [
                              ButtonSegment(
                                value: Brightness.light,
                                icon: Icon(Icons.light_mode_outlined),
                                label: Text('Claro'),
                              ),
                              ButtonSegment(
                                value: Brightness.dark,
                                icon: Icon(Icons.dark_mode_outlined),
                                label: Text('Escuro'),
                              ),
                            ],
                            selected: {appearance.brightness},
                            onSelectionChanged: (values) =>
                                reportPreferenceSave(
                                  context,
                                  appearance.setBrightness(values.single),
                                ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'As cores das tags e dos avisos são preservadas nas duas paletas. Suas escolhas são lembradas neste dispositivo.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Organização',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    FloatingCard(
                      child: Column(
                        children: [
                          _Tile(
                            icon: Icons.label_outline,
                            label: 'Tags',
                            subtitle: 'Gerencie tags e seus lembretes',
                            onTap: () => Navigator.pushNamed(context, '/tags'),
                          ),
                          const Divider(indent: 16, endIndent: 16),
                          _Tile(
                            icon: Icons.cloud_sync_outlined,
                            label: 'Backup',
                            subtitle: 'Salve ou restaure sua agenda na nuvem',
                            onTap: () =>
                                Navigator.pushNamed(context, '/backup'),
                          ),
                          const Divider(indent: 16, endIndent: 16),
                          _Tile(
                            icon: Icons.bar_chart_rounded,
                            label: 'Estatísticas',
                            subtitle: 'Resumo das suas atividades',
                            onTap: () =>
                                Navigator.pushNamed(context, '/statistics'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 3),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    leading: Icon(icon, color: Theme.of(context).colorScheme.onSurface),
    title: Text(label, style: Theme.of(context).textTheme.titleMedium),
    subtitle: Text(subtitle),
    trailing: const Icon(Icons.chevron_right),
    onTap: onTap,
  );
}
