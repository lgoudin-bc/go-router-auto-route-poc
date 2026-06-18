import 'package:flutter/material.dart';

/// Poker's own top header — stands in for flutter-poker's `NavigationBarScreen`
/// (back button left, Betclic logo centered, wallet right). In the real app this
/// is rendered by the poker module itself; here it's shown inside the poker tab
/// so risk 1 (double header) is visible when the shell's [AppHeader] also shows.
class PokerHeader extends StatelessWidget {
  const PokerHeader({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.teal.shade900,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 56,
          child: Row(
            children: [
              SizedBox(
                width: 56,
                child: onBack == null
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: onBack,
                      ),
              ),
              const Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'betclic',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      'flutter-poker NavigationBarScreen',
                      style: TextStyle(color: Colors.white70, fontSize: 10),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                width: 56,
                child: Icon(Icons.account_balance_wallet, color: Colors.white, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
