import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../router/app_router.dart';
import '../widgets/router_banner.dart';

/// The Home bottom tab. Pure auto_route. Demonstrates auto_route's own stack
/// navigation by pushing a [DetailRoute] onto this tab's nested stack.
@RoutePage()
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home tab')),
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
                  const Text(
                    'This tab and its stack are driven by auto_route.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => context.router.push(const DetailRoute()),
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Push auto_route Detail'),
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
