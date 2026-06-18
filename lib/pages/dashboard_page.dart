import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../router/app_router.dart';
import '../state/navbar_state.dart';

/// The app shell. auto_route's [AutoTabsScaffold] owns the bottom navigation,
/// but — like flutter-front — the bar's CONTENT and VISIBILITY are driven by
/// Riverpod providers ([tabConfigProvider], [navBarVisibleProvider]) rather than
/// by static route config. That's what lets the go_router poker side influence
/// the bar (label, visibility) through shared state.
@RoutePage()
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AutoTabsScaffold(
      routes: const [HomeRoute(), PokerHostRoute(), RiskLabRoute()],
      bottomNavigationBuilder: (_, tabsRouter) {
        return Consumer(
          builder: (context, ref, _) {
            // Risk 3: a poker page can hide the whole bar via this provider.
            if (!ref.watch(navBarVisibleProvider)) return const SizedBox.shrink();
            final tabs = ref.watch(tabConfigProvider);
            return BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: tabsRouter.activeIndex,
              onTap: tabsRouter.setActiveIndex,
              items: [
                for (final tab in tabs)
                  BottomNavigationBarItem(
                    icon: Icon(tab.icon),
                    label: tab.label,
                  ),
              ],
            );
          },
        );
      },
    );
  }
}
