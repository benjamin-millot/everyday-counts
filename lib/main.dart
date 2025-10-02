import 'package:flutter/material.dart';
import 'screens/main_navigation_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Everday Counts',
      theme: AppTheme.lightTheme,
      home: const MainNavigationScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
