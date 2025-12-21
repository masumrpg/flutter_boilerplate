import 'dart:io';

void createAppFile() {
  final content = '''
import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_router.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter BLoC App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}
''';
  File('lib/app.dart').writeAsStringSync(content);
  print('✅ Created: lib/app.dart');
}