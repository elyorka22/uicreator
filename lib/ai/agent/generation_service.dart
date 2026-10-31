import 'package:ai_ui_studio/ai/agent/prompt_builder.dart';
import 'package:ai_ui_studio/ai/agent/response_parser.dart';
import 'package:ai_ui_studio/ai/ports/ai_models.dart';
import 'package:ai_ui_studio/ai/ports/ai_provider_port.dart';
import 'package:ai_ui_studio/ai/registry/provider_registry.dart';
import 'package:ai_ui_studio/core/errors/failures.dart';
import 'package:ai_ui_studio/core/logging/redacting_logger.dart';
import 'package:ai_ui_studio/domain/entities/ai_provider_config.dart';
import 'package:ai_ui_studio/domain/entities/ui_component.dart';
import 'package:ai_ui_studio/domain/repositories/provider_config_repository.dart';
import 'package:dio/dio.dart';

class GenerationProgress {
  const GenerationProgress({
    required this.partialText,
    this.done = false,
    this.envelope,
    this.error,
  });

  final String partialText;
  final bool done;
  final GenerationEnvelope? envelope;
  final String? error;
}

class GenerationService {
  GenerationService({
    required ProviderConfigRepository providerRepo,
    required ProviderRegistry registry,
    required RedactingLogger logger,
  })  : _providerRepo = providerRepo,
        _registry = registry,
        _logger = logger;

  final ProviderConfigRepository _providerRepo;
  final ProviderRegistry _registry;
  final RedactingLogger _logger;

  Stream<GenerationProgress> generate({
    required String prompt,
    required TargetPlatformKind platform,
    String? regenerateHint,
    CancelToken? cancelToken,
    int maxRepairAttempts = 1,
  }) {
    return _run(
      platform: platform,
      userContent: PromptBuilder.userPrompt(
        description: prompt,
        platform: platform,
        regenerateHint: regenerateHint,
      ),
      cancelToken: cancelToken,
      maxRepairAttempts: maxRepairAttempts,
    );
  }

  /// Apply a follow-up prompt to an existing component (schema + source context).
  Stream<GenerationProgress> refine({
    required UiComponent component,
    required String changeRequest,
    CancelToken? cancelToken,
    int maxRepairAttempts = 1,
  }) {
    return _run(
      platform: component.platform,
      userContent: PromptBuilder.refineUserPrompt(
        changeRequest: changeRequest,
        platform: component.platform,
        componentName: component.name,
        originalPrompt: component.prompt,
        currentSchemaJson: component.schemaJson,
        currentSourceFiles: component.sourceFiles,
      ),
      cancelToken: cancelToken,
      maxRepairAttempts: maxRepairAttempts,
      temperature: 0.3,
    );
  }

  Stream<GenerationProgress> _run({
    required TargetPlatformKind platform,
    required String userContent,
    CancelToken? cancelToken,
    int maxRepairAttempts = 1,
    double temperature = 0.35,
  }) async* {
    final config = await _requireProvider();
    final apiKey = await _requireApiKey(config);
    final adapter = _registry.resolve(config.type);

    final messages = <AiChatMessage>[
      AiChatMessage(
        role: AiMessageRole.system,
        content: PromptBuilder.systemPrompt(platform),
      ),
      AiChatMessage(
        role: AiMessageRole.user,
        content: userContent,
      ),
    ];

    var buffer = '';
    try {
      await for (final chunk in adapter.streamChat(
        AiChatRequest(
          model: config.modelId,
          messages: messages,
          temperature: temperature,
          maxTokens: 8192,
          responseFormat: adapter.supportsJsonObject
              ? AiResponseFormat.jsonObject
              : AiResponseFormat.text,
        ),
        apiKey: apiKey,
        baseUrl: config.baseUrl,
        cancelToken: cancelToken,
      )) {
        if (chunk.deltaText.isNotEmpty) {
          buffer += chunk.deltaText;
          yield GenerationProgress(partialText: buffer);
        }
      }
    } catch (e) {
      _logger.e('Generation stream failed', error: e);
      yield GenerationProgress(
        partialText: buffer,
        done: true,
        error: e.toString(),
      );
      return;
    }

    try {
      final envelope = ResponseParser.parse(buffer, fallbackPlatform: platform);
      if (envelope.schemaJson != null &&
          !envelope.schemaValid &&
          maxRepairAttempts > 0) {
        final repaired = await _repair(
          adapter: adapter,
          config: config,
          apiKey: apiKey,
          platform: platform,
          previous: buffer,
          errors: envelope.schemaErrors,
          cancelToken: cancelToken,
        );
        if (repaired != null) {
          yield GenerationProgress(
            partialText: repaired.$1,
            done: true,
            envelope: repaired.$2,
          );
          return;
        }
      }
      yield GenerationProgress(
        partialText: buffer,
        done: true,
        envelope: envelope,
      );
    } catch (e) {
      if (maxRepairAttempts > 0) {
        final repaired = await _repair(
          adapter: adapter,
          config: config,
          apiKey: apiKey,
          platform: platform,
          previous: buffer,
          errors: [e.toString()],
          cancelToken: cancelToken,
        );
        if (repaired != null) {
          yield GenerationProgress(
            partialText: repaired.$1,
            done: true,
            envelope: repaired.$2,
          );
          return;
        }
      }
      yield GenerationProgress(
        partialText: buffer,
        done: true,
        error: e.toString(),
      );
    }
  }

  Future<(String, GenerationEnvelope)?> _repair({
    required AiProviderPort adapter,
    required AiProviderConfig config,
    required String apiKey,
    required TargetPlatformKind platform,
    required String previous,
    required List<String> errors,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await adapter.chat(
        AiChatRequest(
          model: config.modelId,
          messages: [
            AiChatMessage(
              role: AiMessageRole.system,
              content: PromptBuilder.systemPrompt(platform),
            ),
            AiChatMessage(
              role: AiMessageRole.user,
              content: PromptBuilder.repairPrompt(
                previousOutput: previous,
                errors: errors,
              ),
            ),
          ],
          temperature: 0.2,
          maxTokens: 8192,
          responseFormat: adapter.supportsJsonObject
              ? AiResponseFormat.jsonObject
              : AiResponseFormat.text,
        ),
        apiKey: apiKey,
        baseUrl: config.baseUrl,
        cancelToken: cancelToken,
      );
      final envelope =
          ResponseParser.parse(response.text, fallbackPlatform: platform);
      return (response.text, envelope);
    } catch (e) {
      _logger.w('Repair failed: $e');
      return null;
    }
  }

  Future<AiProviderConfig> _requireProvider() async {
    final selectedId = await _providerRepo.getSelectedProviderId();
    final all = await _providerRepo.listProviders();
    if (all.isEmpty) {
      throw ValidationFailure('Add an AI provider in Settings first.');
    }
    if (selectedId == null) return all.first;
    return all.firstWhere(
      (e) => e.id == selectedId,
      orElse: () => all.first,
    );
  }

  Future<String> _requireApiKey(AiProviderConfig config) async {
    final key = await _providerRepo.readApiKey(config.credentialKeyId);
    if (key == null || key.isEmpty) {
      throw ValidationFailure('Selected provider has no API key.');
    }
    return key;
  }
}
