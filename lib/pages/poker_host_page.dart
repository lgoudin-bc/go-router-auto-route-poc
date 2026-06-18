import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../poker/poker_router.dart';

/// THE BOUNDARY.
///
/// An auto_route page (it lives in the auto_route route tree as the Poker tab)
/// that hands navigation off to a nested [GoRouter] via a raw [Router] widget.
///
/// The go_router instance is fully independent: it has its own [RouterDelegate],
/// [RouteInformationParser] and [RouteInformationProvider]. We attach a
/// [ChildBackButtonDispatcher] taken from the root so the Android system back
/// button reaches the nested go_router when this tab is in focus.
@RoutePage()
class PokerHostPage extends StatefulWidget {
  const PokerHostPage({super.key});

  @override
  State<PokerHostPage> createState() => _PokerHostPageState();
}

class _PokerHostPageState extends State<PokerHostPage> {
  late final GoRouter _pokerRouter = createPokerRouter();
  ChildBackButtonDispatcher? _backButtonDispatcher;

  @override
  Widget build(BuildContext context) {
    // Chain this nested router's back button handling to the root dispatcher.
    final rootDispatcher = Router.of(context).backButtonDispatcher;
    _backButtonDispatcher ??= rootDispatcher?.createChildBackButtonDispatcher();
    _backButtonDispatcher?.takePriority();

    return Router(
      routerDelegate: _pokerRouter.routerDelegate,
      routeInformationParser: _pokerRouter.routeInformationParser,
      routeInformationProvider: _pokerRouter.routeInformationProvider,
      backButtonDispatcher: _backButtonDispatcher,
    );
  }

  @override
  void dispose() {
    _pokerRouter.dispose();
    super.dispose();
  }
}
