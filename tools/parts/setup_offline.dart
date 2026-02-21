import 'dart:io';

import '../utils/utils.dart';

void setupOffline(String featureName) {
  final feature = featureName.toLowerCase();
  final featureClass = toPascalCase(feature);

  print('🔄 Setting up Offline-First feature: "$feature"...');
  print('');

  // 1. Create AppDatabase if it doesn't exist
  _createAppDatabase(feature, featureClass);

  // 2. Create local datasource (Drift table + queries)
  _createLocalDatasource(feature, featureClass);

  // 3. Create domain model
  _createModel(feature, featureClass);

  // 4. Create remote datasource (Dio)
  _createRemoteDatasource(feature, featureClass);

  // 5. Create repository interface
  _createRepositoryInterface(feature, featureClass);

  // 6. Create repository implementation (offline-first)
  _createRepositoryImpl(feature, featureClass);

  // 7. Create BLoC (events, states, bloc)
  _createBloc(feature, featureClass);

  // 8. Create sample UI page
  _createPage(feature, featureClass);

  // 9. Patch DI
  _patchDI(feature, featureClass);

  // 10. Inject route
  injectRouteName(feature);

  print('');
  print('✅ Offline-first feature "$feature" created successfully!');
  print('');
  print('📋 Next steps:');
  print('  1. Install dependencies:');
  print('     flutter pub add drift drift_flutter connectivity_plus uuid path_provider path');
  print('     flutter pub add --dev drift_dev');
  print('  2. Generate Drift code:');
  print('     dart run build_runner build --delete-conflicting-outputs');
  print('  3. Update AppDatabase to include your table:');
  print('     Open lib/core/database/app_database.dart');
  print('     Add ${featureClass}Items to @DriftDatabase(tables: [...])');
  print('  4. flutter run');
}

// ─── 1. AppDatabase ──────────────────────────────────────────────────────────

void _createAppDatabase(String feature, String featureClass) {
  final dir = Directory('lib/core/database');
  dir.createSync(recursive: true);

  final file = File('lib/core/database/app_database.dart');
  if (file.existsSync()) {
    print('  ℹ️  Skipped: lib/core/database/app_database.dart (already exists)');
    return;
  }

  file.writeAsStringSync('''
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

// Import tables here
import '../../features/$feature/data/datasources/${feature}_local_datasource.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [${featureClass}Items])
class AppDatabase extends _\$AppDatabase {
  AppDatabase._() : super(_openConnection());

  static final AppDatabase instance = AppDatabase._();

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'app_database');
  }
}
''');

  print('  ✅ Created: lib/core/database/app_database.dart');
}

// ─── 2. Local Datasource (Drift Table) ───────────────────────────────────────

void _createLocalDatasource(String feature, String featureClass) {
  final dir = Directory('lib/features/$feature/data/datasources');
  dir.createSync(recursive: true);

  File('lib/features/$feature/data/datasources/${feature}_local_datasource.dart')
      .writeAsStringSync('''
import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';

// ─── Table Definition ────────────────────────────────────────────────────────

class ${featureClass}Items extends Table {
  TextColumn get id => text()();
  TextColumn get title => text().withLength(min: 1, max: 255)();
  TextColumn get description => text().withDefault(const Constant(''))();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// ─── DAO (Data Access Object) ────────────────────────────────────────────────

class ${featureClass}LocalDatasource {
  final AppDatabase _db;

  ${featureClass}LocalDatasource(this._db);

  // Watch all items as a stream (reactive)
  Stream<List<${featureClass}Item>> watchAll() {
    return (_db.select(_db.${_firstLower(featureClass)}Items)
          ..orderBy([
            (t) => OrderingTerm(
                  expression: t.updatedAt,
                  mode: OrderingMode.desc,
                ),
          ]))
        .watch();
  }

  // Get all unsynced items
  Future<List<${featureClass}Item>> getUnsynced() {
    return (_db.select(_db.${_firstLower(featureClass)}Items)
          ..where((t) => t.isSynced.equals(false)))
        .get();
  }

  // Upsert (insert or update)
  Future<void> upsert(${featureClass}ItemsCompanion entry) {
    return _db
        .into(_db.${_firstLower(featureClass)}Items)
        .insertOnConflictUpdate(entry);
  }

  // Mark as synced
  Future<void> markSynced(String id) {
    return (_db.update(_db.${_firstLower(featureClass)}Items)
          ..where((t) => t.id.equals(id)))
        .write(
      const ${featureClass}ItemsCompanion(
        isSynced: Value(true),
      ),
    );
  }

  // Delete
  Future<void> deleteItem(String id) {
    return (_db.delete(_db.${_firstLower(featureClass)}Items)
          ..where((t) => t.id.equals(id)))
        .go();
  }
}
''');

  print(
      '  ✅ Created: lib/features/$feature/data/datasources/${feature}_local_datasource.dart');
}

