import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../router/app_router.dart';
import '../state/header_state.dart';
import '../widgets/app_header.dart';

/// The app shell. auto_route owns the navigation. Two "universes" are simulated
/// like flutter-front: the Sport universe (Home + Risk lab tabs, full bottom
/// bar) and the Poker universe — when the Poker tab is active the bottom bar
/// collapses to a single floating "Back to Sports" button (the universe
/// switcher). The top [AppHeader] is provider-driven (title + visibility).
@RoutePage()
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  static const _pokerIndex = 1;

  @override
  Widget build(BuildContext context) {
    return AutoTabsRouter(
      routes: const [HomeRoute(), PokerHostRoute(), RiskLabRoute()],
      builder: (context, child) {
        final tabsRouter = AutoTabsRouter.of(context);
        return Consumer(
          builder: (context, ref, _) {
            final inPoker = tabsRouter.activeIndex == _pokerIndex;
            final headerVisible = ref.watch(appHeaderVisibleProvider);
            final title = ref.watch(appHeaderTitleProvider);
            return Scaffold(
              body: Column(
                children: [
                  if (headerVisible) AppHeader(title: title),
                  Expanded(child: child),
                ],
              ),
              // Poker universe → floating switcher; Sport universe → full bar.
              floatingActionButton: inPoker
                  ? FloatingActionButton.extended(
                      onPressed: () => tabsRouter.setActiveIndex(0),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Back to Sports'),
                    )
                  : null,
              floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
              bottomNavigationBar:
                  inPoker ? null : _SportTabBar(tabsRouter: tabsRouter),
            );
          },
        );
      },
    );
  }
}

/// The Sport-universe bottom bar: Home + Risk lab tabs on the left, a "Poker"
/// universe-switcher button on the right (mirrors flutter-front's MultiZoneTabBar).
class _SportTabBar extends StatelessWidget {
  const _SportTabBar({required this.tabsRouter});

  final TabsRouter tabsRouter;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                _TabButton(
                  icon: Icons.home,
                  label: 'Home',
                  selected: tabsRouter.activeIndex == 0,
                  onTap: () => tabsRouter.setActiveIndex(0),
                ),
                _TabButton(
                  icon: Icons.science,
                  label: 'Risk lab',
                  selected: tabsRouter.activeIndex == 2,
                  onTap: () => tabsRouter.setActiveIndex(2),
                ),
                const Spacer(),
                // Universe switcher → jump into the Poker universe.
                FilledButton.icon(
                  onPressed: () => tabsRouter.setActiveIndex(1),
                  icon: const Icon(Icons.casino),
                  label: const Text('Poker'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.onSurfaceVariant;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color),
            Text(label, style: TextStyle(color: color, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
