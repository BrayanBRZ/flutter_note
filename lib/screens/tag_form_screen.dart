import 'package:flutter/material.dart';
import 'package:meu_app/data/enums/regularity.dart';
import 'package:meu_app/data/models/reminder.dart';
import 'package:meu_app/data/models/tag.dart';
import 'package:meu_app/services/tag_service.dart';
import 'package:meu_app/shared/widgets/reminder_fields.dart';
import 'package:meu_app/shared/widgets/bottom_nav.dart';
import 'package:meu_app/shared/widgets/form_surface.dart';
import 'package:meu_app/shared/widgets/action_button.dart';
import 'package:meu_app/shared/widgets/app_scaffold.dart';
import 'package:meu_app/shared/widgets/top_bar.dart';
import 'package:meu_app/shared/widgets/tag_indicator.dart';

class TagFormScreen extends StatefulWidget {
  const TagFormScreen({super.key, this.tagService});
  final TagService? tagService;

  @override
  State<TagFormScreen> createState() => _TagFormScreenState();
}

class _TagFormScreenState extends State<TagFormScreen> {
  late final _tagService = widget.tagService ?? TagService();
  final _titleController = TextEditingController();
  final _colors = const [
    Colors.white,
    Colors.red,
    Colors.orange,
    Colors.green,
    Colors.blue,
    Colors.purple,
  ];

  Tag? _tag;
  Color _selectedColor = Colors.white;
  bool _reminderActive = true;
  Regularity _reminderRegularity = Regularity.single;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 12, minute: 0);
  int _remindBeforeMinutes = 30;
  bool _initialized = false;
  late Future<void> _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;

    _tag = ModalRoute.of(context)!.settings.arguments as Tag?;
    final tag = _tag;
    if (tag != null) {
      _titleController.text = tag.title;
      _selectedColor = tag.color;
    }
    _future = _loadReminder();
    _initialized = true;
  }

  Future<void> _loadReminder() async {
    final tag = _tag;
    if (tag == null) return;
    final reminder = await _tagService.findReminder(tag);
    if (reminder == null) return;
    _reminderActive = reminder.isActive;
    _reminderRegularity = reminder.regularity;
    _reminderTime = TimeOfDay(
      hour: reminder.regularTime.hour,
      minute: reminder.regularTime.minute,
    );
    _remindBeforeMinutes = reminder.remindBefore.inMinutes;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickReminderTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );
    if (picked != null) setState(() => _reminderTime = picked);
  }

  Future<void> _submit() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Informe o nome da tag.')));
      return;
    }

    final currentTag = _tag;
    final tag = Tag(
      id: currentTag?.id,
      title: _titleController.text,
      color: _selectedColor,
      reminderId: currentTag?.reminderId,
      isDefault: currentTag?.isDefault ?? false,
    );

    try {
      if (currentTag == null) {
        await _tagService.create(tag, _buildReminder());
      } else {
        await _tagService.update(tag, _buildReminder());
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível salvar a tag.')),
      );
    }
  }

  Reminder _buildReminder() {
    return Reminder(
      regularity: _reminderRegularity,
      regularTime: DateTime(
        1970,
        1,
        1,
        _reminderTime.hour,
        _reminderTime.minute,
      ),
      remindBefore: Duration(minutes: _remindBeforeMinutes),
      isActive: _reminderActive,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: SafeArea(
        child: Column(
          children: [
            TopBar(
              screenName: _tag == null ? 'Criar Tag' : 'Editar Tag',
              showBackButton: true,
            ),
            Expanded(
              child: FutureBuilder<void>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: FilledButton(
                        onPressed: () => setState(() {
                          _future = _loadReminder();
                        }),
                        child: const Text('Tentar carregar novamente'),
                      ),
                    );
                  }
                  return _buildForm();
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNav(currentIndex: null),
    );
  }

  Widget _buildForm() => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FormSection(
          title: 'Identidade da tag',
          subtitle: 'Escolha como ela aparece na sua agenda.',
          icon: Icons.label_outline_rounded,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FormTextField(
                label: 'Nome',
                hint: 'Ex.: Seminário',
                controller: _titleController,
              ),
              const SizedBox(height: 16),
              const FieldLabel('Cor na agenda'),
              const SizedBox(height: 8),
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth >= 328 ? 6 : 3;
                  final slotWidth =
                      (constraints.maxWidth - 8 * (columns - 1)) / columns;
                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _colors.map((color) {
                      final selected =
                          color.toARGB32() == _selectedColor.toARGB32();
                      return SizedBox(
                        width: slotWidth,
                        child: Center(
                          child: Semantics(
                            selected: selected,
                            label:
                                'Cor da tag: ${['Branco', 'Vermelho', 'Laranja', 'Verde', 'Azul', 'Roxo'][_colors.indexOf(color)]}',
                            child: IconButton(
                              onPressed: () =>
                                  setState(() => _selectedColor = color),
                              style: IconButton.styleFrom(
                                minimumSize: const Size(48, 48),
                                shape: const CircleBorder(),
                                backgroundColor: selected
                                    ? Theme.of(
                                        context,
                                      ).colorScheme.primaryContainer
                                    : Colors.transparent,
                                side: BorderSide(
                                  color: selected
                                      ? Theme.of(context).colorScheme.onSurface
                                      : Colors.transparent,
                                  width: 1.5,
                                ),
                              ),
                              icon: Stack(
                                alignment: Alignment.center,
                                children: [
                                  TagIndicator(color: color, size: 24),
                                  if (selected)
                                    Icon(
                                      Icons.check_rounded,
                                      size: 16,
                                      color: color.computeLuminance() > .5
                                          ? Colors.black
                                          : Colors.white,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 16),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _titleController,
                builder: (context, value, _) => Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest.withValues(alpha: .3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                  child: Row(
                    children: [
                      TagIndicator(color: _selectedColor, size: 16),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          value.text.trim().isEmpty
                              ? 'Sua tag'
                              : value.text.trim(),
                          style: Theme.of(context).textTheme.bodyMedium!
                              .copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Prévia',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        FormSection(
          title: 'Lembrete da tag',
          subtitle: 'Ajustes usados pelas atividades com esta tag.',
          icon: Icons.notifications_none_rounded,
          child: ReminderFields(
            active: _reminderActive,
            regularity: _reminderRegularity,
            time: _reminderTime,
            beforeMinutes: _remindBeforeMinutes,
            onActiveChanged: (value) => setState(() => _reminderActive = value),
            onRegularityChanged: (value) {
              if (value != null) setState(() => _reminderRegularity = value);
            },
            onTimeTap: _pickReminderTime,
            onBeforeChanged: (value) {
              if (value != null) setState(() => _remindBeforeMinutes = value);
            },
          ),
        ),
        const SizedBox(height: 24),
        ActionButton(
          label: 'Salvar tag',
          icon: Icons.check_rounded,
          onPressed: _submit,
        ),
      ],
    ),
  );
}
