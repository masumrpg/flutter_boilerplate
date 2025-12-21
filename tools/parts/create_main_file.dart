import 'dart:io';

void createMainFile() {
  final content = '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app.dart';
import 'core/di/service_locator.dart';
import 'shared/blocs/app_bloc_observer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Setup dependency injection
  await setupServiceLocator();

  // Setup BLoC observer
  Bloc.observer = AppBlocObserver();

  runApp(const App());
}
''';
  File('lib/main.dart').writeAsStringSync(content);
  print('✅ Created: lib/main.dart');
}