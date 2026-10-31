enum TargetPlatformKind {
  /// Prompt-first component: live preview via HTML, export platform chosen later.
  visual,
  flutter,
  html,
  react,
}

extension TargetPlatformKindX on TargetPlatformKind {
  String get wireName {
    switch (this) {
      case TargetPlatformKind.visual:
        return 'visual';
      case TargetPlatformKind.flutter:
        return 'flutter';
      case TargetPlatformKind.html:
        return 'html';
      case TargetPlatformKind.react:
        return 'react';
    }
  }

  String get exportLabel {
    switch (this) {
      case TargetPlatformKind.visual:
        return 'Visual (preview only)';
      case TargetPlatformKind.flutter:
        return 'Flutter / Dart';
      case TargetPlatformKind.html:
        return 'HTML / CSS / JS';
      case TargetPlatformKind.react:
        return 'React / JSX';
    }
  }

  bool get isExportTarget =>
      this == TargetPlatformKind.flutter ||
      this == TargetPlatformKind.html ||
      this == TargetPlatformKind.react;

  static TargetPlatformKind fromWire(String? raw) {
    switch (raw) {
      case 'visual':
        return TargetPlatformKind.visual;
      case 'html':
        return TargetPlatformKind.html;
      case 'react':
        return TargetPlatformKind.react;
      case 'flutter':
        return TargetPlatformKind.flutter;
      default:
        // Legacy rows without platform → treat as visual-first.
        return TargetPlatformKind.visual;
    }
  }
}

class SourceFile {
  const SourceFile({required this.path, required this.content});

  final String path;
  final String content;

  factory SourceFile.fromJson(Map<String, dynamic> json) => SourceFile(
        path: json['path']?.toString() ?? 'untitled.txt',
        content: json['content']?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {'path': path, 'content': content};
}

/// Helpers to pick HTML/CSS/JS used for in-app visual preview.
class ComponentPreviewAssets {
  const ComponentPreviewAssets({
    required this.html,
    this.css,
    this.js,
  });

  final String html;
  final String? css;
  final String? js;

  bool get isEmpty => html.trim().isEmpty;

  static ComponentPreviewAssets? fromFiles(List<SourceFile> files) {
    if (files.isEmpty) return null;

    String joinExt(String ext, {bool preferPreviewFolder = true}) {
      final preview = files
          .where((f) =>
              f.path.contains('preview/') &&
              f.path.toLowerCase().endsWith(ext))
          .map((f) => f.content)
          .where((c) => c.trim().isNotEmpty)
          .toList();
      if (preferPreviewFolder && preview.isNotEmpty) {
        return preview.join('\n');
      }
      return files
          .where((f) => f.path.toLowerCase().endsWith(ext))
          .map((f) => f.content)
          .where((c) => c.trim().isNotEmpty)
          .join('\n');
    }

    final html = joinExt('.html');
    if (html.trim().isEmpty) return null;
    final css = joinExt('.css');
    final js = joinExt('.js');
    return ComponentPreviewAssets(
      html: html,
      css: css.isEmpty ? null : css,
      js: js.isEmpty ? null : js,
    );
  }

  static bool hasDart(List<SourceFile> files) =>
      files.any((f) => f.path.toLowerCase().endsWith('.dart'));

  static bool hasReact(List<SourceFile> files) => files.any((f) {
        final p = f.path.toLowerCase();
        return p.endsWith('.jsx') || p.endsWith('.tsx') || p.endsWith('.jsx.md');
      });

  static bool hasHtml(List<SourceFile> files) =>
      files.any((f) => f.path.toLowerCase().endsWith('.html'));
}

class UiComponent {
  const UiComponent({
    required this.id,
    required this.name,
    required this.description,
    required this.platform,
    required this.schemaJson,
    required this.sourceFiles,
    required this.tags,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    this.projectId,
    this.category,
    this.prompt,
    this.generationMode = 'schema_and_source',
  });

  final String id;
  final String name;
  final String description;
  final TargetPlatformKind platform;
  final String? schemaJson;
  final List<SourceFile> sourceFiles;
  final List<String> tags;
  final int version;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? projectId;
  final String? category;
  final String? prompt;
  final String generationMode;

  ComponentPreviewAssets? get previewAssets =>
      ComponentPreviewAssets.fromFiles(sourceFiles);

  UiComponent copyWith({
    String? name,
    String? description,
    TargetPlatformKind? platform,
    String? schemaJson,
    List<SourceFile>? sourceFiles,
    List<String>? tags,
    int? version,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? projectId,
    String? category,
    String? prompt,
    String? generationMode,
  }) {
    return UiComponent(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      platform: platform ?? this.platform,
      schemaJson: schemaJson ?? this.schemaJson,
      sourceFiles: sourceFiles ?? this.sourceFiles,
      tags: tags ?? this.tags,
      version: version ?? this.version,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      projectId: projectId ?? this.projectId,
      category: category ?? this.category,
      prompt: prompt ?? this.prompt,
      generationMode: generationMode ?? this.generationMode,
    );
  }
}

class StudioProject {
  const StudioProject({
    required this.id,
    required this.name,
    required this.createdAt,
    this.description = '',
  });

  final String id;
  final String name;
  final String description;
  final DateTime createdAt;
}
