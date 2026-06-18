import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../widgets/router_banner.dart';

/// An auto_route page that lives at the ROOT of the auto_route tree. It is
/// presented as a bottom-to-top sheet on top of everything (including the
/// bottom tabs) — and, crucially, it can be triggered from the go_router side.
@RoutePage()
class MyAccountPage extends StatelessWidget {
  const MyAccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My account'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.router.maybePop(),
        ),
      ),
      body: Column(
        children: [
          const RouterBanner(
            label: 'auto_route page — presented from go_router',
            color: Colors.deepPurple,
          ),
          const Expanded(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'This page belongs to the auto_route tree and is presented as a '
                  'root-level bottom-to-top sheet, over the bottom tabs.\n\n'
                  'It was opened from a go_router screen via '
                  'context.router.root.push(const MyAccountRoute()).',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
