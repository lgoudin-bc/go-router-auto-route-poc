import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../widgets/router_banner.dart';

/// A detail screen pushed onto the Home tab's auto_route stack.
@RoutePage()
class DetailPage extends StatelessWidget {
  const DetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail (auto_route)')),
      body: Column(
        children: [
          const RouterBanner(
            label: 'Routed by auto_route',
            color: Colors.indigo,
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Pushed onto the Home tab stack by auto_route.'),
                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                    onPressed: () => context.router.maybePop(),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Pop (auto_route)'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
