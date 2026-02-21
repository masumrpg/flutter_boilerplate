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
  final templateName = 'flutter_boilerplate';

  print('🔄 Renaming project to "$newName"...');
  if (currentName != newName) {
    print('   (Current name: "$currentName")');
  }

  // 1. Update pubspec.yaml
  _updatePubspec(newName);

  final oldNames = {currentName, templateName, 'flutter_boilerplate'};

  // 2. Update Dart imports
  _updateDartImports(oldNames, newName);

  // 3. Update Android files
  _updateAndroidProject(oldNames, newName);

  // 4. Update iOS project
  _updateIOSProject(oldNames, newName);

  // 5. Update Web project
  _updateWebProject(oldNames, newName);

  // 6. Update Linux project
  _updateLinuxProject(oldNames, newName);

  // 7. Update Documentation
  _updateDocumentation(oldNames, newName);

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

void _updateAndroidProject(Set<String> oldNames, String newName) {
  // Update build.gradle (.kts)
  final gradleFiles = [
    File('android/app/build.gradle'),
    File('android/app/build.gradle.kts'),
  ];

  for (final gradleFile in gradleFiles) {
    if (gradleFile.existsSync()) {
      String content = gradleFile.readAsStringSync();
      for (final oldName in oldNames) {
        content = content.replaceAll('com.example.$oldName', 'com.example.$newName');
      }
      content = content.replaceAll(RegExp(r'namespace\s*=\s*".*"'), 'namespace = "com.example.$newName"');
      content = content.replaceAll(RegExp(r'applicationId\s*=\s*".*"'), 'applicationId = "com.example.$newName"');
      gradleFile.writeAsStringSync(content);
      print('✅ Updated: ${gradleFile.path}');
    }
  }

  // Update Manifest
  final manifestFile = File('android/app/src/main/AndroidManifest.xml');
  if (manifestFile.existsSync()) {
    String content = manifestFile.readAsStringSync();
    for (final oldName in oldNames) {
      content = content.replaceAll('com.example.$oldName', 'com.example.$newName');
    }
    content = content.replaceAll(RegExp(r'android:label=".*"'), 'android:label="$newName"');
    manifestFile.writeAsStringSync(content);
    print('✅ Updated: AndroidManifest.xml');
  }

  // Update MainActivity (.kt or .java)
  // We try to find any MainActivity in the expected package structure
  final basePaths = [
    'android/app/src/main/kotlin',
    'android/app/src/main/java',
  ];

  for (final base in basePaths) {
    final dir = Directory(base);
    if (!dir.existsSync()) continue;

    dir.listSync(recursive: true).forEach((entity) {
      if (entity is File && (entity.path.endsWith('MainActivity.kt') || entity.path.endsWith('MainActivity.java'))) {
        String content = entity.readAsStringSync();
        bool changed = false;
        for (final oldName in oldNames) {
          if (content.contains('package com.example.$oldName')) {
            content = content.replaceAll('package com.example.$oldName', 'package com.example.$newName');
            changed = true;
          }
        }
        if (changed) {
          entity.writeAsStringSync(content);
          print('✅ Updated: ${entity.path} (Warning: Directory structure not changed)');
        }
      }
    });
  }
}

void _updateIOSProject(Set<String> oldNames, String newName) {
  final pbxprojFile = File('ios/Runner.xcodeproj/project.pbxproj');
  if (pbxprojFile.existsSync()) {
    String content = pbxprojFile.readAsStringSync();
    for (final oldName in oldNames) {
      content = content.replaceAll('com.example.$oldName', 'com.example.$newName');
    }
    content = content.replaceAll(RegExp(r'PRODUCT_BUNDLE_IDENTIFIER\s*=\s*.*;'), 'PRODUCT_BUNDLE_IDENTIFIER = com.example.$newName;');
    pbxprojFile.writeAsStringSync(content);
    print('✅ Updated: project.pbxproj');
  }
}

void _updateWebProject(Set<String> oldNames, String newName) {
  final files = ['web/index.html', 'web/manifest.json'];
  for (final path in files) {
    final file = File(path);
    if (file.existsSync()) {
      String content = file.readAsStringSync();
      for (final oldName in oldNames) {
        content = content.replaceAll(oldName, newName);
      }
      file.writeAsStringSync(content);
      print('✅ Updated: $path');
    }
  }
}

void _updateLinuxProject(Set<String> oldNames, String newName) {
  final file = File('linux/runner/my_application.cc');
  if (file.existsSync()) {
    String content = file.readAsStringSync();
    for (final oldName in oldNames) {
      content = content.replaceAll('"$oldName"', '"$newName"');
    }
    file.writeAsStringSync(content);
    print('✅ Updated: linux/runner/my_application.cc');
  }
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
        if (content.contains(oldName)) {
          content = content.replaceAll(oldName, newName);
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
