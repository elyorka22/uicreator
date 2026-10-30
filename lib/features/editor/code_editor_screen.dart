import 'package:ai_ui_studio/app/mvp_providers.dart';
import 'package:ai_ui_studio/domain/entities/ui_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:re_editor/re_editor.dart';
import 'package:re_highlight/languages/css.dart';
import 'package:re_highlight/languages/dart.dart';
import 'package:re_highlight/languages/javascript.dart';
import 'package:re_highlight/languages/json.dart';
import 'package:re_highlight/languages/xml.dart';
import 'package:re_highlight/styles/atom-one-light.dart';
import 'package:share_plus/share_plus.dart';

class CodeEditorScreen extends ConsumerStatefulWidget {
  const CodeEditorScreen({super.key, required this.componentId});

  final String componentId;

  @override
  ConsumerState<CodeEditorScreen> createState() => _CodeEditorScreenState();
}

class _CodeEditorScreenState extends ConsumerState<CodeEditorScreen> {
  final _controller = CodeLineEditingController();
  List<SourceFile> _files = [];
  int _index = 0;
  bool _loaded = false;
  String? _status;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _loadFile(int index) {
    if (_files.isEmpty) return;
    _index = index.clamp(0, _files.length - 1);
    _controller.text = _files[_index].content;
    setState(() {});
  }

  Future<void> _save(UiComponent component) async {
    if (_files.isEmpty) return;
    final updatedFiles = [..._files];
    updatedFiles[_index] = SourceFile(
      path: updatedFiles[_index].path,
      content: _controller.text,
    );
    final saved = await ref.read(componentsListProvider.notifier).save(
          component.copyWith(
            sourceFiles: updatedFiles,
            updatedAt: DateTime.now().toUtc(),
          ),
        );
    _files = saved.sourceFiles;
    setState(() => _status = 'Saved ${_files[_index].path}');
    ref.invalidate(componentDetailProvider(widget.componentId));
  }

  @override
  Widget build(BuildContext context) {
    final asyncComponent =
        ref.watch(componentDetailProvider(widget.componentId));

    return asyncComponent.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(body: Center(child: Text('$e'))),
      data: (component) {
        if (component == null) {
          return const Scaffold(body: Center(child: Text('Not found')));
        }
        if (!_loaded) {
          _files = List.of(component.sourceFiles);
          _loaded = true;
          if (_files.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _loadFile(0);
            });
          }
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(_files.isEmpty ? 'Editor' : _files[_index].path),
            actions: [
              IconButton(
                tooltip: 'Copy',
                onPressed: () async {
                  await Clipboard.setData(
                    ClipboardData(text: _controller.text),
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Copied')),
                    );
                  }
                },
                icon: const Icon(Icons.copy),
              ),
              IconButton(
                tooltip: 'Share file',
                onPressed: _files.isEmpty
                    ? null
                    : () => Share.share(
                          _controller.text,
                          subject: _files[_index].path,
                        ),
                icon: const Icon(Icons.share),
              ),
              IconButton(
                tooltip: 'Save',
                onPressed: () => _save(component),
                icon: const Icon(Icons.save),
              ),
            ],
          ),
          body: _files.isEmpty
              ? const Center(child: Text('No source files to edit.'))
              : Column(
                  children: [
                    if (_status != null)
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(_status!),
                      ),
                    SizedBox(
                      height: 48,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        itemCount: _files.length,
                        itemBuilder: (context, index) {
                          final selected = index == _index;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: ChoiceChip(
                              label: Text(_files[index].path),
                              selected: selected,
                              onSelected: (_) {
                                // Persist current buffer into local list before switch.
                                _files[_index] = SourceFile(
                                  path: _files[_index].path,
                                  content: _controller.text,
                                );
                                _loadFile(index);
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: CodeEditor(
                        controller: _controller,
                        style: CodeEditorStyle(
                          fontSize: 13,
                          codeTheme: CodeHighlightTheme(
                            languages: {
                              'dart': CodeHighlightThemeMode(mode: langDart),
                              'javascript':
                                  CodeHighlightThemeMode(mode: langJavascript),
                              'xml': CodeHighlightThemeMode(mode: langXml),
                              'css': CodeHighlightThemeMode(mode: langCss),
                              'json': CodeHighlightThemeMode(mode: langJson),
                            },
                            theme: atomOneLightTheme,
                          ),
                        ),
                        indicatorBuilder: (
                          context,
                          editingController,
                          chunkController,
                          notifier,
                        ) {
                          return DefaultCodeLineNumber(
                            controller: editingController,
                            notifier: notifier,
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        'Editing ${_files[_index].path}. '
                        'Saved source edits do not automatically rewrite the Universal UI Schema preview.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
