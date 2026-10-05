import 'package:flutter/material.dart';
import 'package:meu_app/shared/widgets/app_scaffold.dart';
import 'package:meu_app/shared/widgets/floating_card.dart';

class ConfirmActionScreen extends StatelessWidget {
  const ConfirmActionScreen({super.key});
  @override
  Widget build(BuildContext context) => AppScaffold(
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: FloatingCard(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_outline_rounded,
                  color: Theme.of(context).colorScheme.onSurface,
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  'Validado',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
