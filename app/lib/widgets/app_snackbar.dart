import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum AppSnackbarType { info, success, warning, error }

/// Displays a floating snackbar.
/// - info/success/warning/error types map to semantic container colors
/// - Duration: 3s default, 5s when [actionLabel] is provided
void showAppSnackbar(
  BuildContext context, {
  required String message,
  AppSnackbarType type = AppSnackbarType.info,
  String? actionLabel,
  VoidCallback? onAction,
  Duration duration = const Duration(seconds: 3),
}) {
  final colors = context.colors;

  final backgroundColor = switch (type) {
    AppSnackbarType.info => colors.infoContainer,
    AppSnackbarType.success => colors.successContainer,
    AppSnackbarType.warning => colors.warningContainer,
    AppSnackbarType.error => colors.errorContainer,
  };

  final contentColor = switch (type) {
    AppSnackbarType.info => colors.info,
    AppSnackbarType.success => colors.success,
    AppSnackbarType.warning => colors.warning,
    AppSnackbarType.error => colors.error,
  };

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message, style: TextStyle(color: contentColor)),
      backgroundColor: backgroundColor,
      duration: actionLabel != null ? const Duration(seconds: 5) : duration,
      action: actionLabel != null
          ? SnackBarAction(
              label: actionLabel,
              textColor: contentColor,
              onPressed: onAction ?? () {},
            )
          : null,
    ),
  );
}
