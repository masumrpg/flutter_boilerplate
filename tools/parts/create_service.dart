import 'dart:io';

import '../utils/utils.dart';

void createService(String featureName, String serviceName) {
  final feature = featureName.toLowerCase();
  final service = serviceName.toLowerCase();

  if (!Directory('lib/features/$feature').existsSync()) {
    print('❌ Feature "$feature" does not exist. Create it first with:');
    print('   dart generator.dart feature $feature');
    exit(1);
  }

  // Ensure domain/services directory exists
  Directory('lib/features/$feature/domain/services').createSync(recursive: true);

  // Use feature + service name for class name to follow naming convention
  final serviceInterfaceName = feature == service ? '${toPascalCase(feature)}Service' : '${toPascalCase(feature)}${toPascalCase(service)}Service';
  final serviceImplName = feature == service ? '${toPascalCase(feature)}ServiceImpl' : '${toPascalCase(feature)}${toPascalCase(service)}ServiceImpl';

  final serviceContent = '''
abstract class $serviceInterfaceName {
  // Define your service methods here
  // Example:
  // Future<bool> doSomething();
}

class $serviceImplName implements $serviceInterfaceName {
  // Implement your service methods here
  // Example:
  // @override
  // Future<bool> doSomething() async {
  //   // Service implementation
  //   return true;
  // }
}
''';
  // Use feature_service naming convention for consistency
  final fileName = service == feature ? '${feature}_service' : '${feature}_${service}_service';
  File('lib/features/$feature/domain/services/$fileName.dart').writeAsStringSync(serviceContent);

  print('✅ Service "$service" created in feature "$feature" domain/services');
}