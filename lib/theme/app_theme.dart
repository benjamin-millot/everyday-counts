import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // Use the theme seed for dynamic color generation
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.themeSeed,
        brightness: Brightness.light,
      ).copyWith(
        // Override specific colors for our modern look
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.onSurface,
        onError: Colors.white,
      ),
      
      // AppBar Theme - Modern and sharp
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTypography.headline3.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        surfaceTintColor: Colors.transparent,
        shadowColor: AppColors.primary.withValues(alpha: 0.1),
      ),
      
      // Card Theme - Sharp corners, subtle shadows
      cardTheme: CardThemeData(
        elevation: 1,
        shadowColor: AppColors.outline.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
      ),
      
      // Elevated Button Theme - Modern, sharp
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: AppColors.primary.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          textStyle: AppTypography.button.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      // Input Decoration Theme - Sharp, modern
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        filled: true,
        fillColor: AppColors.surfaceVariant,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        labelStyle: TextStyle(
          color: AppColors.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: TextStyle(
          color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
        ),
      ),
      
      // Text Theme - Modern typography
      textTheme: TextTheme(
        headlineLarge: AppTypography.headline1.copyWith(
          color: AppColors.onSurface,
          fontWeight: FontWeight.w700,
        ),
        headlineMedium: AppTypography.headline2.copyWith(
          color: AppColors.onSurface,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: AppTypography.headline3.copyWith(
          color: AppColors.onSurface,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: AppTypography.body1.copyWith(
          color: AppColors.onSurface,
        ),
        bodyMedium: AppTypography.body2.copyWith(
          color: AppColors.onSurface,
        ),
        labelLarge: AppTypography.label1.copyWith(
          color: AppColors.onSurface,
          fontWeight: FontWeight.w600,
        ),
        labelMedium: AppTypography.label2.copyWith(
          color: AppColors.onSurfaceVariant,
        ),
        bodySmall: AppTypography.caption.copyWith(
          color: AppColors.onSurfaceVariant,
        ),
      ),
      
      // Navigation Bar Theme - Modern, sharp
      navigationBarTheme: NavigationBarThemeData(
        elevation: 2,
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primary.withValues(alpha: 0.1),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTypography.label2.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            );
          }
          return AppTypography.label2.copyWith(
            color: AppColors.onSurfaceVariant,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primary);
          }
          return IconThemeData(color: AppColors.onSurfaceVariant);
        }),
      ),
      
      // Switch Theme - Modern
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.onSurfaceVariant;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary.withValues(alpha: 0.3);
          }
          return AppColors.outline;
        }),
      ),
      
      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      
      // List Tile Theme
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        titleTextStyle: AppTypography.body1.copyWith(
          color: AppColors.onSurface,
          fontWeight: FontWeight.w500,
        ),
        subtitleTextStyle: AppTypography.body2.copyWith(
          color: AppColors.onSurfaceVariant,
        ),
      ),
    );
  }
}