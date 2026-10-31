import 'dart:convert';

import 'package:ai_ui_studio/ai/agent/response_parser.dart';
import 'package:ai_ui_studio/app/mvp_providers.dart';
import 'package:ai_ui_studio/domain/entities/ui_component.dart';
import 'package:ai_ui_studio/renderers/flutter_renderer/widget_renderer.dart';
import 'package:ai_ui_studio/renderers/web_renderer/html_preview.dart';
import 'package:ai_ui_studio/schema/ui_node.dart';
import 'package:ai_ui_studio/schema/ui_schema_validator.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

class StudioScreen extends ConsumerStatefulWidget {
  const StudioScreen({super.key, required this.componentId});

  final String componentId;

  @override
  ConsumerState<StudioScreen> createState() => _StudioScreenState();
}

class _StudioScreenState extends ConsumerState<StudioScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final _refineController = TextEditingController();
  bool _busy = false;
  String? _status;
  CancelToken? _cancelToken;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _cancelToken?.cancel('disposed');
    _refineController.dispose();
    _tabs.dispose();
    super.dispose();
  }

  UiDocument? _documentOf(UiComponent component) {
    if (component.schemaJson == null || component.schemaJson!.isEmpty) {
      return null;
    }
    try {
      final decoded = jsonDecode(component.schemaJson!);
      final result = UiSchemaValidator.validate(decoded);
      return result.document;
    } catch (_) {
      return null;
    }
  }

  Future<void> _rename(UiComponent component) async {
    final controller = TextEditingController(text: component.name);
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename component'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (name == null || name.isEmpty) return;
    await ref.read(componentsListProvider.notifier).save(
          component.copyWith(name: name, updatedAt: DateTime.now().toUtc()),
        );
    ref.invalidate(componentDetailProvider(widget.componentId));
  }

  Future<void> _refine(UiComponent component) async {
    final change = _refineController.text.trim();
    if (change.isEmpty || _busy) return;

    setState(() {
      _busy = true;
      _status = 'Applying changes…';
    });
    _cancelToken = CancelToken();
    GenerationEnvelope? envelope;
    String? error;

    try {
      await for (final progress in ref.read(generationServiceProvider).refine(
            component: component,
            changeRequest: change,
            cancelToken: _cancelToken,
          )) {
        if (progress.envelope != null) envelope = progress.envelope;
        if (progress.error != null) error = progress.error;
        if (progress.done) break;
      }

      if (envelope == null) {
        setState(() => _status = error ?? 'Refine failed');
        return;
      }

      final promptHistory = [
        if (component.prompt != null && component.prompt!.trim().isNotEmpty)
          component.prompt!.trim(),
        'Refine: $change',
      ].join('\n');

      final updated = component.copyWith(
        name: envelope.componentName,
        description: envelope.description,
        platform: TargetPlatformKind.visual,
        schemaJson: envelope.schemaJson,
        sourceFiles: envelope.sourceFiles,
        tags: envelope.tags,
        prompt: promptHistory,
        generationMode: envelope.hasHtmlPreview
            ? 'visual_preview'
            : (envelope.schemaValid ? 'schema_and_source' : 'source_only'),
        updatedAt: DateTime.now().toUtc(),
      );
      await ref.read(componentsListProvider.notifier).save(updated);
      ref.invalidate(componentDetailProvider(widget.componentId));
      _refineController.clear();
      setState(() => _status = 'Changes applied and saved');
    } catch (e) {
      setState(() => _status = e.toString());
    } finally {
      _cancelToken = null;
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _regenerate(UiComponent component) async {
    final hintController = TextEditingController();
    final hint = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Regenerate from scratch'),
        content: TextField(
          controller: hintController,
          decoration: const InputDecoration(
            labelText: 'Optional direction',
            hintText: 'Rebuild with a darker theme…',
          ),
          minLines: 2,
          maxLines: 4,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, hintController.text),
            child: const Text('Regenerate'),
          ),
        ],
      ),
    );
    if (hint == null) return;

    setState(() {
      _busy = true;
      _status = 'Regenerating…';
    });
    _cancelToken = CancelToken();
    GenerationEnvelope? envelope;
    String? error;
    try {
      await for (final progress
          in ref.read(generationServiceProvider).generate(
                prompt: component.prompt?.isNotEmpty == true
                    ? component.prompt!
                    : component.description.isNotEmpty
                        ? component.description
                        : component.name,
                regenerateHint: hint,
                cancelToken: _cancelToken,
              )) {
        if (progress.envelope != null) envelope = progress.envelope;
        if (progress.error != null) error = progress.error;
        if (progress.done) break;
      }
      if (envelope == null) {
        setState(() => _status = error ?? 'Regeneration failed');
        return;
      }
      final updated = component.copyWith(
        name: envelope.componentName,
        description: envelope.description,
        platform: TargetPlatformKind.visual,
        schemaJson: envelope.schemaJson,
        sourceFiles: envelope.sourceFiles,
        tags: envelope.tags,
        generationMode: envelope.hasHtmlPreview
            ? 'visual_preview'
            : (envelope.schemaValid ? 'schema_and_source' : 'source_only'),
        updatedAt: DateTime.now().toUtc(),
      );
      await ref.read(componentsListProvider.notifier).save(updated);
      ref.invalidate(componentDetailProvider(widget.componentId));
      setState(() => _status = 'Regenerated and saved');
    } catch (e) {
      setState(() => _status = e.toString());
    } finally {
      _cancelToken = null;
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _export(UiComponent component) async {
    final target = await showModalBottomSheet<TargetPlatformKind>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Text(
                  'Экспорт — выберите платформу',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(
                  'Сначала вы видели preview. Сейчас получите код под проект.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.phone_android),
                title: const Text('Flutter / Dart'),
                subtitle: const Text('Виджет для Flutter-проекта'),
                onTap: () => Navigator.pop(context, TargetPlatformKind.flutter),
              ),
              ListTile(
                leading: const Icon(Icons.language),
                title: const Text('HTML / CSS / JS'),
                subtitle: const Text('Как в preview, готовые файлы'),
                onTap: () => Navigator.pop(context, TargetPlatformKind.html),
              ),
              ListTile(
                leading: const Icon(Icons.code),
                title: const Text('React / JSX'),
                subtitle: const Text('Компонент для React'),
                onTap: () => Navigator.pop(context, TargetPlatformKind.react),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
    if (target == null) return;

    setState(() {
      _busy = true;
      _status = 'Готовим ${target.exportLabel}…';
    });
    _cancelToken = CancelToken();

    try {
      final exportService = ref.read(exportServiceProvider);
      var files = component.sourceFiles;
      var working = component;

      final needsConvert =
          !exportService.canExportWithoutConvert(component, target);
      if (needsConvert) {
        setState(() => _status = 'Генерируем ${target.exportLabel} код…');
        GenerationEnvelope? envelope;
        String? error;
        await for (final progress
            in ref.read(generationServiceProvider).convertForExport(
                  component: component,
                  target: target,
                  cancelToken: _cancelToken,
                )) {
          if (progress.envelope != null) envelope = progress.envelope;
          if (progress.error != null) error = progress.error;
          if (progress.done) break;
        }
        if (envelope == null) {
          setState(() => _status = error ?? 'Export convert failed');
          return;
        }
        files = envelope.sourceFiles;
        working = component.copyWith(
          name: envelope.componentName,
          description: envelope.description,
          platform: target,
          schemaJson: envelope.schemaJson,
          sourceFiles: envelope.sourceFiles,
          tags: envelope.tags,
          generationMode: 'exported_${target.wireName}',
          updatedAt: DateTime.now().toUtc(),
        );
        await ref.read(componentsListProvider.notifier).save(working);
        ref.invalidate(componentDetailProvider(widget.componentId));
      } else if (target != component.platform && target.isExportTarget) {
        working = component.copyWith(
          platform: target,
          updatedAt: DateTime.now().toUtc(),
        );
        await ref.read(componentsListProvider.notifier).save(working);
        ref.invalidate(componentDetailProvider(widget.componentId));
      }

      setState(() => _status = 'Packaging ZIP…');
      final bundle = await exportService.exportComponent(
        working,
        target: target,
        filesOverride: files,
      );
      await Share.shareXFiles(
        [XFile(bundle.zipFile.path)],
        text: '${working.name} (${target.exportLabel}) — AI UI Studio',
      );
      setState(() => _status = 'Exported ${target.exportLabel}');
    } catch (e) {
      setState(() => _status = 'Export failed: $e');
    } finally {
      _cancelToken = null;
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _preview(UiComponent component) {
    // Visual-first: always prefer interactive HTML preview when available.
    final assets = component.previewAssets;
    if (assets != null && !assets.isEmpty) {
      return HtmlPreview(html: assets.html, css: assets.css, js: assets.js);
    }

    final document = _documentOf(component);
    if (document != null) {
      return SchemaPreview(
        document: document,
        caption:
            'Schema fallback · доработайте промптом, чтобы получить HTML preview',
        onAction: (type, payload) {
          final message = payload['message']?.toString() ?? type;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Preview action: $message')),
          );
        },
      );
    }

    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Нет HTML preview и schema.\n'
          'Доработайте промптом или пересоздайте элемент.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _refineBar(UiComponent component) {
    return Material(
      elevation: 6,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Доработать промптом',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _refineController,
                      enabled: !_busy,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _refine(component),
                      decoration: const InputDecoration(
                        hintText:
                            'Например: переделай в type badge, shake-анимация, кликабельно…',
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (_busy)
                    IconButton.filled(
                      onPressed: () => _cancelToken?.cancel('User cancelled'),
                      icon: const Icon(Icons.stop),
                      tooltip: 'Stop',
                    )
                  else
                    IconButton.filled(
                      onPressed: () => _refine(component),
                      icon: const Icon(Icons.send),
                      tooltip: 'Apply refine',
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final asyncComponent =
        ref.watch(componentDetailProvider(widget.componentId));

    return asyncComponent.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('$e')),
      ),
      data: (component) {
        if (component == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Component not found')),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(component.name),
            leading: BackButton(
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/library');
                }
              },
            ),
            actions: [
              IconButton(
                tooltip: 'Rename',
                onPressed: _busy ? null : () => _rename(component),
                icon: const Icon(Icons.drive_file_rename_outline),
              ),
              IconButton(
                tooltip: 'Regenerate from scratch',
                onPressed: _busy ? null : () => _regenerate(component),
                icon: const Icon(Icons.refresh),
              ),
              IconButton(
                tooltip: 'Export ZIP',
                onPressed: _busy ? null : () => _export(component),
                icon: const Icon(Icons.ios_share),
              ),
              IconButton(
                tooltip: 'Edit code',
                onPressed: () =>
                    context.push('/library/studio/${component.id}/editor'),
                icon: const Icon(Icons.code),
              ),
            ],
            bottom: TabBar(
              controller: _tabs,
              tabs: const [
                Tab(text: 'Preview'),
                Tab(text: 'Schema'),
                Tab(text: 'Code'),
              ],
            ),
          ),
          body: Column(
            children: [
              if (_busy) const LinearProgressIndicator(),
              if (_status != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                  child: Text(_status!),
                ),
              Expanded(
                child: TabBarView(
                  controller: _tabs,
                  children: [
                    _preview(component),
                    _SchemaTab(schemaJson: component.schemaJson),
                    _CodeTab(files: component.sourceFiles),
                  ],
                ),
              ),
              _refineBar(component),
            ],
          ),
        );
      },
    );
  }
}

class _SchemaTab extends StatelessWidget {
  const _SchemaTab({required this.schemaJson});

  final String? schemaJson;

  @override
  Widget build(BuildContext context) {
    if (schemaJson == null || schemaJson!.isEmpty) {
      return const Center(child: Text('No schema stored for this component.'));
    }
    String pretty = schemaJson!;
    try {
      pretty =
          const JsonEncoder.withIndent('  ').convert(jsonDecode(schemaJson!));
    } catch (_) {}
    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: pretty));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Schema copied')),
                );
              }
            },
            icon: const Icon(Icons.copy),
            label: const Text('Copy'),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: SelectableText(
              pretty,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }
}

class _CodeTab extends StatelessWidget {
  const _CodeTab({required this.files});

  final List<SourceFile> files;

  @override
  Widget build(BuildContext context) {
    if (files.isEmpty) {
      return const Center(child: Text('No source files.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: files.length,
      itemBuilder: (context, index) {
        final file = files[index];
        return Card(
          child: ExpansionTile(
            title: Text(file.path),
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: file.content));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Copied ${file.path}')),
                      );
                    }
                  },
                  icon: const Icon(Icons.copy),
                  label: const Text('Copy'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: SelectableText(
                  file.content,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
