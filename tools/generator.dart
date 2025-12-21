#!/usr/bin/env dart

import 'dart:io';

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

  print('📦 Project name: $projectName');
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
    print('   - flutter_bloc: ^8.1.6');
    print('   - go_router: ^14.6.2');
    print('   - dio: ^5.7.0');
    print('   - get_it: ^8.0.2');
  }

  if (!File('analysis_options.yaml').existsSync()) {
    createAnalysisOptionsFile();
  } else {
    print('ℹ️  Skipped: analysis_options.yaml (already exists)');
  }

  // Create sample feature as example
  print('');
  print('📚 Creating sample feature: "home"...');
  createFeature('home', withSample: true);
}

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

void createDIFile() {
  final content = '''
import 'package:get_it/get_it.dart';
import '../network/api_client.dart';

final sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Network
  sl.registerLazySingleton(() => ApiClient());

  // Repositories
  // Example: sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));

  // Data sources
  // Example: sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(sl()));

  // BLoCs (if needed globally)
  // Example: sl.registerFactory(() => AuthBloc(sl()));
}
''';
  File('lib/core/di/service_locator.dart').writeAsStringSync(content);
  print('✅ Created: lib/core/di/service_locator.dart');
}

void createNetworkFiles() {
  // api_client.dart
  final clientContent = '''
import 'package:dio/dio.dart';
import 'interceptors.dart';

class ApiClient {
  late final Dio _dio;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://api.example.com',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.addAll([
      LoggingInterceptor(),
      AuthInterceptor(),
    ]);
  }

  Dio get dio => _dio;

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) {
    return _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data}) {
    return _dio.post(path, data: data);
  }

  Future<Response> put(String path, {dynamic data}) {
    return _dio.put(path, data: data);
  }

  Future<Response> delete(String path) {
    return _dio.delete(path);
  }

  Future<Response> patch(String path, {dynamic data}) {
    return _dio.patch(path, data: data);
  }
}
''';
  File('lib/core/network/api_client.dart').writeAsStringSync(clientContent);

  // interceptors.dart
  final interceptorsContent = '''
import 'package:dio/dio.dart';

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('REQUEST[\${options.method}] => PATH: \${options.path}');
    print('Headers: \${options.headers}');
    print('Data: \${options.data}');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('RESPONSE[\${response.statusCode}] => PATH: \${response.requestOptions.path}');
    print('Data: \${response.data}');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('ERROR[\${err.response?.statusCode}] => PATH: \${err.requestOptions.path}');
    print('Message: \${err.message}');
    print('Data: \${err.response?.data}');
    super.onError(err, handler);
  }
}

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Add auth token here
    // Example:
    // final token = await secureStorage.read(key: 'auth_token');
    // if (token != null) {
    //   options.headers['Authorization'] = 'Bearer \$token';
    // }
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Handle 401 Unauthorized - refresh token
    if (err.response?.statusCode == 401) {
      // Implement token refresh logic
      // final refreshed = await refreshToken();
      // if (refreshed) {
      //   return handler.resolve(await _retry(err.requestOptions));
      // }
    }
    super.onError(err, handler);
  }

  // Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
  //   final options = Options(
  //     method: requestOptions.method,
  //     headers: requestOptions.headers,
  //   );
  //   return Dio().request<dynamic>(
  //     requestOptions.path,
  //     data: requestOptions.data,
  //     queryParameters: requestOptions.queryParameters,
  //     options: options,
  //   );
  // }
}
''';
  File('lib/core/network/interceptors.dart').writeAsStringSync(interceptorsContent);

  print('✅ Created: Network files');
}

void createErrorFiles() {
  // failure.dart
  final failureContent = '''
import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure(super.message);
}
''';
  File('lib/core/error/failure.dart').writeAsStringSync(failureContent);

  // exception.dart
  final exceptionContent = '''
class ServerException implements Exception {
  final String message;
  const ServerException(this.message);
}

class NetworkException implements Exception {
  final String message;
  const NetworkException(this.message);
}

class CacheException implements Exception {
  final String message;
  const CacheException(this.message);
}

class ValidationException implements Exception {
  final String message;
  const ValidationException(this.message);
}

class UnauthorizedException implements Exception {
  final String message;
  const UnauthorizedException(this.message);
}
''';
  File('lib/core/error/exception.dart').writeAsStringSync(exceptionContent);

  print('✅ Created: Error files');
}

