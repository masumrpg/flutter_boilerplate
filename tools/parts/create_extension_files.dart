import 'dart:io';

void createExtensionFiles() {
  final content = '''
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Extension methods for [BuildContext] to simplify access to common theme,
/// navigation, and UI utilities. 
/// 
/// Note: We wrap GoRouter methods to avoid ambiguous member conflicts 
/// and to provide a unified navigation API.
extension ContextExtension on BuildContext {
  // ─── Navigation (GoRouter Wrappers) ────────────────────────────────────────
  
  void push(String location, {Object? extra}) => GoRouter.of(this).push(location, extra: extra);
  void pushNamed(String name, {Map<String, String> pathParameters = const <String, String>{}, Map<String, dynamic> queryParameters = const <String, dynamic>{}, Object? extra}) => 
      GoRouter.of(this).pushNamed(name, pathParameters: pathParameters, queryParameters: queryParameters, extra: extra);
  
  void go(String location, {Object? extra}) => GoRouter.of(this).go(location, extra: extra);
  void goNamed(String name, {Map<String, String> pathParameters = const <String, String>{}, Map<String, dynamic> queryParameters = const <String, dynamic>{}, Object? extra}) => 
      GoRouter.of(this).goNamed(name, pathParameters: pathParameters, queryParameters: queryParameters, extra: extra);
  
  void replace(String location, {Object? extra}) => GoRouter.of(this).replace(location, extra: extra);
  void replaceNamed(String name, {Map<String, String> pathParameters = const <String, String>{}, Map<String, dynamic> queryParameters = const <String, dynamic>{}, Object? extra}) => 
      GoRouter.of(this).replaceNamed(name, pathParameters: pathParameters, queryParameters: queryParameters, extra: extra);
  
  void pop<T extends Object?>([T? result]) => GoRouter.of(this).pop(result);

  // ─── Theme ────────────────────────────────────────────────────────────────
  
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  // ─── MediaQuery ──────────────────────────────────────────────────────────
  
  Size get screenSize => MediaQuery.of(this).size;
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  EdgeInsets get padding => MediaQuery.of(this).padding;
  EdgeInsets get viewInsets => MediaQuery.of(this).viewInsets;

  // ─── Responsive ──────────────────────────────────────────────────────────
  
  bool get isMobile => screenWidth < 600;
  bool get isTablet => screenWidth >= 600 && screenWidth < 1024;
  bool get isDesktop => screenWidth >= 1024;

  // ─── Snackbar ────────────────────────────────────────────────────────────
  
  void showSnackBar(String message, {Duration? duration}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration ?? const Duration(seconds: 3),
      ),
    );
  }

  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ─── Dialog ──────────────────────────────────────────────────────────────
  
  Future<T?> showCustomDialog<T>(Widget dialog) {
    return showDialog<T>(
      context: this,
      builder: (context) => dialog,
    );
  }
}
''';
  File('lib/core/extensions/context_extension.dart').writeAsStringSync(content);
  print('✅ Created: lib/core/extensions/context_extension.dart (Hardened)');
}