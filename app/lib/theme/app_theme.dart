import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

abstract final class AppTheme {
  static ThemeData get light => _build(AppColors.light, Brightness.light);
  static ThemeData get dark => _build(AppColors.dark, Brightness.dark);

  static ThemeData _build(AppColors c, Brightness brightness) {
    final textTheme = buildAppTextTheme();
    final isLight = brightness == Brightness.light;

    final colorScheme = isLight
        ? ColorScheme.light(
            primary: c.primary,
            onPrimary: c.onPrimary,
            primaryContainer: c.surfaceVariant,
            onPrimaryContainer: c.primary,
            secondary: c.secondary,
            onSecondary: c.onSecondary,
            secondaryContainer: c.infoContainer,
            onSecondaryContainer: c.secondary,
            error: c.error,
            onError: c.onError,
            errorContainer: c.errorContainer,
            surface: c.surface,
            onSurface: c.onSurface,
            surfaceContainerHighest: c.surfaceVariant,
            onSurfaceVariant: c.onSurfaceVariant,
            outline: c.outline,
            outlineVariant: c.outlineVariant,
            scrim: c.overlayScrim,
          )
        : ColorScheme.dark(
            primary: c.primary,
            onPrimary: c.onPrimary,
            primaryContainer: c.surfaceVariant,
            onPrimaryContainer: c.primary,
            secondary: c.secondary,
            onSecondary: c.onSecondary,
            secondaryContainer: c.infoContainer,
            onSecondaryContainer: c.secondary,
            error: c.error,
            onError: c.onError,
            errorContainer: c.errorContainer,
            surface: c.surface,
            onSurface: c.onSurface,
            surfaceContainerHighest: c.surfaceVariant,
            onSurfaceVariant: c.onSurfaceVariant,
            outline: c.outline,
            outlineVariant: c.outlineVariant,
            scrim: c.overlayScrim,
          );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      textTheme: textTheme,
      extensions: [c],

      // Scaffold background
      scaffoldBackgroundColor: c.background,

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: c.surface,
        foregroundColor: c.textPrimary,
        elevation: 0,
        titleTextStyle:
            textTheme.titleLarge?.copyWith(color: c.textPrimary),
      ),

      // Buttons
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 44),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 44),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(64, 44),
          textStyle: textTheme.labelLarge,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(48, 48),
        ),
      ),

      // TextField
      inputDecorationTheme: InputDecorationTheme(
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        constraints: const BoxConstraints(minHeight: 56),
        hintStyle: textTheme.bodyLarge?.copyWith(color: c.textDisabled),
        errorStyle: textTheme.bodySmall?.copyWith(color: c.error),
      ),

      // Card
      cardTheme: const CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        margin: EdgeInsets.zero,
      ),

      // Chip
      chipTheme: ChipThemeData(
        labelStyle: textTheme.labelMedium,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        shape: const StadiumBorder(),
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(28)),
        ),
        titleTextStyle:
            textTheme.headlineSmall?.copyWith(color: c.textPrimary),
        contentTextStyle:
            textTheme.bodyMedium?.copyWith(color: c.textSecondary),
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        contentTextStyle:
            textTheme.bodyMedium?.copyWith(color: c.onSurface),
      ),

      // Tooltip
      tooltipTheme: TooltipThemeData(
        waitDuration: const Duration(milliseconds: 500),
        textStyle:
            textTheme.labelSmall?.copyWith(color: c.surface),
        decoration: BoxDecoration(
          color: c.onSurface,
          borderRadius: const BorderRadius.all(Radius.circular(4)),
        ),
        constraints: const BoxConstraints(maxWidth: 280),
      ),

      // NavigationRail
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: c.surface,
        selectedIconTheme: IconThemeData(
          color: colorScheme.onSecondaryContainer,
          size: 24,
        ),
        unselectedIconTheme: IconThemeData(
          color: c.onSurfaceVariant,
          size: 24,
        ),
        selectedLabelTextStyle:
            textTheme.labelMedium?.copyWith(
          color: colorScheme.onSecondaryContainer,
        ),
        unselectedLabelTextStyle:
            textTheme.labelMedium?.copyWith(color: c.onSurfaceVariant),
        indicatorColor: colorScheme.secondaryContainer,
        minWidth: 72,
        minExtendedWidth: 200,
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: c.outlineVariant,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
