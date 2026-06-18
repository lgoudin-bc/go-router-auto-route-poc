import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../poker/poker_router.dart';
import '../state/back_dispatcher.dart';
import '../state/navbar_state.dart';
import '../state/notifiers.dart';
import '../state/risk_toggles.dart';

/// THE BOUNDARY.
///
/// An auto_route page (the Poker tab) that hands navigation off to a nested
/// [GoRouter] via a raw [Router] widget. It also stages three migration risks
/// whose mitigations are toggled from the Risk lab tab:
///   - Risk 1: poker's own bottom bar (double-nav)
///   - Risk 2: a shadowing ProviderScope around the poker subtree
///   - Risk 5: whether the nested go_router takes back-button priority
@RoutePage()
class PokerHostPage extends ConsumerStatefulWidget {
  const PokerHostPage({super.key});

  @override
  ConsumerState<PokerHostPage> createState() => _PokerHostPageState();
}

class _PokerHostPageState extends ConsumerState<PokerHostPage> {
  late final GoRouter _pokerRouter = createPokerRouter();
  ChildBackButtonDispatcher? _backButtonDispatcher;

  @override
  void initState() {
    super.initState();
    // The faithful mitigation for risks 3 & 4: a single go_router listener that
    // bridges navigation events into shared Riverpod state. Runs on navigation
    // (not during widget dispose), so it notifies the navbar reliably.
    _pokerRouter.routerDelegate.addListener(_syncFromGoRouter);
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) _syncFromGoRouter();
    });
  }

  void _syncFromGoRouter() {
    // The routerDelegate notifies during build, so defer the provider writes to
    // after the frame — modifying providers during build is not allowed.
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Use the last match's location: an imperative push() keeps cfg.uri at the
      // base ('/'), but the pushed match carries the real location.
      final matches = _pokerRouter.routerDelegate.currentConfiguration.matches;
      final loc = matches.isEmpty ? '/' : matches.last.matchedLocation;
      final onTable = loc.startsWith('/table/');

      // Risk 3: hide the bar on a fullscreen go_router route, but only if wired.
      final hide = ref.read(fixAutoHideProvider) && onTable;
      ref.read(navBarVisibleProvider.notifier).set(!hide);

      // Risk 4: publish the real go_router location, but only if bridged.
      final pretty =
          loc == '/' ? 'poker / lobby' : 'poker / ${loc.substring(1)}';
      ref.read(pokerActiveSubRouteProvider.notifier).set(
            ref.read(fixSubRouteProvider)
                ? pretty
                : '(not bridged — auto_route only sees "poker")',
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final fixBackPriority = ref.watch(fixBackPriorityProvider);
    final fixDoubleBar = ref.watch(fixDoubleBarProvider);
    final fixShadowScope = ref.watch(fixShadowScopeProvider);
    // Re-sync when the risk 3/4 toggles flip while a route is already showing.
    ref.listen(fixAutoHideProvider, (_, _) => _syncFromGoRouter());
    ref.listen(fixSubRouteProvider, (_, _) => _syncFromGoRouter());

    // Risk 5: only take back priority (and hand the dispatcher to the nested
    // Router) when the fix is on. Otherwise system back skips the go_router stack.
    final rootDispatcher = ref.watch(rootBackDispatcherProvider);
    _backButtonDispatcher ??= rootDispatcher.createChildBackButtonDispatcher();
    if (fixBackPriority) _backButtonDispatcher?.takePriority();

    Widget content = Router(
      routerDelegate: _pokerRouter.routerDelegate,
      routeInformationParser: _pokerRouter.routeInformationParser,
      routeInformationProvider: _pokerRouter.routeInformationProvider,
      backButtonDispatcher: fixBackPriority ? _backButtonDispatcher : null,
    );

    // Risk 1: when NOT fixed, poker renders its own bottom bar inside the tab,
    // stacking a second bar above the auto_route one.
    if (!fixDoubleBar) {
      content = Scaffold(
        body: content,
        bottomNavigationBar: const _PokerOwnBar(),
      );
    }

    // Risk 2: when NOT fixed, wrap the poker subtree in a ProviderScope that
    // OVERRIDES the tab-label provider. Poker's "rename" writes then hit this
    // local copy and never reach the navbar reading the root provider.
    if (!fixShadowScope) {
      content = ProviderScope(
        overrides: [
          pokerTabLabelProvider.overrideWith(() => StringNotifier('Poker')),
        ],
        child: content,
      );
    }

    return content;
  }

  @override
  void dispose() {
    _pokerRouter.routerDelegate.removeListener(_syncFromGoRouter);
    _pokerRouter.dispose();
    super.dispose();
  }
}

/// A fake bottom bar standing in for flutter-poker's own NavigationBarScreen.
class _PokerOwnBar extends StatelessWidget {
  const _PokerOwnBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.teal.shade700,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _PokerOwnBarItem(icon: Icons.list, label: "Poker's own: Lobby"),
          _PokerOwnBarItem(icon: Icons.emoji_events, label: 'Tournaments'),
          _PokerOwnBarItem(icon: Icons.person, label: 'Account'),
        ],
      ),
    );
  }
}

class _PokerOwnBarItem extends StatelessWidget {
  const _PokerOwnBarItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 18),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 10)),
      ],
    );
  }
}
