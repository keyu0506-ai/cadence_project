import 'package:flutter/material.dart';

import '../../widgets/cadence_bottom_navigation_bar.dart';

class NavigationPlaceholderScreen extends StatelessWidget {
  const NavigationPlaceholderScreen({
    super.key,
    required this.title,
    required this.destination,
  });

  final String title;
  final CadenceNavDestination destination;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5FF),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_iconFor(destination), color: const Color(0xFF7440E7), size: 56),
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
              ),
            ),
            CadenceBottomNavigationBar(selectedDestination: destination),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(CadenceNavDestination destination) {
    switch (destination) {
      case CadenceNavDestination.schedule:
        return Icons.calendar_month_rounded;
      case CadenceNavDestination.power:
        return Icons.bolt_rounded;
      case CadenceNavDestination.recall:
        return Icons.sync_rounded;
      case CadenceNavDestination.profile:
        return Icons.person_rounded;
      case CadenceNavDestination.today:
        return Icons.home_rounded;
    }
  }
}
