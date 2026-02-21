import 'dart:io';

import '../utils/utils.dart';

void createFeature(String featureName, {bool withSample = false}) {
  final feature = featureName.toLowerCase();
  final featureClass = toPascalCase(feature);

  final dirs = [
    'lib/features/$feature/domain/entities',
    'lib/features/$feature/domain/repositories',
    'lib/features/$feature/domain/services',
    'lib/features/$feature/data/datasources',
    'lib/features/$feature/data/models',
    'lib/features/$feature/data/repositories',
    'lib/features/$feature/ui/pages',
    'lib/features/$feature/ui/widgets',
  ];

  for (final dir in dirs) {
    Directory(dir).createSync(recursive: true);
  }

  // Create repository interface
  final repoContent = '''
import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../entities/${feature}_entity.dart';

abstract class ${featureClass}Repository {
  Future<Either<Failure, List<${featureClass}Entity>>> getItems();
  // Future<Either<Failure, ${featureClass}Entity>> getItemById(String id);
}
''';
  File(
    'lib/features/$feature/domain/repositories/${feature}_repository.dart',
  ).writeAsStringSync(repoContent);

  // Create repository implementation
  final repoImplContent = '''
import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/error/exception.dart';
import '../../domain/repositories/${feature}_repository.dart';
import '../../domain/entities/${feature}_entity.dart';
import '../datasources/${feature}_remote_datasource.dart';

class ${featureClass}RepositoryImpl implements ${featureClass}Repository {
  final ${featureClass}RemoteDataSource remoteDataSource;

  ${featureClass}RepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<${featureClass}Entity>>> getItems() async {
    try {
      final models = await remoteDataSource.getItems();
      return Right(models.map((e) => e.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
''';
  File(
    'lib/features/$feature/data/repositories/${feature}_repository_impl.dart',
  ).writeAsStringSync(repoImplContent);

  // Create entity example
  final entityContent = '''
import 'package:equatable/equatable.dart';

class ${featureClass}Entity extends Equatable {
  final String id;
  final String name;

  const ${featureClass}Entity({
    required this.id,
    required this.name,
  });

  @override
  List<Object?> get props => [id, name];
}
''';
  File('lib/features/$feature/domain/entities/${feature}_entity.dart').writeAsStringSync(entityContent);

  // Create model example
  final modelContent = '''
import '../../domain/entities/${feature}_entity.dart';

class ${featureClass}Model extends ${featureClass}Entity {
  const ${featureClass}Model({
    required super.id,
    required super.name,
  });

  factory ${featureClass}Model.fromJson(Map<String, dynamic> json) {
    return ${featureClass}Model(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  ${featureClass}Entity toEntity() {
    return ${featureClass}Entity(
      id: id,
      name: name,
    );
  }
}
''';
  File('lib/features/$feature/data/models/${feature}_model.dart').writeAsStringSync(modelContent);

  // Create datasource example
  final datasourceContent = '''
import '../../../../core/network/api_client.dart';
import '../../../../core/error/exception.dart';
import '../models/${feature}_model.dart';
// import 'package:dio/dio.dart'; // Uncomment if needed

abstract class ${featureClass}RemoteDataSource {
  Future<List<${featureClass}Model>> getItems();
  Future<${featureClass}Model> getItemById(String id);
}

class ${featureClass}RemoteDataSourceImpl implements ${featureClass}RemoteDataSource {
  final ApiClient apiClient;

  ${featureClass}RemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<${featureClass}Model>> getItems() async {
    try {
      // Example call
      // final response = await apiClient.get('/$feature');
      // final List<dynamic> data = response.data as List<dynamic>;
      // return data.map((json) => \${featureClass}Model.fromJson(json as Map<String, dynamic>)).toList();

      // Mock data
      await Future.delayed(const Duration(seconds: 1));
      return [
        const ${featureClass}Model(id: '1', name: 'Item 1'),
        const ${featureClass}Model(id: '2', name: 'Item 2'),
      ];
    } catch (e) {
      throw ServerException('Failed to fetch items: \$e');
    }
  }

  @override
  Future<${featureClass}Model> getItemById(String id) async {
    try {
      // Example call
      // final response = await apiClient.get('/\$feature/\$id');
      // return \${featureClass}Model.fromJson(response.data as Map<String, dynamic>);

      // Mock data
      await Future.delayed(const Duration(milliseconds: 500));
      return ${featureClass}Model(id: id, name: 'Sample Item \$id');
    } catch (e) {
      throw ServerException('Failed to fetch item: \$e');
    }
  }
}
''';
  File('lib/features/$feature/data/datasources/${feature}_remote_datasource.dart').writeAsStringSync(datasourceContent);

  // Always create a basic page when feature is generated
  String pageContent;

  if (feature == 'home' && withSample) {
    // Bio profile page for home feature sample
    pageContent =
        '''
import 'package:flutter/material.dart';

class ${featureClass}Page extends StatelessWidget {
  const ${featureClass}Page({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 32),
              // Avatar
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: const CircleAvatar(
                  radius: 60,
                  backgroundImage: NetworkImage(
                    'https://avatars.githubusercontent.com/u/75865642?v=4',
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Name
              Text(
                "Ma'sum",
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '@masumrpg',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Fullstack Web & Mobile Developer',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Indonesia',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Stats row
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 24,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? theme.colorScheme.surface
                      : theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatItem(label: 'Repos', value: '25'),
                    _StatItem(label: 'Followers', value: '7'),
                    _StatItem(label: 'Following', value: '17'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // About card
              _InfoCard(
                title: 'About',
                icon: Icons.person_outline,
                theme: theme,
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _AboutItem(
                      icon: Icons.rocket_launch_outlined,
                      text: 'Becoming a Mobile Engineer',
                    ),
                    SizedBox(height: 8),
                    _AboutItem(
                      icon: Icons.code,
                      text: 'Ask me about React Native & Expo',
                    ),
                    SizedBox(height: 8),
                    _AboutItem(
                      icon: Icons.language,
                      text: 'masumdev.my.id',
                    ),
                    SizedBox(height: 8),
                    _AboutItem(
                      icon: Icons.email_outlined,
                      text: 'mclasix@gmail.com',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Skills card
              _InfoCard(
                title: 'Skills',
                icon: Icons.build_outlined,
                theme: theme,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    'Flutter',
                    'React Native',
                    'Expo',
                    'Dart',
                    'TypeScript',
                    'Kotlin',
                    'Rust',
                    'Go',
                    'Node.js',
                    'PostgreSQL',
                  ]
                      .map(
                        (skill) => Chip(
                          label: Text(skill),
                          backgroundColor:
                              theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                          side: BorderSide.none,
                          padding: EdgeInsets.zero,
                          labelStyle: theme.textTheme.bodySmall,
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 32),
              // Footer
              Text(
                'Built with Flutter BLoC Generator \\u2764\\ufe0f',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final ThemeData theme;
  final Widget child;

  const _InfoCard({
    required this.title,
    required this.icon,
    required this.theme,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _AboutItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _AboutItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
''';
  } else {
    pageContent =
        '''
import 'package:flutter/material.dart';

class ${featureClass}Page extends StatelessWidget {
  const ${featureClass}Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('$featureClass'),
      ),
      body: const SafeArea(
        child: Center(
          child: Text('$featureClass Page'),
        ),
      ),
    );
  }
}
''';
  }
  File(
    'lib/features/$feature/ui/pages/${feature}_page.dart',
  ).writeAsStringSync(pageContent);

  print('✅ Feature "$feature" created successfully!');

  // Inject route name only (the path constant)
  injectRouteName(feature);

  // Inject route for the created page if it's not the home feature (which is already in the initial router)
  if (feature != 'home') {
    // Import insertion for the page
    final file = File('lib/routes/app_router.dart');
    if (file.existsSync()) {
      var content = file.readAsStringSync();

      // Import insertion
      final importStatement = "import '../features/$feature/ui/pages/${feature}_page.dart';";
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
      final routesStartIndex = content.indexOf('routes: [');
      if (routesStartIndex != -1) {
        final routesEndIndex = findMatchingBracket(
          content,
          routesStartIndex + 'routes: '.length,
        );
        if (routesEndIndex != -1) {
          final routeEntry = '''
      GoRoute(
        path: RouteNames.$feature,
        name: RouteNames.$feature,
        builder: (context, state) => const ${featureClass}Page(),
      ),
''';

          content = content.replaceRange(routesEndIndex, routesEndIndex, routeEntry);
          file.writeAsStringSync(content);
        }
      }
    }
  }

  if (withSample) {
    print('   📄 Sample files included: page');
  }

  print('');
  print('Next steps:');
  print('  • Update repository implementation');
  print('  • Create BLoC/Cubit: dart generator.dart bloc $feature ${feature}_name');
  print('  • Add widgets to: lib/features/$feature/ui/widgets');
  print('  • Check lib/routes/app_router.dart for the new route');
}