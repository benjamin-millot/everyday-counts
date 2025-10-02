import 'package:flutter/material.dart';
import 'screens/app_navigation_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const HabitTrackerApp());
}

class HabitTrackerApp extends StatelessWidget {
  const HabitTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Everday Counts',
      theme: AppTheme.lightTheme,
      home: const AppNavigationScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
