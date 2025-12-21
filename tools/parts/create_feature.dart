import 'dart:io';

import '../utils/utils.dart';
import 'create_cubit.dart';

void createFeature(String featureName, {bool withSample = false}) {
  final feature = featureName.toLowerCase();
  final featureClass = toPascalCase(feature);

  final dirs = [
    'lib/features/$feature/cubit',
    'lib/features/$feature/domain/entities',
    'lib/features/$feature/domain/repositories',
    'lib/features/$feature/domain/services',
    'lib/features/$feature/data/datasources',
    'lib/features/$feature/data/models',
    'lib/features/$feature/data/repositories',
    'lib/features/$feature/ui/widgets',
    'lib/features/$feature/ui/pages',
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

  if (withSample) {
    // Create sample cubit
    createCubit(feature, '${feature}_list', withSample: true);

    // Create sample page
    final pageContent = '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';
import '../../cubit/${feature}_list_cubit.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/error_view.dart';
import '../widgets/${feature}_card.dart';

class ${featureClass}Page extends StatelessWidget {
  const ${featureClass}Page({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ${featureClass}ListCubit()..loadItems(),
      child: const ${featureClass}View(),
    );
  }
}

class ${featureClass}View extends StatelessWidget {
  const ${featureClass}View({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('$featureClass'),
      ),
      body: SafeArea(
        child: BlocBuilder<${featureClass}ListCubit, ${featureClass}ListState>(
          builder: (context, state) {
            if (state is ${featureClass}ListLoading) {
              return const LoadingIndicator(message: 'Loading items...');
            }

            if (state is ${featureClass}ListError) {
              return ErrorView(
                message: state.message,
                onRetry: () => context.read<${featureClass}ListCubit>().loadItems(),
              );
            }

            if (state is ${featureClass}ListLoaded) {
              if (state.items.isEmpty) {
                return const Center(child: Text('No items found'));
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: state.items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = state.items[index];
                  return ${featureClass}Card(
                    item: item,
                    onTap: () {
                      // context.push('/$feature/details/\${item.id}');
                    },
                  );
                },
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Action
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
''';
    File(
      'lib/features/$feature/ui/pages/${feature}_page.dart',
    ).writeAsStringSync(pageContent);

    // Create sample widget
    final widgetContent = '''
import 'package:flutter/material.dart';
import '../../domain/entities/${feature}_entity.dart';

class ${featureClass}Card extends StatelessWidget {
  final ${featureClass}Entity item;
  final VoidCallback? onTap;

  const ${featureClass}Card({
    required this.item,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.article,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID: \${item.id}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
''';
    File('lib/features/$feature/ui/widgets/${feature}_card.dart').writeAsStringSync(widgetContent);
  }

  print('✅ Feature "$feature" created successfully!');

  // Inject route name only (the path constant)
  injectRouteName(feature);

  // Only inject route if sample page was created (for the home feature)
  if (withSample) {
    injectRoute(feature, featureClass);
    print('   📄 Sample files included: page, cubit, widgets');
  }

  print('');
  print('Next steps:');
  print('  • Update repository implementation');
  print('  • Create BLoC/Cubit: dart generator.dart bloc $feature ${feature}_name');
  print('  • Create Page: dart generator.dart page $feature $feature');
  print('  • Check lib/routes/app_router.dart for the new route');
}