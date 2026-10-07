import 'dart:async';
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
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HomeHeader(username: username),
            const SizedBox(height: 14),
            const _BrainTodayCard(),
            const SizedBox(height: 12),
            const _NextFocusCard(),
            const SizedBox(height: 18),
            const _PlanSection(),
            const SizedBox(height: 18),
            const _DeadlinesSection(),
          ],
        ),
      ),
    );
  }
}

class _HomeHeader extends StatefulWidget {
  const _HomeHeader({required this.username});

  final String username;

  @override
  State<_HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<_HomeHeader> with WidgetsBindingObserver {
  late final Timer _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _timer = Timer.periodic(const Duration(minutes: 1), (_) => _refresh());
  }

  void _refresh() => setState(() => _now = DateTime.now());

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refresh();
  }

  @override
  void dispose() {
    _timer.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final greeting = switch (_now.hour) {
      >= 5 && < 12 => 'Good morning',
      >= 12 && < 17 => 'Good afternoon',
      >= 17 && < 21 => 'Good evening',
      _ => 'Good night',
    };
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                MaterialLocalizations.of(context).formatFullDate(_now),
                style: TextStyle(
                  color: Color(0xFF8882A5),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                '$greeting, ${widget.username} ✦',
                style: const TextStyle(
                  color: Color(0xFF120D2D),
                  fontSize: 24,
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
              width: 48,
              height: 48,
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
                size: 30,
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF20184C), Color(0xFF13102F)],
        ),
        borderRadius: BorderRadius.circular(24),
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
                fontSize: 20,
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
              fontSize: 12,
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
              fontSize: 17,
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
                    fontSize: 11,
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
            Expanded(
              child: Text(
                'Predicted focus capacity',
                style: TextStyle(
                  color: Color(0xFFD9D4E6),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(width: 8),
            Text(
              '82%',
              style: TextStyle(
                color: Color(0xFFB59BFF),
                fontSize: 16,
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
        borderRadius: BorderRadius.circular(20),
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
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8451F1), Color(0xFF4A1CB7)],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.bolt_rounded,
              color: Colors.white,
              size: 30,
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
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'AP Bio — Cell Respiration',
                  style: TextStyle(
                    color: Color(0xFF17112F),
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '⏱  2 × 25 min Pomodoro · peak window',
                  style: TextStyle(color: Color(0xFF8D87AA), fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            onPressed: () {},
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFF151131),
              minimumSize: const Size(40, 40),
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
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            IconButton.filled(
              tooltip: 'Add tasks',
              onPressed: () => context.push('/capture'),
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFF8946F5),
                foregroundColor: Colors.white,
                minimumSize: const Size(36, 36),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              icon: const Icon(Icons.add_rounded),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const _TaskList(upcoming: false),
      ],
    );
  }
}

class _DeadlinesSection extends ConsumerWidget {
  const _DeadlinesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Upcoming Deadlines',
          style: TextStyle(
            color: Color(0xFF17112F),
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 14),
        const _TaskList(upcoming: true),
      ],
    );
  }
}

class _TaskList extends ConsumerWidget {
  const _TaskList({required this.upcoming});
  final bool upcoming;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(tasksProvider)
        .when(
          skipLoadingOnRefresh: false,
          skipLoadingOnReload: false,
          loading: () => const Padding(
            padding: EdgeInsets.all(12),
            child: LinearProgressIndicator(semanticsLabel: 'Loading tasks'),
          ),
          error: (_, _) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Could not load tasks. Please try again.',
                style: TextStyle(color: Color(0xFFB3261E)),
              ),
              TextButton(
                onPressed: () {
                  final userId = ref.read(taskUserIdProvider);
                  if (userId != null) ref.invalidate(userTasksProvider(userId));
                },
                child: const Text('Retry'),
              ),
            ],
          ),
          data: (allTasks) {
            final today = taskDate(DateTime.now());
            final tasks =
                allTasks
                    .where(
                      (task) => upcoming
                          ? task.dueDate.isAfter(today)
                          : task.dueDate == today,
                    )
                    .toList()
                  ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
            if (tasks.isEmpty) {
              return Text(
                upcoming
                    ? 'No upcoming deadlines'
                    : 'There is nothing due today',
                style: const TextStyle(color: Color(0xFF8882A5)),
              );
            }
            if (upcoming) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  final width = ((constraints.maxWidth - 16) / 3)
                      .clamp(112.0, 180.0)
                      .toDouble();
                  return SizedBox(
                    height: 104,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: tasks.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, index) => _UpcomingTaskCard(
                        task: tasks[index],
                        index: index,
                        width: width,
                      ),
                    ),
                  );
                },
              );
            }
            return Column(
              children: [
                for (var index = 0; index < tasks.length; index++)
                  _TodayTaskRow(task: tasks[index], index: index),
              ],
            );
          },
        );
  }
}

