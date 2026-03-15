import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'theme/theme.dart';
import 'widgets/widgets.dart';
import 'models/role.dart' as rm show Role, AgentStatus;
import 'models/message.dart' as mm show Message, MessageRole;
import 'providers/connection_provider.dart' show connectionProvider;
import 'services/websocket_service.dart' as ws;
import 'providers/roles_provider.dart';
import 'providers/messages_provider.dart';
import 'providers/permission_provider.dart';
import 'providers/sdk_server_service_provider.dart';
import 'providers/app_startup_provider.dart';
import 'providers/server_process_provider.dart';
import 'providers/models_provider.dart';
import 'providers/enabled_roles_provider.dart';
import 'providers/quick_phrases_provider.dart';

// ── Role models ───────────────────────────────────────────────────────────────

class _Role {
  const _Role({
    required this.name,
    required this.initial,
    required this.avatarColor,
    required this.state,
    required this.lastActivityTime,
    this.currentIssue,
    // ignore: unused_element_parameter — will be wired to real unread count
    this.unread = 0,
  });

  final String name;
  final String initial;
  final Color avatarColor;
  final ConnectionStatus state;
  final DateTime lastActivityTime;
  /// e.g. '#3 記錄決策：狀態管理策略' — null when idle with no active issue
  final String? currentIssue;
  final int unread;
}

String _relativeTime(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inSeconds < 60) return '剛剛';
  if (diff.inMinutes < 60) return '${diff.inMinutes} 分鐘前';
  if (diff.inHours < 24) return '${diff.inHours} 小時前';
  return '${diff.inDays} 天前';
}

String _formatConversation(List<mm.Message> messages, String roleName) {
  final now = DateTime.now();
  final ts =
      '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} '
      '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  final buf = StringBuffer();
  buf.writeln('[$roleName] $ts');
  buf.writeln('─' * 48);
  for (final msg in messages) {
    switch (msg.role) {
      case mm.MessageRole.user:
        buf.writeln('USER: ${msg.content}');
      case mm.MessageRole.tool:
        buf.writeln('[${msg.toolName ?? 'tool'}] ${msg.content}');
      case mm.MessageRole.assistant:
        // Inline tool calls as [name] args
        final parts = _parseAssistantParts(msg.content);
        final lines = parts.map((p) => switch (p) {
              _TextPart(:final text) => text,
              _ToolPart(:final name, :final args) =>
                args.isEmpty ? '[$name]' : '[$name] $args',
            });
        buf.writeln('A: ${lines.join('\n')}');
    }
    buf.writeln();
  }
  return buf.toString().trimRight();
}

// ── Tool call parsing ─────────────────────────────────────────────────────────

sealed class _MsgPart {}

class _TextPart extends _MsgPart {
  _TextPart(this.text);
  final String text;
}

class _ToolPart extends _MsgPart {
  _ToolPart(this.name, this.args);
  final String name;
  final String args;
}

/// Parse assistant text into alternating text / tool-call parts.
/// [[tool_name] args] blocks become _ToolPart; everything else is _TextPart.
List<_MsgPart> _parseAssistantParts(String raw) {
  final regex = RegExp(r'\[\[(\w[\w_-]*)\]([\s\S]*?)\][ \t]*\n?', multiLine: true);
  final parts = <_MsgPart>[];
  int last = 0;
  for (final m in regex.allMatches(raw)) {
    if (m.start > last) {
      final t = raw.substring(last, m.start).trim();
      if (t.isNotEmpty) parts.add(_TextPart(t));
    }
    parts.add(_ToolPart(m.group(1)!, m.group(2)!.trim()));
    last = m.end;
  }
  if (last < raw.length) {
    final t = raw.substring(last).trim();
    if (t.isNotEmpty) parts.add(_TextPart(t));
  }
  return parts;
}

// ── Inline tool-call block ────────────────────────────────────────────────────

/// Styled block for a single [[tool_name] args] inline in the message stream.
class _ToolCallBlock extends StatelessWidget {
  const _ToolCallBlock({required this.name, required this.args});
  final String name;
  final String args;

