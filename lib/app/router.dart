import 'package:ai_ui_studio/features/components/library_screen.dart';
import 'package:ai_ui_studio/features/editor/code_editor_screen.dart';
import 'package:ai_ui_studio/features/generator/chat_screen.dart';
import 'package:ai_ui_studio/features/generator/generator_screen.dart';
import 'package:ai_ui_studio/features/home/home_screen.dart';
import 'package:ai_ui_studio/features/settings/provider_edit_screen.dart';
import 'package:ai_ui_studio/features/settings/providers_list_screen.dart';
import 'package:ai_ui_studio/features/settings/settings_screen.dart';
import 'package:ai_ui_studio/features/shell/app_shell.dart';
import 'package:ai_ui_studio/features/studio/studio_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createAppRouter() {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/generate',
                builder: (context, state) => const GeneratorScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/library',
                builder: (context, state) => const LibraryScreen(),
                routes: [
                  GoRoute(
                    path: 'chat',
                    builder: (context, state) => const ChatScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
                routes: [
                  GoRoute(
                    path: 'providers',
                    builder: (context, state) => const ProvidersListScreen(),
                    routes: [
                      GoRoute(
                        path: 'new',
                        builder: (context, state) =>
                            const ProviderEditScreen(),
                      ),
                      GoRoute(
                        path: ':id',
                        builder: (context, state) => ProviderEditScreen(
                          providerId: state.pathParameters['id'],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/studio/:id',
        builder: (context, state) => StudioScreen(
          componentId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/editor/:id',
        builder: (context, state) => CodeEditorScreen(
          componentId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/chat',
        builder: (context, state) => const ChatScreen(),
      ),
    ],
  );
}