// ─── 3. Domain Model ─────────────────────────────────────────────────────────

void _createModel(String feature, String featureClass) {
  final dir = Directory('lib/features/$feature/data/models');
  dir.createSync(recursive: true);

  File('lib/features/$feature/data/models/${feature}_model.dart')
      .writeAsStringSync('''
import 'package:drift/drift.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/database/app_database.dart';

class ${featureClass}Model extends Equatable {
  final String id;
  final String title;
  final String description;
  final bool isSynced;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ${featureClass}Model({
    required this.id,
    required this.title,
    this.description = '',
    this.isSynced = false,
    required this.createdAt,
    required this.updatedAt,
  });

  ${featureClass}Model copyWith({
    String? id,
    String? title,
    String? description,
    bool? isSynced,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ${featureClass}Model(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isSynced: isSynced ?? this.isSynced,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ─── JSON Serialization ──────────────────────────────────────────────────

  factory ${featureClass}Model.fromJson(Map<String, dynamic> json) {
    return ${featureClass}Model(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      isSynced: true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // ─── Drift Mappers ───────────────────────────────────────────────────────

  /// Drift entity → Domain model
  factory ${featureClass}Model.fromDrift(${featureClass}Item item) {
    return ${featureClass}Model(
      id: item.id,
      title: item.title,
      description: item.description,
      isSynced: item.isSynced,
      createdAt: item.createdAt,
      updatedAt: item.updatedAt,
    );
  }

  /// Domain model → Drift Companion (for insert/update)
  ${featureClass}ItemsCompanion toDriftCompanion() {
    return ${featureClass}ItemsCompanion.insert(
      id: id,
      title: title,
      description: Value(description),
      isSynced: Value(isSynced),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  @override
  List<Object?> get props =>
      [id, title, description, isSynced, createdAt, updatedAt];
}
''');

  print('  ✅ Created: lib/features/$feature/data/models/${feature}_model.dart');
}

// ─── 4. Remote Datasource ────────────────────────────────────────────────────

void _createRemoteDatasource(String feature, String featureClass) {
  final dir = Directory('lib/features/$feature/data/datasources');
  dir.createSync(recursive: true);

  File('lib/features/$feature/data/datasources/${feature}_remote_datasource.dart')
      .writeAsStringSync('''
import '../../../../core/network/api_client.dart';
import '../models/${feature}_model.dart';

abstract class ${featureClass}RemoteDataSource {
  Future<List<${featureClass}Model>> fetchAll();
  Future<${featureClass}Model> create(${featureClass}Model item);
  Future<${featureClass}Model> update(${featureClass}Model item);
  Future<void> delete(String id);
}

class ${featureClass}RemoteDataSourceImpl implements ${featureClass}RemoteDataSource {
  final ApiClient apiClient;

  ${featureClass}RemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<${featureClass}Model>> fetchAll() async {
    // TODO: Replace with your actual API endpoint
    final response = await apiClient.get('/$feature');
    final List<dynamic> data = response.data as List<dynamic>;
    return data
        .map((json) =>
            ${featureClass}Model.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<${featureClass}Model> create(${featureClass}Model item) async {
    final response = await apiClient.post(
      '/$feature',
      data: item.toJson(),
    );
    return ${featureClass}Model.fromJson(
        response.data as Map<String, dynamic>);
  }

  @override
  Future<${featureClass}Model> update(${featureClass}Model item) async {
    final response = await apiClient.put(
      '/$feature/\${item.id}',
      data: item.toJson(),
    );
    return ${featureClass}Model.fromJson(
        response.data as Map<String, dynamic>);
  }

  @override
  Future<void> delete(String id) async {
    await apiClient.delete('/$feature/\$id');
  }
}
''');

  print(
      '  ✅ Created: lib/features/$feature/data/datasources/${feature}_remote_datasource.dart');
}

