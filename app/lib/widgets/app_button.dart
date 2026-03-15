import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum AppButtonSize { large, medium, small }

/// Maps [AppButtonSize] to height in dp.
double _buttonHeight(AppButtonSize size) => switch (size) {
      AppButtonSize.large => 52,
      AppButtonSize.medium => 44,
      AppButtonSize.small => 36,
    };

/// Primary CTA button. Only one per page.
class AppFilledButton extends StatelessWidget {
  const AppFilledButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.size = AppButtonSize.medium,
    this.loading = false,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final AppButtonSize size;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _buttonHeight(size),
      child: FilledButton(
        onPressed: loading ? null : onPressed,
        child: loading
            ? SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: context.colors.onPrimary,
                ),
              )
            : child,
      ),
    );
  }
}

/// Secondary filled button (tonal).
class AppTonalButton extends StatelessWidget {
  const AppTonalButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.size = AppButtonSize.medium,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final AppButtonSize size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _buttonHeight(size),
      child: FilledButton.tonal(onPressed: onPressed, child: child),
    );
  }
}

/// Neutral button for cancel / back actions.
class AppOutlinedButton extends StatelessWidget {
  const AppOutlinedButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.size = AppButtonSize.medium,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final AppButtonSize size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _buttonHeight(size),
      child: OutlinedButton(onPressed: onPressed, child: child),
    );
  }
}

/// Low-priority action button.
class AppTextButton extends StatelessWidget {
  const AppTextButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.size = AppButtonSize.medium,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final AppButtonSize size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _buttonHeight(size),
      child: TextButton(onPressed: onPressed, child: child),
    );
  }
}

/// Toolbar / inline icon action. Minimum touch target 48×48dp.
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.tooltip,
  });

  final VoidCallback? onPressed;
  final Widget icon;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: icon,
      tooltip: tooltip,
      constraints: const BoxConstraints.tightFor(width: 48, height: 48),
    );
  }
}
