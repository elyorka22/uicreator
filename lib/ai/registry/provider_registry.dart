import 'package:ai_ui_studio/ai/ports/ai_provider_port.dart';
import 'package:ai_ui_studio/ai/provider_presets.dart';
import 'package:ai_ui_studio/ai/providers/anthropic_adapter.dart';
import 'package:ai_ui_studio/ai/providers/gemini_adapter.dart';
import 'package:ai_ui_studio/ai/providers/openai_compatible_adapter.dart';
import 'package:ai_ui_studio/domain/entities/ai_provider_config.dart';

class ProviderRegistry {
  ProviderRegistry({
    required OpenAiCompatibleAdapter openAiCompatibleAdapter,
    required AnthropicAdapter anthropicAdapter,
    required GeminiAdapter geminiAdapter,
  })  : _openAi = openAiCompatibleAdapter,
        _anthropic = anthropicAdapter,
        _gemini = geminiAdapter;

  final OpenAiCompatibleAdapter _openAi;
  final AnthropicAdapter _anthropic;
  final GeminiAdapter _gemini;

  AiProviderPort resolve(AiProviderType type) {
    switch (ProviderPresets.byType(type).family) {
      case AiAdapterFamily.openaiCompatible:
        return _openAi;
      case AiAdapterFamily.anthropic:
        return _anthropic;
      case AiAdapterFamily.gemini:
        return _gemini;
    }
  }

  AiProviderPort? resolveById(String adapterId) {
    switch (adapterId) {
      case 'openai_compatible':
        return _openAi;
      case 'anthropic':
        return _anthropic;
      case 'gemini':
        return _gemini;
      default:
        return null;
    }
  }

  List<AiProviderPort> get all => [_openAi, _anthropic, _gemini];
}