// ─── 5. Repository Interface ─────────────────────────────────────────────────

void _createRepositoryInterface(String feature, String featureClass) {
  final dir = Directory('lib/features/$feature/domain/repositories');
  dir.createSync(recursive: true);

  File('lib/features/$feature/domain/repositories/${feature}_repository.dart')
      .writeAsStringSync('''
import '../../data/models/${feature}_model.dart';

abstract class ${featureClass}Repository {
  /// Watch all items reactively from local DB
  Stream<List<${featureClass}Model>> watchAll();

  /// Add a new item (local first, then sync)
  Future<void> add(${featureClass}Model item);

  /// Update an item (local first, then sync)
  Future<void> update(${featureClass}Model item);

  /// Delete an item
  Future<void> delete(String id);

  /// Sync all pending changes to remote
  Future<void> syncPendingChanges();
}
''');

  print(
      '  ✅ Created: lib/features/$feature/domain/repositories/${feature}_repository.dart');
}

// ─── 6. Repository Implementation ────────────────────────────────────────────

void _createRepositoryImpl(String feature, String featureClass) {
  final dir = Directory('lib/features/$feature/data/repositories');
  dir.createSync(recursive: true);

  File('lib/features/$feature/data/repositories/${feature}_repository_impl.dart')
      .writeAsStringSync('''
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../domain/repositories/${feature}_repository.dart';
import '../datasources/${feature}_local_datasource.dart';
import '../datasources/${feature}_remote_datasource.dart';
import '../models/${feature}_model.dart';

class ${featureClass}RepositoryImpl implements ${featureClass}Repository {
  final ${featureClass}LocalDatasource localDatasource;
  final ${featureClass}RemoteDataSource remoteDatasource;
  final Connectivity connectivity;

  ${featureClass}RepositoryImpl({
    required this.localDatasource,
    required this.remoteDatasource,
    required this.connectivity,
  });

  Future<bool> get _isOnline async {
    final result = await connectivity.checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  @override
  Stream<List<${featureClass}Model>> watchAll() {
    return localDatasource.watchAll().map(
          (items) =>
              items.map((e) => ${featureClass}Model.fromDrift(e)).toList(),
        );
  }

  @override
  Future<void> add(${featureClass}Model item) async {
    // 1. Save to local DB first (isSynced: false)
    final localItem = item.copyWith(isSynced: false);
    await localDatasource.upsert(localItem.toDriftCompanion());

    // 2. Try to sync to remote if online
    if (await _isOnline) {
      try {
        await remoteDatasource.create(item);
        await localDatasource.markSynced(item.id);
      } catch (_) {
        // Failed to sync — will be retried later
      }
    }
  }

  @override
  Future<void> update(${featureClass}Model item) async {
    // 1. Update locally first
    final localItem = item.copyWith(
      isSynced: false,
      updatedAt: DateTime.now(),
    );
    await localDatasource.upsert(localItem.toDriftCompanion());

    // 2. Try to sync to remote if online
    if (await _isOnline) {
      try {
        await remoteDatasource.update(item);
        await localDatasource.markSynced(item.id);
      } catch (_) {
        // Failed to sync — will be retried later
      }
    }
  }

  @override
  Future<void> delete(String id) async {
    // 1. Delete locally
    await localDatasource.deleteItem(id);

    // 2. Try to delete from remote if online
    if (await _isOnline) {
      try {
        await remoteDatasource.delete(id);
      } catch (_) {
        // TODO: Queue delete for later sync
      }
    }
  }

  @override
  Future<void> syncPendingChanges() async {
    if (!await _isOnline) return;

    final unsyncedItems = await localDatasource.getUnsynced();
    for (final item in unsyncedItems) {
      try {
        final model = ${featureClass}Model.fromDrift(item);
        // Strategy: push to remote, server wins on conflict
        await remoteDatasource.update(model);
        await localDatasource.markSynced(item.id);
      } catch (_) {
        // Skip failed items, retry on next sync
        continue;
      }
    }
  }
}
''');

  print(
      '  ✅ Created: lib/features/$feature/data/repositories/${feature}_repository_impl.dart');
}

// ─── 7. BLoC ─────────────────────────────────────────────────────────────────

