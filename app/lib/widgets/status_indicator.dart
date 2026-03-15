import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/role.dart' show AgentStatus;

enum ConnectionStatus { connected, connecting, disconnected, running, waiting, error }

/// Canonical mapping from [AgentStatus] (domain) to [ConnectionStatus] (display).
/// Use this everywhere instead of repeating the switch.
ConnectionStatus agentStatusToConnection(AgentStatus s) => switch (s) {
  AgentStatus.idle    => ConnectionStatus.connected,
  AgentStatus.running => ConnectionStatus.running,
  AgentStatus.waiting => ConnectionStatus.waiting,
  AgentStatus.done    => ConnectionStatus.connected,
  AgentStatus.error   => ConnectionStatus.error,
  AgentStatus.offline => ConnectionStatus.disconnected,
};

/// Just the animated dot/spinner — no text label.
/// Used by [StatusIndicator] and wherever a standalone status dot is needed (e.g. avatar corner).
class StatusDot extends StatefulWidget {
  const StatusDot({
    super.key,
    required this.status,
    this.size = 8,
  });

  final ConnectionStatus status;
  /// Diameter of the dot in logical pixels. Default 8.
  final double size;

  @override
  State<StatusDot> createState() => _StatusDotState();
}

class _StatusDotState extends State<StatusDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _pulseAnim = Tween<double>(begin: 0.35, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    _sync();
  }

  @override
  void didUpdateWidget(StatusDot old) {
    super.didUpdateWidget(old);
    if (old.status != widget.status) _sync();
  }

  void _sync() {
    if (widget.status == ConnectionStatus.connecting) {
      _ctrl.duration = const Duration(milliseconds: 800);
      _ctrl.repeat(reverse: true);
    } else if (widget.status == ConnectionStatus.waiting) {
      _ctrl.duration = const Duration(milliseconds: 400);
      _ctrl.repeat(reverse: true);
    } else {
      _ctrl.stop();
      _ctrl.value = 1.0;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final dotColor = switch (widget.status) {
      ConnectionStatus.connected    => colors.success,
      ConnectionStatus.connecting   => colors.warning,
      ConnectionStatus.disconnected => colors.outline,
      ConnectionStatus.running      => colors.primary,
      ConnectionStatus.waiting      => const Color(0xFFF97316),
      ConnectionStatus.error        => colors.error,
    };

    if (widget.status == ConnectionStatus.running) {
      return SizedBox.square(
        dimension: widget.size + 4,
        child: CircularProgressIndicator(strokeWidth: 2, color: dotColor),
      );
    }

    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (_, _) => Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: dotColor.withValues(alpha: _pulseAnim.value),
          shape: BoxShape.circle,
          boxShadow: widget.status == ConnectionStatus.waiting
              ? [BoxShadow(color: dotColor.withValues(alpha: 0.6), blurRadius: 6)]
              : null,
        ),
      ),
    );
  }
}

/// Displays an animated [StatusDot] + text label for agent/connection status.
class StatusIndicator extends StatelessWidget {
  const StatusIndicator({super.key, required this.status, this.label});

  final ConnectionStatus status;
  final String? label;

  String get _defaultLabel => switch (status) {
        ConnectionStatus.connected    => '已連線',
        ConnectionStatus.connecting   => '連線中',
        ConnectionStatus.disconnected => '未連線',
        ConnectionStatus.running      => '執行中',
        ConnectionStatus.waiting      => '等待確認',
        ConnectionStatus.error        => '錯誤',
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.colors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        StatusDot(status: status),
        const SizedBox(width: 6),
        Text(
          label ?? _defaultLabel,
          style: theme.textTheme.labelSmall?.copyWith(color: colors.textSecondary),
        ),
      ],
    );
  }
}
