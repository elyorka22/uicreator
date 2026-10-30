import 'package:ai_ui_studio/schema/style_mapper.dart';
import 'package:ai_ui_studio/schema/ui_node.dart';
import 'package:ai_ui_studio/schema/ui_schema_validator.dart';
import 'package:flutter/material.dart';

typedef PreviewActionHandler = void Function(String actionType, Map<String, dynamic> payload);

class FlutterWidgetRenderer {
  const FlutterWidgetRenderer({this.onAction});

  final PreviewActionHandler? onAction;

  Widget buildDocument(UiDocument document) {
    return _NodeWidget(
      node: document.root,
      onAction: onAction,
    );
  }

  Widget buildFromJson(Map<String, dynamic> json) {
    final result = UiSchemaValidator.validate(json);
    if (!result.isValid || result.document == null) {
      return _ErrorBox(errors: result.errors);
    }
    return buildDocument(result.document!);
  }
}

class SchemaPreview extends StatelessWidget {
  const SchemaPreview({
    super.key,
    required this.document,
    this.onAction,
    this.emptyMessage = 'No preview yet',
  });

  final UiDocument? document;
  final PreviewActionHandler? onAction;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (document == null) {
      return Center(
        child: Text(
          emptyMessage,
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: FlutterWidgetRenderer(onAction: onAction).buildDocument(document!),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.errors});

  final List<String> errors;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Schema error:\n${errors.join('\n')}',
        style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
      ),
    );
  }
}

class _NodeWidget extends StatelessWidget {
  const _NodeWidget({required this.node, this.onAction});

  final UiNode node;
  final PreviewActionHandler? onAction;

  @override
  Widget build(BuildContext context) {
    try {
      return _build(context);
    } catch (e) {
      return _ErrorBox(errors: ['Failed to render ${node.type}: $e']);
    }
  }

