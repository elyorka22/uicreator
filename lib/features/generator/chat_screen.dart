import 'package:ai_ui_studio/ai/ports/ai_models.dart';
import 'package:ai_ui_studio/app/providers.dart';
import 'package:ai_ui_studio/domain/entities/ai_provider_config.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();
  final List<_UiMessage> _messages = [];

  bool _streaming = false;
  String? _error;
  CancelToken? _cancelToken;

  @override
  void dispose() {
    _cancelToken?.cancel('disposed');
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<AiProviderConfig?> _selectedConfig() async {
    final selectedId =
        await ref.read(providerConfigRepositoryProvider).getSelectedProviderId();
    final configs = await ref.read(providerConfigRepositoryProvider).listProviders();
    if (configs.isEmpty) return null;
    if (selectedId == null) return configs.first;
    return configs.cast<AiProviderConfig?>().firstWhere(
          (e) => e?.id == selectedId,
          orElse: () => configs.first,
        );
  }

  Future<void> _send() async {
    final text = _inputController.text.trim();
    if (text.isEmpty || _streaming) return;

    final config = await _selectedConfig();
    if (config == null) {
      setState(() => _error = 'Add an AI provider in Settings first.');
      return;
    }
    if (!config.hasCredential) {
      setState(() => _error = 'Selected provider has no API key.');
      return;
    }

    final apiKey = await ref
        .read(providerConfigRepositoryProvider)
        .readApiKey(config.credentialKeyId);
    if (apiKey == null || apiKey.isEmpty) {
      setState(() => _error = 'Could not read API key from secure storage.');
      return;
    }

    setState(() {
      _error = null;
      _messages.add(_UiMessage(role: AiMessageRole.user, text: text));
      _messages.add(const _UiMessage(role: AiMessageRole.assistant, text: ''));
      _streaming = true;
      _inputController.clear();
    });
    _scrollToEnd();

    final adapter = ref.read(providerRegistryProvider).resolve(config.type);
    final history = _messages
        .where((m) => m.text.isNotEmpty || m.role == AiMessageRole.user)
        .map((m) => AiChatMessage(role: m.role, content: m.text))
        .toList();
    // Drop the empty assistant placeholder from the request payload.
    if (history.isNotEmpty &&
        history.last.role == AiMessageRole.assistant &&
        history.last.content.isEmpty) {
      history.removeLast();
    }

    _cancelToken = CancelToken();
    try {
      final stream = adapter.streamChat(
        AiChatRequest(model: config.modelId, messages: history),
        apiKey: apiKey,
        baseUrl: config.baseUrl,
        cancelToken: _cancelToken,
      );

      await for (final chunk in stream) {
        if (!mounted) return;
        if (chunk.deltaText.isNotEmpty) {
          setState(() {
            final last = _messages.last;
            _messages[_messages.length - 1] = last.copyWith(
              text: last.text + chunk.deltaText,
            );
          });
          _scrollToEnd();
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        if (_messages.isNotEmpty &&
            _messages.last.role == AiMessageRole.assistant &&
            _messages.last.text.isEmpty) {
          _messages.removeLast();
        }
      });
    } finally {
      if (mounted) {
        setState(() => _streaming = false);
      }
      _cancelToken = null;
    }
  }

  void _cancel() {
    _cancelToken?.cancel('User cancelled');
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final configs = ref.watch(providerConfigsProvider);
    final selectedId = ref.watch(selectedProviderIdProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Chat'),
        actions: [
          if (_streaming)
            TextButton(
              onPressed: _cancel,
              child: const Text('Stop'),
            ),
        ],
      ),
      body: Column(
        children: [
          configs.when(
            data: (items) {
              if (items.isEmpty) {
                return MaterialBanner(
                  content: const Text('No AI provider configured.'),
                  actions: [
                    TextButton(
                      onPressed: () => context.go('/settings/providers/new'),
                      child: const Text('Add provider'),
                    ),
                  ],
                );
              }
              final selected = items.cast<AiProviderConfig?>().firstWhere(
                    (e) => e?.id == selectedId,
                    orElse: () => items.first,
                  )!;
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${selected.displayName} · ${selected.modelId}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go('/settings/providers'),
                      child: const Text('Change'),
                    ),
                  ],
                ),
              );
            },
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('$e'),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message.role == AiMessageRole.user;
                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.85,
                    ),
                    decoration: BoxDecoration(
                      color: isUser
                          ? Theme.of(context).colorScheme.primaryContainer
                          : Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SelectableText(
                      message.text.isEmpty && _streaming && !isUser
                          ? '…'
                          : message.text,
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _inputController,
                      minLines: 1,
                      maxLines: 4,
                      enabled: !_streaming,
                      decoration: const InputDecoration(
                        hintText: 'Message the model…',
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _streaming ? null : _send,
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UiMessage {
  const _UiMessage({required this.role, required this.text});

  final AiMessageRole role;
  final String text;

  _UiMessage copyWith({AiMessageRole? role, String? text}) {
    return _UiMessage(
      role: role ?? this.role,
      text: text ?? this.text,
    );
  }
}
