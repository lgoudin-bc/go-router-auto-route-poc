// Proves the two routers coexist AND demonstrates each migration risk in both
// its broken (default) and fixed (mitigated) state.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:go_router_auto_route_poc/main.dart';
import 'package:go_router_auto_route_poc/state/notifiers.dart';
import 'package:go_router_auto_route_poc/state/risk_toggles.dart';

/// Pump and settle a fully-built widget tree.
Future<void> pump(WidgetTester tester, Widget app) async {
  await tester.pumpWidget(app);
  await tester.pumpAndSettle();
}

Future<void> tapAndSettle(WidgetTester tester, Finder f) async {
  await tester.tap(f);
  await tester.pumpAndSettle();
}

void main() {
  group('coexistence', () {
    testWidgets('auto_route shell hosts a go_router sub-route', (tester) async {
      await pump(tester, const ProviderScope(child: MyApp()));

      expect(find.text('Routed by auto_route'), findsOneWidget);
      expect(find.text('Home tab'), findsOneWidget);

      await tapAndSettle(tester, find.byIcon(Icons.casino)); // Poker tab
      expect(find.text('Routed by go_router'), findsOneWidget);
      expect(find.text('Poker lobby'), findsOneWidget);

      await tapAndSettle(tester, find.text('Table Alpha')); // go_router push
      expect(find.text('Table Alpha (go_router)'), findsOneWidget);

      await tapAndSettle(tester, find.text('Pop (go_router)'));
      expect(find.text('Poker lobby'), findsOneWidget);
    });

    testWidgets('go_router screen presents a root auto_route modal', (tester) async {
      await pump(tester, const ProviderScope(child: MyApp()));
      await tapAndSettle(tester, find.byIcon(Icons.casino));
      await tapAndSettle(tester, find.text('Open My Account (auto_route)'));
      expect(find.text('My account'), findsOneWidget);
      await tapAndSettle(tester, find.byIcon(Icons.close));
      expect(find.text('Poker lobby'), findsOneWidget);
    });
  });

  group('risk 1 — double bottom-nav', () {
    testWidgets('broken: poker renders its own bar', (tester) async {
      await pump(tester, const ProviderScope(child: MyApp())); // fix off
      await tapAndSettle(tester, find.byIcon(Icons.casino));
      expect(find.text("Poker's own: Lobby"), findsOneWidget);
    });

    testWidgets('fixed: poker bar suppressed', (tester) async {
      await pump(
        tester,
        ProviderScope(
          overrides: [fixDoubleBarProvider.overrideWith(() => BoolNotifier(true))],
          child: const MyApp(),
        ),
      );
      await tapAndSettle(tester, find.byIcon(Icons.casino));
      expect(find.text("Poker's own: Lobby"), findsNothing);
    });
  });

  group('risk 2 — ProviderScope shadowing (title from go_router)', () {
    testWidgets('broken: rename does NOT reach the navbar', (tester) async {
      await pump(tester, const ProviderScope(child: MyApp())); // shadow on
      await tapAndSettle(tester, find.byIcon(Icons.casino));
      await tapAndSettle(tester, find.text('Rename tab from go_router'));
      expect(find.text('Hot Tables 🔥'), findsNothing);
      expect(find.text('Poker'), findsOneWidget); // nav label unchanged
    });

    testWidgets('fixed: rename updates the navbar title', (tester) async {
      await pump(
        tester,
        ProviderScope(
          overrides: [fixShadowScopeProvider.overrideWith(() => BoolNotifier(true))],
          child: const MyApp(),
        ),
      );
      await tapAndSettle(tester, find.byIcon(Icons.casino));
      await tapAndSettle(tester, find.text('Rename tab from go_router'));
      expect(find.text('Hot Tables 🔥'), findsOneWidget); // nav label updated
    });
  });

  group('risk 3 — navbar visibility on a fullscreen route', () {
    testWidgets('broken: bar stays visible on the table', (tester) async {
      await pump(tester, const ProviderScope(child: MyApp())); // auto-hide off
      await tapAndSettle(tester, find.byIcon(Icons.casino));
      await tapAndSettle(tester, find.text('Table Alpha'));
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });

    testWidgets('fixed: bar hides on the table, restores on pop', (tester) async {
      await pump(
        tester,
        ProviderScope(
          overrides: [fixAutoHideProvider.overrideWith(() => BoolNotifier(true))],
          child: const MyApp(),
        ),
      );
      await tapAndSettle(tester, find.byIcon(Icons.casino));
      await tapAndSettle(tester, find.text('Table Alpha'));
      expect(find.byType(BottomNavigationBar), findsNothing);
      await tapAndSettle(tester, find.text('Pop (go_router)'));
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });
  });

  group('risk 4 — sub-route awareness', () {
    testWidgets('broken: only "poker" is known', (tester) async {
      await pump(tester, const ProviderScope(child: MyApp())); // bridge off
      await tapAndSettle(tester, find.byIcon(Icons.casino)); // visit lobby
      await tapAndSettle(tester, find.byIcon(Icons.science)); // Risk lab
      expect(find.textContaining('not bridged'), findsWidgets);
    });

    testWidgets('fixed: real go_router location is published', (tester) async {
      await pump(
        tester,
        ProviderScope(
          overrides: [fixSubRouteProvider.overrideWith(() => BoolNotifier(true))],
          child: const MyApp(),
        ),
      );
      await tapAndSettle(tester, find.byIcon(Icons.casino));
      await tapAndSettle(tester, find.text('Table Alpha')); // location = table
      await tapAndSettle(tester, find.byIcon(Icons.science));
      expect(find.text('poker / table/Alpha'), findsOneWidget);
    });
  });

  group('risk 5 — back-button ownership', () {
    testWidgets('broken: simulated back skips the go_router stack', (tester) async {
      await pump(tester, const ProviderScope(child: MyApp())); // back prio off
      await tapAndSettle(tester, find.byIcon(Icons.casino));
      await tapAndSettle(tester, find.text('Table Alpha'));
      await tapAndSettle(tester, find.text('Simulate Android system back'));
      expect(find.text('Table Alpha (go_router)'), findsOneWidget); // still here
    });

    testWidgets('fixed: simulated back pops the go_router stack', (tester) async {
      await pump(
        tester,
        ProviderScope(
          overrides: [fixBackPriorityProvider.overrideWith(() => BoolNotifier(true))],
          child: const MyApp(),
        ),
      );
      await tapAndSettle(tester, find.byIcon(Icons.casino));
      await tapAndSettle(tester, find.text('Table Alpha'));
      await tapAndSettle(tester, find.text('Simulate Android system back'));
      expect(find.text('Table Alpha (go_router)'), findsNothing);
      expect(find.text('Poker lobby'), findsOneWidget);
    });
  });
}
