import 'dart:io';

import '../utils/utils.dart';


void createCubit(String featureName, String cubitName, {bool withSample = false}) {
  final feature = featureName.toLowerCase();
  final cubit = cubitName.toLowerCase();
  final cubitClass = toPascalCase(cubit);

  if (!Directory('lib/features/$feature').existsSync()) {
    print('❌ Feature "$feature" does not exist. Create it first with:');
    print('   dart generator.dart feature $feature');
    exit(1);
  }

  Directory('lib/features/$feature/cubit').createSync(recursive: true);

  if (withSample) {
    // Cubit with sample logic
    final cubitContent = '''
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../domain/entities/${feature}_entity.dart';

part '${cubit}_state.dart';

class ${cubitClass}Cubit extends Cubit<${cubitClass}State> {
  ${cubitClass}Cubit() : super(${cubitClass}Initial());

  Future<void> loadItems() async {
    emit(${cubitClass}Loading());

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Sample data
      final items = List.generate(
        10,
        (index) => ${toPascalCase(feature)}Entity(
          id: 'item_\$index',
          name: 'Sample Item \$index',
        ),
      );

      emit(${cubitClass}Loaded(items));
    } catch (e) {
      emit(${cubitClass}Error('Failed to load items: \$e'));
    }
  }

  void refresh() => loadItems();
}
''';
    File('lib/features/$feature/cubit/${cubit}_cubit.dart').writeAsStringSync(cubitContent);

    // State with sample
    final stateContent = '''
part of '${cubit}_cubit.dart';

abstract class ${cubitClass}State extends Equatable {
  const ${cubitClass}State();

  @override
  List<Object> get props => [];
}

class ${cubitClass}Initial extends ${cubitClass}State {}

class ${cubitClass}Loading extends ${cubitClass}State {}

class ${cubitClass}Loaded extends ${cubitClass}State {
  final List<${toPascalCase(feature)}Entity> items;

  const ${cubitClass}Loaded(this.items);

  @override
  List<Object> get props => [items];
}

class ${cubitClass}Error extends ${cubitClass}State {
  final String message;

  const ${cubitClass}Error(this.message);

  @override
  List<Object> get props => [message];
}
''';
    File('lib/features/$feature/cubit/${cubit}_state.dart').writeAsStringSync(stateContent);
  } else {
    // Basic cubit template
    final cubitContent = '''
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part '${cubit}_state.dart';

class ${cubitClass}Cubit extends Cubit<${cubitClass}State> {
  ${cubitClass}Cubit() : super(${cubitClass}Initial());

  void doSomething() {
    emit(${cubitClass}Loading());
    // Your logic here
    emit(${cubitClass}Success());
  }
}
''';
    File('lib/features/$feature/cubit/${cubit}_cubit.dart').writeAsStringSync(cubitContent);

    final stateContent = '''
part of '${cubit}_cubit.dart';

abstract class ${cubitClass}State extends Equatable {
  const ${cubitClass}State();

  @override
  List<Object> get props => [];
}

class ${cubitClass}Initial extends ${cubitClass}State {}

class ${cubitClass}Loading extends ${cubitClass}State {}

class ${cubitClass}Success extends ${cubitClass}State {}

class ${cubitClass}Error extends ${cubitClass}State {
  final String message;
  const ${cubitClass}Error(this.message);

  @override
  List<Object> get props => [message];
}
''';
    File('lib/features/$feature/cubit/${cubit}_state.dart').writeAsStringSync(stateContent);
  }

  print('✅ Cubit "$cubit" created in feature "$feature"');
}