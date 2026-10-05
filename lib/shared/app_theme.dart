import 'package:flutter/material.dart';
import 'package:meu_app/shared/appearance.dart';

@immutable
class GlassTokens extends ThemeExtension<GlassTokens> {
  const GlassTokens({
    required this.surface,
    required this.border,
    required this.backgroundAccent,
    required this.shadow,
  });

  final Color surface;
  final Color border;
  final Color backgroundAccent;
  final Color shadow;

  @override
  GlassTokens copyWith({
    Color? surface,
    Color? border,
    Color? backgroundAccent,
    Color? shadow,
  }) => GlassTokens(
    surface: surface ?? this.surface,
    border: border ?? this.border,
    backgroundAccent: backgroundAccent ?? this.backgroundAccent,
    shadow: shadow ?? this.shadow,
  );

  @override
  GlassTokens lerp(GlassTokens? other, double t) {
    if (other == null) return this;
    return GlassTokens(
      surface: Color.lerp(surface, other.surface, t)!,
      border: Color.lerp(border, other.border, t)!,
      backgroundAccent: Color.lerp(
        backgroundAccent,
        other.backgroundAccent,
        t,
      )!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
    );
  }
}

ThemeData buildAppTheme(AppPalette palette, Brightness brightness) {
  const orange = Color(0xFFF54927);
  const peach = Color(0xFFFEEBE7);
  const warm = Color(0xFF302826);
  final dark = brightness == Brightness.dark;
  final mono = palette == AppPalette.monochrome;
  final primary = mono ? (dark ? Colors.white : Colors.black) : orange;
  final background = dark
      ? (mono ? const Color(0xFF121212) : warm)
      : (mono ? const Color(0xFFF4F4F4) : peach);
  final text = dark ? Colors.white : (mono ? Colors.black : warm);
  final secondaryText = dark
      ? const Color(0xFFCCCCCC)
      : (mono ? const Color(0xFF606060) : const Color(0xFF615957));
  final scheme = ColorScheme(
    brightness: brightness,
    primary: primary,
    onPrimary: mono && !dark ? Colors.white : Colors.black,
    secondary: text,
    onSecondary: dark ? Colors.black : Colors.white,
    error: dark ? const Color(0xFFFFB4AB) : const Color(0xFFB3261E),
    onError: dark ? Colors.black : Colors.white,
    surface: dark ? (mono ? const Color(0xFF202020) : warm) : Colors.white,
    onSurface: text,
    onSurfaceVariant: secondaryText,
    surfaceContainerHighest: dark
        ? (mono ? const Color(0xFF333333) : const Color(0xFF493F3C))
        : (mono ? const Color(0xFFEAEAEA) : peach),
    outline: mono
        ? const Color(0xFF808080)
        : (dark ? const Color(0xFF8C8583) : const Color(0xFF827773)),
    outlineVariant: mono
        ? (dark ? const Color(0xFF505050) : const Color(0xFFD8D8D8))
        : (dark ? const Color(0xFF504B49) : const Color(0xFFDDD2CE)),
    primaryContainer: mono
        ? (dark ? const Color(0xFF393939) : const Color(0xFFE4E4E4))
        : (dark ? const Color(0xFF573329) : peach),
    onPrimaryContainer: text,
  );
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: background,
    visualDensity: VisualDensity.standard,
  );
  final buttonShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(14),
  );
  return base.copyWith(
    textTheme: base.textTheme.copyWith(
      headlineMedium: base.textTheme.headlineMedium!.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: text,
      ),
      titleLarge: base.textTheme.titleLarge!.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: text,
      ),
      titleMedium: base.textTheme.titleMedium!.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: text,
      ),
      bodyLarge: base.textTheme.bodyLarge!.copyWith(
        fontSize: 16,
        height: 1.4,
        color: text,
      ),
      bodyMedium: base.textTheme.bodyMedium!.copyWith(
        fontSize: 14,
        height: 1.4,
        color: text,
      ),
      bodySmall: base.textTheme.bodySmall!.copyWith(
        fontSize: 12,
        height: 1.4,
        color: secondaryText,
      ),
    ),
    extensions: [
      GlassTokens(
        surface: (dark ? Colors.black : Colors.white).withValues(
          alpha: dark ? .72 : .84,
        ),
        border: (dark ? Colors.white : (mono ? Colors.black : warm)).withValues(
          alpha: dark ? .16 : .10,
        ),
        backgroundAccent: mono
            ? (dark ? const Color(0xFF282828) : Colors.white)
            : (dark ? const Color(0xFF503229) : Colors.white),
        shadow: Colors.black.withValues(alpha: dark ? .16 : .05),
      ),
    ],
    iconTheme: IconThemeData(color: scheme.onSurfaceVariant, size: 24),
    dividerTheme: DividerThemeData(color: scheme.outlineVariant, space: 1),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 52),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        shape: buttonShape,
        textStyle: base.textTheme.labelLarge!.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: text,
        minimumSize: const Size(48, 52),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        shape: buttonShape,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: text,
        minimumSize: const Size(48, 48),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: TextStyle(color: secondaryText),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: primary, width: 2),
      ),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(Size(48, 48)),
        foregroundColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? scheme.onPrimary : text,
        ),
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? primary
              : Colors.transparent,
        ),
      ),
    ),
    datePickerTheme: DatePickerThemeData(
      todayForegroundColor: WidgetStatePropertyAll(text),
      todayBorder: BorderSide(color: primary),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: dark ? Colors.white : warm,
      contentTextStyle: TextStyle(color: dark ? Colors.black : Colors.white),
      shape: buttonShape,
    ),
  );
}
