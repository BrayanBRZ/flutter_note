import 'package:flutter/material.dart';
import 'package:meu_app/shared/widgets/floating_card.dart';

/// Opaque form surfaces keep fields readable without stacking blur filters.
class FormSurface extends StatefulWidget {
  const FormSurface({
    super.key,
    required this.child,
    this.padding,
    this.height,
  });
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? height;

  @override
  State<FormSurface> createState() => _FormSurfaceState();
}

class _FormSurfaceState extends State<FormSurface> {
  bool _focused = false;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Focus(
      canRequestFocus: false,
      onFocusChange: (value) => setState(() => _focused = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: double.infinity,
        constraints: BoxConstraints(minHeight: widget.height ?? 64),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest.withValues(alpha: .32),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _focused
                ? scheme.primary
                : scheme.outlineVariant.withValues(alpha: .6),
            width: _focused ? 1.5 : 1,
          ),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: Padding(
            padding: widget.padding ?? EdgeInsets.zero,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

class PickerField extends StatelessWidget {
  const PickerField({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.caption,
  });
  final String label;
  final String? caption;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => FormSurface(
    child: InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (caption != null) ...[
                    FieldLabel(caption!),
                    const SizedBox(height: 4),
                  ],
                  Text(label, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              icon,
              size: 20,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    ),
  );
}

class FormSection extends StatelessWidget {
  const FormSection({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
    this.subtitle,
  });
  final String title;
  final IconData icon;
  final String? subtitle;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FloatingCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(title, style: theme.textTheme.titleMedium),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(subtitle!, style: theme.textTheme.bodySmall),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class FieldLabel extends StatelessWidget {
  const FieldLabel(this.label, {super.key});
  final String label;
  @override
  Widget build(BuildContext context) => Text(
    label,
    style: Theme.of(
      context,
    ).textTheme.bodySmall!.copyWith(fontWeight: FontWeight.w600),
  );
}

class FormTextField extends StatefulWidget {
  const FormTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.maxLines = 1,
  });
  final String label;
  final String hint;
  final TextEditingController controller;
  final int maxLines;
  @override
  State<FormTextField> createState() => _FormTextFieldState();
}

class _FormTextFieldState extends State<FormTextField> {
  final _focusNode = FocusNode();
  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: _focusNode.requestFocus,
    child: FormSurface(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FieldLabel(widget.label),
          const SizedBox(height: 4),
          Semantics(
            label: widget.label,
            child: TextField(
              focusNode: _focusNode,
              controller: widget.controller,
              maxLines: widget.maxLines,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: widget.maxLines == 1
                  ? TextInputAction.next
                  : TextInputAction.newline,
              style: Theme.of(context).textTheme.bodyMedium,
              decoration: InputDecoration(
                hintText: widget.hint,
                filled: false,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class FormSelect<T> extends StatelessWidget {
  const FormSelect({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  @override
  Widget build(BuildContext context) => FormSurface(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<T>(
        value: value,
        isExpanded: true,
        itemHeight: null,
        borderRadius: BorderRadius.circular(16),
        dropdownColor: Theme.of(context).colorScheme.surface,
        style: Theme.of(context).textTheme.bodyMedium,
        icon: const Icon(Icons.expand_more_rounded, size: 20),
        selectedItemBuilder: (context) => [
          for (final item in items)
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FieldLabel(label),
                  const SizedBox(height: 4),
                  item.child,
                ],
              ),
            ),
        ],
        hint: Text(label, style: Theme.of(context).textTheme.bodySmall),
        items: items,
        onChanged: onChanged,
      ),
    ),
  );
}

class FormToggle extends StatelessWidget {
  const FormToggle({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });
  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.circular(14),
    onTap: () => onChanged(!value),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w600),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    ),
  );
}
