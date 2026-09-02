import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'cadence_shell.dart';
import '../providers/auth_providers.dart';
import '../screens/home/home_screen.dart';
import '../screens/placeholder/navigation_placeholder_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/sign_in/sign_in_screen.dart';
import '../screens/sign_up/sign_up_screen.dart';
import '../screens/welcome/welcome_screen.dart';

class AppRoutes {
  static const welcome = 'welcome';
  static const signUp = 'signUp';
  static const signIn = 'signIn';
  static const home = 'home';
  static const schedule = 'schedule';
  static const power = 'power';
  static const recall = 'recall';
  static const profile = 'profile';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  late final GoRouter router;

  router = GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);

      if (authState is AsyncLoading) {
        return null;
      }

      final user = switch (authState) {
        AsyncData(:final value) => value,
        _ => null,
      };
      final isPublicRoute = state.matchedLocation == '/' ||
          state.matchedLocation == '/sign-in' ||
          state.matchedLocation == '/sign-up';

      if (user == null && !isPublicRoute) {
        return '/';
      }

      if (user != null && isPublicRoute) {
        return '/home';
      }

      return null;
    },
    routes: [
    GoRoute(
      path: '/',
      name: AppRoutes.welcome,
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: '/sign-up',
      name: AppRoutes.signUp,
      builder: (context, state) => const SignUpScreen(),
    ),
    GoRoute(
      path: '/sign-in',
      name: AppRoutes.signIn,
      builder: (context, state) => const SignInScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return CadenceShell(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              name: AppRoutes.home,
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/schedule',
              name: AppRoutes.schedule,
              builder: (context, state) => const NavigationPlaceholderScreen(
                title: 'Schedule',
                icon: Icons.calendar_month_rounded,
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/power',
              name: AppRoutes.power,
              builder: (context, state) => const NavigationPlaceholderScreen(
                title: 'Power',
                icon: Icons.bolt_rounded,
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/recall',
              name: AppRoutes.recall,
              builder: (context, state) => const NavigationPlaceholderScreen(
                title: 'Recall',
                icon: Icons.sync_rounded,
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              name: AppRoutes.profile,
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
    ],
  );

  ref.listen(authStateProvider, (_, _) => router.refresh());
  ref.onDispose(router.dispose);

  return router;
});
