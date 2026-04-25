import 'dart:io';

void createThemeFiles() {
  // app_colors.dart
  final colorsContent = '''
import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const primary = Color(0xFF4F46E5);    // Modern Indigo
  static const secondary = Color(0xFF06B6D4);  // Vibrant Cyan
  static const accent = Color(0xFFF43F5E);     // Rose Pink
  
  // Semantic Colors
  static const error = Color(0xFFEF4444);
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const info = Color(0xFF3B82F6);

  // Neutral Colors
  static const black = Color(0xFF0F172A);      // Slate 900
  static const white = Color(0xFFFFFFFF);
  static const grey = Color(0xFF64748B);       // Slate 500
  static const lightGrey = Color(0xFFF1F5F9);  // Slate 100
  
  // Background Colors
  static const backgroundLight = Color(0xFFF8FAFC);
  static const backgroundDark = Color(0xFF0F172A);
  
  // Surface Colors
  static const surfaceLight = Color(0xFFFFFFFF);
  static const surfaceDark = Color(0xFF1E293B);
  
  // Border Colors
  static const borderLight = Color(0x1A64748B); // Slate 500 with 10% alpha
  static const borderDark = Color(0x1AFFFFFF);  // White with 10% alpha

  // Gradients
  static const primaryGradient = [
    Color(0xFF4F46E5),
    Color(0xFF7C3AED),
  ];
  
  static const surfaceGradient = [
    Color(0xFF1E293B),
    Color(0xFF0F172A),
  ];
}
''';
  File('lib/core/theme/app_colors.dart').writeAsStringSync(colorsContent);

  // app_theme.dart
  final themeContent = '''
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surfaceLight,
        error: AppColors.error,
        onPrimary: AppColors.white,
        onSecondary: AppColors.white,
        onSurface: AppColors.black,
        onError: AppColors.white,
      ),
      textTheme: AppTypography.textTheme,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.black,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borderLight),
        ),
        color: AppColors.surfaceLight,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surfaceDark,
        error: AppColors.error,
        onPrimary: AppColors.white,
        onSecondary: AppColors.white,
        onSurface: AppColors.white,
        onError: AppColors.white,
      ),
      textTheme: AppTypography.textTheme,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.white,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borderDark),
        ),
        color: AppColors.surfaceDark,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
''';
  File('lib/core/theme/app_theme.dart').writeAsStringSync(themeContent);

  // app_typography.dart
  final typographyContent = '''
import 'package:flutter/material.dart';

class AppTypography {
  static TextTheme get textTheme {
    return const TextTheme(
      displayLarge: TextStyle(
        fontSize: 48,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.0,
      ),
      displayMedium: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
      ),
      displaySmall: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.bold,
      ),
      headlineLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.2,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      headlineSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        height: 1.5,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        height: 1.4,
      ),
    );
  }
}
''';
  File('lib/core/theme/app_typography.dart').writeAsStringSync(typographyContent);

  // extensions/app_spacing.dart
  final spacingContent = '''
import 'package:flutter/material.dart';

extension AppSpacing on BuildContext {
  double get space4 => 4.0;
  double get space8 => 8.0;
  double get space12 => 12.0;
  double get space16 => 16.0;
  double get space20 => 20.0;
  double get space24 => 24.0;
  double get space32 => 32.0;
  double get space40 => 40.0;
  double get space48 => 48.0;
  double get space64 => 64.0;
  
  // Screen relative spacing
  double get widthPct10 => MediaQuery.of(this).size.width * 0.1;
  double get widthPct20 => MediaQuery.of(this).size.width * 0.2;
}
''';
  File('lib/core/theme/extensions/app_spacing.dart').writeAsStringSync(spacingContent);

  print('✅ Created: Theme files (Zero Hardcoded Colors)');
}