# auto_route → go_router nesting PoC

Proves that a Flutter app whose **top-level routing uses `auto_route`** can contain a
**sub-route driven by `go_router`**. This mirrors the upcoming migration where
`flutter-poker` (go_router) becomes a bottom tab inside `flutter-front` (auto_route).

## Versions (pinned to the real apps)

| Package | Version | Source app |
|---|---|---|
| `auto_route` | `11.1.0` | flutter-front |
| `auto_route_generator` | `10.4.0` | flutter-front |
| `go_router` | `15.1.3` | flutter-poker |
| `go_router_builder` | `^4.2.0` | flutter-poker |

Flutter `3.41.3` (fvm). The two routing packages resolve and build together with no
dependency conflict.

## Video proof

A screen recording (iOS simulator) of the running app showing auto_route tab
navigation, the auto_route stack push, and the nested go_router navigation inside the
Poker tab:

<img height="800" alt="ezgif-6d385f421543ea8c" src="https://github.com/user-attachments/assets/b2b7d68e-6d93-42a5-9857-54e2eee2e797" />

## How it works

```
MaterialApp.router
└── AppRouter (auto_route)                ← top-level routing
    └── DashboardPage / AutoTabsScaffold  ← bottom navigation (auto_route)
        ├── Home tab        → HomePage ──push──▶ DetailPage     (auto_route stack)
        └── Poker tab       → PokerHostPage                     ← THE BOUNDARY
                                  └── Router(widget) wired to a GoRouter
                                      └── PokerLobbyPage ──push──▶ PokerTablePage
                                          (go_router stack, typed routes via
                                           go_router_builder)
    └── MyAccountRoute (root-level CupertinoModalRoute)  ← presented bottom-to-top
            ▲                                              over EVERYTHING, and
            └─── pushed from the go_router lobby ──────────  triggered from go_router
```

The boundary lives in [`lib/pages/poker_host_page.dart`](lib/pages/poker_host_page.dart):
an auto_route page renders a standalone `GoRouter` through a raw `Router` widget
(`routerDelegate` / `routeInformationParser` / `routeInformationProvider`), and chains a
`ChildBackButtonDispatcher` from the root so the system back button reaches the nested
go_router. The two routers are completely independent.

go_router routes are declared with `go_router_builder` typed routes in
[`lib/poker/poker_router.dart`](lib/poker/poker_router.dart), exactly as flutter-poker
does.

### Reverse direction: a go_router screen presenting an auto_route page

The go_router lobby has an **"Open My Account (auto_route)"** button that presents
[`MyAccountPage`](lib/pages/my_account_page.dart) — a page that belongs to the
**auto_route** tree — as a root-level, bottom-to-top sheet over the entire shell
(including the bottom tabs):

```dart
// inside a go_router screen:
context.router.root.push(const MyAccountRoute());
```

This works because auto_route's `RouterScope` `InheritedWidget` propagates down through
the nested go_router's `Navigator`, so `context.router` inside a go_router page still
resolves to the auto_route controller; `.root` pushes onto the root stack.
[`MyAccountRoute`](lib/router/app_router.dart) is registered at the root as a
`CupertinoModalRoute` ([`lib/router/cupertino_modal_route.dart`](lib/router/cupertino_modal_route.dart)),
a copy of flutter-front's bottom-to-top modal pattern (`fullscreenDialog: true` +
`CupertinoSheetRoute`).

## What proves the point

Run the app and:

1. **Switch bottom tabs** (Home ↔ Poker) — driven by **auto_route**.
2. **Home → "Push auto_route Detail" → Pop** — an **auto_route** stack push/pop.
3. **Poker tab → tap a table → "Pop (go_router)"** — a **go_router** stack push/pop,
   while the auto_route bottom tabs stay visible the whole time.
4. **Poker tab → "Open My Account (auto_route)"** — a **go_router** screen presents an
   **auto_route** page as a bottom-to-top sheet over the whole shell, then closes.

Every screen shows a colored banner naming the router that rendered it
(indigo = auto_route, teal = go_router), so the coexistence is visible at a glance.

## Migration risks proven (Risk lab tab)

The navbar is **Riverpod-driven** like flutter-front (the bar's labels and visibility
come from providers — [`lib/state/navbar_state.dart`](lib/state/navbar_state.dart) —
not from static route config). The **Risk lab** tab has one switch per migration risk:
**OFF = risk reproduced, ON = fix applied**. Flip a switch, then watch the Poker tab /
navbar. Each risk is also asserted in both states in
[`test/widget_test.dart`](test/widget_test.dart).

| # | Risk | Reproduced (OFF) | Mitigation (ON) |
|---|------|------------------|-----------------|
| 1 | **Double bottom-nav** | poker renders its own bar (like flutter-poker's `NavigationBarScreen`) → two stacked bars | poker's bar suppressed → single bar |
| 2 | **ProviderScope shadowing** | a nested `ProviderScope` over the poker subtree shadows `pokerTabLabelProvider`; "Rename tab from go_router" never reaches the navbar | shared scope → the go_router rename updates the auto_route tab title |
| 3 | **Bar visibility isn't automatic** | opening a go_router fullscreen table leaves the auto_route bar visible | a go_router listener drives `navBarVisibleProvider` → bar hides on the table, restores on pop |
| 4 | **Sub-route awareness lost** | only "poker" is known; the go_router location is invisible to auto_route | the same listener bridges the real location into `pokerActiveSubRouteProvider` |
| 5 | **Back-button ownership** | "Simulate Android system back" skips the go_router stack | the nested go_router takes back priority → system back pops its stack first |

Key takeaways for the migration:
- Cross-router control of the navbar works **only through shared Riverpod state**, never
  through go_router's routing APIs — and only if poker and the shell share one
  `ProviderScope` (risk 2).
- Risks 3 & 4 are mitigated centrally by a single go_router listener in
  [`lib/pages/poker_host_page.dart`](lib/pages/poker_host_page.dart) that bridges
  navigation into providers. Provider writes are deferred (post-frame) because the
  router notifies during build.
- Risk 6 (package-name collisions, e.g. both repos ship a `base_router`) is a build-time
  monorepo concern and isn't demonstrable in one running app — see the analysis, not the PoC.

## Run it

```sh
fvm flutter pub get
fvm dart run build_runner build      # generates app_router.gr.dart + poker_router.g.dart
fvm flutter run                      # or: fvm flutter run -d chrome
```

## Verify

```sh
fvm flutter analyze    # No issues found
fvm flutter test       # smoke test exercises the full nested-router flow
fvm flutter build web  # full app compiles with both routers
```

The 12 tests in [`test/widget_test.dart`](test/widget_test.dart) cover the coexistence
flow (nested go_router, the auto_route modal opened from go_router) plus each migration
risk in both its broken and fixed state.

## Design doc

[`docs/specs/2026-06-18-auto-route-go-router-nesting-design.md`](docs/specs/2026-06-18-auto-route-go-router-nesting-design.md)