  Widget _build(BuildContext context) {
    switch (node.type) {
      case 'text':
        return Text(
          node.propString('data') ?? node.propString('text') ?? '',
          style: StyleMapper.textStyle(node.style),
          textAlign: _textAlign(node.props['textAlign']),
        );
      case 'button':
        final label =
            node.propString('label') ?? node.propString('text') ?? 'Button';
        final variant = node.propString('variant') ?? 'filled';
        void onPressed() => _dispatch('onPressed');
        switch (variant) {
          case 'outlined':
            return OutlinedButton(onPressed: onPressed, child: Text(label));
          case 'text':
            return TextButton(onPressed: onPressed, child: Text(label));
          default:
            return FilledButton(onPressed: onPressed, child: Text(label));
        }
      case 'icon':
        return Icon(
          _iconData(node.propString('name') ?? 'star'),
          size: StyleMapper.width(node.style) ?? 24,
          color: StyleMapper.color(node.style['color']),
        );
      case 'image':
        final url = node.propString('url') ?? node.propString('src') ?? '';
        final w = StyleMapper.width(node.style);
        final h = StyleMapper.height(node.style);
        if (url.isEmpty) {
          return const Icon(Icons.broken_image_outlined);
        }
        return Image.network(
          url,
          width: w,
          height: h,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(Icons.broken_image_outlined),
        );
      case 'divider':
        return const Divider();
      case 'spacer':
        return const Spacer();
      case 'sizedBox':
        return SizedBox(
          width: StyleMapper.width(node.style) ?? node.propNum('width')?.toDouble(),
          height:
              StyleMapper.height(node.style) ?? node.propNum('height')?.toDouble(),
          child: _maybeChild(),
        );
      case 'padding':
        return Padding(
          padding: StyleMapper.edgeInsets(
            node.style['padding'] ?? node.props['padding'],
            fallback: const EdgeInsets.all(8),
          ),
          child: _maybeChild() ?? const SizedBox.shrink(),
        );
      case 'center':
        return Center(child: _maybeChild());
      case 'expanded':
        return Expanded(child: _maybeChild() ?? const SizedBox.shrink());
      case 'flexible':
        return Flexible(child: _maybeChild() ?? const SizedBox.shrink());
      case 'scrollView':
        return SingleChildScrollView(
          child: _maybeChild() ?? _childrenColumn(),
        );
      case 'row':
        return _wrapStyle(
          Row(
            mainAxisAlignment:
                StyleMapper.mainAxisAlignment(node.style['mainAxisAlignment']),
            crossAxisAlignment:
                StyleMapper.crossAxisAlignment(node.style['crossAxisAlignment']),
            children: _gapChildren(Axis.horizontal),
          ),
        );
      case 'column':
        return _wrapStyle(
          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment:
                StyleMapper.mainAxisAlignment(node.style['mainAxisAlignment']),
            crossAxisAlignment:
                StyleMapper.crossAxisAlignment(node.style['crossAxisAlignment']),
            children: _gapChildren(Axis.vertical),
          ),
        );
      case 'stack':
        return _wrapStyle(
          Stack(
            alignment: StyleMapper.alignment(node.style['alignment']),
            children: node.children
                .map((c) => _NodeWidget(node: c, onAction: onAction))
                .toList(),
          ),
        );
      case 'card':
        return Card(
          elevation: node.propNum('elevation')?.toDouble() ?? 1,
          child: Padding(
            padding: StyleMapper.edgeInsets(
              node.style['padding'],
              fallback: const EdgeInsets.all(12),
            ),
            child: _maybeChild() ?? _childrenColumn(),
          ),
        );
      case 'container':
        return _wrapStyle(
          _maybeChild() ?? _childrenColumn(),
        );
      case 'textField':
        return TextField(
          decoration: InputDecoration(
            labelText: node.propString('label'),
            hintText: node.propString('hint') ?? node.propString('placeholder'),
          ),
          obscureText: node.propBool('obscure'),
          onChanged: (_) => _dispatch('onChanged'),
        );
      case 'checkbox':
        return CheckboxListTile(
          value: node.propBool('value'),
          title: Text(node.propString('label') ?? ''),
          controlAffinity: ListTileControlAffinity.leading,
          onChanged: (_) => _dispatch('onChanged'),
        );
      case 'switch':
        return SwitchListTile(
          value: node.propBool('value'),
          title: Text(node.propString('label') ?? ''),
          onChanged: (_) => _dispatch('onChanged'),
        );
      default:
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.orange),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Unsupported: ${node.type}'),
              if (node.children.isNotEmpty) _childrenColumn(),
            ],
          ),
        );
    }
  }

  Widget? _maybeChild() {
    if (node.children.isEmpty) return null;
    if (node.children.length == 1) {
      return _NodeWidget(node: node.children.first, onAction: onAction);
    }
    return _childrenColumn();
  }

  Widget _childrenColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: node.children
          .map((c) => _NodeWidget(node: c, onAction: onAction))
          .toList(),
    );
  }

  List<Widget> _gapChildren(Axis axis) {
    final gap = StyleMapper.gap(node.style) ?? 0;
    final widgets = <Widget>[];
    for (var i = 0; i < node.children.length; i++) {
      if (i > 0 && gap > 0) {
        widgets.add(
          axis == Axis.horizontal
              ? SizedBox(width: gap)
              : SizedBox(height: gap),
        );
      }
      widgets.add(_NodeWidget(node: node.children[i], onAction: onAction));
    }
    return widgets;
  }

  Widget _wrapStyle(Widget child) {
    final padding = StyleMapper.edgeInsets(node.style['padding']);
    final margin = StyleMapper.edgeInsets(node.style['margin']);
    final decoration = StyleMapper.boxDecoration(node.style);
    final width = StyleMapper.width(node.style);
    final height = StyleMapper.height(node.style);

    Widget current = child;
    if (decoration != null || width != null || height != null) {
      current = Container(
        width: width,
        height: height,
        decoration: decoration,
        padding: padding == EdgeInsets.zero ? null : padding,
        child: current,
      );
    } else if (padding != EdgeInsets.zero) {
      current = Padding(padding: padding, child: current);
    }
    if (margin != EdgeInsets.zero) {
      current = Padding(padding: margin, child: current);
    }
    return current;
  }

  void _dispatch(String actionKey) {
    final action = node.actions[actionKey];
    if (action is Map) {
      final map = Map<String, dynamic>.from(action);
      final type = map['type']?.toString() ?? actionKey;
      onAction?.call(type, map);
    } else {
      onAction?.call(actionKey, const {});
    }
  }

  TextAlign? _textAlign(dynamic raw) {
    switch (raw?.toString()) {
      case 'center':
        return TextAlign.center;
      case 'right':
      case 'end':
        return TextAlign.right;
      case 'left':
      case 'start':
        return TextAlign.left;
      case 'justify':
        return TextAlign.justify;
      default:
        return null;
    }
  }

  IconData _iconData(String name) {
    switch (name) {
      case 'home':
        return Icons.home;
      case 'settings':
        return Icons.settings;
      case 'person':
        return Icons.person;
      case 'search':
        return Icons.search;
      case 'add':
        return Icons.add;
      case 'check':
        return Icons.check;
      case 'close':
        return Icons.close;
      case 'favorite':
        return Icons.favorite;
      case 'star':
      default:
        return Icons.star;
    }
  }
}
