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
  flutter_bloc: ^8.1.6
  equatable: ^2.0.5

  # Navigation
  go_router: ^14.6.2

  # Network
  dio: ^5.7.0

  # Dependency Injection
  get_it: ^8.0.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  very_good_analysis: ^6.0.0
  flutter_lints: ^5.0.0

flutter:
  uses-material-design: true
''';
  File('pubspec.yaml').writeAsStringSync(content);
  print('✅ Created: pubspec.yaml');
}