void _createBloc(String feature, String featureClass) {
  final dir = Directory('lib/features/$feature/bloc');
  dir.createSync(recursive: true);

  // Events
  File('lib/features/$feature/bloc/${feature}_event.dart').writeAsStringSync('''
import 'package:equatable/equatable.dart';
import '../data/models/${feature}_model.dart';

abstract class ${featureClass}Event extends Equatable {
  const ${featureClass}Event();

  @override
  List<Object?> get props => [];
}

/// Initialize: subscribe to DB stream + connectivity
class ${featureClass}Started extends ${featureClass}Event {
  const ${featureClass}Started();
}

/// User adds a new item
class ${featureClass}Added extends ${featureClass}Event {
  final ${featureClass}Model item;
  const ${featureClass}Added(this.item);

  @override
  List<Object?> get props => [item];
}

/// User updates an item
class ${featureClass}Updated extends ${featureClass}Event {
  final ${featureClass}Model item;
  const ${featureClass}Updated(this.item);

  @override
  List<Object?> get props => [item];
}

/// User deletes an item
class ${featureClass}Deleted extends ${featureClass}Event {
  final String id;
  const ${featureClass}Deleted(this.id);

  @override
  List<Object?> get props => [id];
}

/// Trigger sync (manual or auto on reconnect)
class ${featureClass}SyncRequested extends ${featureClass}Event {
  const ${featureClass}SyncRequested();
}
''');

  // States
  File('lib/features/$feature/bloc/${feature}_state.dart').writeAsStringSync('''
import 'package:equatable/equatable.dart';
import '../data/models/${feature}_model.dart';

abstract class ${featureClass}State extends Equatable {
  const ${featureClass}State();

  @override
  List<Object?> get props => [];
}

class ${featureClass}Initial extends ${featureClass}State {
  const ${featureClass}Initial();
}

class ${featureClass}Loading extends ${featureClass}State {
  const ${featureClass}Loading();
}

class ${featureClass}Loaded extends ${featureClass}State {
  final List<${featureClass}Model> items;
  final bool isSyncing;
  final bool hasPendingSync;

  const ${featureClass}Loaded({
    required this.items,
    this.isSyncing = false,
    this.hasPendingSync = false,
  });

  ${featureClass}Loaded copyWith({
    List<${featureClass}Model>? items,
    bool? isSyncing,
    bool? hasPendingSync,
  }) {
    return ${featureClass}Loaded(
      items: items ?? this.items,
      isSyncing: isSyncing ?? this.isSyncing,
      hasPendingSync: hasPendingSync ?? this.hasPendingSync,
    );
  }

  @override
  List<Object?> get props => [items, isSyncing, hasPendingSync];
}

class ${featureClass}Error extends ${featureClass}State {
  final String message;
  const ${featureClass}Error(this.message);

  @override
  List<Object?> get props => [message];
}
''');

  // BLoC
  File('lib/features/$feature/bloc/${feature}_bloc.dart').writeAsStringSync('''
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../domain/repositories/${feature}_repository.dart';
import '../data/models/${feature}_model.dart';
import '${feature}_event.dart';
import '${feature}_state.dart';

/// Internal event: Drift stream emitted new data
class _${featureClass}DataChanged extends ${featureClass}Event {
  final List<${featureClass}Model> items;
  const _${featureClass}DataChanged(this.items);

  @override
  List<Object?> get props => [items];
}

class ${featureClass}Bloc extends Bloc<${featureClass}Event, ${featureClass}State> {
  final ${featureClass}Repository repository;
  final Connectivity connectivity;

  StreamSubscription<List<${featureClass}Model>>? _dataSubscription;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  ${featureClass}Bloc({
    required this.repository,
    required this.connectivity,
  }) : super(const ${featureClass}Initial()) {
    on<${featureClass}Started>(_onStarted);
    on<${featureClass}Added>(_onAdded);
    on<${featureClass}Updated>(_onUpdated);
    on<${featureClass}Deleted>(_onDeleted);
    on<${featureClass}SyncRequested>(_onSyncRequested);
    on<_${featureClass}DataChanged>(_onDataChanged);
  }

  Future<void> _onStarted(
    ${featureClass}Started event,
    Emitter<${featureClass}State> emit,
  ) async {
    emit(const ${featureClass}Loading());

    // Subscribe to Drift stream
    _dataSubscription = repository.watchAll().listen(
      (items) => add(_${featureClass}DataChanged(items)),
    );

    // Subscribe to connectivity changes
    _connectivitySubscription = connectivity.onConnectivityChanged.listen(
      (results) {
        if (!results.contains(ConnectivityResult.none)) {
          // Back online → auto sync
          add(const ${featureClass}SyncRequested());
        }
      },
    );
  }

  void _onDataChanged(
    _${featureClass}DataChanged event,
    Emitter<${featureClass}State> emit,
  ) {
    final hasPending = event.items.any((item) => !item.isSynced);
    final currentState = state;

    emit(${featureClass}Loaded(
      items: event.items,
      isSyncing: currentState is ${featureClass}Loaded
          ? currentState.isSyncing
          : false,
      hasPendingSync: hasPending,
    ));
  }

  Future<void> _onAdded(
    ${featureClass}Added event,
    Emitter<${featureClass}State> emit,
  ) async {
    try {
      await repository.add(event.item);
      // No need to emit — Drift stream will update automatically
    } catch (e) {
      emit(${featureClass}Error(e.toString()));
    }
  }

  Future<void> _onUpdated(
    ${featureClass}Updated event,
    Emitter<${featureClass}State> emit,
  ) async {
    try {
      await repository.update(event.item);
    } catch (e) {
      emit(${featureClass}Error(e.toString()));
    }
  }

  Future<void> _onDeleted(
    ${featureClass}Deleted event,
    Emitter<${featureClass}State> emit,
  ) async {
    try {
      await repository.delete(event.id);
    } catch (e) {
      emit(${featureClass}Error(e.toString()));
    }
  }

  Future<void> _onSyncRequested(
    ${featureClass}SyncRequested event,
    Emitter<${featureClass}State> emit,
  ) async {
    final currentState = state;
    if (currentState is ${featureClass}Loaded) {
      emit(currentState.copyWith(isSyncing: true));
    }

    try {
      await repository.syncPendingChanges();
    } catch (_) {
      // Sync failed silently — will retry
    }

    final afterState = state;
    if (afterState is ${featureClass}Loaded) {
      emit(afterState.copyWith(isSyncing: false));
    }
  }

  @override
  Future<void> close() {
    _dataSubscription?.cancel();
    _connectivitySubscription?.cancel();
    return super.close();
  }
}
''');

  print('  ✅ Created: lib/features/$feature/bloc/${feature}_event.dart');
  print('  ✅ Created: lib/features/$feature/bloc/${feature}_state.dart');
  print('  ✅ Created: lib/features/$feature/bloc/${feature}_bloc.dart');
}

