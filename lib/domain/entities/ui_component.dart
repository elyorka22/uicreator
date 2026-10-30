enum TargetPlatformKind { flutter, html, react }

extension TargetPlatformKindX on TargetPlatformKind {
  String get wireName {
    switch (this) {
      case TargetPlatformKind.flutter:
        return 'flutter';
      case TargetPlatformKind.html:
        return 'html';
      case TargetPlatformKind.react:
        return 'react';
    }
  }

  static TargetPlatformKind fromWire(String? raw) {
    switch (raw) {
      case 'html':
        return TargetPlatformKind.html;
      case 'react':
        return TargetPlatformKind.react;
      default:
        return TargetPlatformKind.flutter;
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

  UiComponent copyWith({
    String? name,
    String? description,
    TargetPlatformKind? platform,
    String? schemaJson,
    List<SourceFile>? sourceFiles,
    List<String>? tags,
    int? version,
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
      createdAt: createdAt,
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
