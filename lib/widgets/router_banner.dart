import 'package:flutter/material.dart';

/// A loud banner that states which routing package rendered the screen.
///
/// This is the visual proof of the PoC: as you navigate, the banners make it
/// obvious whether auto_route or go_router put the current screen on screen.
class RouterBanner extends StatelessWidget {
  const RouterBanner({super.key, required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: color,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.alt_route, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
