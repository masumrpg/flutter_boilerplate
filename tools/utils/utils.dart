import 'dart:io';

int findMatchingBracket(String text, int openIndex) {
  int closeIndex = openIndex;
  int counter = 1;
  while (counter > 0 && closeIndex < text.length - 1) {
    closeIndex++;
    if (text[closeIndex] == '[') counter++;
    if (text[closeIndex] == ']') counter--;
  }
  return counter == 0 ? closeIndex : -1;
}

void injectRouteName(String feature) {
  final file = File('lib/routes/route_names.dart');
  if (!file.existsSync()) return;

  final content = file.readAsStringSync();
  // Check if variable name already exists to avoid duplicates (e.g. 'home')
  if (content.contains('String $feature =')) return;

  final routeName = '/$feature';
  final routeConst = "  static const String $feature = '$routeName';";

  final lines = content.split('\n');
  final lastConstIndex = lines.lastIndexWhere(
    (line) => line.trim().startsWith('static const String'),
  );

  if (lastConstIndex != -1) {
    lines.insert(lastConstIndex + 1, routeConst);
    file.writeAsStringSync(lines.join('\n'));
    print('   ➕ Injected route constant: RouteNames.$feature');
  }
}

void injectRoute(String feature, String featureClass) {
  final file = File('lib/routes/app_router.dart');
  if (!file.existsSync()) return;

  var content = file.readAsStringSync();

  // Check if already injected
  if (content.contains('path: RouteNames.$feature')) return;

  // Import insertion
  final importStatement =
      "import '../features/$feature/ui/pages/${feature}_page.dart';";
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

  // Inject before the closing bracket of routes list
  final routeEntry =
      '''
      GoRoute(
        path: RouteNames.$feature,
        name: RouteNames.$feature,
        builder: (context, state) => const ${featureClass}Page(),
      ),
''';

  // If we found a GoRoute, we try to find its end and insert after it,
  // or just insert before the list end if simpler.
  // Safest is to insert before the last closing bracket of the list.

  // Finding the last ']' of the list is tricky with nested routes.
  // Let's use string manipulation to insert before the list's closing bracket.
  // The _findMatchingBracket gives us the index of ']', so we insert before it.

  content = content.replaceRange(routesEndIndex, routesEndIndex, routeEntry);

  file.writeAsStringSync(content);
  print('   ➕ Injected route configuration for $feature');
}

String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

String toPascalCase(String s) {
  return s.split('_').map((word) => capitalize(word)).join();
}