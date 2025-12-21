import 'dart:io';

import '../utils/utils.dart';


void createSharedWidget(String widgetName) {
  final widget = widgetName.toLowerCase();
  final widgetClass = toPascalCase(widget);

  final content = '''
import 'package:flutter/material.dart';

class $widgetClass extends StatelessWidget {
  const $widgetClass({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Placeholder(),
    );
  }
}
''';
  File('lib/shared/widgets/$widget.dart').writeAsStringSync(content);
  print('✅ Widget "$widgetClass" created in shared/widgets');
}