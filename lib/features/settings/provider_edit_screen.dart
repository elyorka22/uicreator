import 'package:ai_ui_studio/app/providers.dart';
import 'package:ai_ui_studio/core/constants/app_constants.dart';
import 'package:ai_ui_studio/core/utils/url_validator.dart';
import 'package:ai_ui_studio/domain/entities/ai_provider_config.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

class ProviderEditScreen extends ConsumerStatefulWidget {
  const ProviderEditScreen({super.key, this.providerId});

  final String? providerId;

  @override
  ConsumerState<ProviderEditScreen> createState() => _ProviderEditScreenState();
}

class _ProviderEditScreenState extends ConsumerState<ProviderEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _baseUrlController = TextEditingController();
  final _modelController = TextEditingController();
  final _apiKeyController = TextEditingController();

  AiProviderType _type = AiProviderType.openaiCompatible;
  AiProviderConfig? _existing;
  bool _loading = true;
  bool _saving = false;
  bool _testing = false;
  bool _obscureKey = true;
  String? _status;

  bool get _isNew => widget.providerId == null;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    if (_isNew) {
      _baseUrlController.text = AppConstants.openAiDefaultBaseUrl;
      _modelController.text = 'gpt-4o-mini';
      _nameController.text = 'OpenAI';
      setState(() => _loading = false);
      return;
    }

    final repo = ref.read(providerConfigRepositoryProvider);
    final existing = await repo.getById(widget.providerId!);
    if (existing != null) {
      _existing = existing;
      _type = existing.type;
      _nameController.text = existing.displayName;
      _baseUrlController.text = existing.baseUrl;
      _modelController.text = existing.modelId;
    }
    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _baseUrlController.dispose();
    _modelController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  void _onTypeChanged(AiProviderType? type) {
    if (type == null) return;
    setState(() {
      _type = type;
      if (_isNew || _baseUrlController.text.trim().isEmpty) {
        _baseUrlController.text = type == AiProviderType.anthropic
            ? AppConstants.anthropicDefaultBaseUrl
            : AppConstants.openAiDefaultBaseUrl;
      }
      if (_isNew) {
        _modelController.text = type == AiProviderType.anthropic
            ? 'claude-3-5-haiku-latest'
            : 'gpt-4o-mini';
        _nameController.text =
            type == AiProviderType.anthropic ? 'Anthropic' : 'OpenAI';
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _status = null;
    });

    try {
      final allowInsecure =
          ref.read(allowInsecureHttpProvider).valueOrNull ?? false;
      final urlResult = UrlValidator.validate(
        _baseUrlController.text,
        allowInsecureHttp: allowInsecure,
      );
      if (!urlResult.isValid) {
        setState(() => _status = urlResult.message);
        return;
      }

      final id = _existing?.id ?? const Uuid().v4();
      final credentialKeyId = _existing?.credentialKeyId ?? '';
      final apiKey = _apiKeyController.text.trim();

      if (_isNew && apiKey.isEmpty) {
        setState(() => _status = 'API key is required for a new provider.');
        return;
      }

      final config = AiProviderConfig(
        id: id,
        type: _type,
        displayName: _nameController.text.trim(),
        baseUrl: urlResult.normalizedUrl!,
        modelId: _modelController.text.trim(),
        credentialKeyId: credentialKeyId,
        hasCredential: _existing?.hasCredential ?? false,
        lastFourOfKey: _existing?.lastFourOfKey,
        createdAt: _existing?.createdAt,
      );

      final saved = await ref.read(providerConfigsProvider.notifier).save(
            config: config,
            apiKey: apiKey.isEmpty ? null : apiKey,
          );
      await ref.read(selectedProviderIdProvider.notifier).select(saved.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              urlResult.isSecure
                  ? 'Provider saved.'
                  : 'Provider saved. ${urlResult.message ?? ''}',
            ),
          ),
        );
        context.go('/settings/providers');
      }
    } catch (e) {
      setState(() => _status = e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _testConnection() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _testing = true;
      _status = null;
    });

    final cancelToken = CancelToken();
    try {
      final allowInsecure =
          ref.read(allowInsecureHttpProvider).valueOrNull ?? false;
      UrlValidator.ensureValid(
        _baseUrlController.text,
        allowInsecureHttp: allowInsecure,
      );

      final repo = ref.read(providerConfigRepositoryProvider);
      var apiKey = _apiKeyController.text.trim();
      if (apiKey.isEmpty && _existing != null) {
        apiKey = await repo.readApiKey(_existing!.credentialKeyId) ?? '';
      }
      if (apiKey.isEmpty) {
        setState(() => _status = 'Enter an API key to test the connection.');
        return;
      }

      final adapter = ref.read(providerRegistryProvider).resolve(_type);
      final result = await adapter.testConnection(
        apiKey: apiKey,
        baseUrl: _baseUrlController.text.trim(),
        modelId: _modelController.text.trim(),
        cancelToken: cancelToken,
      );
      setState(() => _status = result.message);
    } catch (e) {
      setState(() => _status = e.toString());
    } finally {
      if (mounted) setState(() => _testing = false);
    }
  }

  Future<void> _delete() async {
    if (_existing == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete provider?'),
        content: const Text('The API key will be removed from secure storage.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(providerConfigsProvider.notifier).delete(_existing!.id);
    if (mounted) context.go('/settings/providers');
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final registry = ref.watch(providerRegistryProvider);
    final adapter = registry.resolve(_type);
    final modelOptions = adapter.catalogModels;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isNew ? 'Add provider' : 'Edit provider'),
        actions: [
          if (!_isNew)
            IconButton(
              onPressed: _delete,
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete',
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<AiProviderType>(
              value: _type,
              decoration: const InputDecoration(labelText: 'Provider type'),
              items: const [
                DropdownMenuItem(
                  value: AiProviderType.openaiCompatible,
                  child: Text('OpenAI / OpenAI-compatible'),
                ),
                DropdownMenuItem(
                  value: AiProviderType.anthropic,
                  child: Text('Anthropic Claude'),
                ),
              ],
              onChanged: _onTypeChanged,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Display name'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _baseUrlController,
              decoration: const InputDecoration(
                labelText: 'Base URL',
                helperText: 'HTTPS by default. HTTP requires Settings opt-in.',
              ),
              validator: (v) {
                final allow = ref.read(allowInsecureHttpProvider).valueOrNull ??
                    false;
                final result =
                    UrlValidator.validate(v ?? '', allowInsecureHttp: allow);
                return result.isValid ? null : result.message;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _modelController,
              decoration: InputDecoration(
                labelText: 'Model',
                helperText: modelOptions.map((m) => m.id).join(', '),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _apiKeyController,
              obscureText: _obscureKey,
              decoration: InputDecoration(
                labelText: _isNew ? 'API key' : 'API key (leave blank to keep)',
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _obscureKey = !_obscureKey),
                  icon: Icon(
                    _obscureKey ? Icons.visibility : Icons.visibility_off,
                  ),
                ),
              ),
            ),
            if (_existing?.lastFourOfKey != null) ...[
              const SizedBox(height: 8),
              Text('Saved key ends with ${_existing!.lastFourOfKey}'),
            ],
            const SizedBox(height: 20),
            if (_status != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  _status!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _testing || _saving ? null : _testConnection,
                    child: _testing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Test connection'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _saving || _testing ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Save'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
