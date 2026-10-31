import 'package:ai_ui_studio/ai/agent/prompt_builder.dart';
import 'package:ai_ui_studio/domain/entities/ui_component.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('refine prompt includes current schema/source and change request', () {
    final prompt = PromptBuilder.refineUserPrompt(
      changeRequest: 'Make the badge red and larger',
      platform: TargetPlatformKind.flutter,
      componentName: 'NotificationBell',
      originalPrompt: 'notification bell with unread count',
      currentSchemaJson: '{"\$schemaVersion":"1.0","root":{"type":"icon"}}',
      currentSourceFiles: const [
        SourceFile(path: 'notification_bell.dart', content: 'class NotificationBell {}'),
      ],
    );

    expect(prompt, contains('REFINE'));
    expect(prompt, contains('Make the badge red and larger'));
    expect(prompt, contains('notification_bell.dart'));
    expect(prompt, contains('Current schema JSON'));
    expect(prompt, contains('Do not start from scratch'));
  });
}
