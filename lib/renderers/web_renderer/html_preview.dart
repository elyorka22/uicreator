import 'dart:convert';

import 'package:ai_ui_studio/renderers/preview_frame/artifact_preview_frame.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Local HTML preview via WebView. No remote server required.
/// JavaScript is enabled only for preview of generated HTML; navigation is locked down.
class HtmlPreview extends StatefulWidget {
  const HtmlPreview({
    super.key,
    required this.html,
    this.css,
    this.js,
    this.framed = true,
  });

  final String html;
  final String? css;
  final String? js;
  final bool framed;

  @override
  State<HtmlPreview> createState() => _HtmlPreviewState();
}

class _HtmlPreviewState extends State<HtmlPreview> {
  late final WebViewController _controller;
  var _ready = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            // Lock navigation to the in-memory document only.
            if (request.url.startsWith('data:')) {
              return NavigationDecision.navigate;
            }
            return NavigationDecision.prevent;
          },
        ),
      );
    _load();
  }

  @override
  void didUpdateWidget(covariant HtmlPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.html != widget.html ||
        oldWidget.css != widget.css ||
        oldWidget.js != widget.js) {
      _load();
    }
  }

  void _load() {
    final document = _composeHtml(widget.html, widget.css, widget.js);
    _controller.loadRequest(
      Uri.dataFromString(
        document,
        mimeType: 'text/html',
        encoding: utf8,
      ),
    );
    setState(() => _ready = true);
  }

  static String _composeHtml(String html, String? css, String? js) {
    final trimmed = html.trim();
    if (trimmed.toLowerCase().contains('<html')) {
      return trimmed;
    }
    return '''
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1"/>
<style>
html, body {
  margin: 0;
  padding: 0;
  min-height: 100%;
  background: transparent;
  font-family: system-ui, -apple-system, sans-serif;
}
body {
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 12px;
  box-sizing: border-box;
}
${css ?? ''}
</style>
</head>
<body>
$html
<script>
${js ?? ''}
</script>
</body>
</html>
''';
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Center(child: CircularProgressIndicator());
    }
    final web = SizedBox(
      height: 320,
      width: double.infinity,
      child: WebViewWidget(controller: _controller),
    );
    if (!widget.framed) return web;
    return ArtifactPreviewFrame(
      caption: 'HTML preview — готовый элемент в контейнере',
      child: web,
    );
  }
}
