import 'package:ai_ui_studio/app/mvp_providers.dart';
import 'package:ai_ui_studio/app/providers.dart';
import 'package:ai_ui_studio/core/constants/app_constants.dart';
import 'package:ai_ui_studio/domain/entities/ui_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final providers = ref.watch(providerConfigsProvider);
    final components = ref.watch(componentsListProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          IconButton(
            tooltip: 'AI chat',
            onPressed: () => context.push('/generate/chat'),
            icon: const Icon(Icons.chat_bubble_outline),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            AppConstants.appName,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Describe a UI, generate a schema + source with your own AI keys, '
            'preview it locally, then save and export.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          providers.when(
            data: (items) {
              if (items.isEmpty) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('1. Add an AI provider',
                            style: theme.textTheme.titleMedium),
                        const SizedBox(height: 8),
                        const Text(
                          'OpenAI-compatible and Anthropic are supported. Keys stay in secure storage.',
                        ),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: () =>
                              context.go('/settings/providers/new'),
                          icon: const Icon(Icons.add),
                          label: const Text('Add AI provider'),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.check_circle_outline),
                  title: Text('${items.length} provider(s) ready'),
                  subtitle: const Text('BYOK — keys never leave this device except to the AI API'),
                  onTap: () => context.go('/settings/providers'),
                ),
              );
            },
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('$e'),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => context.go('/generate'),
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Generate UI component'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => context.go('/library'),
            icon: const Icon(Icons.widgets_outlined),
            label: const Text('Open library'),
          ),
          const SizedBox(height: 24),
          Text('Recent components', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          components.when(
            data: (items) {
              if (items.isEmpty) {
                return const Text('Nothing saved yet.');
              }
              return Column(
                children: items.take(5).map((item) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(item.name),
                    subtitle: Text(item.platform.wireName),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/library/studio/${item.id}'),
                  );
                }).toList(),
              );
            },
            loading: () => const CircularProgressIndicator(),
            error: (e, _) => Text('$e'),
          ),
        ],
      ),
    );
  }
}
