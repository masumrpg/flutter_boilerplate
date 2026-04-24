import 'dart:io';

void createMainFile(String projectName) {
  final content = '''
import 'package:flutter/material.dart';
import 'package:$projectName/app.dart';
import 'package:$projectName/core/di/service_locator.dart';
import 'package:$projectName/shared/blocs/app_bloc_observer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Service Locator
  await setupServiceLocator();
  
  // Set BLoC observer
  Bloc.observer = AppBlocObserver();
  
  runApp(const App());
}
''';
  File('lib/main.dart').writeAsStringSync(content);
  print('✅ Created: lib/main.dart');
}