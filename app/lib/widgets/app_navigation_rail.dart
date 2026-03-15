import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// A destination entry for [AppNavigationRail].
class AppNavDestination {
  const AppNavDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final Widget icon;
  final Widget selectedIcon;
  final String label;
}

/// Collapsible Navigation Rail for desktop IDE layout.
///
/// - Collapsed width: 72dp (icons only)
/// - Expanded width: 200dp (icons + labels)
/// - Hamburger button (⌘B) toggles expand/collapse
/// - Defaults to expanded when window ≥ 1280dp
class AppNavigationRail extends StatefulWidget {
  const AppNavigationRail({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.header,
    this.footer,
  });

  final List<AppNavDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  /// Optional widget shown below the hamburger button.
  final Widget? header;

  /// Optional widget pinned to the bottom.
  final Widget? footer;

  @override
  State<AppNavigationRail> createState() => _AppNavigationRailState();
}

class _AppNavigationRailState extends State<AppNavigationRail>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late final AnimationController _animCtrl;
  late final Animation<double> _widthAnim;

  static const _collapsedWidth = 72.0;
  static const _expandedWidth = 200.0;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _widthAnim = Tween<double>(
      begin: _collapsedWidth,
      end: _expandedWidth,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (MediaQuery.of(context).size.width >= 1280) {
        _setExpanded(true, animate: false);
      }
    });
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void _setExpanded(bool value, {bool animate = true}) {
    setState(() => _expanded = value);
    if (animate) {
      value ? _animCtrl.forward() : _animCtrl.reverse();
    } else {
      _animCtrl.value = value ? 1.0 : 0.0;
    }
  }

  void _toggle() => _setExpanded(!_expanded);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _widthAnim,
      builder: (_, _) {
        final w = _widthAnim.value;
        final labelOpacity = ((w - _collapsedWidth) /
                (_expandedWidth - _collapsedWidth))
            .clamp(0.0, 1.0);

        return Container(
          width: w,
          color: colors.surface,
          child: Column(
            children: [
              // Hamburger toggle
              SizedBox(
                height: 56,
                child: Tooltip(
                  message: '切換導覽列 ⌘B',
                  child: IconButton(
                    onPressed: _toggle,
                    icon: const Icon(Icons.menu),
                  ),
                ),
              ),

              if (widget.header != null) widget.header!,

              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: widget.destinations.length,
                  itemBuilder: (_, i) {
                    final dest = widget.destinations[i];
                    final isSelected = i == widget.selectedIndex;
                    final iconColor = isSelected
                        ? theme.colorScheme.onSecondaryContainer
                        : colors.onSurfaceVariant;

                    return Tooltip(
                      message: _expanded ? '' : dest.label,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        child: InkWell(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(24)),
                          onTap: () => widget.onDestinationSelected(i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            height: 48,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? theme.colorScheme.secondaryContainer
                                  : null,
                              borderRadius: const BorderRadius.all(
                                Radius.circular(24),
                              ),
                            ),
                            child: Row(
                              children: [
                                const SizedBox(width: 12),
                                IconTheme(
                                  data: IconThemeData(
                                    color: iconColor,
                                    size: 24,
                                  ),
                                  child: isSelected
                                      ? dest.selectedIcon
                                      : dest.icon,
                                ),
                                if (labelOpacity > 0) ...[
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Opacity(
                                      opacity: labelOpacity,
                                      child: Text(
                                        dest.label,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.labelMedium
                                            ?.copyWith(color: iconColor),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              if (widget.footer != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: widget.footer!,
                ),
            ],
          ),
        );
      },
    );
  }
}
