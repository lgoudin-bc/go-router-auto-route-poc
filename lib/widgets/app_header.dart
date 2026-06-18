import 'package:flutter/material.dart';

/// The shell's global top header — stands in for flutter-front's `HeaderWidget`.
/// Provider-driven (title + visibility) and owned by the auto_route shell, it
/// sits above every tab's content.
class AppHeader extends StatelessWidget {
  const AppHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.indigo,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 56,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const Text(
                      'flutter-front HeaderWidget',
                      style: TextStyle(color: Colors.white70, fontSize: 10),
                    ),
                  ],
                ),
                const Spacer(),
                const Icon(Icons.account_balance_wallet, color: Colors.white, size: 20),
                const SizedBox(width: 6),
                const Text('€100', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
