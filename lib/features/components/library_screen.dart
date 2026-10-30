import 'package:ai_ui_studio/app/mvp_providers.dart';
import 'package:ai_ui_studio/domain/entities/ui_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final components = ref.watch(componentsListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Component Library'),
        actions: [
          IconButton(
            tooltip: 'Generate',
            onPressed: () => context.go('/generate'),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search components',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  onPressed: () {
                    _searchController.clear();
                    ref.read(componentsListProvider.notifier).refresh(query: '');
                  },
                  icon: const Icon(Icons.clear),
                ),
              ),
              onChanged: (value) {
                ref.read(componentsListProvider.notifier).refresh(query: value);
              },
            ),
          ),
          Expanded(
            child: components.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('$e')),
              data: (items) {
                if (items.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'No saved components yet.\nGenerate a UI to get started.',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          FilledButton(
                            onPressed: () => context.go('/generate'),
                            child: const Text('Open Generator'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ListTile(
                      title: Text(item.name),
                      subtitle: Text(
                        '${item.platform.wireName} · v${item.version}'
                        '${item.category != null ? ' · ${item.category}' : ''}'
                        '${item.tags.isNotEmpty ? ' · ${item.tags.join(', ')}' : ''}',
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) async {
                          if (value == 'open') {
                            context.go('/studio/${item.id}');
                          } else if (value == 'duplicate') {
                            final copy = await ref
                                .read(componentsListProvider.notifier)
                                .duplicate(item.id);
                            if (context.mounted) {
                              context.go('/studio/${copy.id}');
                            }
                          } else if (value == 'delete') {
                            final ok = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Delete component?'),
                                content: Text('Delete "${item.name}"?'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Cancel'),
                                  ),
                                  FilledButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );
                            if (ok == true) {
                              await ref
                                  .read(componentsListProvider.notifier)
                                  .delete(item.id);
                            }
                          }
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(value: 'open', child: Text('Open')),
                          PopupMenuItem(
                            value: 'duplicate',
                            child: Text('Duplicate'),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Text('Delete'),
                          ),
                        ],
                      ),
                      onTap: () => context.go('/studio/${item.id}'),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
