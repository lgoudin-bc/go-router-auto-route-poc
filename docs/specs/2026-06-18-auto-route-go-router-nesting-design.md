# PoC: auto_route hosting a go_router sub-route

Date: 2026-06-18

## Goal

Prove without a doubt that a Flutter app whose top-level routing uses **auto_route**
can contain a sub-route whose navigation is driven by **go_router**. This mirrors an
upcoming migration where `flutter-poker` (go_router) becomes a bottom tab inside
`flutter-front` (auto_route).

## Versions (pinned to match the real apps)

- `auto_route: 11.1.0` + `auto_route_generator: 10.4.0` (from flutter-front)
- `go_router: 15.1.3` + `go_router_builder: ^4.2.0` (from flutter-poker)
- Flutter `3.41.3` via fvm; Dart SDK `>=3.11.0 <4.0.0`

## Architecture

### Top level — auto_route owns the shell
- `MaterialApp.router` wired to an auto_route `AppRouter` (codegen).
- `AutoTabsScaffold` with a `BottomNavigationBar`, two tabs:
  - **Home tab**: pure auto_route. Home → Detail stacked push to show auto_route's
    own stack navigation works normally.
  - **Poker tab**: an auto_route page (`PokerHostPage`) that embeds the go_router module.

### Boundary — nested `Router` widget
- `PokerHostPage` renders the go_router module via a raw `Router` widget using
  `goRouter.routerDelegate`, `goRouter.routeInformationParser`,
  `goRouter.routeInformationProvider`, and a `ChildBackButtonDispatcher` taken from
  the root `Router` so the Android back button reaches the nested go_router.
- The two routers are fully independent — this is the crux of the proof.

### Inside the tab — go_router owns sub-navigation (go_router_builder codegen)
- Typed routes: `PokerLobbyRoute` (`/`) → `PokerTableRoute` (`table/:id`).
- Lobby lists tables; tapping one performs a go_router navigation to the table screen;
  back returns to the lobby — all driven by go_router while the auto_route bottom tabs
  remain visible and switchable.

## Proof made visible
Every screen shows a banner labeling which router rendered it
("Routed by auto_route" / "Routed by go_router"). Demonstrable interactions:
1. Switch bottom tabs (auto_route).
2. Push/pop within Home tab (auto_route stack).
3. Open a table and go back inside Poker tab (go_router stack) while tabs stay visible.

## Verification
- `dart run build_runner build` generates both auto_route and go_router_builder code
  with no conflict.
- App compiles and runs (Chrome or simulator); all three interactions above work.
- README documents how to run and what each interaction proves.

## Out of scope (YAGNI)
- Riverpod / DI, real poker logic, deep-link URL syncing between the two routers,
  theming, tests beyond a smoke check. This PoC only proves coexistence.
