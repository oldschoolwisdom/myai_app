import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'theme/theme.dart';
import 'providers/connection_provider.dart' show connectionProvider;
import 'providers/server_process_provider.dart';
import 'providers/roles_provider.dart';
import 'providers/env_provider.dart';
import 'providers/app_startup_provider.dart';
import 'providers/startup_prefs_provider.dart';
import 'providers/enabled_roles_provider.dart';
import 'providers/scanned_roles_provider.dart';
import 'providers/server_binary_path_provider.dart';
import 'services/websocket_service.dart' as ws;
import 'models/role.dart' as rm;
import 'models/role_config.dart';
import 'widgets/status_indicator.dart';
import 'widgets/app_text_field.dart';
import 'providers/quick_phrases_provider.dart';
import 'models/quick_phrase.dart';

class SystemStatusPage extends ConsumerStatefulWidget {
  const SystemStatusPage({super.key});

  @override
  ConsumerState<SystemStatusPage> createState() => _SystemStatusPageState();
}

class _SystemStatusPageState extends ConsumerState<SystemStatusPage> {
  late final TextEditingController _binaryPathCtrl;
  ThemeMode _themeMode = ThemeMode.system;
  bool _streamMarkdown = true;
  final _apiKeyCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _binaryPathCtrl = TextEditingController(
      text: ref.read(serverBinaryPathProvider) ?? '',
    );
  }

  @override
  void dispose() {
    _binaryPathCtrl.dispose();
    _apiKeyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context);
    final connStatus = ref.watch(connectionProvider);
    final serverState = ref.watch(serverProcessProvider);
    final roles = ref.watch(rolesProvider);
    final enabledIds = ref.watch(enabledRolesProvider);
    final scannedRoles = ref.watch(scannedRolesProvider);
    final scannedIds = scannedRoles.map((r) => r.id).toSet();
    // All known role IDs = scanned ∪ enabled (covers orphans from myai.env)
    final allRoleIds = {...scannedIds, ...enabledIds};
    final startupState = ref.watch(appStartupProvider);
    final prefs = ref.watch(startupPrefsProvider);
    final envService = ref.read(envProvider);
    final port = int.tryParse(envService.get('AI_SERVER_PORT') ?? '') ?? 7788;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: colors.textPrimary),
          tooltip: '返回',
          onPressed: () => context.pop(),
        ),
        title: Text(
          '系統設定',
          style: theme.textTheme.titleMedium?.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: colors.outlineVariant),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        children: [
          // ── SDK Server ──────────────────────────────────────────────────
          _SectionCard(
            title: 'SDK Server',
            icon: Icons.dns_outlined,
            children: [
              _ServerStatusRow(serverState: serverState),
              if (serverState.status == ServerStatus.running &&
                  serverState.pid != null) ...[
                const SizedBox(height: 8),
                _InfoRow(label: 'PID', value: '${serverState.pid}'),
              ],
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: _ToggleRow(
                    label: '啟動時自動執行',
                    value: prefs.autoStartServer,
                    onChanged: (v) => ref
                        .read(startupPrefsProvider.notifier)
                        .setAutoStartServer(v),
                  ),
                ),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                if (serverState.status != ServerStatus.running)
                  _ActionButton(
                    label: '啟動 Server',
                    icon: Icons.play_arrow_rounded,
                    color: const Color(0xFF22C55E),
                    loading: serverState.status == ServerStatus.starting,
                    onTap: () => ref
                        .read(appStartupProvider.notifier)
                        .startServerOnly(),
                  )
                else
                  _ActionButton(
                    label: '停止 Server',
                    icon: Icons.stop_rounded,
                    color: const Color(0xFFEF4444),
                    onTap: () =>
                        ref.read(serverProcessProvider.notifier).stop(),
                  ),
                const SizedBox(width: 8),
                _ActionButton(
                  label: '重啟 Server',
                  icon: Icons.restart_alt_rounded,
                  color: colors.primary,
                  loading: startupState.phase == StartupPhase.startingServer,
                  onTap: () =>
                      ref.read(appStartupProvider.notifier).restart(),
                ),
              ]),
            ],
          ),
          const SizedBox(height: 16),

          // ── WebSocket 連線 ───────────────────────────────────────────────
          _SectionCard(
            title: 'WebSocket 連線',
            icon: Icons.cable_outlined,
            children: [
              _ConnStatusRow(connStatus: connStatus),
              const SizedBox(height: 8),
              _InfoRow(label: 'Port', value: '$port'),
              const SizedBox(height: 12),
              _ToggleRow(
                label: '啟動時自動連線',
                value: prefs.autoConnect,
                onChanged: (v) => ref
                    .read(startupPrefsProvider.notifier)
                    .setAutoConnect(v),
              ),
              const SizedBox(height: 10),
              Row(children: [
                if (connStatus != ws.ConnectionStatus.connected)
                  _ActionButton(
                    label: '連線',
                    icon: Icons.link_rounded,
                    color: const Color(0xFF22C55E),
                    loading: connStatus == ws.ConnectionStatus.connecting,
                    onTap: () => ref
                        .read(appStartupProvider.notifier)
                        .connectWs(),
                  )
                else
                  _ActionButton(
                    label: '中斷連線',
                    icon: Icons.link_off_rounded,
                    color: const Color(0xFFEF4444),
                    onTap: () => ref
                        .read(connectionProvider.notifier)
                        .disconnect(),
                  ),
              ]),
            ],
          ),
          const SizedBox(height: 16),

          // ── 啟動序列 ──────────────────────────────────────────────────────
          _SectionCard(
            title: '啟動序列',
            icon: Icons.playlist_play_rounded,
            trailing: _PhaseBadge(phase: startupState.phase),
            children: [
              if (startupState.logs.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    '（尚無記錄）',
                    style: TextStyle(
                        fontSize: 12, color: colors.textSecondary),
                  ),
                )
              else
                ...startupState.logs.map((log) => _LogRow(log: log)),
            ],
          ),
          const SizedBox(height: 16),

          // ── 角色狀態 ─────────────────────────────────────────────────────
          _SectionCard(
            title: '角色狀態',
            icon: Icons.smart_toy_outlined,
            trailing: Text(
              '${enabledIds.length} / ${allRoleIds.length} 個啟用',
              style: TextStyle(fontSize: 12, color: colors.textSecondary),
            ),
            children: allRoleIds.isEmpty
                ? [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        '尚未載入角色',
                        style: TextStyle(
                            fontSize: 12, color: colors.textSecondary),
                      ),
                    )
                  ]
                : allRoleIds.map((id) {
                    final role = roles[id];
                    final isEnabled = enabledIds.contains(id);
                    final hasPrompt = scannedIds.contains(id);
                    final config = scannedRoles
                        .where((r) => r.id == id)
                        .firstOrNull;
                    return _RoleStatusRow(
                      roleId: id,
                      role: role,
                      isEnabled: isEnabled,
                      hasPrompt: hasPrompt,
                      config: config,
                    );
                  }).toList(),
          ),
          const SizedBox(height: 16),

          // ── SDK Server 設定 ───────────────────────────────────────────────
          _SectionCard(
            title: 'SDK Server 設定',
            icon: Icons.terminal_outlined,
            children: [
              _SettingsTile(
                icon: Icons.folder_outlined,
                label: 'Binary 路徑',
                child: AppTextField(
                  key: const Key('settings_server_binary_path_input'),
                  controller: _binaryPathCtrl,
                  hintText: 'server/code/sdk-server（預設）',
                  onChanged: (v) =>
                      ref.read(serverBinaryPathProvider.notifier).set(v),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── 外觀 ──────────────────────────────────────────────────────────
          _SectionCard(
            title: '外觀',
            icon: Icons.palette_outlined,
            children: [
              _SettingsTile(
                icon: Icons.palette_outlined,
                label: '主題模式',
                trailing: SegmentedButton<ThemeMode>(
                  key: const Key('settings_theme_mode_selector'),
                  segments: const [
                    ButtonSegment(
                      value: ThemeMode.light,
                      icon: Icon(Icons.light_mode_outlined, size: 18),
                      label: Text('淺色'),
                    ),
                    ButtonSegment(
                      value: ThemeMode.system,
                      icon: Icon(Icons.brightness_auto_outlined, size: 18),
                      label: Text('自動'),
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      icon: Icon(Icons.dark_mode_outlined, size: 18),
                      label: Text('深色'),
                    ),
                  ],
                  selected: {_themeMode},
                  onSelectionChanged: (v) =>
                      setState(() => _themeMode = v.first),
                  style: const ButtonStyle(
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ),
              _SettingsTile(
                icon: Icons.stream_outlined,
                label: '串流時渲染 Markdown',
                trailing: Switch(
                  key: const Key('settings_streaming_markdown_switch'),
                  value: _streamMarkdown,
                  onChanged: (v) => setState(() => _streamMarkdown = v),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── 自訂 API 金鑰（BYOK）────────────────────────────────────────
          _SectionCard(
            title: '自訂 API 金鑰（BYOK）',
            icon: Icons.vpn_key_outlined,
            children: [
              _SettingsTile(
                icon: Icons.vpn_key_outlined,
                label: 'API Key',
                child: AppTextField(
                  key: const Key('settings_byok_api_key_input'),
                  controller: _apiKeyCtrl,
                  hintText: 'sk-...',
                  obscureText: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── 常用語管理 ────────────────────────────────────────────────────
          _QuickPhrasesSection(),
          const SizedBox(height: 16),

          // ── 關於 ──────────────────────────────────────────────────────────
          _SectionCard(
            title: '關於',
            icon: Icons.info_outline_rounded,
            children: [
              _SettingsTile(
                icon: Icons.info_outline_rounded,
                label: 'MyAi',
                trailing: Text(
                  'v0.1.0',
                  style: theme.textTheme.labelMedium
                      ?.copyWith(color: colors.textSecondary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Toggle row ────────────────────────────────────────────────────────────────

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(children: [
      Expanded(
        child: Text(label,
            style: TextStyle(fontSize: 13, color: colors.textPrimary)),
      ),
      Switch(value: value, onChanged: onChanged),
    ]);
  }
}

// ── Action button ─────────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.loading = false,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withValues(alpha: 0.5)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onPressed: loading ? null : onTap,
      icon: loading
          ? SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: color),
            )
          : Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }
}

// ── Section card ──────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
    this.trailing,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(children: [
              Icon(icon, size: 16, color: colors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (trailing != null) ...[
                const Spacer(),
                trailing!,
              ],
            ]),
          ),
          Container(height: 1, color: colors.outlineVariant),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Server status row ─────────────────────────────────────────────────────────

class _ServerStatusRow extends StatelessWidget {
  const _ServerStatusRow({required this.serverState});
  final ServerProcessState serverState;

  @override
  Widget build(BuildContext context) {
    final (icon, label, color) = switch (serverState.status) {
      ServerStatus.running  => (Icons.check_circle_outline, '執行中', const Color(0xFF22C55E)),
      ServerStatus.starting => (Icons.hourglass_empty, '啟動中…', const Color(0xFFF59E0B)),
      ServerStatus.stopped  => (Icons.cancel_outlined, '已停止', const Color(0xFF888888)),
      ServerStatus.error    => (Icons.error_outline, '錯誤', const Color(0xFFEF4444)),
    };
    return Row(children: [
      Icon(icon, size: 16, color: color),
      const SizedBox(width: 8),
      Text(label, style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w500)),
      if (serverState.error != null) ...[
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            serverState.error!,
            style: const TextStyle(fontSize: 11, color: Color(0xFFEF4444)),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ]);
  }
}

// ── Connection status row ────────────────────────────────────────────────────

class _ConnStatusRow extends StatelessWidget {
  const _ConnStatusRow({required this.connStatus});
  final ws.ConnectionStatus connStatus;

  @override
  Widget build(BuildContext context) {
    final (dotColor, label) = switch (connStatus) {
      ws.ConnectionStatus.connected    => (const Color(0xFF22C55E), '已連線'),
      ws.ConnectionStatus.connecting   => (const Color(0xFFF59E0B), '連線中…'),
      ws.ConnectionStatus.disconnected => (const Color(0xFF888888), '未連線'),
      ws.ConnectionStatus.error        => (const Color(0xFFEF4444), '連線錯誤'),
    };
    return Row(children: [
      Container(
        width: 10, height: 10,
        decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
      ),
      const SizedBox(width: 8),
      Text(label,
          style: TextStyle(
              fontSize: 13, color: dotColor, fontWeight: FontWeight.w500)),
    ]);
  }
}

// ── Info row ─────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(children: [
      SizedBox(
        width: 60,
        child: Text(label,
            style: TextStyle(fontSize: 12, color: colors.textSecondary)),
      ),
      Text(value,
          style: TextStyle(
              fontSize: 13,
              color: colors.textPrimary,
              fontFamily: 'monospace')),
    ]);
  }
}

// ── Log row ──────────────────────────────────────────────────────────────────

class _LogRow extends StatelessWidget {
  const _LogRow({required this.log});
  final StartupLog log;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (log.level) {
      LogLevel.ok   => (Icons.check, const Color(0xFF22C55E)),
      LogLevel.warn => (Icons.warning_amber_rounded, const Color(0xFFF59E0B)),
      LogLevel.fail => (Icons.close, const Color(0xFFEF4444)),
      LogLevel.info => (Icons.info_outline, const Color(0xFF888888)),
    };
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: SelectableText(
            log.message,
            style: TextStyle(fontSize: 12, color: color),
          ),
        ),
      ]),
    );
  }
}

// ── Role status row ───────────────────────────────────────────────────────────

class _RoleStatusRow extends ConsumerWidget {
  const _RoleStatusRow({
    required this.roleId,
    required this.isEnabled,
    required this.hasPrompt,
    this.role,
    this.config,
  });

  final String roleId;
  final rm.Role? role;
  final bool isEnabled;
  final bool hasPrompt;
  final RoleConfig? config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final startup = ref.read(appStartupProvider.notifier);
    final dimmed = !hasPrompt || !isEnabled;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        // Status dot — grey when disabled or prompt missing
        if (isEnabled && hasPrompt && role != null)
          StatusIndicator(status: agentStatusToConnection(role!.status))
        else
          StatusIndicator(status: ConnectionStatus.disconnected),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            roleId,
            style: TextStyle(
              fontSize: 13,
              color: dimmed ? colors.textSecondary : colors.textPrimary,
            ),
          ),
        ),
        // Orphan badge + delete button
        if (!hasPrompt) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: colors.outline.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text('prompt 遺失',
                style: TextStyle(fontSize: 10, color: colors.textSecondary)),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 16),
            color: colors.error,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            tooltip: '移除角色',
            onPressed: () => startup.removeRoleEntry(roleId),
          ),
        ] else ...[
          // Enable / disable toggle
          Switch(
            value: isEnabled,
            onChanged: (v) {
              if (v && config != null) {
                startup.enableRole(config!);
              } else {
                startup.disableRole(roleId);
              }
            },
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ]),
    );
  }
}

