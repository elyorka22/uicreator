import 'package:ai_ui_studio/ai/agent/response_parser.dart';
import 'package:ai_ui_studio/app/mvp_providers.dart';
import 'package:ai_ui_studio/app/providers.dart';
import 'package:ai_ui_studio/domain/entities/ui_component.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

class GeneratorScreen extends ConsumerStatefulWidget {
  const GeneratorScreen({super.key});

  @override
  ConsumerState<GeneratorScreen> createState() => _GeneratorScreenState();
}

class _GeneratorScreenState extends ConsumerState<GeneratorScreen> {
  final _promptController = TextEditingController();
  TargetPlatformKind _platform = TargetPlatformKind.flutter;
  bool _running = false;
  String _stream = '';
  String? _error;
  GenerationEnvelope? _envelope;
  CancelToken? _cancelToken;

  @override
  void dispose() {
    _cancelToken?.cancel('disposed');
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty || _running) return;

    setState(() {
      _running = true;
      _stream = '';
      _error = null;
      _envelope = null;
    });

    _cancelToken = CancelToken();
    try {
      await for (final progress in ref.read(generationServiceProvider).generate(
            prompt: prompt,
            platform: _platform,
            cancelToken: _cancelToken,
          )) {
        if (!mounted) return;
        setState(() {
          _stream = progress.partialText;
          if (progress.error != null) _error = progress.error;
          if (progress.envelope != null) _envelope = progress.envelope;
          if (progress.done) _running = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _running = false;
      });
    } finally {
      _cancelToken = null;
      if (mounted && _running) setState(() => _running = false);
    }
  }

  Future<void> _openStudio() async {
    final envelope = _envelope;
    if (envelope == null) return;
    final now = DateTime.now().toUtc();
    final draft = UiComponent(
      id: const Uuid().v4(),
      name: envelope.componentName,
      description: envelope.description,
      platform: envelope.platform,
      schemaJson: envelope.schemaValid ? envelope.schemaJson : envelope.schemaJson,
      sourceFiles: envelope.sourceFiles,
      tags: envelope.tags,
      version: 1,
      createdAt: now,
      updatedAt: now,
      prompt: _promptController.text.trim(),
      generationMode:
          envelope.schemaValid ? 'schema_and_source' : 'source_only',
    );
    final saved = await ref.read(componentsListProvider.notifier).save(draft);
    if (!mounted) return;
    context.go('/studio/${saved.id}');
  }

  @override
  Widget build(BuildContext context) {
    final providers = ref.watch(providerConfigsProvider);
    final selectedId = ref.watch(selectedProviderIdProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Generator'),
        actions: [
          if (_running)
            TextButton(
              onPressed: () => _cancelToken?.cancel('User cancelled'),
              child: const Text('Stop'),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          providers.when(
            data: (items) {
              if (items.isEmpty) {
                return Card(
                  child: ListTile(
                    title: const Text('No AI provider configured'),
                    subtitle: const Text('Add a provider and API key first.'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.go('/settings/providers/new'),
                  ),
                );
              }
              final selected = items.firstWhere(
                (e) => e.id == selectedId,
                orElse: () => items.first,
              );
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(selected.displayName),
                subtitle: Text(selected.modelId),
                trailing: TextButton(
                  onPressed: () => context.go('/settings/providers'),
                  child: const Text('Change'),
                ),
              );
            },
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('$e'),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<TargetPlatformKind>(
            value: _platform,
            decoration: const InputDecoration(labelText: 'Target platform'),
            items: const [
              DropdownMenuItem(
                value: TargetPlatformKind.flutter,
                child: Text('Flutter / Dart (live preview)'),
              ),
              DropdownMenuItem(
                value: TargetPlatformKind.html,
                child: Text('HTML / CSS / JS'),
              ),
              DropdownMenuItem(
                value: TargetPlatformKind.react,
                child: Text('React / JSX (export only)'),
              ),
            ],
            onChanged: _running
                ? null
                : (v) {
                    if (v != null) setState(() => _platform = v);
                  },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _promptController,
            minLines: 4,
            maxLines: 8,
            enabled: !_running,
            decoration: const InputDecoration(
              labelText: 'Describe the UI',
              hintText:
                  'e.g. A pricing card with title, price, feature list and CTA button',
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _running ? null : _generate,
            icon: _running
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.auto_awesome),
            label: Text(_running ? 'Generating…' : 'Generate UI'),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
          if (_envelope != null) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _envelope!.componentName,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(_envelope!.description),
                    if (_envelope!.warnings.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        _envelope!.warnings.join('\n'),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                      ),
                    ],
                    if (!_envelope!.schemaValid &&
                        _envelope!.schemaErrors.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Schema issues:\n${_envelope!.schemaErrors.join('\n')}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _openStudio,
                      child: const Text('Open in Studio'),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (_stream.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('Raw response', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                _stream.length > 4000
                    ? '${_stream.substring(0, 4000)}…'
                    : _stream,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
            if (_envelope?.rawJson != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Parsed keys: ${(_envelope!.rawJson ?? {}).keys.join(', ')}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
          ],
        ],
      ),
    );
  }
}
