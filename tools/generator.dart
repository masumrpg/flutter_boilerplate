#!/usr/bin/env dart

import 'dart:io';

import 'parts/create_network_files.dart';
import 'parts/create_page.dart';
import 'parts/create_service.dart';
import 'parts/create_analysis_options_file.dart';
import 'parts/create_app_file.dart';
import 'parts/create_bloc.dart';
import 'parts/create_cubit.dart';
import 'parts/create_di_file.dart';
import 'parts/create_error_files.dart';
import 'parts/create_extension_files.dart';
import 'parts/create_feature.dart';
import 'parts/create_main_file.dart';
import 'parts/create_pubspec_file.dart';
import 'parts/create_route_files.dart';
import 'parts/create_shared_files.dart';
import 'parts/create_shared_widget.dart';
import 'parts/create_theme_files.dart';
import 'parts/create_utils_files.dart';

void main(List<String> arguments) {
  print('🚀 Flutter BLoC Scaffold Generator');
  print('=' * 50);

  // Default to inject if no arguments provided
  if (arguments.isEmpty) {
    print('💉 No command specified, running inject...');
    print('');
    injectIntoExisting();
    return;
  }

  final command = arguments[0];

  switch (command) {
    case 'init':
      print('⚠️  Warning: "init" is deprecated. Use "inject" instead.');
      print('   Running inject...');
      print('');
      injectIntoExisting();
      break;
    case 'inject':
      injectIntoExisting();
      break;
    case 'feature':
      if (arguments.length < 2) {
        print('❌ Error: Feature name required');
        print('Usage: dart generator.dart feature <feature_name>');
        exit(1);
      }
      createFeature(arguments[1]);
      break;
    case 'cubit':
      if (arguments.length < 3) {
        print('❌ Error: Feature and cubit name required');
        print('Usage: dart generator.dart cubit <feature_name> <cubit_name>');
        exit(1);
      }
      createCubit(arguments[1], arguments[2]);
      break;
    case 'bloc':
      if (arguments.length < 3) {
        print('❌ Error: Feature and bloc name required');
        print('Usage: dart generator.dart bloc <feature_name> <bloc_name>');
        exit(1);
      }
      createBloc(arguments[1], arguments[2]);
      break;
    case 'widget':
      if (arguments.length < 2) {
        print('❌ Error: Widget name required');
        print('Usage: dart generator.dart widget <widget_name>');
        exit(1);
      }
      createSharedWidget(arguments[1]);
      break;
    case 'page':
      if (arguments.length < 3) {
        print('❌ Error: Feature and page name required');
        print('Usage: dart generator.dart page <feature_name> <page_name>');
        exit(1);
      }
      createPage(arguments[1], arguments[2]);
      break;
    case 'service':
      if (arguments.length < 3) {
        print('❌ Error: Feature and service name required');
        print('Usage: dart generator.dart service <feature_name> <service_name>');
        exit(1);
      }
      createService(arguments[1], arguments[2]);
      break;
    default:
      print('❌ Unknown command: $command');
      printUsage();
      exit(1);
  }
}

void printUsage() {
  print('''
Commands:
  inject                           Inject structure into current project (DEFAULT)
  feature <feature_name>           Create new feature module with samples
  cubit <feature> <cubit_name>     Create cubit in feature
  bloc <feature> <bloc_name>       Create bloc in feature
  widget <widget_name>             Create shared widget
  page <feature> <page_name>       Create page in feature
  service <feature> <service_name> Create service in feature

Examples:
  # Inject structure (default command)
  dart tools/generator.dart inject
  # or simply
  dart tools/generator.dart

  # Create features with boilerplate samples
  dart tools/generator.dart feature products
  dart tools/generator.dart cubit home counter
  dart tools/generator.dart bloc auth login
  dart tools/generator.dart widget custom_button
  dart tools/generator.dart page products detail
  dart tools/generator.dart service products analytics
''');
}

void initProject(String projectName) {
  print('📦 Creating project: $projectName');

  // Create project directory first
  if (Directory(projectName).existsSync()) {
    print('❌ Error: Directory "$projectName" already exists!');
    exit(1);
  }

  Directory(projectName).createSync();

  // Change to project directory
  Directory.current = projectName;

  _generateStructure(projectName);

  print('');
  print('✨ Project scaffold created successfully!');
  print('');
  print('📝 Next steps:');
  print('1. cd $projectName');
  print('2. flutter pub get');
  print('3. dart generator.dart feature auth');
  print('4. flutter run');
}

void injectIntoExisting() {
  // Check if we're in a Flutter project
  if (!File('pubspec.yaml').existsSync()) {
    print('❌ Error: Not in a Flutter project directory!');
    print('   Run this command inside your Flutter project folder.');
    print('   Make sure pubspec.yaml exists in the current directory.');
    exit(1);
  }

  print('📁 Current directory: ${Directory.current.path}');
  print('⚠️  This will create folders and files in lib/');
  print('');

  // Read project name from pubspec.yaml
  final pubspec = File('pubspec.yaml').readAsStringSync();
  final nameMatch = RegExp(r'name:\s*(\w+)').firstMatch(pubspec);
  final projectName = nameMatch?.group(1) ?? 'app';

  print('📦 Project name: your_project_name');
  print('');

  _generateStructure(projectName);

  print('');
  print('✨ Structure injected successfully!');
  print('');
  print('📝 Next steps:');
  print('1. Add dependencies to pubspec.yaml (see above)');
  print('2. flutter pub get');
  print('3. dart tools/generator.dart feature <your_feature>');
  print('4. Check lib/features/home/ for sample code!');
  print('5. flutter run');
}

void _generateStructure(String projectName) {
  final dirs = [
    'lib/core/theme',
    'lib/core/theme/extensions',
    'lib/core/di',
    'lib/core/network',
    'lib/core/error',
    'lib/core/utils',
    'lib/core/extensions',
    'lib/features',
    'lib/shared/widgets',
    'lib/shared/blocs',
    'lib/routes',
  ];

  for (final dir in dirs) {
    Directory(dir).createSync(recursive: true);
    print('✅ Created: $dir');
  }

  // Create core files
  createMainFile();
  createAppFile();
  createThemeFiles();
  createDIFile();
  createNetworkFiles();
  createErrorFiles();
  createUtilsFiles();
  createExtensionFiles();
  createRouteFiles();
  createSharedFiles();

  // Check if pubspec.yaml exists before creating
  if (!File('pubspec.yaml').existsSync()) {
    createPubspecFile(projectName);
  } else {
    print('ℹ️  Skipped: pubspec.yaml (already exists)');
    print('   Add these dependencies manually:');
    print('   - flutter_bloc: ^9.1.1');
    print('   - equatable: ^2.0.7');
    print('   - go_router: ^17.0.1');
    print('   - dio: ^5.9.0');
    print('   - get_it: ^9.2.0');
    print('   - fpdart: ^1.2.0');
  }

  if (!File('analysis_options.yaml').existsSync()) {
    createAnalysisOptionsFile();
  } else {
    print('ℹ️  Skipped: analysis_options.yaml (already exists)');
  }

  // Remove default widget test as it doesn't match the new structure
  if (File('test/widget_test.dart').existsSync()) {
    File('test/widget_test.dart').deleteSync();
    print(
      '🗑️  Removed: test/widget_test.dart (incompatible with new structure)',
    );
  }

  // Create sample feature as example
  print('');
  print('📚 Creating sample feature: "home"...');
  createFeature('home', withSample: true);
}

