// ── Phase badge ───────────────────────────────────────────────────────────────

class _PhaseBadge extends StatelessWidget {
  const _PhaseBadge({required this.phase});
  final StartupPhase phase;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (phase) {
      StartupPhase.ready        => ('就緒', const Color(0xFF22C55E)),
      StartupPhase.error        => ('錯誤', const Color(0xFFEF4444)),
      StartupPhase.idle         => ('待機', const Color(0xFF888888)),
      StartupPhase.loadingEnv   => ('載入設定…', const Color(0xFFF59E0B)),
      StartupPhase.startingServer => ('啟動 Server…', const Color(0xFFF59E0B)),
      StartupPhase.configuring  => ('設定中…', const Color(0xFFF59E0B)),
      StartupPhase.connecting   => ('連線中…', const Color(0xFFF59E0B)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    );
  }
}

// ── Settings tile ─────────────────────────────────────────────────────────────

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.label,
    this.trailing,
    this.child,
    this.onTap, // ignore: unused_element_parameter
  });

  final IconData icon;
  final String label;
  final Widget? trailing;
  final Widget? child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: colors.textSecondary),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: colors.textPrimary),
                ),
                if (trailing != null) ...[
                  const Spacer(),
                  trailing!,
                ],
                if (trailing == null && onTap != null)
                  Icon(Icons.chevron_right,
                      size: 18, color: colors.textSecondary),
              ],
            ),
            if (child != null) ...[
              const SizedBox(height: 8),
              child!,
            ],
          ],
        ),
      ),
    );
  }
}

