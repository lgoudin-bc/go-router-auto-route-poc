import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'notifiers.dart';

/// One toggle per migration risk. Each represents "the fix is applied":
///   OFF (default) → the risk is reproduced.
///   ON            → the mitigation is wired and the problem goes away.
/// All default to false so the app opens showing every risk, ready to be fixed.

/// Risk 1 — Double header. OFF: the poker module renders its OWN header (like
/// flutter-poker's NavigationBarScreen) on top of the shell's AppHeader → two
/// stacked top bars. ON: poker suppresses its own header → a single header.
final fixDoubleHeaderProvider =
    NotifierProvider<BoolNotifier, bool>(() => BoolNotifier(false));

/// Risk 2 — ProviderScope shadowing. OFF: the poker subtree is wrapped in a
/// nested ProviderScope that overrides [appHeaderTitleProvider], so poker's
/// "rename" writes never reach the shell header. ON: no shadow → writes reach it.
final fixShadowScopeProvider =
    NotifierProvider<BoolNotifier, bool>(() => BoolNotifier(false));

/// Risk 3 — Header visibility isn't automatic. OFF: opening a go_router
/// fullscreen route leaves the shell AppHeader visible. ON: the go_router
/// listener drives appHeaderVisibleProvider so the header hides and restores.
final fixAutoHideProvider =
    NotifierProvider<BoolNotifier, bool>(() => BoolNotifier(false));

/// Risk 4 — Sub-route awareness lost. OFF: only "poker" is known (auto_route
/// can't see inside the go_router stack). ON: a bridge publishes the real
/// go_router location to pokerActiveSubRouteProvider.
final fixSubRouteProvider =
    NotifierProvider<BoolNotifier, bool>(() => BoolNotifier(false));

/// Risk 5 — Back-button ownership. OFF: the nested go_router doesn't take back
/// priority, so a system back skips its stack. ON: it takes priority and pops
/// the go_router stack first.
final fixBackPriorityProvider =
    NotifierProvider<BoolNotifier, bool>(() => BoolNotifier(false));
