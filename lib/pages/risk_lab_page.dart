import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/navbar_state.dart';
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
            title: 'Double bottom-nav',
            off: "Poker renders its own bar → two bars stacked.",
            on: "Poker's own bar suppressed → single bar.",
            observe: 'Open the Poker tab and look at the bottom.',
            provider: fixDoubleBarProvider,
          ),
          _RiskTile(
            n: 2,
            title: 'ProviderScope shadowing',
            off: 'A nested scope shadows the label provider → rename is lost.',
            on: 'Shared scope → rename reaches the navbar.',
            observe: 'In Poker lobby tap "Rename tab from go_router", '
                'watch this tab\'s label below.',
            provider: fixShadowScopeProvider,
          ),
          _RiskTile(
            n: 3,
            title: 'Bar visibility not automatic',
            off: 'Opening a go_router table leaves the bar visible.',
            on: 'Poker wires the route → bar hides on the table, restores on pop.',
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
