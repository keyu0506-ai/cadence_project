import 'package:flutter/material.dart';

class NavigationPlaceholderScreen extends StatelessWidget {
  const NavigationPlaceholderScreen({
    super.key,
    required this.title,
    required this.icon,
  });

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF7440E7), size: 56),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF17112F),
              fontSize: 30,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'This section is coming soon.',
            style: TextStyle(color: Color(0xFF8882A5), fontSize: 16),
          ),
        ],
      ),
    );
  }
}