// ─── 8. UI Page ──────────────────────────────────────────────────────────────

void _createPage(String feature, String featureClass) {
  final dir = Directory('lib/features/$feature/ui/pages');
  dir.createSync(recursive: true);

  File('lib/features/$feature/ui/pages/${feature}_page.dart')
      .writeAsStringSync('''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../bloc/${feature}_bloc.dart';
import '../../bloc/${feature}_event.dart';
import '../../bloc/${feature}_state.dart';
import '../../data/models/${feature}_model.dart';

class ${featureClass}Page extends StatelessWidget {
  const ${featureClass}Page({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => context.read<${featureClass}Bloc>()
        ..add(const ${featureClass}Started()),
      child: const _${featureClass}View(),
    );
  }
}

class _${featureClass}View extends StatelessWidget {
  const _${featureClass}View();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('$featureClass'),
        actions: [
          // Sync button
          BlocBuilder<${featureClass}Bloc, ${featureClass}State>(
            builder: (context, state) {
              if (state is ${featureClass}Loaded && state.isSyncing) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }
              return IconButton(
                icon: const Icon(Icons.sync),
                onPressed: () => context
                    .read<${featureClass}Bloc>()
                    .add(const ${featureClass}SyncRequested()),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<${featureClass}Bloc, ${featureClass}State>(
        builder: (context, state) {
          if (state is ${featureClass}Loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ${featureClass}Error) {
            return Center(child: Text('Error: \${state.message}'));
          }

          if (state is ${featureClass}Loaded) {
            return Column(
              children: [
                // Pending sync banner
                if (state.hasPendingSync)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    color: Colors.orange.shade100,
                    child: Row(
                      children: [
                        Icon(Icons.cloud_off,
                            size: 16, color: Colors.orange.shade800),
                        const SizedBox(width: 8),
                        Text(
                          'Pending sync',
                          style: TextStyle(color: Colors.orange.shade800),
                        ),
                      ],
                    ),
                  ),
                // Item list
                Expanded(
                  child: state.items.isEmpty
                      ? const Center(child: Text('No items yet'))
                      : ListView.builder(
                          itemCount: state.items.length,
                          itemBuilder: (context, index) {
                            final item = state.items[index];
                            return ListTile(
                              title: Text(item.title),
                              subtitle: Text(item.description),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Sync status icon
                                  Icon(
                                    item.isSynced
                                        ? Icons.cloud_done
                                        : Icons.cloud_upload_outlined,
                                    size: 18,
                                    color: item.isSynced
                                        ? Colors.green
                                        : Colors.orange,
                                  ),
                                  const SizedBox(width: 8),
                                  // Delete button
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline),
                                    onPressed: () => context
                                        .read<${featureClass}Bloc>()
                                        .add(${featureClass}Deleted(item.id)),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                final now = DateTime.now();
                context.read<${featureClass}Bloc>().add(
                      ${featureClass}Added(
                        ${featureClass}Model(
                          id: const Uuid().v4(),
                          title: titleController.text,
                          description: descController.text,
                          createdAt: now,
                          updatedAt: now,
                        ),
                      ),
                    );
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
''');

  print('  ✅ Created: lib/features/$feature/ui/pages/${feature}_page.dart');
}

