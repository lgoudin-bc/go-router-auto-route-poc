import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../router/app_router.dart';
import '../state/navbar_state.dart';
import '../widgets/router_banner.dart';
import 'poker_router.dart';

/// Lobby screen — the initial location of the embedded go_router.
class PokerLobbyPage extends ConsumerWidget {
  const PokerLobbyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const tables = ['Alpha', 'Bravo', 'Charlie'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Poker lobby'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          const RouterBanner(
            label: 'Routed by go_router',
            color: Colors.teal,
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'This screen and the navigation below are driven by go_router, '
              'nested inside the auto_route Poker tab.',
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: [
                FilledButton.tonalIcon(
                  // Cross-router call: push a root-level auto_route modal.
                  onPressed: () =>
                      context.router.root.push(const MyAccountRoute()),
                  icon: const Icon(Icons.account_circle),
                  label: const Text('Open My Account (auto_route)'),
                ),
                FilledButton.tonalIcon(
                  // Risk 2: write the auto_route tab's label from the go_router
                  // side. Reaches the navbar only when there's no shadow scope.
                  onPressed: () => ref
                      .read(pokerTabLabelProvider.notifier)
                      .set('Hot Tables 🔥'),
                  icon: const Icon(Icons.edit),
                  label: const Text('Rename tab from go_router'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                for (final id in tables)
                  ListTile(
                    leading: const Icon(Icons.table_bar),
                    title: Text('Table $id'),
                    trailing: const Icon(Icons.chevron_right),
                    // go_router navigation (typed route from go_router_builder).
                    onTap: () => PokerTableRoute(id: id).push(context),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
