import 'package:ai_ui_studio/ai/ports/ai_provider_port.dart';
import 'package:ai_ui_studio/ai/providers/anthropic_adapter.dart';
import 'package:ai_ui_studio/ai/providers/openai_compatible_adapter.dart';
import 'package:ai_ui_studio/domain/entities/ai_provider_config.dart';

class ProviderRegistry {
  ProviderRegistry({
    required OpenAiCompatibleAdapter openAiCompatibleAdapter,
    required AnthropicAdapter anthropicAdapter,
  }) : _adapters = {
          AiProviderType.openaiCompatible: openAiCompatibleAdapter,
          AiProviderType.anthropic: anthropicAdapter,
        };

  final Map<AiProviderType, AiProviderPort> _adapters;

  List<AiProviderPort> get all => _adapters.values.toList(growable: false);

  AiProviderPort resolve(AiProviderType type) {
    final adapter = _adapters[type];
    if (adapter == null) {
      throw StateError('No adapter registered for $type');
    }
    return adapter;
  }

  AiProviderPort? resolveById(String adapterId) {
    for (final adapter in _adapters.values) {
      if (adapter.id == adapterId) return adapter;
    }
    return null;
  }
}
