import 'dart:io';

void renameProject(String newName) {
  if (!File('pubspec.yaml').existsSync()) {
    print('❌ Error: pubspec.yaml not found. Are you in the project root?');
    return;
  }

  final pubspecContent = File('pubspec.yaml').readAsStringSync();
  final nameMatch = RegExp(r'name:\s*(\w+)').firstMatch(pubspecContent);

  if (nameMatch == null) {
    print('❌ Error: Could not find project name in pubspec.yaml');
    return;
  }

  final currentName = nameMatch.group(1)!;

  print('🔄 Renaming project to "$newName"...');
  if (currentName != newName) {
    print('   (Current name: "$currentName")');
  }

  final oldNames = {currentName};

  // 1. Update pubspec.yaml
  _updatePubspec(newName);

  // 2. Update Dart imports
  _updateDartImports(oldNames, newName);

  // 3. Update Documentation using word boundaries
  _updateDocumentation(oldNames, newName);

  // 4. Update Native Projects using rename package
  _updateNativeProjects(newName);

  print('\n✨ Project renamed successfully to "$newName"!');
  print('📝 Note: You might need to run "flutter pub get" and "flutter clean".');
}

void _updatePubspec(String newName) {
  final file = File('pubspec.yaml');
  String content = file.readAsStringSync();
  content = content.replaceFirst(RegExp(r'name:\s*\w+'), 'name: $newName');
  file.writeAsStringSync(content);
  print('✅ Updated: pubspec.yaml');
}

void _updateDartImports(Set<String> oldNames, String newName) {
  final directories = ['lib', 'test', 'tools'];
  int count = 0;

  for (final dirPath in directories) {
    final dir = Directory(dirPath);
    if (!dir.existsSync()) continue;

    dir.listSync(recursive: true).forEach((entity) {
      if (entity is File && entity.path.endsWith('.dart')) {
        String content = entity.readAsStringSync();
        bool changed = false;

        for (final oldName in oldNames) {
          final oldImport = 'package:$oldName/';
          final newImport = 'package:$newName/';
          if (content.contains(oldImport)) {
            content = content.replaceAll(oldImport, newImport);
            changed = true;
          }
        }

        if (changed) {
          entity.writeAsStringSync(content);
          count++;
        }
      }
    });
  }
  print('✅ Updated: $count Dart files');
}

void _updateDocumentation(Set<String> oldNames, String newName) {
  final rootDir = Directory.current;
  int count = 0;

  rootDir.listSync(recursive: true).forEach((entity) {
    if (entity is File && entity.path.endsWith('.md')) {
      if (entity.path.contains('.dart_tool/') || entity.path.contains('build/')) return;

      String content = entity.readAsStringSync();
      bool changed = false;
      for (final oldName in oldNames) {
        // Use word boundaries so we don't accidentally replace substrings
        final pattern = RegExp(r'\b' + oldName + r'\b');
        if (pattern.hasMatch(content)) {
          content = content.replaceAll(pattern, newName);
          changed = true;
        }
      }
      if (changed) {
        entity.writeAsStringSync(content);
        count++;
      }
    }
  });
  print('✅ Updated: $count documentation files');
}

void _updateNativeProjects(String newName) {
  print('⚙️ Running native rename using package "rename"...');
  
  // 1. Install rename globally
  print('  Installing "rename" package globally...');
  var result = Process.runSync('dart', ['pub', 'global', 'activate', 'rename']);
  if (result.exitCode != 0) {
    print('❌ Failed to install rename package: ${result.stderr}');
    return;
  }
  
  // Create pretty app name from snake_case
  final appName = newName.split('_').map((word) => word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : '').join(' ');

  // 2. Run setAppName
  print('  Setting App Name to "$appName"...');
  result = Process.runSync('dart', ['pub', 'global', 'run', 'rename', 'setAppName', '--targets', 'ios,android,macos,linux,windows,web', '--value', appName]);
  if (result.exitCode != 0) {
    print('⚠️  Failed to set app name: ${result.stderr}');
  }

  // 3. Run setBundleId
  final bundleId = 'com.example.$newName';
  print('  Setting Bundle ID to "$bundleId"...');
  result = Process.runSync('dart', ['pub', 'global', 'run', 'rename', 'setBundleId', '--targets', 'ios,android,macos,linux,windows,web', '--value', bundleId]);
  if (result.exitCode != 0) {
    print('⚠️  Failed to set bundle id: ${result.stderr}');
  }
  
  print('✅ Updated Native Projects (Android, iOS, Web, Desktop)');
}
