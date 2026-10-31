import 'package:ai_ui_studio/ai/provider_presets.dart';
import 'package:ai_ui_studio/domain/entities/ai_provider_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('includes DeepSeek and maps it to OpenAI-compatible family', () {
    final deepseek = ProviderPresets.byType(AiProviderType.deepseek);
    expect(deepseek.label, 'DeepSeek');
    expect(deepseek.baseUrl, contains('deepseek.com'));
    expect(deepseek.family, AiAdapterFamily.openaiCompatible);
    expect(deepseek.models.any((m) => m.id == 'deepseek-chat'), isTrue);
  });

  test('covers major provider presets', () {
    final types = ProviderPresets.all.map((p) => p.type).toSet();
    expect(types, containsAll([
      AiProviderType.openai,
      AiProviderType.deepseek,
      AiProviderType.groq,
      AiProviderType.openRouter,
      AiProviderType.mistral,
      AiProviderType.together,
      AiProviderType.openaiCompatible,
      AiProviderType.anthropic,
      AiProviderType.gemini,
    ]));
  });
}
