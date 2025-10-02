import 'package:flutter/material.dart';
import 'app_theme.dart';

class ThemeProvider extends ChangeNotifier {
  // Simplified to only support light mode
  bool get isDarkMode => false;
  
  // No-op methods for backward compatibility
  void toggleTheme() {
    // Do nothing - only light mode supported
  }
  
  void setTheme(bool isDark) {
    // Do nothing - only light mode supported
  }
  
  ThemeData get lightTheme => AppTheme.lightTheme;
  
  ThemeMode get themeMode => ThemeMode.light;
}
