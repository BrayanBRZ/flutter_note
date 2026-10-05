import 'package:flutter/material.dart';
import 'package:meu_app/shared/widgets/floating_card.dart';

class TopBar extends StatelessWidget {
  const TopBar({
    super.key,
    required this.screenName,
    this.showBackButton = false,
    this.backTooltip = 'Voltar',
  });
  final String screenName;
  final bool showBackButton;
  final String backTooltip;

  @override
  Widget build(BuildContext context) {
    final canGoBack = showBackButton && Navigator.of(context).canPop();
    final compact =
        MediaQuery.sizeOf(context).height -
            MediaQuery.viewInsetsOf(context).bottom <
        400;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, compact ? 8 : 16, 16, 8),
      child: FloatingCard(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            if (canGoBack)
              IconButton(
                tooltip: backTooltip,
                onPressed: () => Navigator.maybePop(context),
                icon: const Icon(Icons.arrow_back_rounded),
              )
            else
              SizedBox(
                width: 48,
                height: 48,
                child: Icon(
                  Icons.auto_stories_outlined,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            Expanded(
              child: Semantics(
                header: true,
                child: Text(
                  screenName,
                  style: compact
                      ? Theme.of(context).textTheme.titleMedium
                      : Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}
