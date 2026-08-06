import 'package:flutter/material.dart';
import '../screens/welcome/welcome_screen.dart';

class CadenceApp extends StatelessWidget {
  const CadenceApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cadence',
      theme: ThemeData(),
      home: WelcomeScreen(),
    );
  }
}
