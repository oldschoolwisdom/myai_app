import 'package:flutter/material.dart';

enum AppCardVariant { elevated, filled, outlined }

/// Material 3 card with consistent 16dp radius and 16dp padding.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.variant = AppCardVariant.elevated,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final AppCardVariant variant;
  final VoidCallback? onTap;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.all(Radius.circular(16));
    final content = Padding(padding: padding, child: child);

    Widget card = switch (variant) {
      AppCardVariant.elevated => Card(
          elevation: 1,
          shape: const RoundedRectangleBorder(borderRadius: radius),
          child: content,
        ),
      AppCardVariant.filled => Card.filled(
          shape: const RoundedRectangleBorder(borderRadius: radius),
          child: content,
        ),
      AppCardVariant.outlined => Card.outlined(
          shape: const RoundedRectangleBorder(borderRadius: radius),
          child: content,
        ),
    };

    if (onTap != null) {
      // Wrap with tappable ink — Card already clips
      card = switch (variant) {
        AppCardVariant.elevated => Card(
            elevation: 1,
            shape: const RoundedRectangleBorder(borderRadius: radius),
            clipBehavior: Clip.antiAlias,
            child: InkWell(onTap: onTap, child: content),
          ),
        AppCardVariant.filled => Card.filled(
            shape: const RoundedRectangleBorder(borderRadius: radius),
            clipBehavior: Clip.antiAlias,
            child: InkWell(onTap: onTap, child: content),
          ),
        AppCardVariant.outlined => Card.outlined(
            shape: const RoundedRectangleBorder(borderRadius: radius),
            clipBehavior: Clip.antiAlias,
            child: InkWell(onTap: onTap, child: content),
          ),
      };
    }

    return card;
  }
}
