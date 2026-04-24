import 'dart:io';
import '../utils/utils.dart';

void setupProduction({String feature = 'all'}) {
  if (feature == 'all') {
    print('📦 Setting up all production-ready features...');
    print('');
    setupEnv();
    print('');
    setupL10n();
    print('');
    setupStorage();
    print('');
    setupLogger();
    print('');
    setupNative();
    print('');
    setupResponsive();
    print('');
    _printDependencySummary();
    print('\n✨ All production-ready features setup successfully!');
    print('📝 Next: Run the commands above to install dependencies.');
  } else {
    switch (feature) {
      case 'env':
        setupEnv();
        break;
      case 'l10n':
        setupL10n();
        break;
      case 'storage':
        setupStorage();
        break;
      case 'logger':
        setupLogger();
        break;
      case 'native':
        setupNative();
        break;
      case 'responsive':
        setupResponsive();
        break;
      default:
        print('❌ Unknown setup feature: $feature');
        print('Available: env, l10n, storage, logger, native, responsive, all');
    }
  }
}

// ─── 1. Environment Configuration ────────────────────────────────────────────

void setupEnv() {
  print('🌐 Setting up Environment (Envied)...');

  Directory('env').createSync();

  File('env/.env.development').writeAsStringSync('''
API_BASE_URL=https://api-dev.example.com
API_KEY=dev_key_123
''');

  File('env/.env.production').writeAsStringSync('''
API_BASE_URL=https://api.example.com
API_KEY=prod_key_789
''');

  // .gitignore for env files
  final gitignore = File('.gitignore');
  if (gitignore.existsSync()) {
    final content = gitignore.readAsStringSync();
    if (!content.contains('env/.env')) {
      gitignore.writeAsStringSync(
        '\n# Environment files\nenv/.env.*\n!env/.env.example\n',
        mode: FileMode.append,
      );
    }
  }

  File('env/.env.example').writeAsStringSync('''
API_BASE_URL=https://api.example.com
API_KEY=your_api_key_here
''');

  Directory('lib/core/config').createSync(recursive: true);
  File('lib/core/config/env.dart').writeAsStringSync('''
import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: 'env/.env.development')
abstract class Env {
  @EnviedField(varName: 'API_BASE_URL')
  static const String apiBaseUrl = _Env.apiBaseUrl;

  @EnviedField(varName: 'API_KEY', obfuscate: true)
  static final String apiKey = _Env.apiKey;
}
''');

  print('  ✅ Created: env/.env.development');
  print('  ✅ Created: env/.env.production');
  print('  ✅ Created: env/.env.example');
  print('  ✅ Created: lib/core/config/env.dart');
  print('  ℹ️  Run: flutter pub add envied dev:envied_generator dev:build_runner');
  print('  ℹ️  Then: dart run build_runner build --delete-conflicting-outputs');
}

// ─── 2. Localization ─────────────────────────────────────────────────────────

void setupL10n() {
  print('🌍 Setting up Localization (l10n)...');

  File('l10n.yaml').writeAsStringSync('''arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
''');

  Directory('lib/l10n').createSync(recursive: true);

  File('lib/l10n/app_en.arb').writeAsStringSync('''{
  "@@locale": "en",
  "appName": "Flutter BLoC App",
  "@appName": {
    "description": "The title of the application"
  },
  "helloWorld": "Hello World!",
  "@helloWorld": {
    "description": "A hello world message"
  }
}
''');

  File('lib/l10n/app_id.arb').writeAsStringSync('''{
  "@@locale": "id",
  "appName": "Aplikasi Flutter BLoC",
  "helloWorld": "Halo Dunia!"
}
''');

  // Patch app.dart if it exists
  _patchAppForL10n();

  // Patch pubspec.yaml to add generate: true
  _patchPubspecForL10n();

  print('  ✅ Created: l10n.yaml');
  print('  ✅ Created: lib/l10n/app_en.arb');
  print('  ✅ Created: lib/l10n/app_id.arb');
  print('  ℹ️  Run: flutter pub add flutter_localizations --sdk=flutter && flutter pub add intl');
}

// ─── 3. Local Storage ────────────────────────────────────────────────────────

void setupStorage() {
  print('💾 Setting up Local Storage (SharedPreferences)...');

  Directory('lib/core/services').createSync(recursive: true);
  File('lib/core/services/storage_service.dart').writeAsStringSync('''
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  // String
  Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  String? getString(String key) => _prefs.getString(key);

  // Bool
  Future<void> setBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  bool? getBool(String key) => _prefs.getBool(key);

  // Int
  Future<void> setInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }

  int? getInt(String key) => _prefs.getInt(key);

  // Remove & Clear
  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  Future<void> clear() async {
    await _prefs.clear();
  }

  bool containsKey(String key) => _prefs.containsKey(key);
}
''');

  // Patch service_locator.dart if it exists
  _patchDIForStorage(getProjectName());

  print('  ✅ Created: lib/core/services/storage_service.dart');
  print('  ℹ️  Run: flutter pub add shared_preferences');
}

