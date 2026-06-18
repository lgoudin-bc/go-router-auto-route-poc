import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../poker/poker_router.dart';
import '../state/back_dispatcher.dart';
import '../state/header_state.dart';
import '../state/notifiers.dart';
import '../state/risk_toggles.dart';
import '../widgets/poker_header.dart';

/// THE BOUNDARY.
///
/// An auto_route page (the Poker tab) that hands navigation off to a nested
/// [GoRouter]. It also stages the migration risks whose mitigations are toggled
/// from the Risk lab:
///   - Risk 1: poker's own header (double header vs the shell's AppHeader)
///   - Risk 2: a shadowing ProviderScope around the poker subtree
///   - Risk 3/4: a go_router listener bridging navigation into shared state
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
    _pokerRouter.routerDelegate.addListener(_syncFromGoRouter);
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) _syncFromGoRouter();
    });
  }

  void _syncFromGoRouter() {
    // The routerDelegate notifies during build, so defer all reads/writes to
    // after the frame — modifying providers or calling setState during build is
    // not allowed.
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // An imperative push() keeps cfg.uri at '/'; the pushed match has the loc.
      final matches = _pokerRouter.routerDelegate.currentConfiguration.matches;
      final loc = matches.isEmpty ? '/' : matches.last.matchedLocation;
      final onTable = loc.startsWith('/table/');

      // Risk 3: hide the shell header on a fullscreen go_router route, if wired.
      final hide = ref.read(fixAutoHideProvider) && onTable;
      ref.read(appHeaderVisibleProvider.notifier).set(!hide);

      // Risk 4: publish the real go_router location, if bridged.
      final pretty =
          loc == '/' ? 'poker / lobby' : 'poker / ${loc.substring(1)}';
      ref.read(pokerActiveSubRouteProvider.notifier).set(
            ref.read(fixSubRouteProvider)
                ? pretty
                : '(not bridged — auto_route only sees "poker")',
          );

      // Refresh so the poker header's back button reflects the new stack depth.
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final fixBackPriority = ref.watch(fixBackPriorityProvider);
    final fixDoubleHeader = ref.watch(fixDoubleHeaderProvider);
    final fixShadowScope = ref.watch(fixShadowScopeProvider);
    // Re-sync when the risk 3/4 toggles flip while a route is already showing.
    ref.listen(fixAutoHideProvider, (_, _) => _syncFromGoRouter());
    ref.listen(fixSubRouteProvider, (_, _) => _syncFromGoRouter());

    // Risk 5: only take back priority (and hand the dispatcher to the nested
    // Router) when the fix is on. Otherwise system back skips the go_router stack.
    final rootDispatcher = ref.watch(rootBackDispatcherProvider);
    _backButtonDispatcher ??= rootDispatcher.createChildBackButtonDispatcher();
    if (fixBackPriority) _backButtonDispatcher?.takePriority();

    final router = Router(
      routerDelegate: _pokerRouter.routerDelegate,
      routeInformationParser: _pokerRouter.routeInformationParser,
      routeInformationProvider: _pokerRouter.routeInformationProvider,
      backButtonDispatcher: fixBackPriority ? _backButtonDispatcher : null,
    );

    // Risk 1: when NOT fixed, poker renders its OWN header in addition to the
    // shell's AppHeader → two stacked top bars.
    Widget content = Column(
      children: [
        if (!fixDoubleHeader)
          PokerHeader(
            onBack: _pokerRouter.canPop() ? () => _pokerRouter.pop() : null,
          ),
        Expanded(child: router),
      ],
    );

    // Risk 2: when NOT fixed, wrap the poker subtree in a ProviderScope that
    // OVERRIDES the header-title provider. Poker's "rename" writes then hit this
    // local copy and never reach the shell AppHeader reading the root provider.
    if (!fixShadowScope) {
      content = ProviderScope(
        overrides: [
          appHeaderTitleProvider.overrideWith(() => StringNotifier('Betclic Sport')),
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
