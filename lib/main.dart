import 'package:ai_ui_studio/app/app.dart';
import 'package:ai_ui_studio/app/bootstrap.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  await bootstrap();
  runApp(
    const ProviderScope(
      child: _Root(),
    ),
  );
}

class _Root extends StatelessWidget {
  const _Root();

  @override
  Widget build(BuildContext context) {
    return AiUiStudioApp();
  }
}
