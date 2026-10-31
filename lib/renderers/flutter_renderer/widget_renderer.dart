import 'dart:math' as math;

import 'package:ai_ui_studio/renderers/preview_frame/artifact_preview_frame.dart';
import 'package:ai_ui_studio/schema/style_mapper.dart';
import 'package:ai_ui_studio/schema/ui_node.dart';
import 'package:ai_ui_studio/schema/ui_schema_validator.dart';
import 'package:flutter/material.dart';

typedef PreviewActionHandler = void Function(
  String actionType,
  Map<String, dynamic> payload,
);

class FlutterWidgetRenderer {
  const FlutterWidgetRenderer({this.onAction});

  final PreviewActionHandler? onAction;

  Widget buildDocument(UiDocument document) {
    return _NodeWidget(node: document.root, onAction: onAction);
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
    this.caption,
    this.framed = true,
  });

  final UiDocument? document;
  final PreviewActionHandler? onAction;
  final String emptyMessage;
  final String? caption;
  final bool framed;

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

    final content = FlutterWidgetRenderer(onAction: onAction)
        .buildDocument(document!);

    if (!framed) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Align(alignment: Alignment.topLeft, child: content),
      );
    }

    // Claude-style: component as a ready element inside an artifact card.
    return ArtifactPreviewFrame(
      caption: caption ?? 'Нажмите на элемент — это интерактивный preview',
      child: content,
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
      return _maybeAnimate(_build(context));
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
      case 'badge':
        return _buildBadge();
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
          width:
              StyleMapper.width(node.style) ?? node.propNum('width')?.toDouble(),
          height: StyleMapper.height(node.style) ??
              node.propNum('height')?.toDouble(),
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
            mainAxisSize: MainAxisSize.min,
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
        return _buildStack();
      case 'positioned':
        return Positioned(
          top: _styleDouble(node.style['top']),
          right: _styleDouble(node.style['right']),
          bottom: _styleDouble(node.style['bottom']),
          left: _styleDouble(node.style['left']),
          width: StyleMapper.width(node.style),
          height: StyleMapper.height(node.style),
          child: _maybeChild() ?? const SizedBox.shrink(),
        );
      case 'gestureDetector':
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _dispatch('onPressed'),
          child: _maybeChild() ?? _childrenColumn(),
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
        return _wrapStyle(_maybeChild() ?? _childrenColumn());
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

  /// Compact badge+icon control that never stretches across the screen.
  Widget _buildBadge() {
    final count = node.propNum('count')?.toInt() ??
        int.tryParse(node.propString('label') ?? '') ??
        0;
    final max = node.propNum('max')?.toInt() ?? 9;
    final iconName = node.propString('icon') ??
        node.propString('name') ??
        'notifications';
    final size = StyleMapper.width(node.style) ?? 44;
    final iconSize = node.propNum('iconSize')?.toDouble() ?? size * 0.64;
    final show = count > 0;
    final label = count > max ? '$max+' : '$count';

    Widget child = SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Icon(
            _iconData(iconName),
            size: iconSize,
            color: StyleMapper.color(node.style['color']) ??
                const Color(0xFF1C1C24),
          ),
          if (show)
            Positioned(
              top: 2,
              right: 2,
              child: Container(
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: StyleMapper.color(node.props['badgeColor']) ??
                      const Color(0xFFFF3B5C),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    if (node.actions.containsKey('onPressed')) {
      child = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _dispatch('onPressed'),
        child: child,
      );
    }
    return child;
  }

  Widget _buildStack() {
    final hasPositioned = node.children.any((c) => c.type == 'positioned');
    final styleW = StyleMapper.width(node.style);
    final styleH = StyleMapper.height(node.style);
    // Positioned(right/top) needs a bounded Stack; default hit-target ~48.
    final double? boxW = styleW ?? (hasPositioned ? 48 : null);
    final double? boxH = styleH ?? (hasPositioned ? 48 : null);

    Widget stack = Stack(
      clipBehavior: Clip.none,
      fit: (boxW != null && boxH != null) ? StackFit.expand : StackFit.loose,
      alignment: StyleMapper.alignment(node.style['alignment']),
      children: node.children
          .map((c) => _NodeWidget(node: c, onAction: onAction))
          .toList(),
    );

    if (boxW != null || boxH != null) {
      stack = SizedBox(width: boxW, height: boxH, child: stack);
    }

    // Keep compact: don't let parents stretch the stack across the screen.
    return Align(
      alignment: Alignment.topLeft,
      widthFactor: 1,
      heightFactor: 1,
      child: _wrapStyle(stack),
    );
  }

  Widget _maybeAnimate(Widget child) {
    final animation = node.style['animation'] ?? node.props['animation'];
    if (animation == null) return child;
    String kind = 'pulse';
    if (animation is String) {
      kind = animation;
    } else if (animation is Map) {
      kind = animation['type']?.toString() ?? animation['kind']?.toString() ?? 'pulse';
    }
    return _PreviewAnimation(kind: kind, child: child);
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
      crossAxisAlignment: CrossAxisAlignment.start,
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

  double? _styleDouble(dynamic raw) {
    if (raw is num) return raw.toDouble();
    return double.tryParse(raw?.toString() ?? '');
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
      case 'notifications':
      case 'notifications_rounded':
      case 'notification':
      case 'bell':
        return Icons.notifications_rounded;
      case 'notifications_none':
      case 'notifications_none_rounded':
        return Icons.notifications_none_rounded;
      case 'notifications_active':
        return Icons.notifications_active_rounded;
      case 'mail':
      case 'email':
        return Icons.mail_outline;
      case 'menu':
        return Icons.menu;
      case 'more':
      case 'more_vert':
        return Icons.more_vert;
      case 'star':
      default:
        return Icons.star;
    }
  }
}

class _PreviewAnimation extends StatefulWidget {
  const _PreviewAnimation({required this.kind, required this.child});

  final String kind;
  final Widget child;

  @override
  State<_PreviewAnimation> createState() => _PreviewAnimationState();
}

class _PreviewAnimationState extends State<_PreviewAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    final shake = widget.kind == 'shake' || widget.kind == 'wiggle';
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: shake ? 4000 : 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduce) return widget.child;

    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final t = _controller.value;
        switch (widget.kind) {
          case 'shake':
          case 'wiggle':
            final ringEnd = 0.22;
            final angle = t >= ringEnd
                ? 0.0
                : math.sin((t / ringEnd) * math.pi * 6) *
                    (1 - t / ringEnd) *
                    0.38;
            return Transform.rotate(
              angle: angle,
              alignment: Alignment.topCenter,
              child: child,
            );
          case 'bounce':
            final dy = -6 * math.sin(t * math.pi * 2).abs();
            return Transform.translate(offset: Offset(0, dy), child: child);
          case 'pulse':
          default:
            final scale = 1 + 0.06 * math.sin(t * math.pi * 2);
            return Transform.scale(scale: scale, child: child);
        }
      },
    );
  }
}
