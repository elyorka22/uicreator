import 'package:ai_ui_studio/ai/agent/prompt_builder.dart';
import 'package:ai_ui_studio/domain/entities/ui_component.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('visual system prompt prioritizes HTML preview artifact', () {
    final prompt = PromptBuilder.visualSystemPrompt();
    expect(prompt, contains('preview/index.html'));
    expect(prompt, contains('platform": "visual"'));
    expect(prompt, contains('micro-interactions'));
  });

  test('visual user prompt does not lock export platform', () {
    final prompt = PromptBuilder.visualUserPrompt(
      description: 'notification bell',
    );
    expect(prompt, contains('Platform will be chosen later'));
    expect(prompt, contains('HTML preview'));
    expect(prompt, contains('Avoid toy demo layouts'));
  });

  test('export convert prompt targets flutter', () {
    final prompt = PromptBuilder.exportConvertUserPrompt(
      target: TargetPlatformKind.flutter,
      componentName: 'Bell',
      currentSourceFiles: const [
        SourceFile(path: 'preview/index.html', content: '<button>x</button>'),
      ],
    );
    expect(prompt, contains('EXPORT as flutter'));
    expect(prompt, contains('preview/index.html'));
  });
}
