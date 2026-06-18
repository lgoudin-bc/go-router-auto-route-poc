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
Poker tab: [`docs/media/poc-demo.mov`](docs/media/poc-demo.mov).

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
```

The boundary lives in [`lib/pages/poker_host_page.dart`](lib/pages/poker_host_page.dart):
an auto_route page renders a standalone `GoRouter` through a raw `Router` widget
(`routerDelegate` / `routeInformationParser` / `routeInformationProvider`), and chains a
`ChildBackButtonDispatcher` from the root so the system back button reaches the nested
go_router. The two routers are completely independent.

go_router routes are declared with `go_router_builder` typed routes in
[`lib/poker/poker_router.dart`](lib/poker/poker_router.dart), exactly as flutter-poker
does.

## What proves the point

Run the app and:

1. **Switch bottom tabs** (Home ↔ Poker) — driven by **auto_route**.
2. **Home → "Push auto_route Detail" → Pop** — an **auto_route** stack push/pop.
3. **Poker tab → tap a table → "Pop (go_router)"** — a **go_router** stack push/pop,
   while the auto_route bottom tabs stay visible the whole time.

Every screen shows a colored banner naming the router that rendered it
(indigo = auto_route, teal = go_router), so the coexistence is visible at a glance.

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

The smoke test in [`test/widget_test.dart`](test/widget_test.dart) asserts the auto_route
shell renders, switching to the Poker tab reveals a go_router screen, a go_router push
opens a table while the auto_route tabs remain on screen, and a go_router pop returns to
the lobby.

## Design doc

[`docs/specs/2026-06-18-auto-route-go-router-nesting-design.md`](docs/specs/2026-06-18-auto-route-go-router-nesting-design.md)
