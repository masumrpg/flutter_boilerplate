import 'dart:io';

void createPubspecFile(String projectName) {
  final content = '''
name: $projectName
description: A Flutter BLoC project with best practices
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_bloc: ^9.1.1
  equatable: ^2.0.7
  fpdart: ^1.2.0

  # Navigation
  go_router: ^17.0.1

  # Network
  dio: ^5.9.0

  # Dependency Injection
  get_it: ^9.2.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  very_good_analysis: ^10.0.0
  flutter_lints: ^6.0.0

flutter:
  uses-material-design: true
''';
  File('pubspec.yaml').writeAsStringSync(content);
  print('✅ Created: pubspec.yaml');
}