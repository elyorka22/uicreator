import 'dart:convert';

import 'package:ai_ui_studio/data/database/app_database.dart' as db;
import 'package:ai_ui_studio/domain/entities/ui_component.dart';
import 'package:ai_ui_studio/domain/repositories/component_repository.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

class ComponentRepositoryImpl implements ComponentRepository {
  ComponentRepositoryImpl(this._db, {Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final db.AppDatabase _db;
  final Uuid _uuid;

  @override
  Future<List<StudioProject>> listProjects() async {
    final rows = await _db.select(_db.projects).get();
    return rows
        .map(
          (r) => StudioProject(
            id: r.id,
            name: r.name,
            description: r.description,
            createdAt: r.createdAt,
          ),
        )
        .toList();
  }

  @override
  Future<StudioProject> saveProject(StudioProject project) async {
    await _db.into(_db.projects).insertOnConflictUpdate(
          db.ProjectsCompanion(
            id: Value(project.id),
            name: Value(project.name),
            description: Value(project.description),
            createdAt: Value(project.createdAt),
          ),
        );
    return project;
  }

  @override
  Future<void> deleteProject(String id) async {
    await (_db.delete(_db.projects)..where((t) => t.id.equals(id))).go();
    await (_db.update(_db.components)..where((t) => t.projectId.equals(id)))
        .write(const db.ComponentsCompanion(projectId: Value(null)));
  }

  @override
  Future<List<UiComponent>> listComponents({
    String? query,
    String? projectId,
    String? category,
  }) async {
    final rows = await _db.select(_db.components).get();
    var items = rows.map(_mapComponent).toList();
    if (projectId != null) {
      items = items.where((e) => e.projectId == projectId).toList();
    }
    if (category != null && category.isNotEmpty) {
      items = items.where((e) => e.category == category).toList();
    }
    if (query != null && query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      items = items
          .where(
            (e) =>
                e.name.toLowerCase().contains(q) ||
                e.description.toLowerCase().contains(q) ||
                e.tags.any((t) => t.toLowerCase().contains(q)),
          )
          .toList();
    }
    items.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return items;
  }

  @override
  Future<UiComponent?> getComponent(String id) async {
    final row = await (_db.select(_db.components)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _mapComponent(row);
  }

  @override
  Future<UiComponent> saveComponent(UiComponent component) async {
    final existing = await getComponent(component.id);
    final version = existing == null ? 1 : existing.version + 1;
    final now = DateTime.now().toUtc();
    final saved = component.copyWith(
      version: version,
      updatedAt: now,
    );
    await _db.into(_db.components).insertOnConflictUpdate(
          db.ComponentsCompanion(
            id: Value(saved.id),
            projectId: Value(saved.projectId),
            name: Value(saved.name),
            description: Value(saved.description),
            platform: Value(saved.platform.wireName),
            schemaJson: Value(saved.schemaJson),
            sourceJson: Value(
              jsonEncode(saved.sourceFiles.map((e) => e.toJson()).toList()),
            ),
            tagsJson: Value(jsonEncode(saved.tags)),
            category: Value(saved.category),
            prompt: Value(saved.prompt),
            generationMode: Value(saved.generationMode),
            version: Value(saved.version),
            createdAt: Value(saved.createdAt),
            updatedAt: Value(saved.updatedAt),
          ),
        );
    return saved;
  }

  @override
  Future<void> deleteComponent(String id) async {
    await (_db.delete(_db.components)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<UiComponent> duplicateComponent(String id) async {
    final original = await getComponent(id);
    if (original == null) {
      throw StateError('Component not found: $id');
    }
    final now = DateTime.now().toUtc();
    final copy = UiComponent(
      id: _uuid.v4(),
      name: '${original.name} Copy',
      description: original.description,
      platform: original.platform,
      schemaJson: original.schemaJson,
      sourceFiles: original.sourceFiles,
      tags: original.tags,
      version: 1,
      createdAt: now,
      updatedAt: now,
      projectId: original.projectId,
      category: original.category,
      prompt: original.prompt,
      generationMode: original.generationMode,
    );
    return saveComponent(copy);
  }

  UiComponent _mapComponent(db.Component row) {
    List<SourceFile> sources = const [];
    List<String> tags = const [];
    try {
      final decoded = jsonDecode(row.sourceJson);
      if (decoded is List) {
        sources = decoded
            .whereType<Map>()
            .map((e) => SourceFile.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    } catch (_) {}
    try {
      final decoded = jsonDecode(row.tagsJson);
      if (decoded is List) {
        tags = decoded.map((e) => e.toString()).toList();
      }
    } catch (_) {}

    return UiComponent(
      id: row.id,
      projectId: row.projectId,
      name: row.name,
      description: row.description,
      platform: TargetPlatformKindX.fromWire(row.platform),
      schemaJson: row.schemaJson,
      sourceFiles: sources,
      tags: tags,
      category: row.category,
      prompt: row.prompt,
      generationMode: row.generationMode,
      version: row.version,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}
