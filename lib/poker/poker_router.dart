import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'poker_lobby_page.dart';
import 'poker_table_page.dart';

part 'poker_router.g.dart';

/// Typed routes for the embedded poker module, defined with go_router_builder
/// exactly like flutter-poker does. These compile into the generated
/// `$appRoutes` list consumed by [createPokerRouter].

@TypedGoRoute<PokerLobbyRoute>(
  path: '/',
  routes: [
    TypedGoRoute<PokerTableRoute>(path: 'table/:id'),
  ],
)
class PokerLobbyRoute extends GoRouteData with $PokerLobbyRoute {
  const PokerLobbyRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const PokerLobbyPage();
}

class PokerTableRoute extends GoRouteData with $PokerTableRoute {
  const PokerTableRoute({required this.id});

  final String id;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      PokerTablePage(tableId: id);
}

/// Builds the go_router instance that drives navigation *inside* the Poker tab.
///
/// It is intentionally a standalone [GoRouter] (not wired to MaterialApp) so it
/// can be embedded under auto_route via a nested `Router` widget.
GoRouter createPokerRouter() => GoRouter(routes: $appRoutes);
