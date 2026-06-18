import 'package:auto_route/auto_route.dart';

import '../pages/dashboard_page.dart';
import '../pages/detail_page.dart';
import '../pages/home_page.dart';
import '../pages/my_account_page.dart';
import '../pages/poker_host_page.dart';
import 'cupertino_modal_route.dart';

part 'app_router.gr.dart';

/// Top-level auto_route configuration.
///
/// The dashboard hosts two tabs (Home, Poker). Home keeps its own auto_route
/// stack (Home -> Detail). Poker hands off to go_router inside [PokerHostPage].
@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(
          path: '/',
          page: DashboardRoute.page,
          initial: true,
          children: [
            AutoRoute(path: 'home', page: HomeRoute.page, initial: true),
            AutoRoute(path: 'detail', page: DetailRoute.page),
            AutoRoute(path: 'poker', page: PokerHostRoute.page),
          ],
        ),
        // Root-level modal: presented bottom-to-top over everything (incl. the
        // bottom tabs). Triggered from the go_router side. See [MyAccountPage].
        CupertinoModalRoute(path: '/my-account', page: MyAccountRoute.page),
      ];
}
