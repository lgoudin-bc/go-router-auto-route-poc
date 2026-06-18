import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../router/app_router.dart';

/// The app shell. auto_route's [AutoTabsScaffold] owns the bottom navigation.
///
/// Tab 0 (Home) is pure auto_route. Tab 1 (Poker) hosts a go_router-driven
/// module via [PokerHostRoute] — mirroring flutter-poker becoming a bottom tab
/// inside flutter-front.
@RoutePage()
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AutoTabsScaffold(
      routes: const [HomeRoute(), PokerHostRoute()],
      bottomNavigationBuilder: (_, tabsRouter) {
        return BottomNavigationBar(
          currentIndex: tabsRouter.activeIndex,
          onTap: tabsRouter.setActiveIndex,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.casino), label: 'Poker'),
          ],
        );
      },
    );
  }
}
