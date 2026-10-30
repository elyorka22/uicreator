import 'package:flutter/material.dart';

class StyleMapper {
  static EdgeInsets edgeInsets(dynamic raw, {EdgeInsets fallback = EdgeInsets.zero}) {
    if (raw == null) return fallback;
    if (raw is num) return EdgeInsets.all(raw.toDouble());
    if (raw is! Map) return fallback;
    final map = Map<String, dynamic>.from(raw);
    if (map.containsKey('all')) {
      return EdgeInsets.all(_toDouble(map['all']) ?? 0);
    }
    return EdgeInsets.only(
      left: _toDouble(map['left'] ?? map['horizontal']) ?? 0,
      right: _toDouble(map['right'] ?? map['horizontal']) ?? 0,
      top: _toDouble(map['top'] ?? map['vertical']) ?? 0,
      bottom: _toDouble(map['bottom'] ?? map['vertical']) ?? 0,
    );
  }

  static Color? color(dynamic raw) {
    if (raw == null) return null;
    final text = raw.toString().trim();
    if (text.isEmpty) return null;
    var hex = text.replaceFirst('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    if (hex.length != 8) return null;
    final value = int.tryParse(hex, radix: 16);
    if (value == null) return null;
    return Color(value);
  }

  static BorderRadius? borderRadius(dynamic raw) {
    if (raw == null) return null;
    if (raw is num) return BorderRadius.circular(raw.toDouble());
    if (raw is Map) {
      final map = Map<String, dynamic>.from(raw);
      if (map.containsKey('all')) {
        return BorderRadius.circular(_toDouble(map['all']) ?? 0);
      }
    }
    return null;
  }

  static MainAxisAlignment mainAxisAlignment(dynamic raw) {
    switch (raw?.toString()) {
      case 'start':
        return MainAxisAlignment.start;
      case 'end':
        return MainAxisAlignment.end;
      case 'center':
        return MainAxisAlignment.center;
      case 'spaceBetween':
        return MainAxisAlignment.spaceBetween;
      case 'spaceAround':
        return MainAxisAlignment.spaceAround;
      case 'spaceEvenly':
        return MainAxisAlignment.spaceEvenly;
      default:
        return MainAxisAlignment.start;
    }
  }

  static CrossAxisAlignment crossAxisAlignment(dynamic raw) {
    switch (raw?.toString()) {
      case 'start':
        return CrossAxisAlignment.start;
      case 'end':
        return CrossAxisAlignment.end;
      case 'center':
        return CrossAxisAlignment.center;
      case 'stretch':
        return CrossAxisAlignment.stretch;
      case 'baseline':
        return CrossAxisAlignment.baseline;
      default:
        return CrossAxisAlignment.center;
    }
  }

  static Alignment alignment(dynamic raw) {
    switch (raw?.toString()) {
      case 'topLeft':
        return Alignment.topLeft;
      case 'topCenter':
        return Alignment.topCenter;
      case 'topRight':
        return Alignment.topRight;
      case 'centerLeft':
        return Alignment.centerLeft;
      case 'centerRight':
        return Alignment.centerRight;
      case 'bottomLeft':
        return Alignment.bottomLeft;
      case 'bottomCenter':
        return Alignment.bottomCenter;
      case 'bottomRight':
        return Alignment.bottomRight;
      default:
        return Alignment.center;
    }
  }

  static FontWeight fontWeight(dynamic raw) {
    switch (raw?.toString()) {
      case 'w100':
        return FontWeight.w100;
      case 'w200':
        return FontWeight.w200;
      case 'w300':
        return FontWeight.w300;
      case 'w400':
      case 'normal':
        return FontWeight.w400;
      case 'w500':
        return FontWeight.w500;
      case 'w600':
        return FontWeight.w600;
      case 'w700':
      case 'bold':
        return FontWeight.w700;
      case 'w800':
        return FontWeight.w800;
      case 'w900':
        return FontWeight.w900;
      default:
        return FontWeight.w400;
    }
  }

  static TextStyle? textStyle(Map<String, dynamic> style) {
    final raw = style['textStyle'];
    if (raw is! Map) {
      if (style['fontSize'] == null && style['color'] == null) return null;
      return TextStyle(
        fontSize: _toDouble(style['fontSize']),
        color: color(style['color']),
        fontWeight: style['fontWeight'] != null
            ? fontWeight(style['fontWeight'])
            : null,
      );
    }
    final map = Map<String, dynamic>.from(raw);
    return TextStyle(
      fontSize: _toDouble(map['fontSize']),
      color: color(map['color']),
      fontWeight:
          map['fontWeight'] != null ? fontWeight(map['fontWeight']) : null,
      letterSpacing: _toDouble(map['letterSpacing']),
      height: _toDouble(map['height']),
    );
  }

  static BoxDecoration? boxDecoration(Map<String, dynamic> style) {
    final decoration = style['decoration'];
    final map = decoration is Map
        ? Map<String, dynamic>.from(decoration)
        : <String, dynamic>{
            if (style['color'] != null) 'color': style['color'],
            if (style['borderRadius'] != null)
              'borderRadius': style['borderRadius'],
          };
    if (map.isEmpty) return null;

    List<BoxShadow>? shadows;
    final shadowRaw = map['boxShadow'];
    if (shadowRaw is List) {
      shadows = shadowRaw.whereType<Map>().map((s) {
        final m = Map<String, dynamic>.from(s);
        final offset = m['offset'] is Map
            ? Map<String, dynamic>.from(m['offset'] as Map)
            : const <String, dynamic>{};
        return BoxShadow(
          color: color(m['color']) ?? Colors.black26,
          blurRadius: _toDouble(m['blur']) ?? 0,
          offset: Offset(
            _toDouble(offset['x']) ?? 0,
            _toDouble(offset['y']) ?? 0,
          ),
        );
      }).toList();
    }

    Gradient? gradient;
    final gradientRaw = map['gradient'];
    if (gradientRaw is Map) {
      final g = Map<String, dynamic>.from(gradientRaw);
      final colors = (g['colors'] as List?)
              ?.map(color)
              .whereType<Color>()
              .toList() ??
          const <Color>[];
      if (colors.length >= 2) {
        gradient = LinearGradient(
          begin: alignment(g['begin']),
          end: alignment(g['end']),
          colors: colors,
        );
      }
    }

    Border? border;
    final borderRaw = map['border'];
    if (borderRaw is Map) {
      final b = Map<String, dynamic>.from(borderRaw);
      border = Border.all(
        color: color(b['color']) ?? Colors.black12,
        width: _toDouble(b['width']) ?? 1,
      );
    }

    return BoxDecoration(
      color: gradient == null ? color(map['color']) : null,
      borderRadius: borderRadius(map['borderRadius']),
      boxShadow: shadows,
      gradient: gradient,
      border: border,
    );
  }

  static double? _toDouble(dynamic raw) {
    if (raw is num) return raw.toDouble();
    return double.tryParse(raw?.toString() ?? '');
  }

  static double? width(Map<String, dynamic> style) =>
      _toDouble(style['width']);

  static double? height(Map<String, dynamic> style) =>
      _toDouble(style['height']);

  static double? gap(Map<String, dynamic> style) => _toDouble(style['gap']);
}
