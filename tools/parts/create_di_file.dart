import 'dart:io';

void createDIFile(String projectName) {
  final content = '''
import 'package:get_it/get_it.dart';
import 'package:$projectName/core/network/api_client.dart';

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