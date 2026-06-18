// Proves the two routers coexist AND demonstrates each migration risk in both
// its broken (default) and fixed (mitigated) state.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:go_router_auto_route_poc/main.dart';
import 'package:go_router_auto_route_poc/state/notifiers.dart';
import 'package:go_router_auto_route_poc/state/risk_toggles.dart';
import 'package:go_router_auto_route_poc/widgets/app_header.dart';
import 'package:go_router_auto_route_poc/widgets/poker_header.dart';

Future<void> pump(WidgetTester tester, Widget app) async {
  await tester.pumpWidget(app);
  await tester.pumpAndSettle();
}

Future<void> tapAndSettle(WidgetTester tester, Finder f) async {
  await tester.tap(f);
  await tester.pumpAndSettle();
}

// Enter the Poker universe via the bottom-bar switcher button.
Future<void> goToPoker(WidgetTester tester) =>
    tapAndSettle(tester, find.byIcon(Icons.casino));

void main() {
  group('coexistence', () {
    testWidgets('auto_route shell hosts a go_router sub-route', (tester) async {
      await pump(tester, const ProviderScope(child: MyApp()));

      expect(find.text('Routed by auto_route'), findsOneWidget);
      expect(find.text('Home tab'), findsOneWidget);

      await goToPoker(tester);
      expect(find.text('Routed by go_router'), findsOneWidget);
      expect(find.text('Poker lobby'), findsOneWidget);

      await tapAndSettle(tester, find.text('Table Alpha')); // go_router push
      expect(find.text('Table Alpha (go_router)'), findsOneWidget);

      await tapAndSettle(tester, find.text('Pop (go_router)'));
      expect(find.text('Poker lobby'), findsOneWidget);
    });

    testWidgets('Poker tab shows a floating Back to Sports button', (tester) async {
      await pump(tester, const ProviderScope(child: MyApp()));
      await goToPoker(tester);
      expect(find.text('Back to Sports'), findsOneWidget);

      await tapAndSettle(tester, find.text('Back to Sports'));
      expect(find.text('Home tab'), findsOneWidget); // back in the Sport universe
      expect(find.text('Back to Sports'), findsNothing);
    });

    testWidgets('go_router screen presents a root auto_route modal', (tester) async {
      await pump(tester, const ProviderScope(child: MyApp()));
      await goToPoker(tester);
      await tapAndSettle(tester, find.text('Open My Account (auto_route)'));
      expect(find.text('My account'), findsOneWidget);
      await tapAndSettle(tester, find.byIcon(Icons.close));
      expect(find.text('Poker lobby'), findsOneWidget);
    });
  });

  group('risk 1 — double header', () {
    testWidgets('broken: poker renders its own header too', (tester) async {
      await pump(tester, const ProviderScope(child: MyApp()));
      await goToPoker(tester);
      expect(find.byType(AppHeader), findsOneWidget);
      expect(find.byType(PokerHeader), findsOneWidget); // stacked second header
    });

    testWidgets('fixed: poker header suppressed', (tester) async {
      await pump(
        tester,
        ProviderScope(
          overrides: [fixDoubleHeaderProvider.overrideWith(() => BoolNotifier(true))],
          child: const MyApp(),
        ),
      );
      await goToPoker(tester);
      expect(find.byType(AppHeader), findsOneWidget);
      expect(find.byType(PokerHeader), findsNothing);
    });
  });

  group('risk 2 — ProviderScope shadowing (header title from go_router)', () {
    testWidgets('broken: title does NOT reach the shell header', (tester) async {
      await pump(tester, const ProviderScope(child: MyApp())); // shadow on
      await goToPoker(tester);
      await tapAndSettle(tester, find.text('Set header title from go_router'));
      expect(find.text('Hot Table 🔥'), findsNothing);
      expect(find.text('Betclic Sport'), findsOneWidget); // header unchanged
    });

    testWidgets('fixed: title updates the shell header', (tester) async {
      await pump(
        tester,
        ProviderScope(
          overrides: [fixShadowScopeProvider.overrideWith(() => BoolNotifier(true))],
          child: const MyApp(),
        ),
      );
      await goToPoker(tester);
      await tapAndSettle(tester, find.text('Set header title from go_router'));
      expect(find.text('Hot Table 🔥'), findsOneWidget); // header updated
    });
  });

  group('risk 3 — header visibility on a fullscreen route', () {
    testWidgets('broken: header stays visible on the table', (tester) async {
      await pump(tester, const ProviderScope(child: MyApp())); // auto-hide off
      await goToPoker(tester);
      await tapAndSettle(tester, find.text('Table Alpha'));
      expect(find.byType(AppHeader), findsOneWidget);
    });

    testWidgets('fixed: header hides on the table, restores on pop', (tester) async {
      await pump(
        tester,
        ProviderScope(
          overrides: [fixAutoHideProvider.overrideWith(() => BoolNotifier(true))],
          child: const MyApp(),
        ),
      );
      await goToPoker(tester);
      await tapAndSettle(tester, find.text('Table Alpha'));
      expect(find.byType(AppHeader), findsNothing);
      await tapAndSettle(tester, find.text('Pop (go_router)'));
      expect(find.byType(AppHeader), findsOneWidget);
    });
  });

  group('risk 4 — sub-route awareness', () {
    testWidgets('broken: only "poker" is known', (tester) async {
      await pump(tester, const ProviderScope(child: MyApp())); // bridge off
      await goToPoker(tester); // visit lobby → sync runs
      await tapAndSettle(tester, find.text('Back to Sports'));
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
      await goToPoker(tester);
      await tapAndSettle(tester, find.text('Table Alpha')); // location = table
      await tapAndSettle(tester, find.text('Back to Sports'));
      await tapAndSettle(tester, find.byIcon(Icons.science));
      expect(find.text('poker / table/Alpha'), findsOneWidget);
    });
  });

  group('risk 5 — back-button ownership', () {
    testWidgets('broken: simulated back skips the go_router stack', (tester) async {
      await pump(tester, const ProviderScope(child: MyApp())); // back prio off
      await goToPoker(tester);
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
      await goToPoker(tester);
      await tapAndSettle(tester, find.text('Table Alpha'));
      await tapAndSettle(tester, find.text('Simulate Android system back'));
      expect(find.text('Table Alpha (go_router)'), findsNothing);
      expect(find.text('Poker lobby'), findsOneWidget);
    });
  });
}
