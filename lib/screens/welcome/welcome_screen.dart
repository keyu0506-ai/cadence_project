import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_router.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  static const _background = Color(0xFF120D2D);
  static const _mutedText = Color(0xFFB8B1C7);

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.sizeOf(context).height < 700;

    return Scaffold(
      backgroundColor: _background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topRight,
            radius: 1.25,
            colors: [Color(0xFF4A268A), Color(0xFF17112F), _background],
            stops: [0, 0.36, 1],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(24, isCompact ? 10 : 20, 24, isCompact ? 10 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  _BrandHeader(isCompact: isCompact),
                  const Spacer(),
                  _Tagline(isCompact: isCompact),
                  SizedBox(height: isCompact ? 10 : 16),
                  _Headline(isCompact: isCompact),
                  SizedBox(height: isCompact ? 8 : 12),
                  Text(
                    "Cadence reads your teachers' notes, then schedules exactly "
                    'what to do — around your sleep, your mood, and the way '
                    'memory actually works.',
                    style: TextStyle(
                      color: _mutedText,
                      fontSize: isCompact ? 14 : 16,
                      height: isCompact ? 1.25 : 1.35,
                    ),
                  ),
                  SizedBox(height: isCompact ? 12 : 20),
                  FeatureCard(
                    icon: Icons.camera_alt_rounded,
                    iconColor: Color(0xFF7D3AED),
                    title: 'Snap a note → instant calendar',
                    subtitle: 'AI turns any handout into dated to-dos',
                    isCompact: isCompact,
                  ),
                  SizedBox(height: isCompact ? 7 : 10),
                  FeatureCard(
                    icon: Icons.dark_mode_rounded,
                    iconColor: Color(0xFFF43F69),
                    title: 'Plans around your sleep & mood',
                    subtitle: 'Hard tasks land when your brain is sharpest',
                    isCompact: isCompact,
                  ),
                  SizedBox(height: isCompact ? 7 : 10),
                  FeatureCard(
                    icon: Icons.timeline_rounded,
                    iconColor: Color(0xFF10B981),
                    title: 'Beats the forgetting curve',
                    subtitle: 'Spaced reviews + Pomodoro, timed for you',
                    isCompact: isCompact,
                  ),
                  SizedBox(height: isCompact ? 12 : 20),
                  SizedBox(
                    width: double.infinity,
                    height: isCompact ? 48 : 54,
                    child: FilledButton(
                      onPressed: () {
                        context.pushNamed(AppRoutes.signUp);
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF8437E8),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        textStyle: TextStyle(
                          fontSize: isCompact ? 18 : 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [Text('Get Started'), SizedBox(width: 10), Icon(Icons.arrow_forward_rounded)],
                      ),
                    ),
                  ),
                  SizedBox(height: isCompact ? 10 : 14),
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Already have an account? ', style: TextStyle(color: _mutedText, fontSize: isCompact ? 14 : 16)),
                        TextButton(
                          onPressed: () {
                            context.pushNamed(AppRoutes.signIn);
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text('Sign in', style: TextStyle(color: const Color(0xFFD1B6FF), fontSize: isCompact ? 14 : 16, fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader({required this.isCompact});

  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: isCompact ? 44 : 50,
          height: isCompact ? 44 : 50,
          decoration: BoxDecoration(
            color: const Color(0xFF8845EE),
            borderRadius: BorderRadius.circular(isCompact ? 14 : 16),
            boxShadow: const [BoxShadow(color: Color(0x557E3FF2), blurRadius: 24)],
          ),
          child: Icon(Icons.psychology_rounded, color: Colors.white, size: isCompact ? 26 : 29),
        ),
        const SizedBox(width: 14),
        Text('Cadence', style: TextStyle(color: Colors.white, fontSize: isCompact ? 21 : 23, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _Tagline extends StatelessWidget {
  const _Tagline({required this.isCompact});

  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isCompact ? 11 : 15, vertical: isCompact ? 6 : 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
      ),
      child: Text(
        '✦  AI STUDY PLANNER · BUILT ON BRAIN SCIENCE',
        style: TextStyle(color: Colors.white, fontSize: isCompact ? 10 : 12, fontWeight: FontWeight.w700, letterSpacing: 0.15),
      ),
    );
  }
}

class _Headline extends StatelessWidget {
  const _Headline({required this.isCompact});

  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        style: TextStyle(color: Colors.white, fontSize: isCompact ? 37 : 43, height: 1.02, fontWeight: FontWeight.w800, letterSpacing: -1.5),
        children: const [
          TextSpan(text: 'Study in sync\nwith your '),
          TextSpan(text: 'brain.', style: TextStyle(color: Color(0xFFE77BB7))),
        ],
      ),
    );
  }
}

class FeatureCard extends StatelessWidget {
  const FeatureCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.isCompact,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.13)),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: isCompact ? 14 : 18, vertical: isCompact ? 3 : 6),
        leading: Container(
          width: isCompact ? 42 : 48,
          height: isCompact ? 42 : 48,
          decoration: BoxDecoration(color: iconColor, borderRadius: BorderRadius.circular(isCompact ? 12 : 14)),
          child: Icon(icon, color: Colors.white, size: isCompact ? 23 : 26),
        ),
        title: Text(title, style: TextStyle(color: Colors.white, fontSize: isCompact ? 14 : 16, fontWeight: FontWeight.w700)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(subtitle, style: TextStyle(color: const Color(0xFFAFA8BE), fontSize: isCompact ? 12 : 14)),
        ),
      ),
    );
  }
}