void createUtilsFiles() {
  // constants.dart
  final constantsContent = '''
class AppConstants {
  static const String appName = 'Flutter BLoC App';
  static const String apiBaseUrl = 'https://api.example.com';

  // Storage keys
  static const String keyAuthToken = 'auth_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserId = 'user_id';

  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration cacheTimeout = Duration(hours: 1);
}
''';
  File('lib/core/utils/constants.dart').writeAsStringSync(constantsContent);

  // validators.dart
  final validatorsContent = '''
class Validators {
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\\w-\\.]+@([\\w-]+\\.)+[\\w-]{2,4}\$');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '\${fieldName ?? 'Field'} is required';
    }
    return null;
  }

  static String? minLength(String? value, int length, {String? fieldName}) {
    if (value == null || value.length < length) {
      return '\${fieldName ?? 'Field'} must be at least \$length characters';
    }
    return null;
  }

  static String? maxLength(String? value, int length, {String? fieldName}) {
    if (value != null && value.length > length) {
      return '\${fieldName ?? 'Field'} must be at most \$length characters';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    final phoneRegex = RegExp(r'^[+]?[0-9]{10,13}\$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  static String? url(String? value) {
    if (value == null || value.isEmpty) {
      return 'URL is required';
    }
    final urlRegex = RegExp(
      r'^https?:\\/\\/(www\\.)?[-a-zA-Z0-9@:%._\\+~#=]{1,256}\\.[a-zA-Z0-9()]{1,6}\\b([-a-zA-Z0-9()@:%_\\+.~#?&\\/\\/=]*)\$',
    );
    if (!urlRegex.hasMatch(value)) {
      return 'Enter a valid URL';
    }
    return null;
  }
}
''';
  File('lib/core/utils/validators.dart').writeAsStringSync(validatorsContent);

  print('✅ Created: Utils files');
}

void createExtensionFiles() {
  final content = '''
import 'package:flutter/material.dart';

extension ContextExtension on BuildContext {
  // Navigation
  void pop<T>([T? result]) => Navigator.of(this).pop(result);

  // Theme
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  // MediaQuery
  Size get screenSize => MediaQuery.of(this).size;
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  EdgeInsets get padding => MediaQuery.of(this).padding;
  EdgeInsets get viewInsets => MediaQuery.of(this).viewInsets;

  // Responsive
  bool get isMobile => screenWidth < 600;
  bool get isTablet => screenWidth >= 600 && screenWidth < 1024;
  bool get isDesktop => screenWidth >= 1024;

  // Snackbar
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

  // Dialog
  Future<T?> showCustomDialog<T>(Widget dialog) {
    return showDialog<T>(
      context: this,
      builder: (context) => dialog,
    );
  }
}
''';
  File('lib/core/extensions/context_extension.dart').writeAsStringSync(content);
  print('✅ Created: lib/core/extensions/context_extension.dart');
}

void createRouteFiles() {
  // app_router.dart
  final routerContent = '''
import 'package:go_router/go_router.dart';
import 'route_names.dart';
import '../features/home/ui/home_page.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: RouteNames.home,
    routes: [
      GoRoute(
        path: RouteNames.home,
        name: RouteNames.home,
        builder: (context, state) => const HomePage(),
      ),

      // Example: Auth routes
      // GoRoute(
      //   path: RouteNames.login,
      //   name: RouteNames.login,
      //   builder: (context, state) => const LoginPage(),
      // ),

      // Example: Nested routes
      // GoRoute(
      //   path: RouteNames.profile,
      //   name: RouteNames.profile,
      //   builder: (context, state) => const ProfilePage(),
      //   routes: [
      //     GoRoute(
      //       path: 'edit',
      //       name: RouteNames.profileEdit,
      //       builder: (context, state) => const ProfileEditPage(),
      //     ),
      //   ],
      // ),
    ],

    // Error handling
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: \${state.uri}'),
      ),
    ),

    // Redirect logic (e.g., auth guard)
    // redirect: (context, state) {
    //   final isLoggedIn = false; // Check auth state
    //   final isGoingToLogin = state.matchedLocation == RouteNames.login;
    //
    //   if (!isLoggedIn && !isGoingToLogin) {
    //     return RouteNames.login;
    //   }
    //   if (isLoggedIn && isGoingToLogin) {
    //     return RouteNames.home;
    //   }
    //   return null;
    // },
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

  // Add more route names here
  // Example:
  // static const String productDetail = '/products/:id';
  // static const String cart = '/cart';
}
''';
  File('lib/routes/route_names.dart').writeAsStringSync(namesContent);

  print('✅ Created: Route files');
}

