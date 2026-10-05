import 'package:flutter/material.dart';
import 'package:meu_app/data/enums/regularity.dart';
import 'package:meu_app/data/models/subject.dart';
import 'package:meu_app/data/models/tag.dart';
import 'package:meu_app/shared/formatters.dart';
import 'package:meu_app/shared/widgets/action_button.dart';
import 'package:meu_app/shared/widgets/form_surface.dart';
import 'package:meu_app/shared/widgets/tag_indicator.dart';

class TaskForm extends StatelessWidget {
  const TaskForm({
    super.key,
    required this.titleController,
    required this.descriptionController,
    required this.date,
    required this.regularity,
    required this.tags,
    required this.subjects,
    required this.tagId,
    required this.subjectId,
    required this.onDateTap,
    required this.onRegularityChanged,
    required this.onTagChanged,
    required this.onSubjectChanged,
    required this.customReminder,
    required this.onCustomReminderChanged,
    required this.reminderFields,
    required this.saveLabel,
    required this.onSave,
  });
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final DateTime date;
  final Regularity regularity;
  final List<Tag> tags;
  final List<Subject> subjects;
  final int? tagId;
  final int? subjectId;
  final VoidCallback onDateTap;
  final ValueChanged<Regularity?> onRegularityChanged;
  final ValueChanged<int?> onTagChanged;
  final ValueChanged<int?> onSubjectChanged;
  final bool customReminder;
  final ValueChanged<bool> onCustomReminderChanged;
  final Widget reminderFields;
  final String saveLabel;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FormSection(
          title: 'Atividade',
          icon: Icons.edit_note_rounded,
          subtitle: 'O que você precisa fazer?',
          child: Column(
            children: [
              FormTextField(
                label: 'Título',
                hint: 'Ex.: Prova de matemática',
                controller: titleController,
              ),
              const SizedBox(height: 12),
              FormTextField(
                label: 'Descrição · opcional',
                hint: 'Detalhes, materiais ou orientações',
                controller: descriptionController,
                maxLines: 3,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        FormSection(
          title: 'Prazo e frequência',
          icon: Icons.event_outlined,
          child: Column(
            children: [
              PickerField(
                caption: 'Data',
                label: formatDate(date),
                icon: Icons.calendar_month_outlined,
                onTap: onDateTap,
              ),
              const SizedBox(height: 12),
              FormSelect<Regularity>(
                label: 'Regularidade',
                value: regularity,
                items: [
                  for (final value in Regularity.values)
                    DropdownMenuItem(
                      value: value,
                      child: Text(regularityLabel(value)),
                    ),
                ],
                onChanged: onRegularityChanged,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        FormSection(
          title: 'Organização',
          icon: Icons.label_outline_rounded,
          child: Column(
            children: [
              FormSelect<int>(
                label: 'Tag',
                value: tags.any((tag) => tag.id == tagId) ? tagId : null,
                items: [
                  for (final tag in tags)
                    DropdownMenuItem(
                      value: tag.id,
                      child: Row(
                        children: [
                          TagIndicator(color: tag.color, size: 12),
                          const SizedBox(width: 8),
                          Expanded(child: Text(tag.title)),
                        ],
                      ),
                    ),
                ],
                onChanged: onTagChanged,
              ),
              const SizedBox(height: 12),
              FormSelect<int?>(
                label: 'Matéria · opcional',
                value: subjectId,
                items: [
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text('Sem matéria'),
                  ),
                  for (final subject in subjects)
                    DropdownMenuItem<int?>(
                      value: subject.id,
                      child: Text(subject.title),
                    ),
                ],
                onChanged: onSubjectChanged,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        FormSection(
          title: 'Lembrete',
          icon: Icons.notifications_none_rounded,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FormToggle(
                label: 'Lembrete personalizado',
                subtitle: customReminder
                    ? 'Defina os ajustes desta atividade.'
                    : 'Usando os ajustes da tag selecionada.',
                value: customReminder,
                onChanged: onCustomReminderChanged,
              ),
              if (customReminder) ...[
                const Divider(height: 24),
                reminderFields,
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),
        ActionButton(
          label: saveLabel,
          icon: Icons.check_rounded,
          onPressed: onSave,
        ),
      ],
    ),
  );
}
