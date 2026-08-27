import 'package:flutter/material.dart';

import 'app_router.dart';

class CadenceApp extends StatelessWidget {
  const CadenceApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Cadence',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      routerConfig: appRouter,
    );
  }
}