void createSharedFiles() {
  // app_bloc_observer.dart
  final observerContent = '''
import 'package:flutter_bloc/flutter_bloc.dart';

class AppBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    print('🟢 onCreate -- \${bloc.runtimeType}');
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    print('🔄 onChange -- \${bloc.runtimeType}');
    print('   Current State: \${change.currentState}');
    print('   Next State: \${change.nextState}');
  }

  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    print('📩 onEvent -- \${bloc.runtimeType}, \$event');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    print('🔴 onError -- \${bloc.runtimeType}');
    print('   Error: \$error');
    print('   StackTrace: \$stackTrace');
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    print('🔵 onClose -- \${bloc.runtimeType}');
  }
}
''';
  File('lib/shared/blocs/app_bloc_observer.dart').writeAsStringSync(observerContent);

  // app_button.dart
  final buttonContent = '''
import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double height;
  final IconData? icon;

  const AppButton({
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 48,
    this.icon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isOutlined) {
      return SizedBox(
        width: width,
        height: height,
        child: OutlinedButton.icon(
          onPressed: isLoading ? null : onPressed,
          icon: isLoading
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : icon != null
                  ? Icon(icon)
                  : const SizedBox.shrink(),
          label: Text(text),
          style: OutlinedButton.styleFrom(
            foregroundColor: textColor,
            side: BorderSide(color: backgroundColor ?? theme.colorScheme.primary),
          ),
        ),
      );
    }

    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? const SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : icon != null
                ? Icon(icon)
                : const SizedBox.shrink(),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? theme.colorScheme.primary,
          foregroundColor: textColor ?? Colors.white,
        ),
      ),
    );
  }
}
''';
  File('lib/shared/widgets/app_button.dart').writeAsStringSync(buttonContent);

  // app_text_field.dart
  final textFieldContent = '''
import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLines;
  final bool enabled;
  final VoidCallback? onTap;
  final Function(String)? onChanged;

  const AppTextField({
    this.controller,
    this.label,
    this.hint,
    this.validator,
    this.obscureText = false,
    this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.enabled = true,
    this.onTap,
    this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLines: maxLines,
      enabled: enabled,
      onTap: onTap,
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Colors.grey.shade300,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Colors.red,
          ),
        ),
      ),
    );
  }
}
''';
  File('lib/shared/widgets/app_text_field.dart').writeAsStringSync(textFieldContent);

  // loading_indicator.dart
  final loadingContent = '''
import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  final String? message;
  final double size;

  const LoadingIndicator({
    this.message,
    this.size = 40,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }
}
''';
  File('lib/shared/widgets/loading_indicator.dart').writeAsStringSync(loadingContent);

  // error_view.dart
  final errorViewContent = '''
import 'package:flutter/material.dart';

class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorView({
    required this.message,
    this.onRetry,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
''';
  File('lib/shared/widgets/error_view.dart').writeAsStringSync(errorViewContent);

  print('✅ Created: Shared files');
}

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

void createAnalysisOptionsFile() {
  final content = '''
include: package:very_good_analysis/analysis_options.yaml

linter:
  rules:
    public_member_api_docs: false
    lines_longer_than_80_chars: false
''';
  File('analysis_options.yaml').writeAsStringSync(content);
  print('✅ Created: analysis_options.yaml');
}

