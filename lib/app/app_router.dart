import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'cadence_shell.dart';
import '../features/capture/presentation/screens/capture_screen.dart';
import '../features/auth/presentation/screens/sign_in_screen.dart';
import '../features/auth/presentation/screens/sign_up_screen.dart';
import '../features/auth/presentation/screens/welcome_screen.dart';
import '../features/auth/providers/auth_providers.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/power/presentation/screens/power_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/recall/presentation/screens/recall_screen.dart';
import '../features/schedule/presentation/screens/schedule_screen.dart';

class AppRoutes {
  static const welcome = 'welcome';
  static const signUp = 'signUp';
  static const signIn = 'signIn';
  static const home = 'home';
  static const capture = 'capture';
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
    GoRoute(
      path: '/capture',
      name: AppRoutes.capture,
      builder: (context, state) => const CaptureScreen(),
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
              builder: (context, state) => const ScheduleScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/power',
              name: AppRoutes.power,
              builder: (context, state) => const PowerScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/recall',
              name: AppRoutes.recall,
              builder: (context, state) => const RecallScreen(),
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