  /// Colour coding by tool category.
  static Color _accentFor(String name) {
    if (name == 'bash') return const Color(0xFFD97706);
    if (name == 'report_intent') return const Color(0xFF6366F1);
    if (name.startsWith('read') || name.startsWith('view')) {
      return const Color(0xFF0EA5E9);
    }
    if (name.startsWith('edit') || name.startsWith('write') ||
        name.startsWith('create')) {
      return const Color(0xFF10B981);
    }
    return const Color(0xFF8B5CF6);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = _accentFor(name);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Container(
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.07),
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(6),
            bottomRight: Radius.circular(6),
          ),
          border: Border(left: BorderSide(color: accent, width: 3)),
        ),
        padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tool name badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                name,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: accent,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            // Args (only if non-empty)
            if (args.isNotEmpty) ...[
              const SizedBox(height: 3),
              Text(
                args,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                  fontFamily: 'monospace',
                  fontSize: 11,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Directory tree model ──────────────────────────────────────────────────────

class _Node {
  _Node.folder(this.name, this.children, {this.modified = false});
  _Node.file(this.name, {this.modified = false}) : children = null;

  final String name;
  final List<_Node>? children;
  final bool modified;

  bool get isFolder => children != null;
}

/// Mock directory trees per role.
final _roleTrees = <String, List<_Node>>{
  'App': [
    _Node.folder('lib', [
      _Node.folder('theme', [
        _Node.file('app_colors.dart', modified: true),
        _Node.file('app_theme.dart', modified: true),
        _Node.file('app_typography.dart', modified: true),
        _Node.file('theme.dart', modified: true),
      ], modified: true),
      _Node.folder('widgets', [
        _Node.file('app_button.dart', modified: true),
        _Node.file('app_card.dart', modified: true),
        _Node.file('app_chip.dart', modified: true),
        _Node.file('chat_message.dart', modified: true),
        _Node.file('code_block.dart', modified: true),
        _Node.file('loading_widgets.dart', modified: true),
        _Node.file('widgets.dart', modified: true),
      ], modified: true),
      _Node.file('demo_page.dart', modified: true),
      _Node.file('main.dart', modified: true),
    ]),
    _Node.file('pubspec.yaml', modified: true),
  ],
  'Spec': [
    _Node.folder('shared', [
      _Node.file('overview.md', modified: true),
      _Node.file('design_tokens.md', modified: true),
    ], modified: true),
    _Node.folder('app', [
      _Node.file('tech_stack.md', modified: true),
    ]),
    _Node.folder('server', [
      _Node.file('overview.md', modified: true),
    ]),
    _Node.folder('decisions', [
      _Node.file('README.md'),
      _Node.file('260312_001_NoDBNoSync.md', modified: true),
      _Node.file('260312_002_DesktopArch.md', modified: true),
      _Node.file('260312_003_DarkMode.md', modified: true),
      _Node.file('260312_004_MinFont.md', modified: true),
    ], modified: true),
    _Node.file('README.md'),
  ],
  'UX': [
    _Node.folder('guidelines', [
      _Node.file('colors.md', modified: true),
      _Node.file('typography.md', modified: true),
      _Node.folder('components', [
        _Node.file('button.md', modified: true),
        _Node.file('card.md', modified: true),
        _Node.file('chat_message.md', modified: true),
        _Node.file('chip.md', modified: true),
        _Node.file('code_block.md', modified: true),
        _Node.file('dialog.md', modified: true),
        _Node.file('navigation_rail.md', modified: true),
        _Node.file('snackbar.md', modified: true),
        _Node.file('status_indicator.md', modified: true),
        _Node.file('text_field.md', modified: true),
        _Node.file('tooltip.md', modified: true),
      ], modified: true),
    ], modified: true),
    _Node.folder('patterns', [
      _Node.file('ai_conversation.md', modified: true),
      _Node.file('error_handling.md', modified: true),
      _Node.file('keyboard_shortcuts.md', modified: true),
      _Node.file('loading_empty.md', modified: true),
      _Node.file('navigation.md', modified: true),
    ], modified: true),
  ],
  'Server': [
    _Node.folder('src', [
      _Node.file('index.ts'),
    ]),
    _Node.file('package.json'),
  ],
  'QA': [
    _Node.folder('test', [
      _Node.file('widget_test.dart'),
    ]),
  ],
  'Data': [
    _Node.folder('migrations', []),
    _Node.folder('schema', []),
  ],
};

// ── Demo page ─────────────────────────────────────────────────────────────────

// Maps role ID to a display name.
String _displayNameForId(String id) {
  const known = {
    'app': 'App', 'spec': 'Spec', 'server': 'Server', 'qa': 'QA',
    'data': 'Data', 'ux': 'UX', 'ops': 'Ops', 'docs': 'Docs',
    'release': 'Release', 'i18n': 'i18n',
  };
  final lower = id.toLowerCase();
  return known[lower] ?? (id.isNotEmpty ? id[0].toUpperCase() + id.substring(1) : id);
}

// Maps role ID to an avatar initial.
String _initialForId(String id) {
  const known = {
    'app': 'A', 'spec': 'S', 'server': 'Sv', 'qa': 'Q',
    'data': 'D', 'ux': 'U', 'ops': 'O', 'docs': 'Dc',
    'release': 'R', 'i18n': 'I',
  };
  return known[id.toLowerCase()] ?? (id.isNotEmpty ? id[0].toUpperCase() : '?');
}

// Deterministic color from role ID.
Color _avatarColorForId(String id) {
  const palette = [
    Color(0xFF0B2D72), Color(0xFF0992C2), Color(0xFF0AC4E0),
    Color(0xFF6B7280), Color(0xFF16A34A), Color(0xFF7C3AED),
    Color(0xFFDC2626), Color(0xFFD97706),
  ];
  return palette[id.hashCode.abs() % palette.length];
}

// Converts a real Role to the local _Role display model.
_Role _roleFromReal(rm.Role r) => _Role(
      name: _displayNameForId(r.id),
      initial: _initialForId(r.id),
      avatarColor: _avatarColorForId(r.id),
      state: agentStatusToConnection(r.status),
      lastActivityTime: DateTime.now(),
      currentIssue: r.currentTask,
    );

class DemoPage extends ConsumerStatefulWidget {
  const DemoPage({super.key});

  @override
  ConsumerState<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends ConsumerState<DemoPage> {
  String _selectedRole = 'App';
  final _scrollCtrl = ScrollController();

  double _leftWidth = 248;
  double _rightWidth = 240;
  bool _leftCollapsed = false;
  bool _rightCollapsed = false;
  static const double _minPanelWidth = 160;
  static const double _maxPanelWidth = 480;
  static const double _collapsedWidth = 52;

  Timer? _timer;

  @override
  void initState() {
    super.initState();
  }

  void _stopStream() {
    _timer?.cancel();
  }

  bool get _isStreaming => false;

  /// Renders a real [mm.Message] from the provider.
  Widget _buildRealMessage(mm.Message msg,
      {required bool isLast, required bool isStreaming}) {
    switch (msg.role) {
      case mm.MessageRole.user:
        return UserMessage(text: msg.content);
      case mm.MessageRole.tool:
        return _ToolCallBlock(
          name: msg.toolName ?? 'tool',
          args: msg.content,
        );
      case mm.MessageRole.assistant:
        final parts = _parseAssistantParts(msg.content);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: parts.map((part) => switch (part) {
            _TextPart(:final text) => AiMessage(
                text: text,
                isStreaming: isLast && isStreaming,
              ),
            _ToolPart(:final name, :final args) => _ToolCallBlock(
                name: name,
                args: args,
              ),
          }).toList(),
        );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    // ── Real data from providers ──────────────────────────────────────────────
    final connStatus    = ref.watch(connectionProvider);
    final isConnected   = connStatus == ws.ConnectionStatus.connected;
    final realRolesMap  = ref.watch(rolesProvider);
    final enabledIds    = ref.watch(enabledRolesProvider);
    final displayRoles  = realRolesMap.values
        .where((r) => enabledIds.contains(r.id))
        .map(_roleFromReal)
        .toList();

    // Ensure _selectedRole is valid within displayRoles.
    final validName = displayRoles.any((r) => r.name == _selectedRole)
        ? _selectedRole
        : displayRoles.isNotEmpty
            ? displayRoles.first.name
            : _selectedRole;

    final selectedRoleId   = validName.toLowerCase();
    final realMessages     = ref.watch(messagesProvider(selectedRoleId));
    final realPermissions  = ref.watch(permissionsProvider);
    final selectedPerm     = realPermissions[selectedRoleId];

    // Auto-scroll to bottom whenever messages change (new message or streaming chunk).
    ref.listen(messagesProvider(selectedRoleId), (prev, next) {
      WidgetsBinding.instance.addPostFrameCallback((ts) {
        if (_scrollCtrl.hasClients) {
          _scrollCtrl.animateTo(
            _scrollCtrl.position.maxScrollExtent,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
          );
        }
      });
    });

    // Streaming: real mode → role is running; demo mode → char animation.
    final selectedRealRole  = realRolesMap[selectedRoleId];
    final effectiveStreaming = isConnected
        ? (selectedRealRole?.status == rm.AgentStatus.running)
        : _isStreaming;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final showSidePanels = constraints.maxWidth >= _leftWidth + _rightWidth;
          return Row(
            children: [
              // ── Left: Role friends list ──────────────────────────────────
              if (showSidePanels) ...[
                SizedBox(
                  width: _leftCollapsed ? _collapsedWidth : _leftWidth,
                  child: _RoleSidebar(
                    roles: displayRoles,
                    selectedName: validName,
                    onSelect: (name) {
                      setState(() => _selectedRole = name);
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (_scrollCtrl.hasClients) {
                          _scrollCtrl.jumpTo(_scrollCtrl.position.maxScrollExtent);
                        }
                      });
                    },
                    collapsed: _leftCollapsed,
                    onToggleCollapse: () =>
                        setState(() => _leftCollapsed = !_leftCollapsed),
                  ),
                ),
                if (!_leftCollapsed)
                  _ResizeDivider(
                    color: colors.outlineVariant,
                    onDelta: (dx) => setState(() {
                      final next = (_leftWidth + dx).clamp(
                        _collapsedWidth,
                        _maxPanelWidth,
                      );
                      if (next < 120) {
                        _leftCollapsed = true;
                      } else {
                        _leftWidth = next;
                        _leftCollapsed = false;
                      }
                    }),
                  )
                else
                  VerticalDivider(width: 1, color: colors.outlineVariant),
              ],

              // ── Center: Chat ─────────────────────────────────────────────
              Expanded(
                child: Column(
                  children: [
                    _ChatTopBar(roleName: validName, roleId: selectedRoleId, isStreaming: effectiveStreaming),

                    Expanded(
                      child: isConnected
                          ? ListView(
                              controller: _scrollCtrl,
                              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                              children: [
                                if (realMessages.isNotEmpty) ...[
                                  for (int i = 0; i < realMessages.length; i++) ...[
                                    _buildRealMessage(realMessages[i],
                                        isLast: i == realMessages.length - 1,
                                        isStreaming: effectiveStreaming),
                                    const SizedBox(height: 16),
                                  ],
                                ],
                                // Permission card (real).
                                if (selectedPerm != null)
                                  _PermissionCard(
                                    prompt: selectedPerm.question,
                                    onAllow: () async {
                                      await ref
                                          .read(sdkServerServiceProvider)
                                          .respondToPermission(
                                              selectedRoleId, selectedPerm.requestId, true);
                                      ref
                                          .read(permissionsProvider.notifier)
                                          .removeRequest(selectedRoleId);
                                    },
                                    onDeny: () async {
                                      await ref
                                          .read(sdkServerServiceProvider)
                                          .respondToPermission(
                                              selectedRoleId, selectedPerm.requestId, false);
                                      ref
                                          .read(permissionsProvider.notifier)
                                          .removeRequest(selectedRoleId);
                                    },
                                  ),
                                const SizedBox(height: 24),
                              ],
                            )
                          : _DisconnectedPlaceholder(connStatus: connStatus),
                    ),

                    Container(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
                      decoration: BoxDecoration(
                        color: colors.background,
                        border: Border(
                          top: BorderSide(color: colors.outlineVariant),
                        ),
                      ),
                      child: AiChatInput(
                        onSend: (text) {
                          if (text.trim().isNotEmpty) {
                            ref
                                .read(messagesProvider(selectedRoleId).notifier)
                                .addUserMessage(text);
                            ref
                                .read(sdkServerServiceProvider)
                                .sendMessage(selectedRoleId, text)
                                .ignore();
                          }
                        },
                        enabled: isConnected,
                        isStreaming: effectiveStreaming,
                        onStop: isConnected
                            ? () => ref
                                .read(sdkServerServiceProvider)
                                .interrupt(selectedRoleId)
                                .ignore()
                            : _stopStream,
                        statusText: effectiveStreaming ? '串流中…' : null,
                        models: ref.watch(availableModelsProvider).when(
                              data: (m) => m,
                              loading: () => const ['claude-sonnet-4.6'],
                              error: (err, st) => const ['claude-sonnet-4.6'],
                            ),
                        quickPhrases: ref.watch(quickPhrasesProvider),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Right: Directory panel ────────────────────────────────────
              if (showSidePanels) ...[
                if (!_rightCollapsed)
                  _ResizeDivider(
                    color: colors.outlineVariant,
                    onDelta: (dx) => setState(() {
                      _rightWidth = (_rightWidth - dx).clamp(
                        _minPanelWidth,
                        _maxPanelWidth,
                      );
                    }),
                  )
                else
                  VerticalDivider(width: 1, color: colors.outlineVariant),
                SizedBox(
                  width: _rightCollapsed ? _collapsedWidth : _rightWidth,
                  child: _DirectoryPanel(
                    roleName: validName,
                    collapsed: _rightCollapsed,
                    onToggleCollapse: () =>
                        setState(() => _rightCollapsed = !_rightCollapsed),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

// ── Disconnected placeholder ──────────────────────────────────────────────────

class _DisconnectedPlaceholder extends ConsumerWidget {
  const _DisconnectedPlaceholder({required this.connStatus});
  final ws.ConnectionStatus connStatus;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final theme = Theme.of(context);
    final startupState = ref.watch(appStartupProvider);

    final isLoading = startupState.phase != StartupPhase.ready &&
        startupState.phase != StartupPhase.idle &&
        startupState.phase != StartupPhase.error;

    final (icon, label, sublabel) = switch (connStatus) {
      ws.ConnectionStatus.connecting => (
          Icons.sync_outlined,
          '連線中…',
          '正在啟動 SDK Server，請稍候',
        ),
      ws.ConnectionStatus.error => (
          Icons.error_outline,
          '連線失敗',
          startupState.error ?? '無法連線到 SDK Server，請確認設定後重試',
        ),
      _ => (
          Icons.power_settings_new_outlined,
          '未連線',
          '啟動 SDK Server 後即可開始對話',
        ),
    };

    final phaseLabel = switch (startupState.phase) {
      StartupPhase.loadingEnv => '讀取設定中…',
      StartupPhase.startingServer => '啟動 Server 中…',
      StartupPhase.configuring => '設定 SDK 中…',
      StartupPhase.connecting => '連接 WebSocket 中…',
      _ => null,
    };

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLoading)
            const SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            Icon(icon, size: 48, color: colors.textSecondary.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          Text(
            isLoading ? (phaseLabel ?? '啟動中…') : label,
            style: theme.textTheme.titleMedium?.copyWith(
              color: colors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            sublabel,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.textSecondary.withValues(alpha: 0.6),
            ),
          ),
          if (!isLoading && connStatus != ws.ConnectionStatus.connecting) ...[
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () =>
                  ref.read(appStartupProvider.notifier).initialize(forceConnect: true),
              icon: const Icon(Icons.power_settings_new, size: 16),
              label: Text(
                connStatus == ws.ConnectionStatus.error ? '重新連線' : '連線',
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Resizable divider ─────────────────────────────────────────────────────────

class _ResizeDivider extends StatefulWidget {
  const _ResizeDivider({required this.color, required this.onDelta});
  final Color color;
  final ValueChanged<double> onDelta;

  @override
  State<_ResizeDivider> createState() => _ResizeDividerState();
}

class _ResizeDividerState extends State<_ResizeDivider> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onHorizontalDragUpdate: (d) => widget.onDelta(d.delta.dx),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 4,
          color: _hovering
              ? widget.color.withValues(alpha: 0.6)
              : widget.color,
        ),
      ),
    );
  }
}

// ── Role sidebar ──────────────────────────────────────────────────────────────

class _RoleSidebar extends ConsumerStatefulWidget {
  const _RoleSidebar({
    required this.roles,
    required this.selectedName,
    required this.onSelect,
    required this.collapsed,
    required this.onToggleCollapse,
  });

  final List<_Role> roles;
  final String selectedName;
  final ValueChanged<String> onSelect;
  final bool collapsed;
  final VoidCallback onToggleCollapse;

  @override
  ConsumerState<_RoleSidebar> createState() => _RoleSidebarState();
}

class _RoleSidebarState extends ConsumerState<_RoleSidebar> {
  late List<_Role> _ordered;

  @override
  void initState() {
    super.initState();
    _ordered = List.of(widget.roles);
  }

  @override
  void didUpdateWidget(_RoleSidebar old) {
    super.didUpdateWidget(old);
    if (old.roles != widget.roles) {
      // Preserve existing order; append new roles at the end; drop removed ones.
      final incoming = {for (final r in widget.roles) r.name: r};
      _ordered = [
        ..._ordered
            .where((r) => incoming.containsKey(r.name))
            .map((r) => incoming[r.name]!),
        ...widget.roles.where(
          (r) => !_ordered.any((o) => o.name == r.name),
        ),
      ];
    }
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      final item = _ordered.removeAt(oldIndex);
      _ordered.insert(newIndex, item);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context);
    final connStatus = ref.watch(connectionProvider);
    final serverState = ref.watch(serverProcessProvider);

    return LayoutBuilder(builder: (context, constraints) {
      final effectivelyCollapsed =
          widget.collapsed || constraints.maxWidth < 120;

      if (effectivelyCollapsed) {
        return Container(
          color: colors.surface,
          child: Column(
            children: [
              SizedBox(
                height: 56,
                child: Center(
                  child: IconButton(
                    icon: Icon(Icons.keyboard_double_arrow_right,
                        size: 18, color: colors.textSecondary),
                    tooltip: '展開',
                    onPressed: widget.onToggleCollapse,
                  ),
                ),
              ),
              Container(height: 1, color: colors.outlineVariant),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  itemCount: _ordered.length,
                  itemBuilder: (_, i) {
                    final role = _ordered[i];
                    return Tooltip(
                      key: ValueKey(role.name),
                      message: role.name,
                      preferBelow: false,
                      child: InkWell(
                        onTap: () => widget.onSelect(role.name),
                        child: Container(
                          height: 44,
                          alignment: Alignment.center,
                          child: _RoleAvatar(role: role),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(height: 1, color: colors.outlineVariant),
              _SystemStatusButton(
                collapsed: true,
                connStatus: connStatus,
                serverState: serverState,
              ),
            ],
          ),
        );
      }

      return Container(
        color: colors.surface,
        child: Column(
          children: [
            Container(
              height: 56,
              padding: const EdgeInsets.only(left: 16, right: 4),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: colors.outlineVariant),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.smart_toy_outlined,
                      size: 20, color: colors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'MyAi 助理',
                      style: theme.textTheme.titleSmall
                          ?.copyWith(color: colors.textPrimary),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.keyboard_double_arrow_left,
                        size: 18, color: colors.textSecondary),
                    tooltip: '最小化',
                    onPressed: widget.onToggleCollapse,
                  ),
                ],
              ),
            ),
            Expanded(
              child: ReorderableListView.builder(
                key: const Key('main_role_list'),
                padding: const EdgeInsets.symmetric(vertical: 6),
                itemCount: _ordered.length,
                onReorderItem: _onReorder,
                proxyDecorator: (child, index, animation) => Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.transparent,
                  child: child,
                ),
                itemBuilder: (_, i) => _RoleItem(
                  key: ValueKey(_ordered[i].name),
                  role: _ordered[i],
                  selected: _ordered[i].name == widget.selectedName,
                  onTap: () => widget.onSelect(_ordered[i].name),
                ),
              ),
            ),
            Container(height: 1, color: colors.outlineVariant),
            _SystemStatusButton(
              collapsed: false,
              connStatus: connStatus,
              serverState: serverState,
            ),
          ],
        ),
      );
    }); // LayoutBuilder
  }
}

// ── System Status Button ───────────────────────────────────────────────────────

class _SystemStatusButton extends StatelessWidget {
  const _SystemStatusButton({
    required this.collapsed,
    required this.connStatus,
    required this.serverState,
  });

  final bool collapsed;
  final ws.ConnectionStatus connStatus;
  final ServerProcessState serverState;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isActive = serverState.status == ServerStatus.running &&
        connStatus == ws.ConnectionStatus.connected;
    final dotColor = isActive
        ? const Color(0xFF22C55E)
        : serverState.status == ServerStatus.error ||
                connStatus == ws.ConnectionStatus.error
            ? const Color(0xFFEF4444)
            : const Color(0xFF888888);

    void navigate() => context.push('/status');

    if (collapsed) {
      return SizedBox(
        height: 48,
        child: Center(
          child: Tooltip(
            message: '系統設定',
            child: InkWell(
              onTap: navigate,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(Icons.info_outline, size: 20,
                        color: colors.textSecondary),
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: dotColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: colors.surface, width: 1),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return InkWell(
      onTap: navigate,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(Icons.info_outline, size: 18, color: colors.textSecondary),
              Positioned(
                right: -2,
                bottom: -2,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.surface, width: 1),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          Text(
            '系統設定',
            style: TextStyle(fontSize: 13, color: colors.textSecondary),
          ),
          const Spacer(),
          Container(
            width: 8,
            height: 8,
            decoration:
                BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
        ]),
      ),
    );
  }
}

class _RoleItem extends StatelessWidget {
  const _RoleItem({
    super.key,
    required this.role,
    required this.selected,
    required this.onTap,
  });

  final _Role role;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context);
    final isWaiting = role.state == ConnectionStatus.waiting;
    final hasIssue = role.currentIssue != null;
    final issueText = hasIssue ? role.currentIssue! : '待命中';
    final timeText = _relativeTime(role.lastActivityTime);
    const waitingColor = Color(0xFFF97316);

    return InkWell(
      key: Key('main_role_item_${role.name.toLowerCase()}'),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        clipBehavior: Clip.hardEdge,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: isWaiting && !selected
              ? waitingColor.withValues(alpha: 0.08)
              : selected
                  ? colors.surfaceVariant
                  : Colors.transparent,
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          border: isWaiting
              ? Border.all(color: waitingColor.withValues(alpha: 0.4))
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _RoleAvatar(role: role),
            const SizedBox(width: 12),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final showTime = constraints.maxWidth >= 160;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  // Row 1: Role name + unread badge
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          role.name,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: colors.textPrimary,
                            fontWeight: role.unread > 0
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (role.unread > 0 && showTime) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: colors.primary,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10)),
                          ),
                          child: Text(
                            '${role.unread}',
                            style: theme.textTheme.labelSmall
                                ?.copyWith(color: colors.onPrimary),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  // Row 2: issue/status + time
                  Row(
                    children: [
                      if (isWaiting)
                        const Padding(
                          padding: EdgeInsets.only(right: 4),
                          child: Icon(Icons.touch_app_outlined,
                              size: 14, color: waitingColor),
                        ),
                      Expanded(
                        child: Text(
                          isWaiting ? '需要確認 — 點此處理' : issueText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: isWaiting
                                ? waitingColor
                                : hasIssue
                                    ? colors.textPrimary
                                    : colors.textSecondary,
                            fontWeight: isWaiting ? FontWeight.w600 : null,
                          ),
                        ),
                      ),
                      if (showTime) ...[
                        const SizedBox(width: 6),
                        Flexible(
                          fit: FlexFit.loose,
                          child: Text(
                            timeText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleAvatar extends StatefulWidget {
  const _RoleAvatar({required this.role});
  final _Role role;

  @override
  State<_RoleAvatar> createState() => _RoleAvatarState();
}

class _RoleAvatarState extends State<_RoleAvatar> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: Stack(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: widget.role.avatarColor.withAlpha(220),
            child: Text(
              widget.role.initial,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                height: 1,
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Semantics(
              label: 'role-${widget.role.name.toLowerCase()}-status-${widget.role.state.name}',
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.surface,
                    width: 2,
                  ),
                ),
                child: StatusDot(status: widget.role.state, size: 11),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Chat top bar ──────────────────────────────────────────────────────────────

class _ChatTopBar extends ConsumerWidget {
  const _ChatTopBar({
    required this.roleName,
    required this.roleId,
    required this.isStreaming,
  });
  final String roleName;
  final String roleId;
  final bool isStreaming;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final theme = Theme.of(context);
    final role = ref.watch(rolesProvider.select((m) => m[roleId]));

    final indicatorStatus = switch (role?.status) {
      rm.AgentStatus.running  => ConnectionStatus.running,
      rm.AgentStatus.waiting  => ConnectionStatus.waiting,
      rm.AgentStatus.error    => ConnectionStatus.error,
      rm.AgentStatus.offline  => ConnectionStatus.disconnected,
      rm.AgentStatus.idle     => ConnectionStatus.connected,
      rm.AgentStatus.done     => ConnectionStatus.connected,
      null                    => ConnectionStatus.disconnected,
    };

    // During streaming, always show running regardless of server status
    final effectiveStatus = isStreaming ? ConnectionStatus.running : indicatorStatus;

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(bottom: BorderSide(color: colors.outlineVariant)),
      ),
      child: Row(
        children: [
          Flexible(
            child: Text(
              roleName,
              style: theme.textTheme.titleLarge?.copyWith(color: colors.textPrimary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          StatusIndicator(status: effectiveStatus),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.content_copy, size: 18),
            tooltip: '複製對話',
            onPressed: () {
              final messages = ref.read(messagesProvider(roleId));
              final text = _formatConversation(messages, roleName);
              Clipboard.setData(ClipboardData(text: text));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('對話已複製到剪貼板'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ── Directory panel ───────────────────────────────────────────────────────────

class _DirectoryPanel extends StatefulWidget {
  const _DirectoryPanel({
    required this.roleName,
    required this.collapsed,
    required this.onToggleCollapse,
  });
  final String roleName;
  final bool collapsed;
  final VoidCallback onToggleCollapse;

  @override
  State<_DirectoryPanel> createState() => _DirectoryPanelState();
}

class _DirectoryPanelState extends State<_DirectoryPanel> {
  // Tracks which folder paths are expanded. Key = dot-joined path.
  final Set<String> _expanded = {};

  @override
  void initState() {
    super.initState();
    _setDefaultExpanded(widget.roleName);
  }

  @override
  void didUpdateWidget(_DirectoryPanel old) {
    super.didUpdateWidget(old);
    if (old.roleName != widget.roleName) {
      _expanded.clear();
      _setDefaultExpanded(widget.roleName);
    }
  }

  void _setDefaultExpanded(String role) {
    // Auto-expand the top-level and modified folders.
    final nodes = _roleTrees[role] ?? [];
    for (final n in nodes) {
      if (n.isFolder && n.modified) _expanded.add(n.name);
      if (n.isFolder) {
        for (final child in n.children!) {
          if (child.isFolder && child.modified) {
            _expanded.add('${n.name}.${child.name}');
          }
        }
      }
    }
  }

  void _toggle(String path) =>
      setState(() => _expanded.contains(path)
          ? _expanded.remove(path)
          : _expanded.add(path));

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context);
    final nodes = _roleTrees[widget.roleName] ?? [];
    final rootLabel = switch (widget.roleName) {
      'App' => 'app/code/',
      'Spec' => 'spec/',
      'UX' => 'ux/',
      'Server' => 'server/',
      'QA' => 'app/code/',
      _ => '${widget.roleName.toLowerCase()}/',
    };

    if (widget.collapsed) {
      return Container(
        color: colors.surface,
        child: Column(
          children: [
            SizedBox(
              height: 56,
              child: Center(
                child: IconButton(
                  icon: Icon(Icons.keyboard_double_arrow_left,
                      size: 18, color: colors.textSecondary),
                  tooltip: '展開',
                  onPressed: widget.onToggleCollapse,
                ),
              ),
            ),
            Container(height: 1, color: colors.outlineVariant),
          ],
        ),
      );
    }

    return Container(
      color: colors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            height: 56,
            padding: const EdgeInsets.only(left: 16, right: 4),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: colors.outlineVariant),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.folder_open_outlined,
                    size: 18, color: colors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    rootLabel,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(color: colors.textPrimary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.keyboard_double_arrow_right,
                      size: 18, color: colors.textSecondary),
                  tooltip: '最小化',
                  onPressed: widget.onToggleCollapse,
                ),
              ],
            ),
          ),

          // Tree
          Expanded(
            child: nodes.isEmpty
                ? Center(
                    child: Text(
                      '尚無檔案',
                      style: theme.textTheme.labelSmall
                          ?.copyWith(color: colors.textSecondary),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    children: nodes
                        .map((n) => _buildNode(n, 0, n.name))
                        .toList(),
                  ),
          ),

          // Footer: settings menu (removed — settings are now in 系統設定 page)
        ],
      ),
    );
  }

  Widget _buildNode(_Node node, int depth, String path) {
    if (node.isFolder) {
      final isOpen = _expanded.contains(path);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TreeRow(
            name: node.name,
            depth: depth,
            isFolder: true,
            isOpen: isOpen,
            modified: node.modified,
            onTap: () => _toggle(path),
          ),
          if (isOpen)
            for (final child in node.children!)
              _buildNode(child, depth + 1, '$path.${child.name}'),
        ],
      );
    }
    return _TreeRow(
      name: node.name,
      depth: depth,
      isFolder: false,
      modified: node.modified,
    );
  }
}

class _TreeRow extends StatelessWidget {
  const _TreeRow({
    required this.name,
    required this.depth,
    required this.isFolder,
    this.isOpen = false,
    this.modified = false,
    this.onTap,
  });

  final String name;
  final int depth;
  final bool isFolder;
  final bool isOpen;
  final bool modified;
  final VoidCallback? onTap;

  IconData get _icon {
    if (isFolder) return isOpen ? Icons.folder_open : Icons.folder_outlined;
    if (name.endsWith('.dart')) return Icons.code;
    if (name.endsWith('.md')) return Icons.article_outlined;
    if (name.endsWith('.yaml') || name.endsWith('.json')) {
      return Icons.settings_outlined;
    }
    return Icons.insert_drive_file_outlined;
  }

  Color _iconColor(AppColors c) {
    if (isFolder) return const Color(0xFFE8A317); // amber folder
    if (name.endsWith('.dart')) return const Color(0xFF54C5F8); // dart blue
    if (name.endsWith('.md')) return const Color(0xFF9ECBFF);   // md light blue
    return c.textSecondary;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(
          left: 12.0 + depth * 16.0,
          right: 8,
          top: 3,
          bottom: 3,
        ),
        child: Row(
          children: [
            // Expand arrow for folders
            SizedBox(
              width: 16,
              child: isFolder
                  ? Icon(
                      isOpen
                          ? Icons.arrow_drop_down
                          : Icons.arrow_right,
                      size: 16,
                      color: colors.textSecondary,
                    )
                  : null,
            ),
            const SizedBox(width: 2),
            Icon(_icon, size: 16, color: _iconColor(colors)),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                name,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.textPrimary,
                  fontWeight:
                      modified ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            // Modified dot
            if (modified)
              Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.only(left: 4),
                decoration: BoxDecoration(
                  color: colors.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
// ── Permission / consent card ─────────────────────────────────────────────────

class _PermissionCard extends StatefulWidget {
  const _PermissionCard({
    required this.prompt,
    this.onAllow,
    this.onDeny,
  });
  final String prompt;
  final VoidCallback? onAllow;
  final VoidCallback? onDeny;

  @override
  State<_PermissionCard> createState() => _PermissionCardState();
}

class _PermissionCardState extends State<_PermissionCard> {
  bool _responded = false;
  bool _allowed = false;

  void _respond(bool allow) {
    setState(() {
      _responded = true;
      _allowed = allow;
    });
    if (allow) {
      widget.onAllow?.call();
    } else {
      widget.onDeny?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context);
    const waitingColor = Color(0xFFF97316);

    return Container(
      key: const Key('monitor_permission_card'),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: _responded
            ? colors.surface
            : waitingColor.withValues(alpha: 0.06),
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        border: Border.all(
          color: _responded
              ? colors.outlineVariant
              : waitingColor.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                _responded
                    ? (_allowed
                        ? Icons.check_circle_outline
                        : Icons.cancel_outlined)
                    : Icons.lock_open_outlined,
                size: 20,
                color: _responded
                    ? (_allowed ? colors.success : colors.error)
                    : waitingColor,
              ),
              const SizedBox(width: 8),
              Text(
                _responded
                    ? (_allowed ? '已允許' : '已拒絕')
                    : '需要確認',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: _responded
                      ? (_allowed ? colors.success : colors.error)
                      : waitingColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Prompt text
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              border: Border.all(color: colors.outlineVariant),
            ),
            child: Text(
              widget.prompt,
              style: TextStyle(
                fontFamily: 'JetBrainsMono',
                fontSize: 18,
                height: 1.6,
                color: colors.textPrimary,
              ),
            ),
          ),

          if (!_responded) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                AppFilledButton(
                  key: const Key('monitor_permission_allow_button'),
                  onPressed: () => _respond(true),
                  child: const Text('允許'),
                ),
                const SizedBox(width: 12),
                AppOutlinedButton(
                  key: const Key('monitor_permission_deny_button'),
                  onPressed: () => _respond(false),
                  child: const Text('拒絕'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
