import 'dart:io';

void createRouteFiles() {
  // app_router.dart
  final routerContent = '''
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'route_names.dart';
import '../features/home/ui/pages/home_page.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: RouteNames.home,
    routes: [
      GoRoute(
        path: RouteNames.home,
        name: RouteNames.home,
        builder: (context, state) => const HomePage(),
      ),
    ],

    // Error handling
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: \${state.uri}'),
      ),
    ),
  );
}
''';
  File('lib/routes/app_router.dart').writeAsStringSync(routerContent);

  // route_names.dart
  final namesContent = '''
class RouteNames {
  static const String home = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String settings = '/settings';
  static const String profile = '/profile';
  static const String profileEdit = 'edit'; // Relative path for nested routes
}
''';
  File('lib/routes/route_names.dart').writeAsStringSync(namesContent);

  print('✅ Created: Route files');
}