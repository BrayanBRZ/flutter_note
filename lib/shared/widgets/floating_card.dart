import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:meu_app/shared/app_theme.dart';

class FloatingCard extends StatelessWidget {
  const FloatingCard({
    super.key,
    required this.child,
    this.height,
    this.width,
    this.padding,
  });
  final Widget child;
  final double? height;
  final double? width;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<GlassTokens>()!;
    final radius = BorderRadius.circular(20);
    return Container(
      width: width ?? double.infinity,
      constraints: height == null ? null : BoxConstraints(minHeight: height!),
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: tokens.shadow,
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Material(
            color: tokens.surface,
            shape: RoundedRectangleBorder(
              borderRadius: radius,
              side: BorderSide(color: tokens.border),
            ),
            child: Padding(padding: padding ?? EdgeInsets.zero, child: child),
          ),
        ),
      ),
    );
  }
}