// ─── 9. Patch DI ─────────────────────────────────────────────────────────────

void _patchDI(String feature, String featureClass) {
  final diFile = File('lib/core/di/service_locator.dart');
  if (!diFile.existsSync()) {
    print('  ⚠️  Skipped DI patch: lib/core/di/service_locator.dart not found');
    return;
  }

  var content = diFile.readAsStringSync();

  // Skip if already registered
  if (content.contains('${featureClass}Bloc')) return;

  // Add imports
  final imports = '''
import '../../features/$feature/data/datasources/${feature}_local_datasource.dart';
import '../../features/$feature/data/datasources/${feature}_remote_datasource.dart';
import '../../features/$feature/data/repositories/${feature}_repository_impl.dart';
import '../../features/$feature/domain/repositories/${feature}_repository.dart';
import '../../features/$feature/bloc/${feature}_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../database/app_database.dart';
''';

  content = content.replaceFirst(
    "import 'package:get_it/get_it.dart';",
    "import 'package:get_it/get_it.dart';\n$imports",
  );

  // Add registrations
  final registrations = '''

  // ─── Offline-First: $featureClass ────────────────────────────────────────
  // Database
  if (!sl.isRegistered<AppDatabase>()) {
    sl.registerLazySingleton<AppDatabase>(() => AppDatabase.instance);
  }

  // Connectivity
  if (!sl.isRegistered<Connectivity>()) {
    sl.registerLazySingleton<Connectivity>(() => Connectivity());
  }

  // Local Datasource
  sl.registerLazySingleton<${featureClass}LocalDatasource>(
    () => ${featureClass}LocalDatasource(sl()),
  );

  // Remote Datasource
  sl.registerLazySingleton<${featureClass}RemoteDataSource>(
    () => ${featureClass}RemoteDataSourceImpl(sl()),
  );

  // Repository
  sl.registerLazySingleton<${featureClass}Repository>(
    () => ${featureClass}RepositoryImpl(
      localDatasource: sl(),
      remoteDatasource: sl(),
      connectivity: sl(),
    ),
  );

  // BLoC
  sl.registerFactory<${featureClass}Bloc>(
    () => ${featureClass}Bloc(
      repository: sl(),
      connectivity: sl(),
    ),
  );
''';

  // Insert before the closing of setupServiceLocator
  content = content.replaceFirst(
    RegExp(r'(\n}\s*)$'),
    '$registrations\n}\n',
  );

  diFile.writeAsStringSync(content);
  print('  ✅ Patched: lib/core/di/service_locator.dart ($featureClass registered)');
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

String _firstLower(String s) => s[0].toLowerCase() + s.substring(1);
