import 'package:flutter/material.dart';

/// The fill preserves the saved tag color; the outline keeps white tags visible.
class TagIndicator extends StatelessWidget {
  const TagIndicator({super.key, required this.color, this.size = 12});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: color,
      shape: BoxShape.circle,
      border: Border.all(color: Theme.of(context).colorScheme.outline),
    ),
  );
}
