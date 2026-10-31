// Universal UI Schema models (v1.0).
// Preview is always driven by these models — never by executing AI source.

class UiDocument {
  const UiDocument({
    required this.schemaVersion,
    required this.root,
    this.id,
  });

  final String schemaVersion;
  final String? id;
  final UiNode root;

  factory UiDocument.fromJson(Map<String, dynamic> json) {
    final rootRaw = json['root'];
    if (rootRaw is! Map) {
      throw const FormatException('UiDocument.root must be an object');
    }
    return UiDocument(
      schemaVersion: (json['\$schemaVersion'] ?? json['schemaVersion'] ?? '1.0')
          .toString(),
      id: json['id']?.toString(),
      root: UiNode.fromJson(Map<String, dynamic>.from(rootRaw)),
    );
  }

  Map<String, dynamic> toJson() => {
        '\$schemaVersion': schemaVersion,
        if (id != null) 'id': id,
        'root': root.toJson(),
      };

  int get nodeCount => root.totalNodeCount;
}

class UiNode {
  const UiNode({
    required this.type,
    this.id,
    this.props = const {},
    this.style = const {},
    this.actions = const {},
    this.children = const [],
  });

  final String type;
  final String? id;
  final Map<String, dynamic> props;
  final Map<String, dynamic> style;
  final Map<String, dynamic> actions;
  final List<UiNode> children;

  factory UiNode.fromJson(Map<String, dynamic> json) {
    final type = json['type']?.toString();
    if (type == null || type.isEmpty) {
      throw const FormatException('UiNode.type is required');
    }

    final children = <UiNode>[];
    final childrenRaw = json['children'];
    if (childrenRaw is List) {
      for (final item in childrenRaw) {
        if (item is Map) {
          children.add(UiNode.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }
    final childRaw = json['child'];
    if (childRaw is Map) {
      children.add(UiNode.fromJson(Map<String, dynamic>.from(childRaw)));
    }

    return UiNode(
      type: type,
      id: json['id']?.toString(),
      props: _asStringKeyedMap(json['props']),
      style: _asStringKeyedMap(json['style']),
      actions: _asStringKeyedMap(json['actions']),
      children: children,
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        if (id != null) 'id': id,
        if (props.isNotEmpty) 'props': props,
        if (style.isNotEmpty) 'style': style,
        if (actions.isNotEmpty) 'actions': actions,
        if (children.isNotEmpty)
          'children': children.map((e) => e.toJson()).toList(),
      };

  int get totalNodeCount =>
      1 + children.fold<int>(0, (sum, c) => sum + c.totalNodeCount);

  T? prop<T>(String key) {
    final value = props[key];
    if (value is T) return value;
    return null;
  }

  String? propString(String key) => props[key]?.toString();

  bool propBool(String key, {bool fallback = false}) {
    final value = props[key];
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    return fallback;
  }

  num? propNum(String key) {
    final value = props[key];
    if (value is num) return value;
    return num.tryParse(value?.toString() ?? '');
  }
}

Map<String, dynamic> _asStringKeyedMap(dynamic raw) {
  if (raw is Map) {
    return raw.map((key, value) => MapEntry(key.toString(), value));
  }
  return {};
}

/// Supported node types for the Flutter renderer.
const Set<String> kSupportedUiNodeTypes = {
  'container',
  'text',
  'button',
  'image',
  'icon',
  'row',
  'column',
  'stack',
  'positioned',
  'card',
  'textField',
  'checkbox',
  'switch',
  'divider',
  'padding',
  'scrollView',
  'sizedBox',
  'spacer',
  'center',
  'expanded',
  'flexible',
  'gestureDetector',
  'badge',
};
