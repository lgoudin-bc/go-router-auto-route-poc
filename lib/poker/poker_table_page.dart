import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/router_banner.dart';

/// Table detail screen — pushed onto the go_router stack from the lobby.
class PokerTablePage extends StatelessWidget {
  const PokerTablePage({super.key, required this.tableId});

  final String tableId;

  @override
  Widget build(BuildContext context) {
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
