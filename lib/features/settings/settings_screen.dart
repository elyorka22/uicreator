import 'package:ai_ui_studio/app/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allowInsecure = ref.watch(allowInsecureHttpProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.vpn_key_outlined),
            title: const Text('AI providers'),
            subtitle: const Text('API keys, models, and endpoints'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/settings/providers'),
          ),
          const Divider(),
          SwitchListTile(
            secondary: const Icon(Icons.warning_amber_outlined),
            title: const Text('Allow insecure HTTP'),
            subtitle: const Text(
              'Off by default. Enable only for trusted local gateways. '
              'HTTP can expose API keys on the network.',
            ),
            value: allowInsecure.valueOrNull ?? false,
            onChanged: allowInsecure.isLoading
                ? null
                : (value) async {
                    if (value) {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Allow insecure HTTP?'),
                          content: const Text(
                            'Non-HTTPS endpoints may send your API key in cleartext. '
                            'Use this only on trusted local networks for development gateways.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Enable'),
                            ),
                          ],
                        ),
                      );
                      if (confirmed != true) return;
                    }
                    await ref
                        .read(allowInsecureHttpProvider.notifier)
                        .setValue(value);
                  },
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'API keys are stored with Flutter Secure Storage '
              '(Android Keystore-backed). They are never written to the '
              'provider config JSON file or ordinary preferences as secrets.',
            ),
          ),
        ],
      ),
    );
  }
}
