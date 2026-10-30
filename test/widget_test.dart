import 'package:ai_ui_studio/app/app.dart';
import 'package:ai_ui_studio/app/mvp_providers.dart';
import 'package:ai_ui_studio/app/providers.dart';
import 'package:ai_ui_studio/core/constants/app_constants.dart';
import 'package:ai_ui_studio/data/database/app_database.dart';
import 'package:ai_ui_studio/data/repositories/component_repository_impl.dart';
import 'package:ai_ui_studio/domain/entities/ai_provider_config.dart';
import 'package:ai_ui_studio/domain/repositories/provider_config_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeProviderRepo implements ProviderConfigRepository {
  @override
  Future<bool> getAllowInsecureHttp() async => false;
  @override
  Future<AiProviderConfig?> getById(String id) async => null;
  @override
  Future<String?> getSelectedProviderId() async => null;
  @override
  Future<List<AiProviderConfig>> listProviders() async => [];
  @override
  Future<String?> readApiKey(String credentialKeyId) async => null;
  @override
  Future<AiProviderConfig> saveProvider({
    required AiProviderConfig config,
    String? apiKey,
  }) async =>
      config;
  @override
  Future<void> deleteProvider(String id) async {}
  @override
  Future<void> setAllowInsecureHttp(bool value) async {}
  @override
  Future<void> setSelectedProviderId(String? id) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('home screen shows generator CTA', (tester) async {
    final db = AppDatabase.memory();
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          providerConfigRepositoryProvider.overrideWithValue(_FakeProviderRepo()),
          appDatabaseProvider.overrideWithValue(db),
          componentRepositoryProvider.overrideWithValue(
            ComponentRepositoryImpl(db),
          ),
        ],
        child: AiUiStudioApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(AppConstants.appName), findsWidgets);
    expect(find.text('Generate UI component'), findsOneWidget);
    expect(find.text('Add AI provider'), findsOneWidget);
  });
}
