import 'dart:io';

void createThemeFiles() {
  // app_theme.dart
  final themeContent = '''
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ),
      textTheme: AppTypography.textTheme,
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
      ),
      textTheme: AppTypography.textTheme,
    );
  }
}
''';
  File('lib/core/theme/app_theme.dart').writeAsStringSync(themeContent);

  // app_colors.dart
  final colorsContent = '''
import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF6200EE);
  static const secondary = Color(0xFF03DAC6);
  static const background = Color(0xFFF5F5F5);
  static const error = Color(0xFFB00020);
  static const success = Color(0xFF4CAF50);
  static const warning = Color(0xFFFF9800);

  // Grayscale
  static const black = Color(0xFF000000);
  static const white = Color(0xFFFFFFFF);
  static const grey = Color(0xFF9E9E9E);
  static const lightGrey = Color(0xFFE0E0E0);
}
''';
  File('lib/core/theme/app_colors.dart').writeAsStringSync(colorsContent);

  // app_typography.dart
  final typographyContent = '''
import 'package:flutter/material.dart';

class AppTypography {
  static TextTheme get textTheme {
    return const TextTheme(
      displayLarge: TextStyle(
        fontSize: 57,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: TextStyle(
        fontSize: 45,
        fontWeight: FontWeight.bold,
      ),
      displaySmall: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.bold,
      ),
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w500,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
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
  double get spacing4 => 4.0;
  double get spacing8 => 8.0;
  double get spacing12 => 12.0;
  double get spacing16 => 16.0;
  double get spacing20 => 20.0;
  double get spacing24 => 24.0;
  double get spacing32 => 32.0;
  double get spacing48 => 48.0;
  double get spacing64 => 64.0;
}
''';
  File('lib/core/theme/extensions/app_spacing.dart').writeAsStringSync(spacingContent);

  print('✅ Created: Theme files');
}