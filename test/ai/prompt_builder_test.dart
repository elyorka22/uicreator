import 'package:ai_ui_studio/ai/agent/prompt_builder.dart';
import 'package:ai_ui_studio/domain/entities/ui_component.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('flutter system prompt demands production quality and stack badges', () {
    final prompt = PromptBuilder.systemPrompt(TargetPlatformKind.flutter);
    expect(prompt, contains('PRODUCTION-QUALITY'));
    expect(prompt, contains('positioned'));
    expect(prompt, contains('notifications'));
    expect(prompt.toLowerCase(), isNot(contains('prefer nested layouts with row/column/card only')));
    expect(prompt, contains('StatefulWidget'));
  });

  test('user prompt rejects toy demo layouts', () {
    final prompt = PromptBuilder.userPrompt(
      description: 'notification bell',
      platform: TargetPlatformKind.flutter,
    );
    expect(prompt, contains('production-quality'));
    expect(prompt, contains('Avoid toy demo layouts'));
  });
}
