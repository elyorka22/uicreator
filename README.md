# AI UI Studio

Local-first Flutter Android app that generates reusable UI components with **your own AI API keys** (BYOK). No custom backend.

## Features (MVP)

- Configure many AI providers (OpenAI, DeepSeek, Groq, OpenRouter, Mistral, Together, Anthropic, Gemini, custom OpenAI-compatible) with secure key storage
- Generate UI from natural language (schema + source)
- Live Flutter preview from Universal UI Schema (never executes AI Dart)
- HTML WebView preview for HTML exports
- React/JSX generation + export (no in-app React runtime)
- Component library (Drift/SQLite), studio, code editor, ZIP export
- GitHub Actions release APK artifact

## Requirements

- Flutter 3.24.x / Dart 3.5.x
- Android minSdk 23+

## Run

```bash
flutter pub get
flutter run
```

## Test

```bash
flutter analyze
flutter test
```

## Build APK

Local:

```bash
flutter build apk --release
# => build/app/outputs/flutter-apk/app-release.apk
```

CI: see [docs/GITHUB_ACTIONS_APK.md](docs/GITHUB_ACTIONS_APK.md)

## First-run flow

1. Settings → AI providers → add OpenAI-compatible or Anthropic key
2. Generate → describe a UI → Generate UI
3. Open in Studio → preview / schema / code
4. Save is automatic when opening Studio from generation; Library lists components
5. Export ZIP from Studio

## Docs

- [MVP status](docs/MVP_STATUS.md)
- [Implementation plan](docs/IMPLEMENTATION_PLAN.md)
- [Phase 1 status](docs/PHASE1_STATUS.md)
- [GitHub Actions APK](docs/GITHUB_ACTIONS_APK.md)
- Schema asset: `assets/schema/universal_ui.schema.json`

## Security

API keys live in Flutter Secure Storage (Android Keystore-backed). They are never written to SQLite or provider metadata JSON. Logs redact secrets. HTTPS is default; HTTP requires an explicit opt-in warning in Settings.
