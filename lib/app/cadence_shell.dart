import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/cadence_bottom_navigation_bar.dart';

class CadenceShell extends StatelessWidget {
  const CadenceShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5FF),
      body: SafeArea(child: navigationShell),
      bottomNavigationBar: SafeArea(
        top: false,
        child: CadenceBottomNavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: navigationShell.goBranch,
        ),
      ),
    );
  }
}
