import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/providers/auth_providers.dart';
import '../../../tasks/task.dart';
import '../../../tasks/tasks_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const _pageBackground = Color(0xFFF7F5FF);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = switch (authState) {
      AsyncData(:final value) => value,
      _ => null,
    };
    final displayName = user?.displayName?.trim();
    final username = displayName != null && displayName.isNotEmpty
        ? displayName
        : 'there';

    return ColoredBox(
      color: _pageBackground,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 26, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HomeHeader(username: username),
            const SizedBox(height: 24),
            const _BrainTodayCard(),
            const SizedBox(height: 20),
            const _NextFocusCard(),
            const SizedBox(height: 28),
            const _PlanSection(),
            const SizedBox(height: 28),
            const _DeadlinesSection(),
          ],
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.username});

  final String username;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                MaterialLocalizations.of(
                  context,
                ).formatFullDate(DateTime.now()),
                style: TextStyle(
                  color: Color(0xFF8882A5),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                'Good morning, $username ✦',
                style: const TextStyle(
                  color: Color(0xFF120D2D),
                  fontSize: 35,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.2,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFB6EDFF), Color(0xFF4274A6)],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFF8242F0), width: 2),
              ),
              child: const Icon(
                Icons.person_rounded,
                color: Colors.white,
                size: 42,
              ),
            ),
            Positioned(
              right: -2,
              bottom: -2,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: const Color(0xFF5CC48B),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BrainTodayCard extends StatelessWidget {
  const _BrainTodayCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF20184C), Color(0xFF13102F)],
        ),
        borderRadius: BorderRadius.circular(38),
        boxShadow: const [
          BoxShadow(
            color: Color(0x220E0A28),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _SectionPill(
            icon: Icons.psychology_rounded,
            label: 'YOUR BRAIN TODAY',
          ),
          SizedBox(height: 18),
          Text.rich(
            TextSpan(
              style: TextStyle(
                color: Colors.white,
                fontSize: 29,
                height: 1.28,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.8,
              ),
              children: [
                TextSpan(text: 'You slept well — focus peaks '),
                TextSpan(
                  text: '10am–1pm.',
                  style: TextStyle(color: Color(0xFFB59BFF)),
                ),
                TextSpan(text: ' I front-loaded your hardest work there.'),
              ],
            ),
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  value: '7ʰ 40ᵐ',
                  label: 'Sleep · deep',
                  dotColor: Color(0xFF62C9A1),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _MetricCard(
                  value: 'Calm',
                  label: 'Mood · steady',
                  dotColor: Color(0xFF9C83F6),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _MetricCard(
                  value: 'High',
                  label: 'Energy · AM',
                  dotColor: Color(0xFFE58091),
                ),
              ),
            ],
          ),
          SizedBox(height: 22),
          _FocusCapacity(),
        ],
      ),
    );
  }
}

class _SectionPill extends StatelessWidget {
  const _SectionPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFFB59BFF), size: 21),
          const SizedBox(width: 9),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.value,
    required this.label,
    required this.dotColor,
  });

  final String value;
  final String label;
  final Color dotColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 16, 8, 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFFC1BCD0),
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FocusCapacity extends StatelessWidget {
  const _FocusCapacity();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Predicted focus capacity',
              style: TextStyle(
                color: Color(0xFFD9D4E6),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '82%',
              style: TextStyle(
                color: Color(0xFFB59BFF),
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: const LinearProgressIndicator(
            value: 0.82,
            minHeight: 14,
            color: Color(0xFFE8778D),
            backgroundColor: Color(0xFF3D375B),
          ),
        ),
      ],
    );
  }
}

class _NextFocusCard extends StatelessWidget {
  const _NextFocusCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: const [
          BoxShadow(
            color: Color(0x160B0734),
            blurRadius: 22,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8451F1), Color(0xFF4A1CB7)],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.bolt_rounded,
              color: Colors.white,
              size: 42,
            ),
          ),
          const SizedBox(width: 18),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NEXT FOCUS BLOCK · IN 25 MIN',
                  style: TextStyle(
                    color: Color(0xFF7042DD),
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'AP Bio — Cell Respiration',
                  style: TextStyle(
                    color: Color(0xFF17112F),
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '⏱  2 × 25 min Pomodoro · peak window',
                  style: TextStyle(color: Color(0xFF8D87AA), fontSize: 15),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            onPressed: () {},
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFF151131),
              minimumSize: const Size(56, 56),
            ),
            icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _PlanSection extends ConsumerWidget {
  const _PlanSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = taskDate(DateTime.now());
    final tasks = ref
        .watch(tasksProvider)
        .where((task) => task.dueDate == today)
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                "Today's Plan",
                style: TextStyle(
                  color: Color(0xFF17112F),
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            IconButton.filled(
              tooltip: 'Capture note',
              onPressed: () => context.push('/capture'),
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFF8946F5),
                foregroundColor: Colors.white,
                minimumSize: const Size(52, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              icon: const Icon(Icons.add_a_photo_outlined),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (tasks.isEmpty)
          const Text(
            'There is nothing due today',
            style: TextStyle(color: Color(0xFF8882A5)),
          ),
        for (final task in tasks) _SavedTaskCard(task: task),
      ],
    );
  }
}

class _DeadlinesSection extends ConsumerWidget {
  const _DeadlinesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = taskDate(DateTime.now());
    final tasks =
        ref
            .watch(tasksProvider)
            .where((task) => task.dueDate.isAfter(today))
            .toList()
          ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Upcoming Deadlines',
          style: TextStyle(
            color: Color(0xFF17112F),
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 14),
        if (tasks.isEmpty)
          const Text(
            'No upcoming deadlines',
            style: TextStyle(color: Color(0xFF8882A5)),
          ),
        for (final task in tasks) _SavedTaskCard(task: task),
      ],
    );
  }
}

class _SavedTaskCard extends StatelessWidget {
  const _SavedTaskCard({required this.task});
  final Task task;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            task.title,
            style: const TextStyle(
              color: Color(0xFF17112F),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            MaterialLocalizations.of(context).formatMediumDate(task.dueDate),
            style: const TextStyle(color: Color(0xFF7544E5)),
          ),
          if (task.notes != null) ...[
            const SizedBox(height: 8),
            Text(task.notes!, style: const TextStyle(color: Color(0xFF766C8D))),
          ],
        ],
      ),
    );
  }
}
