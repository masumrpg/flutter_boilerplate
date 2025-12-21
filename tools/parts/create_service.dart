import 'dart:io';

import '../utils/utils.dart';

void createService(String featureName, String serviceName) {
  final feature = featureName.toLowerCase();
  final service = serviceName.toLowerCase();
  final serviceClass = toPascalCase(service);

  if (!Directory('lib/features/$feature').existsSync()) {
    print('❌ Feature "$feature" does not exist. Create it first with:');
    print('   dart generator.dart feature $feature');
    exit(1);
  }

  // Ensure domain/services directory exists
  Directory('lib/features/$feature/domain/services').createSync(recursive: true);

  final serviceContent = '''
abstract class ${serviceClass}Service {
  // Define your service methods here
  // Example:
  // Future<bool> doSomething();
}

class ${serviceClass}ServiceImpl implements ${serviceClass}Service {
  // Implement your service methods here
  // Example:
  // @override
  // Future<bool> doSomething() async {
  //   // Service implementation
  //   return true;
  // }
}
''';
  File('lib/features/$feature/domain/services/${service}_service.dart').writeAsStringSync(serviceContent);

  print('✅ Service "$service" created in feature "$feature" domain/services');
}