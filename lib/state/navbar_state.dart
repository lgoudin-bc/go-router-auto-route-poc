import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'notifiers.dart';

/// The poker tab's label. The navbar reads it through [tabConfigProvider], and
/// a go_router poker screen can write to it — proving cross-router title control
/// via shared Riverpod (the mechanism flutter-front uses for badges/labels).
final pokerTabLabelProvider =
    NotifierProvider<StringNotifier, String>(() => StringNotifier('Poker'));

/// Whether the bottom navigation bar is shown. Mirrors flutter-front's
/// tabBarModeProvider — a page deep in a tab can hide the bar.
final navBarVisibleProvider =
    NotifierProvider<BoolNotifier, bool>(() => BoolNotifier(true));

/// What the app believes the active poker location is. Default reflects the
/// risk: without a bridge, auto_route only knows the "poker" tab is active.
final pokerActiveSubRouteProvider = NotifierProvider<StringNotifier, String>(
  () => StringNotifier('(not bridged — auto_route only sees "poker")'),
);

/// A bottom-bar tab descriptor — a tiny stand-in for flutter-front's TabItem.
class TabSpec {
  const TabSpec({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

/// The bottom-bar model, rebuilt from providers — mirrors flutter-front's
/// universesTabConfigurationProvider feeding the TabBar. The poker entry's label
/// is reactive, so changes to [pokerTabLabelProvider] re-render the navbar.
final tabConfigProvider = Provider<List<TabSpec>>((ref) {
  final pokerLabel = ref.watch(pokerTabLabelProvider);
  return [
    const TabSpec(label: 'Home', icon: Icons.home),
    TabSpec(label: pokerLabel, icon: Icons.casino),
    const TabSpec(label: 'Risk lab', icon: Icons.science),
  ];
});