// ── Quick Phrases Section ─────────────────────────────────────────────────────

class _QuickPhrasesSection extends ConsumerStatefulWidget {
  const _QuickPhrasesSection();

  @override
  ConsumerState<_QuickPhrasesSection> createState() =>
      _QuickPhrasesSectionState();
}

class _QuickPhrasesSectionState extends ConsumerState<_QuickPhrasesSection> {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context);
    final phrases = ref.watch(quickPhrasesProvider);

    return _SectionCard(
      title: '常用語',
      icon: Icons.chat_bubble_outline_rounded,
      trailing: IconButton(
        icon: Icon(Icons.add_rounded, size: 18, color: colors.primary),
        tooltip: '新增常用語',
        onPressed: () => _showEditDialog(context, null),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      ),
      children: [
        if (phrases.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              '尚未設定常用語',
              style: TextStyle(fontSize: 12, color: colors.textSecondary),
            ),
          )
        else
          ...phrases.map((phrase) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(Icons.short_text_rounded,
                        size: 16, color: colors.textSecondary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            phrase.label,
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(color: colors.textPrimary),
                          ),
                          Text(
                            phrase.text,
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: colors.textSecondary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.edit_outlined,
                          size: 16, color: colors.textSecondary),
                      tooltip: '編輯',
                      onPressed: () => _showEditDialog(context, phrase),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded,
                          size: 16, color: Color(0xFFEF4444)),
                      tooltip: '刪除',
                      onPressed: () => ref
                          .read(quickPhrasesProvider.notifier)
                          .remove(phrase.id),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              )),
      ],
    );
  }

  void _showEditDialog(BuildContext context, QuickPhrase? existing) {
    final labelCtrl =
        TextEditingController(text: existing?.label ?? '');
    final textCtrl =
        TextEditingController(text: existing?.text ?? '');

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existing == null ? '新增常用語' : '編輯常用語'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: labelCtrl,
              decoration: const InputDecoration(labelText: '名稱（按鈕顯示）'),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: textCtrl,
              decoration: const InputDecoration(labelText: '填入內容'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              final label = labelCtrl.text.trim();
              final text = textCtrl.text.trim();
              if (label.isEmpty || text.isEmpty) return;
              final notifier = ref.read(quickPhrasesProvider.notifier);
              if (existing == null) {
                notifier.add(QuickPhrase(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  label: label,
                  text: text,
                ));
              } else {
                notifier.update(existing.copyWith(label: label, text: text));
              }
              Navigator.of(ctx).pop();
            },
            child: Text(existing == null ? '新增' : '儲存'),
          ),
        ],
      ),
    ).then((_) {
      labelCtrl.dispose();
      textCtrl.dispose();
    });
  }
}
