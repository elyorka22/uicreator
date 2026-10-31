import 'package:ai_ui_studio/ai/ports/ai_models.dart';
import 'package:ai_ui_studio/domain/entities/ai_provider_config.dart';

/// Which HTTP adapter implementation a provider uses under the hood.
enum AiAdapterFamily {
  openaiCompatible,
  anthropic,
  gemini,
}

class ProviderPreset {
  const ProviderPreset({
    required this.type,
    required this.label,
    required this.defaultDisplayName,
    required this.baseUrl,
    required this.defaultModel,
    required this.models,
    required this.family,
    this.helpText,
  });

  final AiProviderType type;
  final String label;
  final String defaultDisplayName;
  final String baseUrl;
  final String defaultModel;
  final List<AiModelInfo> models;
  final AiAdapterFamily family;
  final String? helpText;
}

class ProviderPresets {
  static const List<ProviderPreset> all = [
    ProviderPreset(
      type: AiProviderType.openai,
      label: 'OpenAI',
      defaultDisplayName: 'OpenAI',
      baseUrl: 'https://api.openai.com/v1',
      defaultModel: 'gpt-4o-mini',
      family: AiAdapterFamily.openaiCompatible,
      models: [
        AiModelInfo(id: 'gpt-4o-mini', displayName: 'GPT-4o mini'),
        AiModelInfo(id: 'gpt-4o', displayName: 'GPT-4o'),
        AiModelInfo(id: 'gpt-4.1-mini', displayName: 'GPT-4.1 mini'),
        AiModelInfo(id: 'gpt-4.1', displayName: 'GPT-4.1'),
      ],
    ),
    ProviderPreset(
      type: AiProviderType.deepseek,
      label: 'DeepSeek',
      defaultDisplayName: 'DeepSeek',
      baseUrl: 'https://api.deepseek.com/v1',
      defaultModel: 'deepseek-chat',
      family: AiAdapterFamily.openaiCompatible,
      helpText: 'OpenAI-compatible API. Get a key at platform.deepseek.com',
      models: [
        AiModelInfo(id: 'deepseek-chat', displayName: 'DeepSeek Chat'),
        AiModelInfo(id: 'deepseek-reasoner', displayName: 'DeepSeek Reasoner'),
      ],
    ),
    ProviderPreset(
      type: AiProviderType.groq,
      label: 'Groq',
      defaultDisplayName: 'Groq',
      baseUrl: 'https://api.groq.com/openai/v1',
      defaultModel: 'llama-3.3-70b-versatile',
      family: AiAdapterFamily.openaiCompatible,
      models: [
        AiModelInfo(
          id: 'llama-3.3-70b-versatile',
          displayName: 'Llama 3.3 70B',
        ),
        AiModelInfo(id: 'llama-3.1-8b-instant', displayName: 'Llama 3.1 8B'),
        AiModelInfo(id: 'mixtral-8x7b-32768', displayName: 'Mixtral 8x7B'),
      ],
    ),
    ProviderPreset(
      type: AiProviderType.openRouter,
      label: 'OpenRouter',
      defaultDisplayName: 'OpenRouter',
      baseUrl: 'https://openrouter.ai/api/v1',
      defaultModel: 'deepseek/deepseek-chat',
      family: AiAdapterFamily.openaiCompatible,
      helpText: 'One key for many models (DeepSeek, Claude, Gemini, etc.)',
      models: [
        AiModelInfo(
          id: 'deepseek/deepseek-chat',
          displayName: 'DeepSeek Chat',
        ),
        AiModelInfo(
          id: 'openai/gpt-4o-mini',
          displayName: 'GPT-4o mini',
        ),
        AiModelInfo(
          id: 'anthropic/claude-3.5-sonnet',
          displayName: 'Claude 3.5 Sonnet',
        ),
        AiModelInfo(
          id: 'google/gemini-2.0-flash-001',
          displayName: 'Gemini 2.0 Flash',
        ),
      ],
    ),
    ProviderPreset(
      type: AiProviderType.mistral,
      label: 'Mistral',
      defaultDisplayName: 'Mistral',
      baseUrl: 'https://api.mistral.ai/v1',
      defaultModel: 'mistral-small-latest',
      family: AiAdapterFamily.openaiCompatible,
      models: [
        AiModelInfo(
          id: 'mistral-small-latest',
          displayName: 'Mistral Small',
        ),
        AiModelInfo(
          id: 'mistral-large-latest',
          displayName: 'Mistral Large',
        ),
        AiModelInfo(id: 'codestral-latest', displayName: 'Codestral'),
      ],
    ),
    ProviderPreset(
      type: AiProviderType.together,
      label: 'Together AI',
      defaultDisplayName: 'Together AI',
      baseUrl: 'https://api.together.xyz/v1',
      defaultModel: 'meta-llama/Meta-Llama-3.1-70B-Instruct-Turbo',
      family: AiAdapterFamily.openaiCompatible,
      models: [
        AiModelInfo(
          id: 'meta-llama/Meta-Llama-3.1-70B-Instruct-Turbo',
          displayName: 'Llama 3.1 70B Turbo',
        ),
        AiModelInfo(
          id: 'meta-llama/Meta-Llama-3.1-8B-Instruct-Turbo',
          displayName: 'Llama 3.1 8B Turbo',
        ),
      ],
    ),
    ProviderPreset(
      type: AiProviderType.openaiCompatible,
      label: 'Custom OpenAI-compatible',
      defaultDisplayName: 'Custom API',
      baseUrl: 'https://api.openai.com/v1',
      defaultModel: 'gpt-4o-mini',
      family: AiAdapterFamily.openaiCompatible,
      helpText: 'Any gateway with /chat/completions (LM Studio, vLLM, etc.)',
      models: [
        AiModelInfo(id: 'gpt-4o-mini', displayName: 'gpt-4o-mini'),
        AiModelInfo(id: 'local-model', displayName: 'local-model'),
      ],
    ),
    ProviderPreset(
      type: AiProviderType.anthropic,
      label: 'Anthropic Claude',
      defaultDisplayName: 'Anthropic',
      baseUrl: 'https://api.anthropic.com',
      defaultModel: 'claude-3-5-haiku-latest',
      family: AiAdapterFamily.anthropic,
      models: [
        AiModelInfo(
          id: 'claude-3-5-haiku-latest',
          displayName: 'Claude 3.5 Haiku',
        ),
        AiModelInfo(
          id: 'claude-3-5-sonnet-latest',
          displayName: 'Claude 3.5 Sonnet',
        ),
        AiModelInfo(id: 'claude-sonnet-4-0', displayName: 'Claude Sonnet 4'),
      ],
    ),
    ProviderPreset(
      type: AiProviderType.gemini,
      label: 'Google Gemini',
      defaultDisplayName: 'Google Gemini',
      baseUrl: 'https://generativelanguage.googleapis.com/v1beta',
      defaultModel: 'gemini-2.0-flash',
      family: AiAdapterFamily.gemini,
      helpText: 'Uses Google AI Studio API keys',
      models: [
        AiModelInfo(id: 'gemini-2.0-flash', displayName: 'Gemini 2.0 Flash'),
        AiModelInfo(id: 'gemini-1.5-flash', displayName: 'Gemini 1.5 Flash'),
        AiModelInfo(id: 'gemini-1.5-pro', displayName: 'Gemini 1.5 Pro'),
      ],
    ),
  ];

  static ProviderPreset byType(AiProviderType type) {
    return all.firstWhere(
      (p) => p.type == type,
      orElse: () => all.firstWhere(
        (p) => p.type == AiProviderType.openaiCompatible,
      ),
    );
  }

  static String labelFor(AiProviderType type) => byType(type).label;
}
