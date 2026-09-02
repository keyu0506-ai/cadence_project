import 'package:flutter/material.dart';

class CadenceBottomNavigationBar extends StatelessWidget {
  const CadenceBottomNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x120E0A28),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _NavigationItem(
            icon: Icons.home_rounded,
            label: 'Today',
            selected: selectedIndex == 0,
            onTap: () => onDestinationSelected(0),
          ),
          _NavigationItem(
            icon: Icons.calendar_month_rounded,
            label: 'Schedule',
            selected: selectedIndex == 1,
            onTap: () => onDestinationSelected(1),
          ),
          _FocusNavigationButton(
            selected: selectedIndex == 2,
            onTap: () => onDestinationSelected(2),
          ),
          _NavigationItem(
            icon: Icons.sync_rounded,
            label: 'Recall',
            selected: selectedIndex == 3,
            onTap: () => onDestinationSelected(3),
          ),
          _NavigationItem(
            icon: Icons.person_rounded,
            label: 'Profile',
            selected: selectedIndex == 4,
            onTap: () => onDestinationSelected(4),
          ),
        ],
      ),
    );
  }
}

class _NavigationItem extends StatelessWidget {
  const _NavigationItem({
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
    final color = selected ? const Color(0xFF7440E7) : const Color(0xFF9690B0);

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FocusNavigationButton extends StatelessWidget {
  const _FocusNavigationButton({required this.selected, required this.onTap});

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: 'Power',
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF804CF1), Color(0xFF421AA7)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected ? const Color(0xFFE0D3FF) : const Color(0xFF2B176E),
                width: 2,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x447044D9),
                  blurRadius: 15,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 34),
          ),
        ),
      ),
    );
  }
}
