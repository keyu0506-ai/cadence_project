import 'package:flutter/material.dart';

import '../../../../shared/widgets/feature_placeholder_screen.dart';

class PowerScreen extends StatelessWidget {
  const PowerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholderScreen(
      title: 'Power',
      icon: Icons.bolt_rounded,
    );
  }
}
