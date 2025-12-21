import 'dart:io';

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
      return '\${fieldName ?? 'Field'} must be at least \${length} characters';
    }
    return null;
  }

  static String? maxLength(String? value, int length, {String? fieldName}) {
    if (value != null && value.length > length) {
      return '\${fieldName ?? 'Field'} must be at most \${length} characters';
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
      r'^https?:\\/\\/(www\\.)?[-a-zA-Z0-9@:%._\\+~#=]{1,256}\\.[a-zA-Z0-9()]{1,6}\\b([-a-zA-Z0-9()@:%_+\\.~#?&\\/\\/=]*)\$',
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