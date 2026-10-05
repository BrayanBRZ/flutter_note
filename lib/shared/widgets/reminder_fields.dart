import 'package:flutter/material.dart';
import 'package:meu_app/data/enums/regularity.dart';
import 'package:meu_app/shared/formatters.dart';
import 'package:meu_app/shared/widgets/form_surface.dart';

class ReminderFields extends StatelessWidget {
  const ReminderFields({
    super.key,
    required this.active,
    required this.regularity,
    required this.time,
    required this.beforeMinutes,
    required this.onActiveChanged,
    required this.onRegularityChanged,
    required this.onTimeTap,
    required this.onBeforeChanged,
  });
  final bool active;
  final Regularity regularity;
  final TimeOfDay time;
  final int beforeMinutes;
  final ValueChanged<bool> onActiveChanged;
  final ValueChanged<Regularity?> onRegularityChanged;
  final VoidCallback onTimeTap;
  final ValueChanged<int?> onBeforeChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      FormToggle(label: 'Ativo', value: active, onChanged: onActiveChanged),
      const SizedBox(height: 12),
      FormSelect<Regularity>(
        label: 'Frequência do lembrete',
        value: regularity,
        items: [
          for (final value in Regularity.values)
            DropdownMenuItem(value: value, child: Text(regularityLabel(value))),
        ],
        onChanged: onRegularityChanged,
      ),
      const SizedBox(height: 12),
      PickerField(
        caption: 'Horário',
        label: time.format(context),
        icon: Icons.schedule_rounded,
        onTap: onTimeTap,
      ),
      const SizedBox(height: 12),
      FormSelect<int>(
        label: 'Antecedência',
        value: beforeMinutes,
        items: const [
          DropdownMenuItem(value: 10, child: Text('10 min antes')),
          DropdownMenuItem(value: 30, child: Text('30 min antes')),
          DropdownMenuItem(value: 60, child: Text('1 hora antes')),
          DropdownMenuItem(value: 1440, child: Text('1 dia antes')),
        ],
        onChanged: onBeforeChanged,
      ),
    ],
  );
}
