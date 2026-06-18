import 'package:flutter/material.dart';

import 'router/app_router.dart';

void main() => runApp(MyApp());

/// Root of the app. The top-level routing is owned by auto_route.
class MyApp extends StatelessWidget {
  MyApp({super.key});

  final _appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'auto_route + go_router PoC',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      routerConfig: _appRouter.config(),
    );
  }
}
