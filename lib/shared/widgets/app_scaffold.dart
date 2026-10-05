import 'package:flutter/material.dart';
import 'package:meu_app/shared/app_theme.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({super.key, required this.body, this.bottomNavigationBar});

  final Widget body;
  final Widget? bottomNavigationBar;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final glass = theme.extension<GlassTokens>()!;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [glass.backgroundAccent, theme.scaffoldBackgroundColor],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: body,
        bottomNavigationBar: MediaQuery.viewInsetsOf(context).bottom > 0
            ? null
            : bottomNavigationBar,
      ),
    );
  }
}
