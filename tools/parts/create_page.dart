import 'dart:io';

import '../utils/utils.dart';

void createPage(String featureName, String pageName) {
  final feature = featureName.toLowerCase();
  final page = pageName.toLowerCase();
  // Use feature + page name for class name to follow naming convention
  final pageClass = page == feature ? '${toPascalCase(feature)}Page' : '${toPascalCase(feature)}${toPascalCase(page)}Page';

  if (!Directory('lib/features/$feature').existsSync()) {
    print('❌ Feature "$feature" does not exist. Create it first with:');
    print('   dart generator.dart feature $feature');
    exit(1);
  }

  // Ensure ui/pages directory exists
  Directory('lib/features/$feature/ui/pages').createSync(recursive: true);

  final pageContent = '''
import 'package:flutter/material.dart';

class $pageClass extends StatelessWidget {
  const $pageClass({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('${page == feature ? toPascalCase(feature) : '${toPascalCase(feature)} ${toPascalCase(page)}'}'),
      ),
      body: const SafeArea(
        child: Center(
          child: Text('${page == feature ? '${toPascalCase(feature)} Page' : '${toPascalCase(feature)} ${toPascalCase(page)} Page'}'),
        ),
      ),
    );
  }
}
''';
  // Use feature_page naming convention for consistency
  final fileName = page == feature ? '${feature}_page' : '${feature}_${page}_page';
  File('lib/features/$feature/ui/pages/$fileName.dart').writeAsStringSync(pageContent);

  print('✅ Page "$page" created in feature "$feature"');

  // Now inject the route for this page using the hardened utility
  injectPageRoute(feature, page, pageClass);
}