void createFeature(String featureName, {bool withSample = false}) {
  final feature = featureName.toLowerCase();
  final featureClass = _toPascalCase(feature);

  final dirs = [
    'lib/features/$feature/cubit',
    'lib/features/$feature/domain/entities',
    'lib/features/$feature/data/datasources',
    'lib/features/$feature/data/models',
    'lib/features/$feature/ui/widgets',
  ];

  for (final dir in dirs) {
    Directory(dir).createSync(recursive: true);
  }

  // Create repository interface
  final repoContent = '''
// Repository interface for $featureClass feature
// Define your repository contract here
abstract class ${featureClass}Repository {
  // Example method:
  // Future<Either<Failure, List<Item>>> getItems();
  // Future<Either<Failure, Item>> getItemById(String id);
  // Future<Either<Failure, void>> createItem(Item item);
  // Future<Either<Failure, void>> updateItem(Item item);
  // Future<Either<Failure, void>> deleteItem(String id);
}
''';
  File('lib/features/$feature/domain/${feature}_repository.dart').writeAsStringSync(repoContent);

  // Create repository implementation
  final repoImplContent = '''
import '../domain/${feature}_repository.dart';
// import 'datasources/${feature}_remote_datasource.dart';
// import '../../../core/error/exception.dart';
// import '../../../core/error/failure.dart';

class ${featureClass}RepositoryImpl implements ${featureClass}Repository {
  // final ${featureClass}RemoteDataSource remoteDataSource;

  // ${featureClass}RepositoryImpl(this.remoteDataSource);

  // Example implementation:
  // @override
  // Future<Either<Failure, List<Item>>> getItems() async {
  //   try {
  //     final items = await remoteDataSource.getItems();
  //     return Right(items);
  //   } on ServerException catch (e) {
  //     return Left(ServerFailure(e.message));
  //   } on NetworkException catch (e) {
  //     return Left(NetworkFailure(e.message));
  //   }
  // }
}
''';
  File('lib/features/$feature/data/${feature}_repository_impl.dart').writeAsStringSync(repoImplContent);

  // Create entity example
  final entityContent = '''
import 'package:equatable/equatable.dart';

// Example entity for $featureClass feature
class ${featureClass}Entity extends Equatable {
  final String id;
  final String name;
  // Add more fields as needed

  const ${featureClass}Entity({
    required this.id,
    required this.name,
  });

  @override
  List<Object?> get props => [id, name];
}
''';
  File('lib/features/$feature/domain/entities/${feature}_entity.dart').writeAsStringSync(entityContent);

  // Create model example
  final modelContent = '''
import '../../domain/entities/${feature}_entity.dart';

// Data model for API responses
class ${featureClass}Model extends ${featureClass}Entity {
  const ${featureClass}Model({
    required super.id,
    required super.name,
  });

  // From JSON
  factory ${featureClass}Model.fromJson(Map<String, dynamic> json) {
    return ${featureClass}Model(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  // To Entity
  ${featureClass}Entity toEntity() {
    return ${featureClass}Entity(
      id: id,
      name: name,
    );
  }
}
''';
  File('lib/features/$feature/data/models/${feature}_model.dart').writeAsStringSync(modelContent);

  // Create datasource example
  final datasourceContent = '''
import '../../../../core/network/api_client.dart';
import '../models/${feature}_model.dart';
// import '../../../../core/error/exception.dart';

abstract class ${featureClass}RemoteDataSource {
  Future<List<${featureClass}Model>> getItems();
  Future<${featureClass}Model> getItemById(String id);
  // Add more methods as needed
}

class ${featureClass}RemoteDataSourceImpl implements ${featureClass}RemoteDataSource {
  final ApiClient apiClient;

  ${featureClass}RemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<${featureClass}Model>> getItems() async {
    try {
      final response = await apiClient.get('/$feature');
      final List<dynamic> data = response.data as List<dynamic>;
      return data.map((json) => ${featureClass}Model.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      throw ServerException('Failed to fetch items: \$e');
    }
  }

  @override
  Future<${featureClass}Model> getItemById(String id) async {
    try {
      final response = await apiClient.get('/$feature/\$id');
      return ${featureClass}Model.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw ServerException('Failed to fetch item: \$e');
    }
  }
}
''';
  File('lib/features/$feature/data/datasources/${feature}_remote_datasource.dart').writeAsStringSync(datasourceContent);

  if (withSample) {
    // Create sample cubit
    createCubit(feature, '${feature}_list', withSample: true);

    // Create sample page
    final pageContent = '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/${feature}_list_cubit.dart';
// import '../../../core/di/service_locator.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/error_view.dart';

class ${featureClass}Page extends StatelessWidget {
  const ${featureClass}Page({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ${featureClass}ListCubit()..loadItems(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('$featureClass'),
        ),
        body: BlocBuilder<${featureClass}ListCubit, ${featureClass}ListState>(
          builder: (context, state) {
            if (state is ${featureClass}ListLoading) {
              return const LoadingIndicator(message: 'Loading items...');
            }

            if (state is ${featureClass}ListError) {
              return ErrorView(
                message: state.message,
                onRetry: () => context.read<${featureClass}ListCubit>().loadItems(),
              );
            }

            if (state is ${featureClass}ListLoaded) {
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.items.length,
                itemBuilder: (context, index) {
                  final item = state.items[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text('Item \${item.name}'),
                      subtitle: Text('ID: \${item.id}'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        // Navigate to detail page
                      },
                    ),
                  );
                },
              );
            }

            return const Center(
              child: Text('No data available'),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Add new item
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
''';
    File('lib/features/$feature/ui/${feature}_page.dart').writeAsStringSync(pageContent);

    // Create sample widget
    final widgetContent = '''
import 'package:flutter/material.dart';
import '../../domain/entities/${feature}_entity.dart';

class ${featureClass}Card extends StatelessWidget {
  final ${featureClass}Entity item;
  final VoidCallback? onTap;

  const ${featureClass}Card({
    required this.item,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'ID: \${item.id}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
''';
    File('lib/features/$feature/ui/widgets/${feature}_card.dart').writeAsStringSync(widgetContent);
  }

  print('✅ Feature "$feature" created successfully!');
  if (withSample) {
    print('   📄 Sample files included: page, cubit, widgets');
  }
  print('');
  print('Next steps:');
  print('  • Update repository implementation');
  print('  • Create BLoC/Cubit: dart generator.dart bloc $feature ${feature}_name');
  print('  • Add route to lib/routes/app_router.dart');
}

void createCubit(String featureName, String cubitName, {bool withSample = false}) {
  final feature = featureName.toLowerCase();
  final cubit = cubitName.toLowerCase();
  final cubitClass = _toPascalCase(cubit);

  if (!Directory('lib/features/$feature').existsSync()) {
    print('❌ Feature "$feature" does not exist. Create it first with:');
    print('   dart generator.dart feature $feature');
    exit(1);
  }

  Directory('lib/features/$feature/cubit').createSync(recursive: true);

  if (withSample) {
    // Cubit with sample logic
    final cubitContent = '''
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../domain/entities/${feature}_entity.dart';

part '${cubit}_state.dart';

class ${cubitClass}Cubit extends Cubit<${cubitClass}State> {
  ${cubitClass}Cubit() : super(${cubitClass}Initial());

  Future<void> loadItems() async {
    emit(${cubitClass}Loading());

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Sample data
      final items = List.generate(
        10,
        (index) => ${_toPascalCase(feature)}Entity(
          id: 'item_\$index',
          name: 'Sample Item \$index',
        ),
      );

      emit(${cubitClass}Loaded(items));
    } catch (e) {
      emit(${cubitClass}Error('Failed to load items: \$e'));
    }
  }

  void refresh() => loadItems();
}
''';
    File('lib/features/$feature/cubit/${cubit}_cubit.dart').writeAsStringSync(cubitContent);

    // State with sample
    final stateContent = '''
part of '${cubit}_cubit.dart';

abstract class ${cubitClass}State extends Equatable {
  const ${cubitClass}State();

  @override
  List<Object> get props => [];
}

class ${cubitClass}Initial extends ${cubitClass}State {}

class ${cubitClass}Loading extends ${cubitClass}State {}

class ${cubitClass}Loaded extends ${cubitClass}State {
  final List<${_toPascalCase(feature)}Entity> items;

  const ${cubitClass}Loaded(this.items);

  @override
  List<Object> get props => [items];
}

class ${cubitClass}Error extends ${cubitClass}State {
  final String message;

  const ${cubitClass}Error(this.message);

  @override
  List<Object> get props => [message];
}
''';
    File('lib/features/$feature/cubit/${cubit}_state.dart').writeAsStringSync(stateContent);
  } else {
    // Basic cubit template
    final cubitContent = '''
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part '${cubit}_state.dart';

class ${cubitClass}Cubit extends Cubit<${cubitClass}State> {
  ${cubitClass}Cubit() : super(${cubitClass}Initial());

  void doSomething() {
    emit(${cubitClass}Loading());
    // Your logic here
    emit(${cubitClass}Success());
  }
}
''';
    File('lib/features/$feature/cubit/${cubit}_cubit.dart').writeAsStringSync(cubitContent);

    final stateContent = '''
part of '${cubit}_cubit.dart';

abstract class ${cubitClass}State extends Equatable {
  const ${cubitClass}State();

  @override
  List<Object> get props => [];
}

class ${cubitClass}Initial extends ${cubitClass}State {}

class ${cubitClass}Loading extends ${cubitClass}State {}

class ${cubitClass}Success extends ${cubitClass}State {}

class ${cubitClass}Error extends ${cubitClass}State {
  final String message;
  const ${cubitClass}Error(this.message);

  @override
  List<Object> get props => [message];
}
''';
    File('lib/features/$feature/cubit/${cubit}_state.dart').writeAsStringSync(stateContent);
  }

  print('✅ Cubit "$cubit" created in feature "$feature"');
}

void createBloc(String featureName, String blocName) {
  final feature = featureName.toLowerCase();
  final bloc = blocName.toLowerCase();
  final blocClass = _toPascalCase(bloc);

  if (!Directory('lib/features/$feature').existsSync()) {
    print('❌ Feature "$feature" does not exist. Create it first with:');
    print('   dart generator.dart feature $feature');
    exit(1);
  }

  Directory('lib/features/$feature/bloc').createSync(recursive: true);

  final blocContent = '''
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part '${bloc}_event.dart';
part '${bloc}_state.dart';

class ${blocClass}Bloc extends Bloc<${blocClass}Event, ${blocClass}State> {
  ${blocClass}Bloc() : super(${blocClass}Initial()) {
    on<${blocClass}Started>(_onStarted);
    on<${blocClass}DataRequested>(_onDataRequested);
  }

  Future<void> _onStarted(
    ${blocClass}Started event,
    Emitter<${blocClass}State> emit,
  ) async {
    emit(${blocClass}Loading());
    // Your initialization logic here
    emit(${blocClass}Success());
  }

  Future<void> _onDataRequested(
    ${blocClass}DataRequested event,
    Emitter<${blocClass}State> emit,
  ) async {
    emit(${blocClass}Loading());
    try {
      // Your data fetching logic here
      emit(${blocClass}Success());
    } catch (e) {
      emit(${blocClass}Error(e.toString()));
    }
  }
}
''';
  File('lib/features/$feature/bloc/${bloc}_bloc.dart').writeAsStringSync(blocContent);

  final eventContent = '''
part of '${bloc}_bloc.dart';

abstract class ${blocClass}Event extends Equatable {
  const ${blocClass}Event();

  @override
  List<Object> get props => [];
}

class ${blocClass}Started extends ${blocClass}Event {}

class ${blocClass}DataRequested extends ${blocClass}Event {}

// Add more events as needed
''';
  File('lib/features/$feature/bloc/${bloc}_event.dart').writeAsStringSync(eventContent);

  final stateContent = '''
part of '${bloc}_bloc.dart';

abstract class ${blocClass}State extends Equatable {
  const ${blocClass}State();

  @override
  List<Object> get props => [];
}

class ${blocClass}Initial extends ${blocClass}State {}

class ${blocClass}Loading extends ${blocClass}State {}

class ${blocClass}Success extends ${blocClass}State {}

class ${blocClass}Error extends ${blocClass}State {
  final String message;
  const ${blocClass}Error(this.message);

  @override
  List<Object> get props => [message];
}
''';
  File('lib/features/$feature/bloc/${bloc}_state.dart').writeAsStringSync(stateContent);

  print('✅ BLoC "$bloc" created in feature "$feature"');
}

void createSharedWidget(String widgetName) {
  final widget = widgetName.toLowerCase();
  final widgetClass = _toPascalCase(widget);

  final content = '''
import 'package:flutter/material.dart';

class $widgetClass extends StatelessWidget {
  const $widgetClass({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Placeholder(),
    );
  }
}
''';
  File('lib/shared/widgets/${widget}.dart').writeAsStringSync(content);
  print('✅ Widget "$widgetClass" created in shared/widgets');
}

String _capitalize(String s) => s[0].toUpperCase() + s.substring(1);

String _toPascalCase(String s) {
  return s.split('_').map((word) => _capitalize(word)).join();
}