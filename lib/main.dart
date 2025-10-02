import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/app_navigation_screen.dart';
import 'theme/app_theme.dart';
import 'providers/habit_data_provider.dart';

void main() {
  runApp(const HabitTrackerApp());
}

class HabitTrackerApp extends StatelessWidget {
  const HabitTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => HabitDataProvider()..initialize(),
      child: MaterialApp(
        title: 'Everday Counts',
        theme: AppTheme.lightTheme,
        home: const AppNavigationScreen(),
      ),
    );
  }
}
