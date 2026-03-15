import 'package:flutter/material.dart';

@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.brandNavy,
    required this.brandBlue,
    required this.brandCyan,
    required this.brandSand,
    required this.primary,
    required this.primaryVariant,
    required this.onPrimary,
    required this.secondary,
    required this.secondaryVariant,
    required this.onSecondary,
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.onBackground,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.outline,
    required this.outlineVariant,
    required this.error,
    required this.onError,
    required this.errorContainer,
    required this.warning,
    required this.warningContainer,
    required this.success,
    required this.successContainer,
    required this.info,
    required this.infoContainer,
    required this.textPrimary,
    required this.textSecondary,
    required this.textDisabled,
    required this.textOnBrand,
    required this.textLink,
    required this.overlayHover,
    required this.overlayPressed,
    required this.overlayFocus,
    required this.overlayScrim,
  });

  // Brand palette
  final Color brandNavy;
  final Color brandBlue;
  final Color brandCyan;
  final Color brandSand;

  // Primary
  final Color primary;
  final Color primaryVariant;
  final Color onPrimary;

  // Secondary
  final Color secondary;
  final Color secondaryVariant;
  final Color onSecondary;

  // Background & Surface
  final Color background;
  final Color surface;
  final Color surfaceVariant;
  final Color onBackground;
  final Color onSurface;
  final Color onSurfaceVariant;

  // Outline
  final Color outline;
  final Color outlineVariant;

  // State colors
  final Color error;
  final Color onError;
  final Color errorContainer;
  final Color warning;
  final Color warningContainer;
  final Color success;
  final Color successContainer;
  final Color info;
  final Color infoContainer;

  // Text hierarchy
  final Color textPrimary;
  final Color textSecondary;
  final Color textDisabled;
  final Color textOnBrand;
  final Color textLink;

  // Overlay
  final Color overlayHover;
  final Color overlayPressed;
  final Color overlayFocus;
  final Color overlayScrim;

  static const light = AppColors(
    brandNavy: Color(0xFF0B2D72),
    brandBlue: Color(0xFF0992C2),
    brandCyan: Color(0xFF0AC4E0),
    brandSand: Color(0xFFF6E7BC),
    primary: Color(0xFF0B2D72),
    primaryVariant: Color(0xFF0A2460),
    onPrimary: Color(0xFFFFFFFF),
    secondary: Color(0xFF0992C2),
    secondaryVariant: Color(0xFF077BA8),
    onSecondary: Color(0xFFFFFFFF),
    background: Color(0xFFFFFFFF),
    surface: Color(0xFFF4F7FC),
    surfaceVariant: Color(0xFFE8EEF8),
    onBackground: Color(0xFF0B1A33),
    onSurface: Color(0xFF1A2E50),
    onSurfaceVariant: Color(0xFF4A5E80),
    outline: Color(0xFFB8C8DF),
    outlineVariant: Color(0xFFD8E3F0),
    error: Color(0xFFDC2626),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFEE2E2),
    warning: Color(0xFFD97706),
    warningContainer: Color(0xFFFEF3C7),
    success: Color(0xFF16A34A),
    successContainer: Color(0xFFDCFCE7),
    info: Color(0xFF0992C2),
    infoContainer: Color(0xFFE0F2FE),
    textPrimary: Color(0xFF0B1A33),
    textSecondary: Color(0xFF3A4F6E),
    textDisabled: Color(0xFF9AAFC8),
    textOnBrand: Color(0xFFFFFFFF),
    textLink: Color(0xFF0992C2),
    overlayHover: Color(0x140B2D72),    // brand-navy @ 8%
    overlayPressed: Color(0x290B2D72),  // brand-navy @ 16%
    overlayFocus: Color(0x3D0AC4E0),    // brand-cyan @ 24%
    overlayScrim: Color(0x66000000),    // #000 @ 40%
  );

  static const dark = AppColors(
    brandNavy: Color(0xFF0B2D72),
    brandBlue: Color(0xFF0992C2),
    brandCyan: Color(0xFF0AC4E0),
    brandSand: Color(0xFFF6E7BC),
    primary: Color(0xFF0AC4E0),
    primaryVariant: Color(0xFF0992C2),
    onPrimary: Color(0xFF060F1E),
    secondary: Color(0xFFF6E7BC),
    secondaryVariant: Color(0xFFE8D4A0),
    onSecondary: Color(0xFF0B2D72),
    background: Color(0xFF060F1E),
    surface: Color(0xFF0D1F3C),
    surfaceVariant: Color(0xFF152A4E),
    onBackground: Color(0xFFE8EEF7),
    onSurface: Color(0xFFD0D9EC),
    onSurfaceVariant: Color(0xFF8FA3C3),
    outline: Color(0xFF2A3F5F),
    outlineVariant: Color(0xFF1E3050),
    error: Color(0xFFF87171),
    onError: Color(0xFF7F1D1D),
    errorContainer: Color(0xFF450A0A),
    warning: Color(0xFFFBBF24),
    warningContainer: Color(0xFF451A03),
    success: Color(0xFF4ADE80),
    successContainer: Color(0xFF052E16),
    info: Color(0xFF0AC4E0),
    infoContainer: Color(0xFF0C2A3B),
    textPrimary: Color(0xFFE8EEF7),
    textSecondary: Color(0xFFA0B2CC),
    textDisabled: Color(0xFF3D5070),
    textOnBrand: Color(0xFFFFFFFF),
    textLink: Color(0xFF0AC4E0),
    overlayHover: Color(0x140B2D72),
    overlayPressed: Color(0x290B2D72),
    overlayFocus: Color(0x3D0AC4E0),
    overlayScrim: Color(0x66000000),
  );

  @override
  AppColors copyWith({
    Color? brandNavy,
    Color? brandBlue,
    Color? brandCyan,
    Color? brandSand,
    Color? primary,
    Color? primaryVariant,
    Color? onPrimary,
    Color? secondary,
    Color? secondaryVariant,
    Color? onSecondary,
    Color? background,
    Color? surface,
    Color? surfaceVariant,
    Color? onBackground,
    Color? onSurface,
    Color? onSurfaceVariant,
    Color? outline,
    Color? outlineVariant,
    Color? error,
    Color? onError,
    Color? errorContainer,
    Color? warning,
    Color? warningContainer,
    Color? success,
    Color? successContainer,
    Color? info,
    Color? infoContainer,
    Color? textPrimary,
    Color? textSecondary,
    Color? textDisabled,
    Color? textOnBrand,
    Color? textLink,
    Color? overlayHover,
    Color? overlayPressed,
    Color? overlayFocus,
    Color? overlayScrim,
  }) {
    return AppColors(
      brandNavy: brandNavy ?? this.brandNavy,
      brandBlue: brandBlue ?? this.brandBlue,
      brandCyan: brandCyan ?? this.brandCyan,
      brandSand: brandSand ?? this.brandSand,
      primary: primary ?? this.primary,
      primaryVariant: primaryVariant ?? this.primaryVariant,
      onPrimary: onPrimary ?? this.onPrimary,
      secondary: secondary ?? this.secondary,
      secondaryVariant: secondaryVariant ?? this.secondaryVariant,
      onSecondary: onSecondary ?? this.onSecondary,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      onBackground: onBackground ?? this.onBackground,
      onSurface: onSurface ?? this.onSurface,
      onSurfaceVariant: onSurfaceVariant ?? this.onSurfaceVariant,
      outline: outline ?? this.outline,
      outlineVariant: outlineVariant ?? this.outlineVariant,
      error: error ?? this.error,
      onError: onError ?? this.onError,
      errorContainer: errorContainer ?? this.errorContainer,
      warning: warning ?? this.warning,
      warningContainer: warningContainer ?? this.warningContainer,
      success: success ?? this.success,
      successContainer: successContainer ?? this.successContainer,
      info: info ?? this.info,
      infoContainer: infoContainer ?? this.infoContainer,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textDisabled: textDisabled ?? this.textDisabled,
      textOnBrand: textOnBrand ?? this.textOnBrand,
      textLink: textLink ?? this.textLink,
      overlayHover: overlayHover ?? this.overlayHover,
      overlayPressed: overlayPressed ?? this.overlayPressed,
      overlayFocus: overlayFocus ?? this.overlayFocus,
      overlayScrim: overlayScrim ?? this.overlayScrim,
    );
  }

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      brandNavy: Color.lerp(brandNavy, other.brandNavy, t)!,
      brandBlue: Color.lerp(brandBlue, other.brandBlue, t)!,
      brandCyan: Color.lerp(brandCyan, other.brandCyan, t)!,
      brandSand: Color.lerp(brandSand, other.brandSand, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      primaryVariant: Color.lerp(primaryVariant, other.primaryVariant, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      secondaryVariant:
          Color.lerp(secondaryVariant, other.secondaryVariant, t)!,
      onSecondary: Color.lerp(onSecondary, other.onSecondary, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceVariant: Color.lerp(surfaceVariant, other.surfaceVariant, t)!,
      onBackground: Color.lerp(onBackground, other.onBackground, t)!,
      onSurface: Color.lerp(onSurface, other.onSurface, t)!,
      onSurfaceVariant:
          Color.lerp(onSurfaceVariant, other.onSurfaceVariant, t)!,
      outline: Color.lerp(outline, other.outline, t)!,
      outlineVariant: Color.lerp(outlineVariant, other.outlineVariant, t)!,
      error: Color.lerp(error, other.error, t)!,
      onError: Color.lerp(onError, other.onError, t)!,
      errorContainer: Color.lerp(errorContainer, other.errorContainer, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningContainer:
          Color.lerp(warningContainer, other.warningContainer, t)!,
      success: Color.lerp(success, other.success, t)!,
      successContainer:
          Color.lerp(successContainer, other.successContainer, t)!,
      info: Color.lerp(info, other.info, t)!,
      infoContainer: Color.lerp(infoContainer, other.infoContainer, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t)!,
      textOnBrand: Color.lerp(textOnBrand, other.textOnBrand, t)!,
      textLink: Color.lerp(textLink, other.textLink, t)!,
      overlayHover: Color.lerp(overlayHover, other.overlayHover, t)!,
      overlayPressed: Color.lerp(overlayPressed, other.overlayPressed, t)!,
      overlayFocus: Color.lerp(overlayFocus, other.overlayFocus, t)!,
      overlayScrim: Color.lerp(overlayScrim, other.overlayScrim, t)!,
    );
  }
}

extension AppColorsX on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}
