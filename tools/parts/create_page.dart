import 'dart:io';

import '../utils/utils.dart';

void createPage(String featureName, String pageName) {
  final feature = featureName.toLowerCase();
  final page = pageName.toLowerCase();
  final pageClass = toPascalCase(page);

  if (!Directory('lib/features/$feature').existsSync()) {
    print('❌ Feature "$feature" does not exist. Create it first with:');
    print('   dart generator.dart feature $feature');
    exit(1);
  }

  // Ensure ui/pages directory exists
  Directory('lib/features/$feature/ui/pages').createSync(recursive: true);

  final pageContent = '''
import 'package:flutter/material.dart';

class ${pageClass}Page extends StatelessWidget {
  const ${pageClass}Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('$pageClass'),
      ),
      body: const SafeArea(
        child: Center(
          child: Text('$pageClass Page'),
        ),
      ),
    );
  }
}
''';
  File('lib/features/$feature/ui/pages/${page}_page.dart').writeAsStringSync(pageContent);

  print('✅ Page "$page" created in feature "$feature"');

  // Now inject the route for this page
  injectRouteForPage(feature, page, pageClass);
}

void injectRouteForPage(String feature, String page, String pageClass) {
  final file = File('lib/routes/app_router.dart');
  if (!file.existsSync()) return;

  var content = file.readAsStringSync();

  // Check if already injected
  if (content.contains('const ${pageClass}Page()')) return;

  // Import insertion
  final importStatement = 'import \'../features/$feature/ui/pages/${page}_page.dart\';';
  if (!content.contains(importStatement)) {
    final lastImportIndex = content.lastIndexOf('import ');
    if (lastImportIndex != -1) {
      final endOfLastImport = content.indexOf(';', lastImportIndex) + 1;
      content = content.replaceRange(
        endOfLastImport,
        endOfLastImport,
        '\n$importStatement',
      );
    }
  }

  // Route insertion
  // Look for the routes list [ ... ]
  final routesStartIndex = content.indexOf('routes: [');
  if (routesStartIndex == -1) return;

  final routesEndIndex = findMatchingBracket(
    content,
    routesStartIndex + 'routes: '.length,
  );
  if (routesEndIndex == -1) return;

  // Generate route path
  final routePath = page == feature ? '/$feature' : '/$feature/$page';

  // Create the route entry
  final routeEntry = '''
      GoRoute(
        path: '$routePath',
        name: '${page == feature ? feature : '${feature}_$page'}',
        builder: (context, state) => const ${pageClass}Page(),
      ),
''';

  content = content.replaceRange(routesEndIndex, routesEndIndex, routeEntry);

  file.writeAsStringSync(content);
  print('   ➕ Injected route configuration for $feature/$page');
}