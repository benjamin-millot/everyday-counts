import 'package:flutter/material.dart';
import 'habits_screen.dart';
import 'calendar_screen.dart';
import 'statistics_screen.dart';
import 'settings_screen.dart';

class AppNavigationScreen extends StatefulWidget {
  const AppNavigationScreen({super.key});

  @override
  State<AppNavigationScreen> createState() => _AppNavigationScreenState();
}

class _AppNavigationScreenState extends State<AppNavigationScreen> {
  int _currentIndex = 0;
  late PageController _pageController;
  final GlobalKey<CalendarScreenState> _calendarKey = GlobalKey<CalendarScreenState>();
  final GlobalKey<StatisticsScreenState> _statisticsKey = GlobalKey<StatisticsScreenState>();

  final List<Widget> _screens = [
    const HabitsScreen(),
    CalendarScreen(key: null), // Will be updated in initState
    StatisticsScreen(key: null), // Will be updated in initState
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    // Update the screens with their keys
    _screens[1] = CalendarScreen(key: _calendarKey);
    _screens[2] = StatisticsScreen(key: _statisticsKey);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
          
          // Refresh data when switching to calendar or statistics tab
          if (index == 1) {
            Future.delayed(const Duration(milliseconds: 350), () {
              _calendarKey.currentState?.refreshCalendarData();
            });
          } else if (index == 2) {
            Future.delayed(const Duration(milliseconds: 350), () {
              _statisticsKey.currentState?.refreshStatisticsData();
            });
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Habits',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Calendar',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics),
            label: 'Statistics',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
