import 'dart:io';

int findMatchingBracket(String text, int openIndex) {
  int closeIndex = openIndex;
  int counter = 1;
  while (counter > 0 && closeIndex < text.length - 1) {
    closeIndex++;
    if (text[closeIndex] == '[') counter++;
    if (text[closeIndex] == ']') counter--;
    if (text[closeIndex] == '{') counter++;
    if (text[closeIndex] == '}') counter--;
  }
  return counter == 0 ? closeIndex : -1;
}

void injectRouteName(String feature) {
  final file = File('lib/routes/route_names.dart');
  if (!file.existsSync()) return;

  var content = file.readAsStringSync();
  final featureName = feature.toLowerCase();
  final routeConstant = toCamelCase(featureName);
  
  // Check if variable name already exists in RouteNames class
  if (content.contains('static const String $routeConstant =')) return;

  final nameConst = "  static const String $routeConstant = '$featureName';";
  final pathConst = "  static const String $routeConstant = '/$featureName';";

  final lines = content.split('\n');
  
  // --- Inject into RouteNames class ---
  int routeNamesClassStart = lines.indexWhere((line) => line.contains('class RouteNames'));
  int routePathsClassStart = lines.indexWhere((line) => line.contains('class RoutePaths'));
  
  if (routeNamesClassStart != -1) {
    int routeNamesEnd = (routePathsClassStart != -1) ? routePathsClassStart : lines.length;
    
    // Try to find the last constant in RouteNames
    int insertIndex = -1;
    for (int i = routeNamesEnd - 1; i > routeNamesClassStart; i--) {
      if (lines[i].trim().startsWith('static const String')) {
        insertIndex = i + 1;
        break;
      }
    }
    
    // If no constants, find the opening brace
    if (insertIndex == -1) {
      for (int i = routeNamesClassStart; i < routeNamesEnd; i++) {
        if (lines[i].contains('{')) {
          insertIndex = i + 1;
          break;
        }
      }
    }
    
    if (insertIndex != -1) {
      lines.insert(insertIndex, nameConst);
      // Refresh indices after insertion
      routePathsClassStart = lines.indexWhere((line) => line.contains('class RoutePaths'));
    }
  }

  // --- Inject into RoutePaths class ---
  if (routePathsClassStart != -1) {
    int routePathsEnd = lines.length;
    
    // Try to find the last constant in RoutePaths
    int insertIndex = -1;
    for (int i = routePathsEnd - 1; i > routePathsClassStart; i--) {
      if (lines[i].trim().startsWith('static const String')) {
        insertIndex = i + 1;
        break;
      }
    }
    
    // If no constants, find the opening brace
    if (insertIndex == -1) {
      for (int i = routePathsClassStart; i < routePathsEnd; i++) {
        if (lines[i].contains('{')) {
          insertIndex = i + 1;
          break;
        }
      }
    }
    
    if (insertIndex != -1) {
      lines.insert(insertIndex, pathConst);
    }
  }

  file.writeAsStringSync(lines.join('\n'));
  print('   ➕ Injected route constant: RouteNames.$routeConstant & RoutePaths.$routeConstant');
}

void injectRoute(String feature, String featureClass) {
  final file = File('lib/routes/app_router.dart');
  if (!file.existsSync()) return;

  var content = file.readAsStringSync();
  final featureName = feature.toLowerCase();
  final routeConstant = toCamelCase(featureName);

  // Check if already injected
  if (content.contains('path: RoutePaths.$routeConstant')) return;

  // Import insertion
  final projectName = getProjectName();
  final importStatement =
      "import 'package:$projectName/features/$featureName/ui/pages/${featureName}_page.dart';";
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
  final routesMatch = RegExp(r'routes:\s*(?:<[^>]+>)?\s*\[').firstMatch(content);
  if (routesMatch == null) return;

  final routesStartIndex = routesMatch.end - 1; // Index of '['
  final routesEndIndex = findMatchingBracket(
    content,
    routesStartIndex,
  );
  if (routesEndIndex == -1) return;

  final routeEntry =
      '''
      GoRoute(
        path: RoutePaths.$routeConstant,
        name: RouteNames.$routeConstant,
        builder: (context, state) => const ${featureClass}Page(),
      ),
''';

  // Insert before the closing bracket of the routes list
  content = content.replaceRange(routesEndIndex, routesEndIndex, routeEntry);

  file.writeAsStringSync(content);
  print('   ➕ Injected route configuration for $featureName');
}

String getProjectName() {
  final pubspecFile = File('pubspec.yaml');
  if (pubspecFile.existsSync()) {
    final content = pubspecFile.readAsStringSync();
    final match = RegExp(r'^name:\s*(\w+)', multiLine: true).firstMatch(content);
    if (match != null) {
      return match.group(1)!;
    }
  }
  return Directory.current.path.split(Platform.pathSeparator).last.replaceAll('-', '_').toLowerCase();
}