const _taskColors = [
  Color(0xFF7544E5),
  Color(0xFFE94B64),
  Color(0xFF45AA83),
  Color(0xFFD99528),
];
const _deadlineGradients = [
  [Color(0xFFE94362), Color(0xFFA92742)],
  [Color(0xFF8956EF), Color(0xFF5430B8)],
  [Color(0xFF58B6EC), Color(0xFF337EB7)],
];

void _showTaskDetails(BuildContext context, Task task) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    backgroundColor: const Color(0xFFF7F5FF),
    isScrollControlled: true,
    builder: (context) => SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 4, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task.title,
              style: const TextStyle(
                color: Color(0xFF17112F),
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            if (task.subject != null)
              Text(
                task.subject!,
                style: const TextStyle(
                  color: Color(0xFF7544E5),
                  fontWeight: FontWeight.w700,
                ),
              ),
            const SizedBox(height: 8),
            Text(
              'Due ${MaterialLocalizations.of(context).formatFullDate(task.dueDate)}',
              style: const TextStyle(color: Color(0xFF766C8D)),
            ),
            if (task.notes != null) ...[
              const SizedBox(height: 16),
              Text(
                task.notes!,
                style: const TextStyle(color: Color(0xFF514965), height: 1.5),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}

class _TodayTaskRow extends StatelessWidget {
  const _TodayTaskRow({required this.task, required this.index});
  final Task task;
  final int index;

  @override
  Widget build(BuildContext context) {
    final color = _taskColors[index % _taskColors.length];
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          const SizedBox(
            width: 42,
            child: Column(
              children: [
                Text(
                  'DUE',
                  style: TextStyle(
                    color: Color(0xFF403652),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'TODAY',
                  style: TextStyle(color: Color(0xFF9188AA), fontSize: 9),
                ),
              ],
            ),
          ),
          Expanded(
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                onTap: () => _showTaskDetails(context, task),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [color.withValues(alpha: 0.75), color],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          task.subject == null
                              ? Icons.description_rounded
                              : Icons.school_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF201831),
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (task.notes != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                task.notes!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFF9188AA),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                            if (task.subject != null) ...[
                              const SizedBox(height: 5),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.10),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  task.subject!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: color,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UpcomingTaskCard extends StatelessWidget {
  const _UpcomingTaskCard({
    required this.task,
    required this.index,
    required this.width,
  });
  final Task task;
  final int index;
  final double width;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final days = DateTime.utc(
      task.dueDate.year,
      task.dueDate.month,
      task.dueDate.day,
    ).difference(DateTime.utc(today.year, today.month, today.day)).inDays;
    final date = MaterialLocalizations.of(
      context,
    ).formatShortDate(task.dueDate);
    return SizedBox(
      width: width,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _deadlineGradients[index % _deadlineGradients.length],
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => _showTaskDetails(context, task),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.description_outlined,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          task.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            height: 1.2,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  if (task.subject != null)
                    Text(
                      task.subject!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFEAE1FF),
                        fontSize: 10,
                      ),
                    ),
                  const SizedBox(height: 5),
                  Text(
                    '$date · ${days}d',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
