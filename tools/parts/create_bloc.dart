import 'dart:io';

import '../utils/utils.dart';


void createBloc(String featureName, String blocName) {
  final feature = featureName.toLowerCase();
  final bloc = blocName.toLowerCase();
  final blocClass = toPascalCase(bloc);

  if (!Directory('lib/features/$feature').existsSync()) {
    print('❌ Feature "$feature" does not exist. Create it first with:');
    print('   dart generator.dart feature $feature');
    exit(1);
  }

  Directory('lib/features/$feature/bloc').createSync(recursive: true);

  final blocContent = '''
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part '${bloc}_event.dart';
part '${bloc}_state.dart';

class ${blocClass}Bloc extends Bloc<${blocClass}Event, ${blocClass}State> {
  ${blocClass}Bloc() : super(${blocClass}Initial()) {
    on<${blocClass}Started>(_onStarted);
    on<${blocClass}DataRequested>(_onDataRequested);
  }

  Future<void> _onStarted(
    ${blocClass}Started event,
    Emitter<${blocClass}State> emit,
  ) async {
    emit(${blocClass}Loading());
    // Your initialization logic here
    emit(${blocClass}Success());
  }

  Future<void> _onDataRequested(
    ${blocClass}DataRequested event,
    Emitter<${blocClass}State> emit,
  ) async {
    emit(${blocClass}Loading());
    try {
      // Your data fetching logic here
      emit(${blocClass}Success());
    } catch (e) {
      emit(${blocClass}Error(e.toString()));
    }
  }
}
''';
  File('lib/features/$feature/bloc/${bloc}_bloc.dart').writeAsStringSync(blocContent);

  final eventContent = '''
part of '${bloc}_bloc.dart';

abstract class ${blocClass}Event extends Equatable {
  const ${blocClass}Event();

  @override
  List<Object> get props => [];
}

class ${blocClass}Started extends ${blocClass}Event {}

class ${blocClass}DataRequested extends ${blocClass}Event {}

// Add more events as needed
''';
  File('lib/features/$feature/bloc/${bloc}_event.dart').writeAsStringSync(eventContent);

  final stateContent = '''
part of '${bloc}_bloc.dart';

abstract class ${blocClass}State extends Equatable {
  const ${blocClass}State();

  @override
  List<Object> get props => [];
}

class ${blocClass}Initial extends ${blocClass}State {}

class ${blocClass}Loading extends ${blocClass}State {}

class ${blocClass}Success extends ${blocClass}State {}

class ${blocClass}Error extends ${blocClass}State {
  final String message;
  const ${blocClass}Error(this.message);

  @override
  List<Object> get props => [message];
}
''';
  File('lib/features/$feature/bloc/${bloc}_state.dart').writeAsStringSync(stateContent);

  print('✅ BLoC "$bloc" created in feature "$feature"');
}