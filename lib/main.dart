import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router/app_router.dart';
import 'state/back_dispatcher.dart';

// ProviderScope is created here (not inside MyApp) so tests can wrap MyApp with
// their own overrides without being shadowed by an inner scope.
void main() => runApp(const ProviderScope(child: MyApp()));

/// Root of the app. The top-level routing is owned by auto_route.
class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  final _appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    final config = _appRouter.config();
    return MaterialApp.router(
      title: 'auto_route + go_router PoC',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      routeInformationParser: config.routeInformationParser,
      routerDelegate: config.routerDelegate,
      routeInformationProvider: config.routeInformationProvider,
      // Own the root dispatcher so risk 5's "simulate back" hits the same chain.
      backButtonDispatcher: ref.watch(rootBackDispatcherProvider),
    );
  }
}
