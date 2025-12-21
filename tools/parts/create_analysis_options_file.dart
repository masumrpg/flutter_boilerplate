import 'dart:io';

void createAnalysisOptionsFile() {
  final content = '''
include: package:very_good_analysis/analysis_options.yaml

linter:
  rules:
    public_member_api_docs: false
    lines_longer_than_80_chars: false
''';
  File('analysis_options.yaml').writeAsStringSync(content);
  print('✅ Created: analysis_options.yaml');
}