import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:ai_ui_studio/domain/entities/ui_component.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ExportBundle {
  const ExportBundle({
    required this.directory,
    required this.zipFile,
    required this.files,
    required this.target,
  });

  final Directory directory;
  final File zipFile;
  final List<File> files;
  final TargetPlatformKind target;
}

class ExportService {
  ExportService({Directory? Function()? documentsDirectoryOverride})
      : _documentsDirectoryOverride = documentsDirectoryOverride;

  final Directory? Function()? _documentsDirectoryOverride;

  Future<Directory> _exportsDir() async {
    final docs = _documentsDirectoryOverride?.call() ??
        await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, 'ai_ui_studio', 'exports'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Export for a chosen platform. Pass [filesOverride] after AI convert.
  Future<ExportBundle> exportComponent(
    UiComponent component, {
    TargetPlatformKind? target,
    List<SourceFile>? filesOverride,
  }) async {
    final exportTarget = target ??
        (component.platform.isExportTarget
            ? component.platform
            : TargetPlatformKind.html);

    final exports = await _exportsDir();
    final stamp = DateTime.now().toUtc().millisecondsSinceEpoch;
    final safeName = _safe(component.name);
    final folder = Directory(
      p.join(exports.path, '${safeName}_${exportTarget.wireName}_$stamp'),
    );
    await folder.create(recursive: true);

    final written = <File>[];
    final rawSources = filesOverride ?? component.sourceFiles;
    var sources = _filesForTarget(rawSources, exportTarget);
    if (sources.isEmpty) {
      sources = rawSources;
    }

    if (component.schemaJson != null && component.schemaJson!.isNotEmpty) {
      final schemaFile = File(p.join(folder.path, 'schema.json'));
      final encoded = const JsonEncoder.withIndent('  ')
          .convert(jsonDecode(component.schemaJson!));
      await schemaFile.writeAsString(encoded);
      written.add(schemaFile);
    }

    for (final source in sources) {
      final file = File(p.join(folder.path, source.path));
      await file.parent.create(recursive: true);
      await file.writeAsString(source.content);
      written.add(file);
    }

    final readme = File(p.join(folder.path, 'README_USAGE.md'));
    await readme.writeAsString(_readme(component, exportTarget));
    written.add(readme);

    final zipFile = File(
      p.join(exports.path, '${safeName}_${exportTarget.wireName}_$stamp.zip'),
    );
    final archive = Archive();
    for (final file in written) {
      final bytes = await file.readAsBytes();
      final relative = p.relative(file.path, from: folder.path);
      archive.addFile(ArchiveFile(relative, bytes.length, bytes));
    }
    final zipBytes = ZipEncoder().encode(archive);
    if (zipBytes == null) {
      throw StateError('Failed to encode ZIP archive');
    }
    await zipFile.writeAsBytes(zipBytes, flush: true);

    return ExportBundle(
      directory: folder,
      zipFile: zipFile,
      files: written,
      target: exportTarget,
    );
  }

  Future<File> exportCollection(
    List<UiComponent> components, {
    String name = 'collection',
  }) async {
    final exports = await _exportsDir();
    final stamp = DateTime.now().toUtc().millisecondsSinceEpoch;
    final zipFile = File(p.join(exports.path, '${_safe(name)}_$stamp.zip'));
    final archive = Archive();

    for (final component in components) {
      final prefix = _safe(component.name);
      if (component.schemaJson != null) {
        final bytes = utf8.encode(component.schemaJson!);
        archive.addFile(
          ArchiveFile('$prefix/schema.json', bytes.length, bytes),
        );
      }
      for (final source in component.sourceFiles) {
        final bytes = utf8.encode(source.content);
        archive.addFile(
          ArchiveFile('$prefix/${source.path}', bytes.length, bytes),
        );
      }
      final readme = utf8.encode(_readme(component, component.platform));
      archive.addFile(
        ArchiveFile('$prefix/README_USAGE.md', readme.length, readme),
      );
    }

    final rootReadme = utf8.encode(
      '# AI UI Studio export\n\nContains ${components.length} component(s).\n',
    );
    archive.addFile(
      ArchiveFile('README.md', rootReadme.length, rootReadme),
    );

    final zipBytes = ZipEncoder().encode(archive);
    if (zipBytes == null) {
      throw StateError('Failed to encode ZIP archive');
    }
    await zipFile.writeAsBytes(zipBytes, flush: true);
    return zipFile;
  }

  /// Whether we already have usable files for [target] without another AI call.
  bool canExportWithoutConvert(
    UiComponent component,
    TargetPlatformKind target,
  ) {
    switch (target) {
      case TargetPlatformKind.html:
      case TargetPlatformKind.visual:
        return ComponentPreviewAssets.hasHtml(component.sourceFiles);
      case TargetPlatformKind.flutter:
        return ComponentPreviewAssets.hasDart(component.sourceFiles);
      case TargetPlatformKind.react:
        return ComponentPreviewAssets.hasReact(component.sourceFiles);
    }
  }

  List<SourceFile> _filesForTarget(
    List<SourceFile> all,
    TargetPlatformKind target,
  ) {
    switch (target) {
      case TargetPlatformKind.flutter:
        final dart = all.where((f) => f.path.toLowerCase().endsWith('.dart'));
        return dart.isNotEmpty ? dart.toList() : all;
      case TargetPlatformKind.react:
        final jsx = all.where((f) {
          final p = f.path.toLowerCase();
          return p.endsWith('.jsx') || p.endsWith('.tsx');
        });
        return jsx.isNotEmpty ? jsx.toList() : all;
      case TargetPlatformKind.html:
      case TargetPlatformKind.visual:
        final preview = all.where((f) => f.path.contains('preview/')).toList();
        if (preview.isNotEmpty) {
          // Promote preview/* to top-level names for HTML export.
          return preview
              .map((f) {
                final name = p.basename(f.path);
                if (name == 'index.html') {
                  return SourceFile(path: 'index.html', content: f.content);
                }
                if (name.endsWith('.css')) {
                  return SourceFile(path: 'styles.css', content: f.content);
                }
                if (name.endsWith('.js')) {
                  return SourceFile(path: 'script.js', content: f.content);
                }
                return SourceFile(path: name, content: f.content);
              })
              .toList();
        }
        return all
            .where((f) {
              final path = f.path.toLowerCase();
              return path.endsWith('.html') ||
                  path.endsWith('.css') ||
                  path.endsWith('.js');
            })
            .toList();
    }
  }

  String _safe(String input) {
    final cleaned = input.replaceAll(RegExp(r'[^A-Za-z0-9_\-]+'), '_');
    return cleaned.isEmpty ? 'component' : cleaned;
  }

  String _readme(UiComponent component, TargetPlatformKind target) {
    return '''
# ${component.name}

${component.description}

- Export target: ${target.exportLabel}
- Version: ${component.version}
- Generated by AI UI Studio (prompt → visual preview → export)

## Usage

Copy the source files into your project.

## Note

In-app Studio preview uses the interactive HTML preview (and schema fallback).
Export picks Flutter / HTML / React when you are ready to use the component.
''';
  }
}
