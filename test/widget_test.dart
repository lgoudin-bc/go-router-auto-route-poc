// Smoke test proving the two routers coexist:
//   - Home tab is rendered by auto_route.
//   - Switching to the Poker tab reveals a screen rendered by go_router.
//   - Navigating inside the Poker tab is driven by go_router while the
//     auto_route bottom tabs stay on screen.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:go_router_auto_route_poc/main.dart';

void main() {
  testWidgets('auto_route shell hosts a go_router sub-route', (tester) async {
    await tester.pumpWidget(MyApp());
    await tester.pumpAndSettle();

    // auto_route owns the initial Home tab.
    expect(find.text('Routed by auto_route'), findsOneWidget);
    expect(find.text('Home tab'), findsOneWidget);

    // Switch to the Poker tab (auto_route bottom navigation).
    await tester.tap(find.byIcon(Icons.casino));
    await tester.pumpAndSettle();

    // The Poker tab content is rendered by the nested go_router.
    expect(find.text('Routed by go_router'), findsOneWidget);
    expect(find.text('Poker lobby'), findsOneWidget);

    // Navigate within the poker module — this is a go_router push.
    await tester.tap(find.text('Table Alpha'));
    await tester.pumpAndSettle();

    expect(find.text('Table Alpha (go_router)'), findsOneWidget);
    // The auto_route bottom navigation is still present underneath.
    expect(find.byIcon(Icons.home), findsOneWidget);

    // Pop back to the lobby via go_router.
    await tester.tap(find.text('Pop (go_router)'));
    await tester.pumpAndSettle();
    expect(find.text('Poker lobby'), findsOneWidget);
  });
}
