import 'package:ai_ui_studio/data/database/app_database.dart';
import 'package:ai_ui_studio/data/repositories/component_repository_impl.dart';
import 'package:ai_ui_studio/domain/entities/ui_component.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late ComponentRepositoryImpl repo;

  setUp(() {
    db = AppDatabase.memory();
    repo = ComponentRepositoryImpl(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('CRUD save load search delete', () async {
    final now = DateTime.now().toUtc();
    final saved = await repo.saveComponent(
      UiComponent(
        id: 'c1',
        name: 'Login Form',
        description: 'email + password',
        platform: TargetPlatformKind.flutter,
        schemaJson: '{"\$schemaVersion":"1.0","root":{"type":"text","props":{"data":"x"}}}',
        sourceFiles: const [
          SourceFile(path: 'login_form.dart', content: 'class LoginForm {}'),
        ],
        tags: const ['form', 'auth'],
        version: 1,
        createdAt: now,
        updatedAt: now,
        category: 'forms',
      ),
    );
    expect(saved.version, 1);

    final again = await repo.saveComponent(saved.copyWith(name: 'Login Form 2'));
    expect(again.version, 2);

    final found = await repo.listComponents(query: 'auth');
    expect(found, hasLength(1));
    expect(found.first.name, 'Login Form 2');

    final copy = await repo.duplicateComponent('c1');
    expect(copy.id, isNot('c1'));
    expect(await repo.listComponents(), hasLength(2));

    await repo.deleteComponent('c1');
    expect(await repo.getComponent('c1'), isNull);
  });
}
