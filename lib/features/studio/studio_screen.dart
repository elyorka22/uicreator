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

  Future<void> _regenerate(UiComponent component) async {
    final hintController = TextEditingController();
    final hint = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Regenerate'),
        content: TextField(
          controller: hintController,
          decoration: const InputDecoration(
            labelText: 'Optional changes',
            hintText: 'Make the button larger, use a darker card…',
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
                platform: component.platform,
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
        schemaJson: envelope.schemaJson,
        sourceFiles: envelope.sourceFiles,
        tags: envelope.tags,
        generationMode:
            envelope.schemaValid ? 'schema_and_source' : 'source_only',
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
    setState(() {
      _busy = true;
      _status = 'Exporting…';
    });
    try {
      final bundle =
          await ref.read(exportServiceProvider).exportComponent(component);
      await Share.shareXFiles(
        [XFile(bundle.zipFile.path)],
        text: '${component.name} export from AI UI Studio',
      );
      setState(() => _status = 'Exported ${bundle.zipFile.path}');
    } catch (e) {
      setState(() => _status = 'Export failed: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _preview(UiComponent component) {
    if (component.platform == TargetPlatformKind.html) {
      final html = component.sourceFiles
          .where((f) => f.path.endsWith('.html'))
          .map((f) => f.content)
          .join('\n');
      final css = component.sourceFiles
          .where((f) => f.path.endsWith('.css'))
          .map((f) => f.content)
          .join('\n');
      final js = component.sourceFiles
          .where((f) => f.path.endsWith('.js'))
          .map((f) => f.content)
          .join('\n');
      if (html.isEmpty) {
        return const Center(
          child: Text('No HTML source available for WebView preview.'),
        );
      }
      return HtmlPreview(html: html, css: css, js: js);
    }

    if (component.platform == TargetPlatformKind.react) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'React live preview is not included in the MVP.\n'
            'Use the Code tab to view/edit JSX and Export to share files.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final document = _documentOf(component);
    if (document == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'No valid Universal UI Schema for Flutter preview.\n'
            'Source-only components can still be edited and exported.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return SchemaPreview(
      document: document,
      onAction: (type, payload) {
        final message = payload['message']?.toString() ?? type;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Preview action: $message')),
        );
      },
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
                tooltip: 'Regenerate',
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
                  padding: const EdgeInsets.all(8),
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
