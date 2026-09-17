import 'package:flutter/material.dart';

import '../../../../shared/widgets/feature_placeholder_screen.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholderScreen(
      title: 'Schedule',
      icon: Icons.calendar_month_rounded,
    );
  }
}
