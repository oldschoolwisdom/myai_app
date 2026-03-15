import 'package:flutter/material.dart';

/// Filter chip — used for toggleable filter conditions.
class AppFilterChip extends StatelessWidget {
  const AppFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
    this.avatar,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;
  final Widget? avatar;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      avatar: avatar,
      shape: const StadiumBorder(),
    );
  }
}

/// Assist chip — quick shortcut / suggested action.
class AppAssistChip extends StatelessWidget {
  const AppAssistChip({
    super.key,
    required this.label,
    required this.onPressed,
    this.avatar,
  });

  final String label;
  final VoidCallback onPressed;
  final Widget? avatar;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      avatar: avatar,
      onPressed: onPressed,
      shape: const StadiumBorder(),
    );
  }
}

/// Input chip — removable selected tag.
class AppInputChip extends StatelessWidget {
  const AppInputChip({
    super.key,
    required this.label,
    required this.onDeleted,
    this.avatar,
  });

  final String label;
  final VoidCallback onDeleted;
  final Widget? avatar;

  @override
  Widget build(BuildContext context) {
    return InputChip(
      label: Text(label),
      avatar: avatar,
      onDeleted: onDeleted,
      shape: const StadiumBorder(),
    );
  }
}
