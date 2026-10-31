import 'dart:io';

import 'package:archive/archive.dart';
import 'package:ai_ui_studio/domain/entities/ui_component.dart';
import 'package:ai_ui_studio/export/export_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('ai_ui_export_');
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('exportComponent writes source files and zip archive', () async {
    final now = DateTime.now().toUtc();
    final component = UiComponent(
      id: 'e1',
      name: 'Primary Button',
      description: 'Primary button',
      platform: TargetPlatformKind.flutter,
      schemaJson:
          '{"\$schemaVersion":"1.0","root":{"type":"button","props":{"label":"OK"}}}',
      sourceFiles: const [
        SourceFile(path: 'button.dart', content: 'class Button {}'),
      ],
      tags: const ['button'],
      version: 1,
      createdAt: now,
      updatedAt: now,
    );

    final service = ExportService(
      documentsDirectoryOverride: () => tempDir,
    );
    final bundle = await service.exportComponent(
      component,
      target: TargetPlatformKind.flutter,
    );

    expect(await bundle.zipFile.exists(), isTrue);
    expect(bundle.target, TargetPlatformKind.flutter);
    expect(bundle.files.any((f) => f.path.endsWith('button.dart')), isTrue);
    expect(
      bundle.files.any((f) => f.path.endsWith('README_USAGE.md')),
      isTrue,
    );

    final bytes = await bundle.zipFile.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);
    expect(archive.files.any((f) => f.name.endsWith('button.dart')), isTrue);
  });

  test('exportCollection builds multi-component zip', () async {
    final now = DateTime.now().toUtc();
    final service = ExportService(
      documentsDirectoryOverride: () => tempDir,
    );
    final zip = await service.exportCollection([
      UiComponent(
        id: 'a',
        name: 'A',
        description: '',
        platform: TargetPlatformKind.react,
        schemaJson: null,
        sourceFiles: const [
          SourceFile(path: 'A.jsx', content: 'export default function A(){}'),
        ],
        tags: const [],
        version: 1,
        createdAt: now,
        updatedAt: now,
      ),
      UiComponent(
        id: 'b',
        name: 'B',
        description: '',
        platform: TargetPlatformKind.html,
        schemaJson: null,
        sourceFiles: const [
          SourceFile(path: 'index.html', content: '<div>B</div>'),
        ],
        tags: const [],
        version: 1,
        createdAt: now,
        updatedAt: now,
      ),
    ]);

    final archive = ZipDecoder().decodeBytes(await zip.readAsBytes());
    expect(archive.files.any((f) => f.name.contains('A.jsx')), isTrue);
    expect(archive.files.any((f) => f.name.contains('index.html')), isTrue);
    expect(archive.files.any((f) => f.name == 'README.md'), isTrue);
  });

  test('html export promotes preview folder files', () async {
    final now = DateTime.now().toUtc();
    final service = ExportService(
      documentsDirectoryOverride: () => tempDir,
    );
    final component = UiComponent(
      id: 'v1',
      name: 'Bell',
      description: 'bell',
      platform: TargetPlatformKind.visual,
      schemaJson: null,
      sourceFiles: const [
        SourceFile(path: 'preview/index.html', content: '<button>1</button>'),
        SourceFile(path: 'preview/styles.css', content: 'button{}'),
        SourceFile(path: 'preview/script.js', content: ''),
      ],
      tags: const [],
      version: 1,
      createdAt: now,
      updatedAt: now,
    );

    expect(service.canExportWithoutConvert(component, TargetPlatformKind.html), isTrue);
    expect(
      service.canExportWithoutConvert(component, TargetPlatformKind.flutter),
      isFalse,
    );

    final bundle = await service.exportComponent(
      component,
      target: TargetPlatformKind.html,
    );
    expect(bundle.files.any((f) => f.path.endsWith('index.html')), isTrue);
    expect(bundle.files.any((f) => f.path.endsWith('styles.css')), isTrue);
  });
}