// ─── 4. Logger ───────────────────────────────────────────────────────────────

void setupLogger() {
  print('📝 Setting up Logging (Logger)...');

  Directory('lib/core/utils').createSync(recursive: true);
  File('lib/core/utils/logger_utils.dart').writeAsStringSync('''
import 'package:logger/logger.dart';

class Log {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
    ),
  );

  /// Verbose log
  static void t(String message) => _logger.t(message);

  /// Debug log
  static void d(String message) => _logger.d(message);

  /// Info log
  static void i(String message) => _logger.i(message);

  /// Warning log
  static void w(String message) => _logger.w(message);

  /// Error log
  static void e(String message, [dynamic error, StackTrace? stackTrace]) =>
      _logger.e(message, error: error, stackTrace: stackTrace);

  /// What a terrible failure log
  static void f(String message) => _logger.f(message);
}
''');

  // Patch interceptors.dart if it exists
  _patchInterceptorsForLogger();

  print('  ✅ Created: lib/core/utils/logger_utils.dart');
  print('  ℹ️  Run: flutter pub add logger');
}

// ─── 5. Native Scaffolding ───────────────────────────────────────────────────

void setupNative() {
  print('📱 Setting up Native Scaffolding (Launcher Icons)...');

  Directory('assets/images').createSync(recursive: true);

  File('flutter_launcher_icons.yaml').writeAsStringSync('''flutter_launcher_icons:
  android: "launcher_icon"
  ios: true
  image_path: "assets/images/app_icon.png"
  min_sdk_android: 21
  # web:
  #   generate: true
  #   image_path: "assets/images/app_icon.png"
  #   background_color: "#ffffff"
  #   theme_color: "#ffffff"
''');

  print('  ✅ Created: flutter_launcher_icons.yaml');
  print('  ✅ Created: assets/images/ (place app_icon.png here)');
  print('  ℹ️  Splash screen is handled by SplashPage widget (cross-platform)');

  // Patch pubspec.yaml to add assets
  _patchPubspecForAssets();

  print('  ℹ️  Run: flutter pub add --dev flutter_launcher_icons');
  print('  ℹ️  Then: dart run flutter_launcher_icons');
}

// ─── 6. Responsive Utility ──────────────────────────────────────────────────

void setupResponsive() {
  print('📐 Setting up Responsive Utility (Sizer)...');

  // Patch app.dart if it exists
  _patchAppForSizer();

  print('  ✅ Responsive setup configured');
  print('  ℹ️  Run: flutter pub add sizer');
}

// ─── Patch Helpers ───────────────────────────────────────────────────────────

void _patchAppForL10n() {
  final appFile = File('lib/app.dart');
  if (!appFile.existsSync()) return;

  var content = appFile.readAsStringSync();
  if (content.contains('localizationsDelegates')) return;

  // Add import
  if (!content.contains('flutter_localizations')) {
    content = "import 'package:flutter_localizations/flutter_localizations.dart';\nimport 'l10n/app_localizations.dart';\n$content";
  }

  // Add localization delegates
  content = content.replaceFirst(
    'debugShowCheckedModeBanner: false,',
    '''debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('id'),
      ],''',
  );

  appFile.writeAsStringSync(content);
  print('  ✅ Patched: lib/app.dart (localization delegates added)');
}

void _patchAppForSizer() {
  final appFile = File('lib/app.dart');
  if (!appFile.existsSync()) return;

  var content = appFile.readAsStringSync();
  if (content.contains('Sizer')) return;

  // Add import
  if (!content.contains('package:sizer/sizer.dart')) {
    content = "import 'package:sizer/sizer.dart';\n$content";
  }

  // Wrap MaterialApp.router with Sizer
  content = content.replaceFirst(
    RegExp(r'return\s+MaterialApp\.router\s*\('),
    'return Sizer(\n      builder: (context, orientation, deviceType) {\n        return MaterialApp.router(',
  );

  // Close Sizer builder — replace the widget closing
  content = content.replaceFirst(
    RegExp(r'\s*\);\s*}\s*}\s*$'),
    '\n        );\n      },\n    );\n  }\n}',
  );

  appFile.writeAsStringSync(content);
  print('  ✅ Patched: lib/app.dart (Sizer wrapper added)');
}

