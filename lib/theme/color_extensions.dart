import 'package:flutter/material.dart';
import 'app_colors.dart';

extension AppColorScheme on ColorScheme {
  // Medal colors
  Color get medalGold => AppColors.gold;
  Color get medalSilver => AppColors.silver;
  Color get medalBronze => AppColors.bronze;
  
  // Semantic colors
  Color get success => AppColors.success;
  Color get warning => AppColors.warning;
  Color get error => AppColors.error;
  Color get info => AppColors.info;
  
  // Statistics colors
  Color get statsBlue => AppColors.statsBlue;
  Color get statsGreen => AppColors.statsGreen;
  Color get statsOrange => AppColors.statsOrange;
  Color get statsPurple => AppColors.statsPurple;
  Color get statsTeal => AppColors.statsTeal;
  Color get statsRed => AppColors.statsRed;
  Color get statsAmber => AppColors.statsAmber;
}
