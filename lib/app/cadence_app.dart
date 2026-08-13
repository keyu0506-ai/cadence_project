import 'package:flutter/material.dart';
import '../screens/welcome/welcome_screen.dart';
import '../screens/sign_up/sign_up_screen.dart';
import '../screens/sign_in/sign_in_screen.dart';

class CadenceApp extends StatelessWidget {
  const CadenceApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cadence',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: const SignInScreen(),
    );
  }
}
