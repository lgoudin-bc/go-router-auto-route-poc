import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'notifiers.dart';

/// The app header's title. The shell's [AppHeader] reads it, and a go_router
/// poker screen can write to it — proving cross-router control of the header
/// (flutter-front's HeaderWidget is provider-driven the same way). Risk 2 wraps
/// the poker subtree in a scope that shadows this provider.
final appHeaderTitleProvider =
    NotifierProvider<StringNotifier, String>(() => StringNotifier('Betclic Sport'));

/// Whether the shell's [AppHeader] is shown. Mirrors flutter-front's header
/// display state — a fullscreen go_router route should be able to hide it.
final appHeaderVisibleProvider =
    NotifierProvider<BoolNotifier, bool>(() => BoolNotifier(true));

/// What the app believes the active poker location is. Default reflects the
/// risk: without a bridge, auto_route only knows the "poker" tab is active.
final pokerActiveSubRouteProvider = NotifierProvider<StringNotifier, String>(
  () => StringNotifier('(not bridged — auto_route only sees "poker")'),
);
