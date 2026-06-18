import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/header_state.dart';
import '../state/risk_toggles.dart';
import '../widgets/router_banner.dart';

/// The Risk lab tab. One switch per migration risk: OFF reproduces the risk,
/// ON applies the mitigation. Each switch explains what to observe in the
/// Poker tab. This proves each risk — and its fix — one by one.
@RoutePage()
class RiskLabPage extends ConsumerWidget {
  const RiskLabPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subRoute = ref.watch(pokerActiveSubRouteProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Risk lab')),
      body: ListView(
        children: [
          const RouterBanner(label: 'Routed by auto_route', color: Colors.indigo),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(
              'Each switch is OFF = risk reproduced, ON = fix applied. '
              'Flip a switch, then watch the Poker tab / navbar.',
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: const Icon(Icons.my_location),
              title: const Text('App-known poker location (risk 4)'),
              subtitle: Text(subRoute),
              isThreeLine: true,
            ),
          ),
          _RiskTile(
            n: 1,
            title: 'Double header',
            off: "Poker renders its own header (NavigationBarScreen) on top of "
                'the shell AppHeader → two stacked top bars.',
            on: "Poker's own header suppressed → single header.",
            observe: 'Open the Poker tab and look at the top.',
            provider: fixDoubleHeaderProvider,
          ),
          _RiskTile(
            n: 2,
            title: 'ProviderScope shadowing',
            off: 'A nested scope shadows the header-title provider → the rename '
                'is lost.',
            on: 'Shared scope → the rename reaches the shell header.',
            observe: 'In Poker lobby tap "Set header title from go_router", '
                'watch the top AppHeader title.',
            provider: fixShadowScopeProvider,
          ),
          _RiskTile(
            n: 3,
            title: 'Header visibility not automatic',
            off: 'Opening a go_router table leaves the shell header visible.',
            on: 'Poker wires the route → header hides on the table, restores on pop.',
            observe: 'Open a table from the Poker lobby.',
            provider: fixAutoHideProvider,
          ),
          _RiskTile(
            n: 4,
            title: 'Sub-route awareness lost',
            off: 'Only "poker" is known — the go_router sub-route is invisible.',
            on: 'A bridge publishes the real go_router location.',
            observe: 'Navigate Poker lobby ↔ table; see the value below.',
            provider: fixSubRouteProvider,
          ),
          _RiskTile(
            n: 5,
            title: 'Back-button ownership',
            off: 'System back skips the go_router stack.',
            on: 'Nested go_router takes priority → back pops its stack first.',
            observe: 'On a table, tap "Simulate Android system back".',
            provider: fixBackPriorityProvider,
          ),
          const Divider(height: 32),
          const ListTile(
            dense: true,
            title: Text(
              'auto_route alone always reports just the "poker" tab; the '
              'location card up top only becomes specific when risk 4 is fixed.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }
}

class _RiskTile extends ConsumerWidget {
  const _RiskTile({
    required this.n,
    required this.title,
    required this.off,
    required this.on,
    required this.observe,
    required this.provider,
  });

  final int n;
  final String title;
  final String off;
  final String on;
  final String observe;
  final NotifierProvider<dynamic, bool> provider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fixed = ref.watch(provider);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: SwitchListTile(
        isThreeLine: true,
        value: fixed,
        onChanged: (v) => ref.read(provider.notifier).set(v),
        title: Text('Risk $n — $title  ${fixed ? "✅ fixed" : "⚠️ risk"}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(fixed ? on : off),
            const SizedBox(height: 4),
            Text('▶ $observe',
                style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}
