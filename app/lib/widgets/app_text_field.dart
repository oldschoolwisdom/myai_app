import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../models/quick_phrase.dart';

const _kDefaultModels = [
  'claude-opus-4.6',
  'claude-sonnet-4.6',
  'claude-haiku-4.5',
  'gpt-4o',
  'gpt-4.1',
];

/// Standard outlined text field for forms and settings.
/// When [obscureText] is true and no [suffixIcon] is provided,
/// a visibility-toggle icon is automatically added.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.errorText,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.obscureText = false,
    this.keyboardType,
    this.autofocus = false,
    this.focusNode,
    this.maxLines = 1,
    this.prefixIcon,
    this.suffixIcon,
  });

  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;
  final bool obscureText;
  final TextInputType? keyboardType;
  final bool autofocus;
  final FocusNode? focusNode;
  final int? maxLines;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscured;

  @override
  void initState() {
    super.initState();
    _obscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    // Auto suffix: visibility toggle when obscureText is true and no custom icon
    Widget? suffix = widget.suffixIcon;
    if (widget.obscureText && suffix == null) {
      suffix = IconButton(
        icon: Icon(
          _obscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          size: 20,
        ),
        tooltip: _obscured ? '顯示內容' : '隱藏內容',
        onPressed: () => setState(() => _obscured = !_obscured),
      );
    }

    return TextField(
      controller: widget.controller,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      enabled: widget.enabled,
      obscureText: _obscured,
      keyboardType: widget.keyboardType,
      autofocus: widget.autofocus,
      focusNode: widget.focusNode,
      maxLines: widget.obscureText ? 1 : widget.maxLines,
      decoration: InputDecoration(
        hintText: widget.hintText,
        labelText: widget.labelText,
        errorText: widget.errorText,
        prefixIcon: widget.prefixIcon,
        suffixIcon: suffix,
      ),
    );
  }
}

/// AI conversation input bar.
/// - Multi-line: Enter = newline, Shift+Enter = send
/// - Model selector chip above the input
/// - Send/Stop button on right
/// - Optional status text below
class AiChatInput extends StatefulWidget {
  const AiChatInput({
    super.key,
    required this.onSend,
    this.onStop,
    this.enabled = true,
    this.isStreaming = false,
    this.statusText,
    this.initialModel = 'claude-sonnet-4.6',
    this.onModelChanged,
    this.models = _kDefaultModels,
    this.quickPhrases = const [],
  });

  final ValueChanged<String> onSend;
  final VoidCallback? onStop;
  final bool enabled;
  final bool isStreaming;
  final String? statusText;
  final String initialModel;
  final ValueChanged<String>? onModelChanged;
  final List<String> models;
  final List<QuickPhrase> quickPhrases;

  @override
  State<AiChatInput> createState() => _AiChatInputState();
}

class _AiChatInputState extends State<AiChatInput> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  late String _selectedModel;

  @override
  void initState() {
    super.initState();
    _selectedModel = widget.initialModel;
  }

  bool get _canSend =>
      _controller.text.trim().isNotEmpty && widget.enabled && !widget.isStreaming;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSend(text);
    _controller.clear();
    setState(() {});
    _focusNode.requestFocus();
  }

  KeyEventResult _handleKeyEvent(FocusNode _, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey != LogicalKeyboardKey.enter) return KeyEventResult.ignored;

    if (HardwareKeyboard.instance.isShiftPressed) {
      // Shift+Enter → send
      if (_canSend) _handleSend();
      return KeyEventResult.handled;
    }
    // Plain Enter → allow TextField to insert newline
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Toolbar row: [Quick Phrases] --- spacer --- [Model selector] ──
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            children: [
              // ── Quick Phrases button ──────────────────────────────
              if (widget.quickPhrases.isNotEmpty)
                PopupMenuButton<QuickPhrase>(
                  tooltip: '常用語',
                  onSelected: (phrase) {
                    final cur = _controller.text;
                    final insert = cur.isEmpty ? phrase.text : '$cur\n${phrase.text}';
                    _controller.text = insert;
                    _controller.selection = TextSelection.collapsed(
                      offset: insert.length,
                    );
                    setState(() {});
                    _focusNode.requestFocus();
                  },
                  itemBuilder: (_) => widget.quickPhrases
                      .map((p) => PopupMenuItem<QuickPhrase>(
                            value: p,
                            child: Text(p.label,
                                style: Theme.of(context).textTheme.bodyMedium),
                          ))
                      .toList(),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: context.colors.outlineVariant),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.chat_bubble_outline_rounded,
                            size: 14, color: context.colors.primary),
                        const SizedBox(width: 5),
                        Text(
                          '常用語',
                          style:
                              Theme.of(context).textTheme.labelMedium?.copyWith(
                                    color: context.colors.textPrimary,
                                  ),
                        ),
                        const SizedBox(width: 2),
                        Icon(Icons.arrow_drop_down,
                            size: 16, color: context.colors.textSecondary),
                      ],
                    ),
                  ),
                ),
              const Spacer(),
              // ── Model selector ────────────────────────────────────
              PopupMenuButton<String>(
                initialValue: _selectedModel,
                tooltip: '選擇模型',
                onSelected: (m) {
                  setState(() => _selectedModel = m);
                  widget.onModelChanged?.call(m);
                },
                itemBuilder: (_) => widget.models
                    .map((m) => PopupMenuItem(
                          value: m,
                          child: Text(m,
                              style:
                                  Theme.of(context).textTheme.bodyMedium),
                        ))
                    .toList(),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    border:
                        Border.all(color: context.colors.outlineVariant),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_awesome_outlined,
                          size: 14, color: context.colors.primary),
                      const SizedBox(width: 5),
                      Text(
                        _selectedModel,
                        style:
                            Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: context.colors.textPrimary,
                                ),
                      ),
                      const SizedBox(width: 2),
                      Icon(Icons.arrow_drop_down,
                          size: 16,
                          color: context.colors.textSecondary),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        // ── Text input ──────────────────────────────────────────────
        Focus(
          onKeyEvent: _handleKeyEvent,
          child: TextField(
            key: const Key('main_message_input'),
            controller: _controller,
            focusNode: _focusNode,
            maxLines: null,
            minLines: 1,
            enabled: widget.enabled && !widget.isStreaming,
            onChanged: (_) => setState(() {}),
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            decoration: InputDecoration(
              hintText: 'Shift+Enter 送出，Enter 換行…',
              constraints: const BoxConstraints(minHeight: 56, maxHeight: 200),
              suffixIcon: widget.isStreaming
                  ? _LocalIconButton(
                      onPressed: widget.onStop,
                      icon: const Icon(Icons.stop_circle_outlined),
                      tooltip: '停止串流 Escape',
                    )
                  : _LocalIconButton(
                      key: const Key('main_send_button'),
                      onPressed: _canSend ? _handleSend : null,
                      icon: Icon(
                        Icons.send,
                        color: _canSend ? colors.primary : colors.textDisabled,
                      ),
                      tooltip: 'Shift+Enter 送出',
                    ),
            ),
          ),
        ),
        if (widget.statusText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, right: 4),
            child: Text(
              widget.statusText!,
              style: theme.textTheme.labelSmall
                  ?.copyWith(color: colors.textSecondary),
              textAlign: TextAlign.end,
            ),
          ),
      ],
    );
  }
}

// _LocalIconButton is a private wrapper so this file compiles standalone.
// The exported API uses AppIconButton from app_button.dart.
class _LocalIconButton extends StatelessWidget {
  const _LocalIconButton({
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
