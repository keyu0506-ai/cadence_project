import 'package:go_router/go_router.dart';

import '../screens/home/home_screen.dart';
import '../screens/sign_in/sign_in_screen.dart';
import '../screens/sign_up/sign_up_screen.dart';
import '../screens/welcome/welcome_screen.dart';

class AppRoutes {
  static const welcome = 'welcome';
  static const signUp = 'signUp';
  static const signIn = 'signIn';
  static const home = 'home';
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
  ],
);
