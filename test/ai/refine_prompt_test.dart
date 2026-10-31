import 'package:ai_ui_studio/ai/agent/prompt_builder.dart';
import 'package:ai_ui_studio/domain/entities/ui_component.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('refine prompt updates HTML preview first', () {
    final prompt = PromptBuilder.refineUserPrompt(
      changeRequest: 'Make the badge red and larger',
      platform: TargetPlatformKind.visual,
      componentName: 'NotificationBell',
      originalPrompt: 'notification bell with unread count',
      currentSchemaJson: '{"\$schemaVersion":"1.0","root":{"type":"icon"}}',
      currentSourceFiles: const [
        SourceFile(
          path: 'preview/index.html',
          content: '<button class="bell">3</button>',
        ),
      ],
    );

    expect(prompt, contains('REFINE'));
    expect(prompt, contains('Make the badge red and larger'));
    expect(prompt, contains('preview/index.html'));
    expect(prompt, contains('Update HTML preview'));
    expect(prompt, contains('Do not start from scratch'));
  });
}
