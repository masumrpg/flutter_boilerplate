import 'dart:io';

void createNetworkFiles(String projectName) {
  // api_client.dart
  final clientContent = '''
import 'package:dio/dio.dart';
import 'package:$projectName/core/config/env.dart';
import 'package:$projectName/core/network/interceptors.dart';

class ApiClient {
  late final Dio _dio;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: Env.apiBaseUrl,
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
import 'package:$projectName/core/utils/logger_utils.dart';

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    LoggerUtils.info('REQUEST[\${options.method}] => PATH: \${options.path}');
    LoggerUtils.debug('Headers: \${options.headers}');
    LoggerUtils.debug('Data: \${options.data}');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    LoggerUtils.success('RESPONSE[\${response.statusCode}] => PATH: \${response.requestOptions.path}');
    LoggerUtils.debug('Data: \${response.data}');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    LoggerUtils.error('ERROR[\${err.response?.statusCode}] => PATH: \${err.requestOptions.path}');
    LoggerUtils.error('Message: \${err.message}');
    LoggerUtils.debug('Data: \${err.response?.data}');
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