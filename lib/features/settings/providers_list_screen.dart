import 'package:ai_ui_studio/ai/provider_presets.dart';
import 'package:ai_ui_studio/app/providers.dart';
import 'package:ai_ui_studio/domain/entities/ai_provider_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProvidersListScreen extends ConsumerWidget {
  const ProvidersListScreen({super.key});

  String _typeLabel(AiProviderType type) => ProviderPresets.labelFor(type);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configs = ref.watch(providerConfigsProvider);
    final selectedId = ref.watch(selectedProviderIdProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(title: const Text('AI providers')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/settings/providers/new'),
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
      body: configs.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Text('No providers yet. Tap Add to configure one.'),
            );
          }
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = items[index];
              final selected = item.id == selectedId;
              return ListTile(
                title: Text(item.displayName),
                subtitle: Text(
                  '${_typeLabel(item.type)} · ${item.modelId}'
                  '${item.hasCredential && item.lastFourOfKey != null ? ' · ••••${item.lastFourOfKey}' : ''}',
                ),
                leading: Icon(
                  selected ? Icons.radio_button_checked : Icons.radio_button_off,
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  await ref
                      .read(selectedProviderIdProvider.notifier)
                      .select(item.id);
                  if (context.mounted) {
                    context.go('/settings/providers/${item.id}');
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
