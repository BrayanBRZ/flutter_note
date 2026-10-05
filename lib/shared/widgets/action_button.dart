import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  const ActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.outlined = false,
    this.destructive = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool outlined;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final error = Theme.of(context).colorScheme.error;
    return SizedBox(
      width: double.infinity,
      child: outlined
          ? OutlinedButton.icon(
              onPressed: onPressed,
              style: destructive
                  ? OutlinedButton.styleFrom(foregroundColor: error)
                  : null,
              icon: Icon(icon),
              label: Text(label, textAlign: TextAlign.center),
            )
          : FilledButton.icon(
              onPressed: onPressed,
              icon: Icon(icon),
              label: Text(label, textAlign: TextAlign.center),
            ),
    );
  }
}
