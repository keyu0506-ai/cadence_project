import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

enum CadenceNavDestination { today, schedule, power, recall, profile }

class CadenceBottomNavigationBar extends StatelessWidget {
  const CadenceBottomNavigationBar({
    super.key,
    required this.selectedDestination,
  });

  final CadenceNavDestination selectedDestination;

  void _navigate(BuildContext context, CadenceNavDestination destination) {
    const paths = {
      CadenceNavDestination.today: '/home',
      CadenceNavDestination.schedule: '/schedule',
      CadenceNavDestination.power: '/power',
      CadenceNavDestination.recall: '/recall',
      CadenceNavDestination.profile: '/profile',
    };

    context.go(paths[destination]!);
  }

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
            selected: selectedDestination == CadenceNavDestination.today,
            onTap: () => _navigate(context, CadenceNavDestination.today),
          ),
          _NavigationItem(
            icon: Icons.calendar_month_rounded,
            label: 'Schedule',
            selected: selectedDestination == CadenceNavDestination.schedule,
            onTap: () => _navigate(context, CadenceNavDestination.schedule),
          ),
          _FocusNavigationButton(
            selected: selectedDestination == CadenceNavDestination.power,
            onTap: () => _navigate(context, CadenceNavDestination.power),
          ),
          _NavigationItem(
            icon: Icons.sync_rounded,
            label: 'Recall',
            selected: selectedDestination == CadenceNavDestination.recall,
            onTap: () => _navigate(context, CadenceNavDestination.recall),
          ),
          _NavigationItem(
            icon: Icons.person_rounded,
            label: 'Profile',
            selected: selectedDestination == CadenceNavDestination.profile,
            onTap: () => _navigate(context, CadenceNavDestination.profile),
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
          child: Ink(
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
