import 'package:ai_ui_studio/ai/agent/generation_service.dart';
import 'package:ai_ui_studio/app/providers.dart';
import 'package:ai_ui_studio/data/database/app_database.dart';
import 'package:ai_ui_studio/data/repositories/component_repository_impl.dart';
import 'package:ai_ui_studio/domain/entities/ui_component.dart';
import 'package:ai_ui_studio/domain/repositories/component_repository.dart';
import 'package:ai_ui_studio/export/export_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

final componentRepositoryProvider = Provider<ComponentRepository>((ref) {
  return ComponentRepositoryImpl(ref.watch(appDatabaseProvider));
});

final exportServiceProvider = Provider<ExportService>((ref) {
  return ExportService();
});

final generationServiceProvider = Provider<GenerationService>((ref) {
  return GenerationService(
    providerRepo: ref.watch(providerConfigRepositoryProvider),
    registry: ref.watch(providerRegistryProvider),
    logger: ref.watch(redactingLoggerProvider),
  );
});

final componentsListProvider =
    AsyncNotifierProvider<ComponentsListNotifier, List<UiComponent>>(
  ComponentsListNotifier.new,
);

class ComponentsListNotifier extends AsyncNotifier<List<UiComponent>> {
  String _query = '';

  @override
  Future<List<UiComponent>> build() {
    return ref.read(componentRepositoryProvider).listComponents(query: _query);
  }

  Future<void> refresh({String? query}) async {
    if (query != null) _query = query;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(componentRepositoryProvider)
          .listComponents(query: _query),
    );
  }

  Future<UiComponent> save(UiComponent component) async {
    final saved =
        await ref.read(componentRepositoryProvider).saveComponent(component);
    await refresh();
    return saved;
  }

  Future<void> delete(String id) async {
    await ref.read(componentRepositoryProvider).deleteComponent(id);
    await refresh();
  }

  Future<UiComponent> duplicate(String id) async {
    final copy =
        await ref.read(componentRepositoryProvider).duplicateComponent(id);
    await refresh();
    return copy;
  }
}

final componentDetailProvider =
    FutureProvider.family<UiComponent?, String>((ref, id) async {
  return ref.watch(componentRepositoryProvider).getComponent(id);
});
