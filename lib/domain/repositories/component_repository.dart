import 'package:ai_ui_studio/domain/entities/ui_component.dart';

abstract class ComponentRepository {
  Future<List<StudioProject>> listProjects();
  Future<StudioProject> saveProject(StudioProject project);
  Future<void> deleteProject(String id);

  Future<List<UiComponent>> listComponents({
    String? query,
    String? projectId,
    String? category,
  });

  Future<UiComponent?> getComponent(String id);
  Future<UiComponent> saveComponent(UiComponent component);
  Future<void> deleteComponent(String id);
  Future<UiComponent> duplicateComponent(String id);
}
