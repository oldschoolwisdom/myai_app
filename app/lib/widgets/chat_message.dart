import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../theme/app_colors.dart';

/// User's chat message bubble (right-aligned).
class UserMessage extends StatelessWidget {
  const UserMessage({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context);

    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: colors.primary,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(4),
            ),
          ),
          child: Text(
            text,
            style: theme.textTheme.bodyLarge?.copyWith(color: colors.onPrimary),
          ),
        ),
      ),
    );
  }
}

/// AI response bubble (left-aligned) with Markdown rendering.
///
/// States:
/// - [isStreaming] true + empty text → three-dot pulse animation
/// - [isStreaming] true + partial text → blinking cursor after text
/// - [isStreaming] false → copy button shown
/// - [isError] true → error container with retry button
class AiMessage extends StatelessWidget {
  const AiMessage({
    super.key,
    required this.text,
    this.isStreaming = false,
    this.isError = false,
    this.errorMessage,
    this.onRetry,
  });

  final String text;
  final bool isStreaming;
  final bool isError;
  final String? errorMessage;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    if (isError) {
      return _ErrorBubble(
        message: errorMessage ?? '發生錯誤，請稍後再試。',
        onRetry: onRetry,
      );
    }

    final colors = context.colors;
    final theme = Theme.of(context);

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: colors.surfaceVariant,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isStreaming && text.isEmpty)
              const _ThreeDotsPulse()
            else
              MarkdownBody(
                data: text,
                selectable: true,
                styleSheet: _markdownStyles(context, colors, theme),
              ),
            if (isStreaming && text.isNotEmpty)
              _BlinkingCursor(color: colors.primary),
            if (!isStreaming && text.isNotEmpty)
              _CopyButton(text: text),
          ],
        ),
      ),
    );
  }

  MarkdownStyleSheet _markdownStyles(
    BuildContext context,
    AppColors colors,
    ThemeData theme,
  ) {
    return MarkdownStyleSheet(
      p: theme.textTheme.bodyLarge?.copyWith(color: colors.onSurface),
      h1: theme.textTheme.headlineSmall?.copyWith(color: colors.textPrimary),
      h2: theme.textTheme.titleLarge?.copyWith(color: colors.textPrimary),
      h3: theme.textTheme.titleMedium?.copyWith(color: colors.textPrimary),
      code: TextStyle(
        fontFamily: 'JetBrainsMono',
        fontSize: 20,
        height: 28 / 20,
        backgroundColor: colors.surface,
        color: colors.onSurface,
      ),
      codeblockDecoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        border: Border.all(color: colors.outlineVariant),
      ),
      a: theme.textTheme.bodyLarge?.copyWith(
        color: colors.textLink,
        decoration: TextDecoration.underline,
      ),
      listIndent: 16,
    );
  }
}

class _ErrorBubble extends StatelessWidget {
  const _ErrorBubble({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colors.errorContainer,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(color: colors.error),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: onRetry,
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.error,
                side: BorderSide(color: colors.error),
              ),
              child: const Text('重試'),
            ),
          ],
        ],
      ),
    );
  }
}

class _ThreeDotsPulse extends StatefulWidget {
  const _ThreeDotsPulse();

  @override
  State<_ThreeDotsPulse> createState() => _ThreeDotsPulseState();
}

class _ThreeDotsPulseState extends State<_ThreeDotsPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, _) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          final phase = ((_ctrl.value - i / 3) % 1.0).abs();
          final opacity = phase < 0.5 ? phase * 2 : (1.0 - phase) * 2;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Opacity(
              opacity: opacity.clamp(0.3, 1.0),
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: colors.onSurfaceVariant,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _BlinkingCursor extends StatefulWidget {
  const _BlinkingCursor({required this.color});

  final Color color;

  @override
  State<_BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, _) => Opacity(
        opacity: _ctrl.value,
        child: Container(
          width: 2,
          height: 18,
          margin: const EdgeInsets.only(left: 2, top: 2),
          color: widget.color,
        ),
      ),
    );
  }
}

class _CopyButton extends StatelessWidget {
  const _CopyButton({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: IconButton(
        onPressed: () => Clipboard.setData(ClipboardData(text: text)),
        icon: const Icon(Icons.content_copy, size: 16),
        tooltip: '複製全文',
        visualDensity: VisualDensity.compact,
        color: context.colors.textSecondary,
      ),
    );
  }
}
