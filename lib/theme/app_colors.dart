import 'package:flutter/material.dart';
import 'theme_config.dart';

class AppColors {
  static const Color themeSeed = ThemeConfig.themeSeed; // Get theme from config, avoid changing it here
  
  // Primary Colors (derived from seed)
  static const Color primary = themeSeed;
  static const Color primaryLight = Color(0xFF34495E);
  static const Color primaryDark = Color(0xFF1A252F);
  
  // Secondary Colors (complementary)
  static const Color secondary = Color(0xFF7F8C8D);
  static const Color secondaryLight = Color(0xFF95A5A6);
  static const Color secondaryDark = Color(0xFF5D6D7E);

  // Semantic Colors (dimmer, modern)
  static const Color success = Color(0xFF27AE60);
  static const Color warning = Color(0xFFE67E22);
  static const Color error = Color(0xFFE74C3C);
  static const Color info = Color(0xFF3498DB);

  // Neutral Colors (modern grays)
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F3F4);
  static const Color onSurface = Color(0xFF2C3E50);
  static const Color onSurfaceVariant = Color(0xFF5F6368);

  // Border and Divider Colors
  static const Color outline = Color(0xFFE0E0E0);
  static const Color outlineVariant = Color(0xFFF0F0F0);

  // Medal Colors (refined)
  static const Color gold = Color(0xFFB8860B);
  static const Color silver = Color(0xFF8E8E93);
  static const Color bronze = Color(0xFFCD7F32);

  // Statistics Colors (modern palette)
  static const Color statsBlue = Color(0xFF3498DB);
  static const Color statsGreen = Color(0xFF27AE60);
  static const Color statsOrange = Color(0xFFE67E22);
  static const Color statsPurple = Color(0xFF9B59B6);
  static const Color statsTeal = Color(0xFF1ABC9C);
  static const Color statsRed = Color(0xFFE74C3C);
  static const Color statsAmber = Color(0xFFF39C12);
}