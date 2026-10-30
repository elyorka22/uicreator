import 'package:ai_ui_studio/app/router.dart';
import 'package:ai_ui_studio/app/theme.dart';
import 'package:ai_ui_studio/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AiUiStudioApp extends StatelessWidget {
  AiUiStudioApp({super.key, GoRouter? router})
      : _router = router ?? createAppRouter();

  final GoRouter _router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConstants.appName,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