void injectPageRoute(String feature, String page, String pageClass) {
  final featureName = feature.toLowerCase();
  final pageName = page.toLowerCase();
  
  // 1. Inject into RouteNames/RoutePaths
  final routeNamesFile = File('lib/routes/route_names.dart');
  if (routeNamesFile.existsSync()) {
    final routeConstant = toCamelCase(pageName == featureName ? featureName : '${featureName}_$pageName');
    final routePath = pageName == featureName ? '/$featureName' : '/$featureName/$pageName';
    
    var content = routeNamesFile.readAsStringSync();
    if (!content.contains('static const String $routeConstant =')) {
      final nameConst = "  static const String $routeConstant = '$routeConstant';";
      final pathConst = "  static const String $routeConstant = '$routePath';";

      final lines = content.split('\n');
      
      // Inject Name
      int namesClassStart = lines.indexWhere((line) => line.contains('class RouteNames'));
      int pathsClassStart = lines.indexWhere((line) => line.contains('class RoutePaths'));
      
      if (namesClassStart != -1) {
        int namesEnd = (pathsClassStart != -1) ? pathsClassStart : lines.length;
        int insertIndex = -1;
        for (int i = namesEnd - 1; i > namesClassStart; i--) {
          if (lines[i].trim().startsWith('static const String')) { insertIndex = i + 1; break; }
        }
        if (insertIndex == -1) {
          for (int i = namesClassStart; i < namesEnd; i++) {
            if (lines[i].contains('{')) { insertIndex = i + 1; break; }
          }
        }
        if (insertIndex != -1) {
          lines.insert(insertIndex, nameConst);
          pathsClassStart = lines.indexWhere((line) => line.contains('class RoutePaths'));
        }
      }

      // Inject Path
      if (pathsClassStart != -1) {
        int pathsEnd = lines.length;
        int insertIndex = -1;
        for (int i = pathsEnd - 1; i > pathsClassStart; i--) {
          if (lines[i].trim().startsWith('static const String')) { insertIndex = i + 1; break; }
        }
        if (insertIndex == -1) {
          for (int i = pathsClassStart; i < pathsEnd; i++) {
            if (lines[i].contains('{')) { insertIndex = i + 1; break; }
          }
        }
        if (insertIndex != -1) lines.insert(insertIndex, pathConst);
      }
      
      routeNamesFile.writeAsStringSync(lines.join('\n'));
      print('   ➕ Injected route constant: RouteNames.$routeConstant & RoutePaths.$routeConstant');
    }
  }

  // 2. Inject into AppRouter
  final routerFile = File('lib/routes/app_router.dart');
  if (routerFile.existsSync()) {
    var content = routerFile.readAsStringSync();
    if (!content.contains('const $pageClass()')) {
      final projectName = getProjectName();
      final routeConstant = toCamelCase(pageName == featureName ? featureName : '${featureName}_$pageName');
      final fileName = pageName == featureName ? '${featureName}_page' : '${featureName}_${pageName}_page';
      
      // Import
      final importStatement = "import 'package:$projectName/features/$featureName/ui/pages/$fileName.dart';";
      if (!content.contains(importStatement)) {
        final lastImportIndex = content.lastIndexOf('import ');
        if (lastImportIndex != -1) {
          final endOfLastImport = content.indexOf(';', lastImportIndex) + 1;
          content = content.replaceRange(endOfLastImport, endOfLastImport, '\n$importStatement');
        }
      }

      // Route
      final routesMatch = RegExp(r'routes:\s*(?:<[^>]+>)?\s*\[').firstMatch(content);
      if (routesMatch != null) {
        final routesStartIndex = routesMatch.end - 1;
        final routesEndIndex = findMatchingBracket(content, routesStartIndex);
        if (routesEndIndex != -1) {
          final routeEntry = '''
      GoRoute(
        path: RoutePaths.$routeConstant,
        name: RouteNames.$routeConstant,
        builder: (context, state) => const $pageClass(),
      ),
''';
          content = content.replaceRange(routesEndIndex, routesEndIndex, routeEntry);
          routerFile.writeAsStringSync(content);
          print('   ➕ Injected route configuration for $featureName/$pageName');
        }
      }
    }
  }
}

String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

String toPascalCase(String s) {
  return s.split('_').map((word) => capitalize(word)).join();
}

String toCamelCase(String input) {
  if (input.contains('_')) {
    final parts = input.split('_');
    final result = <String>[];
    for (int i = 0; i < parts.length; i++) {
      if (i == 0) {
        result.add(parts[i]);
      } else {
        result.add(parts[i][0].toUpperCase() + parts[i].substring(1));
      }
    }
    return result.join();
  }
  return input;
}