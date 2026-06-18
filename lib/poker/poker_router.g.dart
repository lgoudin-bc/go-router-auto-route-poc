// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'poker_router.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [$pokerLobbyRoute];

RouteBase get $pokerLobbyRoute => GoRouteData.$route(
  path: '/',
  factory: $PokerLobbyRoute._fromState,
  routes: [
    GoRouteData.$route(path: 'table/:id', factory: $PokerTableRoute._fromState),
  ],
);

mixin $PokerLobbyRoute on GoRouteData {
  static PokerLobbyRoute _fromState(GoRouterState state) =>
      const PokerLobbyRoute();

  @override
  String get location => GoRouteData.$location('/');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $PokerTableRoute on GoRouteData {
  static PokerTableRoute _fromState(GoRouterState state) =>
      PokerTableRoute(id: state.pathParameters['id']!);

  PokerTableRoute get _self => this as PokerTableRoute;

  @override
  String get location =>
      GoRouteData.$location('/table/${Uri.encodeComponent(_self.id)}');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}
