import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../state/back_dispatcher.dart';
import '../widgets/router_banner.dart';

/// Table detail screen — a go_router "fullscreen" route pushed from the lobby.
/// Risks 3 (hide navbar) and 4 (publish location) are driven centrally by the
/// go_router listener in PokerHostPage; this page only adds a button to simulate
/// the Android system back for risk 5.
class PokerTablePage extends ConsumerWidget {
  const PokerTablePage({super.key, required this.tableId});

  final String tableId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text('Table $tableId (go_router)')),
      body: Column(
        children: [
          const RouterBanner(
            label: 'Routed by go_router',
            color: Colors.teal,
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Pushed onto the nested go_router stack.\n'
                    'Path param id = "$tableId".',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Pop (go_router)'),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.tonalIcon(
                    // Risk 5: simulate the OS back button by invoking the same
                    // root dispatcher the OS would. With back priority on, the
                    // nested go_router handles it (table pops); without it, the
                    // root handles it and the table is left untouched.
                    onPressed: () => ref
                        .read(rootBackDispatcherProvider)
                        .invokeCallback(Future<bool>.value(false)),
                    icon: const Icon(Icons.smartphone),
                    label: const Text('Simulate Android system back'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