void _patchDIForStorage(String projectName) {
  final diFile = File('lib/core/di/service_locator.dart');
  if (!diFile.existsSync()) return;

  var content = diFile.readAsStringSync();
  if (content.contains('StorageService')) return;

  // Add imports
  content = content.replaceFirst(
    RegExp(r"import\s+'package:get_it/get_it\.dart';"),
    "import 'package:get_it/get_it.dart';\nimport 'package:shared_preferences/shared_preferences.dart';\nimport 'package:$projectName/core/services/storage_service.dart';",
  );

  // Add registration
  content = content.replaceFirst(
    RegExp(r'//\s*Network'),
    '// Storage\n  final prefs = await SharedPreferences.getInstance();\n  sl.registerLazySingleton(() => StorageService(prefs));\n\n  // Network',
  );

  diFile.writeAsStringSync(content);
  print('  ✅ Patched: lib/core/di/service_locator.dart (StorageService registered)');
}

void _patchInterceptorsForLogger() {
  final interceptorsFile = File('lib/core/network/interceptors.dart');
  if (!interceptorsFile.existsSync()) return;

  var content = interceptorsFile.readAsStringSync();
  if (content.contains('logger_utils.dart')) return;

  // Add import
  content = content.replaceFirst(
    RegExp(r"import\s+'package:dio/dio\.dart';"),
    "import 'package:dio/dio.dart';\nimport '../utils/logger_utils.dart';",
  );

  // Replace print statements with Log calls
  content = content.replaceAll(
    RegExp(r"print\('REQUEST\["),
    "Log.i('REQUEST[",
  );
  content = content.replaceAll(
    RegExp(r"print\('RESPONSE\["),
    "Log.i('RESPONSE[",
  );
  content = content.replaceAll(
    RegExp(r"print\('ERROR\["),
    "Log.e('ERROR[",
  );
  content = content.replaceAll(
    RegExp(r"print\('Headers:"),
    "Log.d('Headers:",
  );
  content = content.replaceAll(
    RegExp(r"print\('Data:"),
    "Log.d('Data:",
  );
  content = content.replaceAll(
    RegExp(r"print\('Message:"),
    "Log.d('Message:",
  );

  interceptorsFile.writeAsStringSync(content);
  print('  ✅ Patched: lib/core/network/interceptors.dart (Logger replaces print)');
}

void _patchPubspecForL10n() {
  final pubspecFile = File('pubspec.yaml');
  if (!pubspecFile.existsSync()) return;

  var content = pubspecFile.readAsStringSync();
  if (content.contains('generate: true')) return;

  // Add generate: true under top-level flutter: section (not dependencies.flutter:)
  content = content.replaceFirst(
    RegExp(r'^flutter:\s*$', multiLine: true),
    'flutter:\n  generate: true',
  );

  pubspecFile.writeAsStringSync(content);
  print('  ✅ Patched: pubspec.yaml (generate: true added)');
}

void _patchPubspecForAssets() {
  final pubspecFile = File('pubspec.yaml');
  if (!pubspecFile.existsSync()) return;

  var content = pubspecFile.readAsStringSync();
  if (content.contains('assets/images/')) return;

  // Replace commented assets section or add assets after uses-material-design
  if (content.contains('# assets:')) {
    content = content.replaceFirst(
      RegExp(r'#\s*To add assets.*?\n\s*#\s*assets:\n\s*#.*?\n\s*#.*?\n'),
      '  assets:\n    - assets/images/\n',
    );
  } else {
    content = content.replaceFirst(
      'uses-material-design: true',
      'uses-material-design: true\n\n  assets:\n    - assets/images/',
    );
  }

  pubspecFile.writeAsStringSync(content);
  print('  ✅ Patched: pubspec.yaml (assets/images/ registered)');
}

// ─── Dependency Summary ──────────────────────────────────────────────────────

void _printDependencySummary() {
  print('📋 Dependency Summary:');
  print('─' * 50);
  print('Run the following commands to install all dependencies:');
  print('');
  print('  # Dependencies');
  print('  flutter pub add envied shared_preferences logger sizer');
  print('  flutter pub add flutter_localizations --sdk=flutter');
  print('  flutter pub add intl');
  print('');
  print('  # Dev Dependencies');
  print('  flutter pub add --dev envied_generator build_runner');
  print('  flutter pub add --dev flutter_launcher_icons');
  print('');
  print('  # Generate env code');
  print('  dart run build_runner build --delete-conflicting-outputs');
  print('');
  print(
    '  # Generate launcher icons (after placing app_icon.png in assets/images/)',
  );
  print('  dart run flutter_launcher_icons');
}
