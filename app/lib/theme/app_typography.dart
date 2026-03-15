import 'package:flutter/material.dart';

/// Builds the app TextTheme using Inter (bundled variable font in assets/).
/// Follows the M3 type scale with all sizes ≥ 18sp per spec.
/// Colors are NOT set here — apply from AppColors tokens per widget.
///
/// NotoSansTC for Traditional Chinese: register similarly under assets/fonts/
/// when available; OS system font handles CJK fallback until then.
TextTheme buildAppTextTheme() {
  // Use fontFamily directly — font is bundled in assets, no network needed.
  const String interFamily = 'Inter';
  return const TextTheme(
    // Display — onboarding, empty page hero
    displayLarge: TextStyle(
      fontFamily: interFamily,
      fontSize: 57,
      fontWeight: FontWeight.w400,
      height: 1.123,
      letterSpacing: -0.25,
    ),
    displayMedium: TextStyle(
      fontFamily: interFamily,
      fontSize: 48,
      fontWeight: FontWeight.w400,
      height: 1.167,
    ),
    displaySmall: TextStyle(
      fontFamily: interFamily,
      fontSize: 40,
      fontWeight: FontWeight.w400,
      height: 1.2,
    ),

    // Headline — page titles, section headers
    headlineLarge: TextStyle(
      fontFamily: interFamily,
      fontSize: 36,
      fontWeight: FontWeight.w600,
      height: 1.222,
    ),
    headlineMedium: TextStyle(
      fontFamily: interFamily,
      fontSize: 32,
      fontWeight: FontWeight.w600,
      height: 1.25,
    ),
    headlineSmall: TextStyle(
      fontFamily: interFamily,
      fontSize: 28,
      fontWeight: FontWeight.w600,
      height: 1.286,
    ),

    // Title — card titles, list item titles
    titleLarge: TextStyle(
      fontFamily: interFamily,
      fontSize: 26,
      fontWeight: FontWeight.w500,
      height: 1.308,
    ),
    titleMedium: TextStyle(
      fontFamily: interFamily,
      fontSize: 22,
      fontWeight: FontWeight.w500,
      height: 1.364,
      letterSpacing: 0.15,
    ),
    titleSmall: TextStyle(
      fontFamily: interFamily,
      fontSize: 20,
      fontWeight: FontWeight.w500,
      height: 1.4,
      letterSpacing: 0.1,
    ),

    // Body — content text
    bodyLarge: TextStyle(
      fontFamily: interFamily,
      fontSize: 22,
      fontWeight: FontWeight.w400,
      height: 1.455,
      letterSpacing: 0.5,
    ),
    bodyMedium: TextStyle(
      fontFamily: interFamily,
      fontSize: 20,
      fontWeight: FontWeight.w400,
      height: 1.4,
      letterSpacing: 0.25,
    ),
    bodySmall: TextStyle(
      fontFamily: interFamily,
      fontSize: 18,
      fontWeight: FontWeight.w400,
      height: 1.444,
      letterSpacing: 0.4,
    ),

    // Label — buttons, tags, captions (minimum 18sp)
    labelLarge: TextStyle(
      fontFamily: interFamily,
      fontSize: 22,
      fontWeight: FontWeight.w500,
      height: 1.364,
      letterSpacing: 0.1,
    ),
    labelMedium: TextStyle(
      fontFamily: interFamily,
      fontSize: 20,
      fontWeight: FontWeight.w500,
      height: 1.4,
      letterSpacing: 0.5,
    ),
    labelSmall: TextStyle(
      fontFamily: interFamily,
      fontSize: 18,
      fontWeight: FontWeight.w500,
      height: 1.444,
      letterSpacing: 0.5,
    ),
  );
}

/// Returns a JetBrains Mono TextStyle for code/ID/numeric contexts.
TextStyle monoStyle({
  double fontSize = 20,
  FontWeight fontWeight = FontWeight.w400,
  Color? color,
}) {
  return TextStyle(
    fontFamily: 'JetBrainsMono',
    fontSize: fontSize,
    fontWeight: fontWeight,
    height: 28 / 20,
    color: color,
  );
}

// Fonts are declared in pubspec.yaml and bundled in assets/fonts/.

