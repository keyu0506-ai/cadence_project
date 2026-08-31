import 'package:go_router/go_router.dart';

import '../screens/home/home_screen.dart';
import '../screens/placeholder/navigation_placeholder_screen.dart';
import '../screens/sign_in/sign_in_screen.dart';
import '../screens/sign_up/sign_up_screen.dart';
import '../screens/welcome/welcome_screen.dart';
import '../widgets/cadence_bottom_navigation_bar.dart';

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

final appRouter = GoRouter(
  initialLocation: '/',
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
      path: '/home',
      name: AppRoutes.home,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/schedule',
      name: AppRoutes.schedule,
      builder: (context, state) => const NavigationPlaceholderScreen(
        title: 'Schedule',
        destination: CadenceNavDestination.schedule,
      ),
    ),
    GoRoute(
      path: '/power',
      name: AppRoutes.power,
      builder: (context, state) => const NavigationPlaceholderScreen(
        title: 'Power',
        destination: CadenceNavDestination.power,
      ),
    ),
    GoRoute(
      path: '/recall',
      name: AppRoutes.recall,
      builder: (context, state) => const NavigationPlaceholderScreen(
        title: 'Recall',
        destination: CadenceNavDestination.recall,
      ),
    ),
    GoRoute(
      path: '/profile',
      name: AppRoutes.profile,
      builder: (context, state) => const NavigationPlaceholderScreen(
        title: 'Profile',
        destination: CadenceNavDestination.profile,
      ),
    ),
  ],
);
