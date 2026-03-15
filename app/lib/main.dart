import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'theme/theme.dart';
import 'demo_page.dart';
import 'system_status_page.dart';
import 'providers/app_startup_provider.dart';
import 'providers/server_process_provider.dart';

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const DemoPage(),
    ),
    GoRoute(
      path: '/status',
      builder: (context, state) => const SystemStatusPage(),
    ),
  ],
);

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _StartupInitializer(
      child: MaterialApp.router(
        title: 'MyAi',
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        routerConfig: _router,
      ),
    );
  }
}

class _StartupInitializer extends ConsumerStatefulWidget {
  const _StartupInitializer({required this.child});
  final Widget child;

  @override
  ConsumerState<_StartupInitializer> createState() => _StartupInitializerState();
}

class _StartupInitializerState extends ConsumerState<_StartupInitializer>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future.microtask(
        () => ref.read(appStartupProvider.notifier).initialize());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      ref.read(serverProcessProvider.notifier).stop();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
