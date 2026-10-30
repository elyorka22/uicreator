# AI UI Studio — MVP Status

**Status:** MVP implemented  
**Date:** 2026-10-31  
**Application ID:** `com.aiuistudio.app`  
**Display name:** AI UI Studio

## What works

1. **AI provider configuration (BYOK)** — OpenAI-compatible Chat Completions + Anthropic Messages; secure key storage; custom base URLs; HTTPS default with HTTP opt-in warning.
2. **AI UI generation** — dedicated prompts return Universal UI Schema + source files; streaming; parse + validation; controlled repair retry.
3. **Universal UI Schema v1.0** — validated JSON tree for preview/edit.
4. **Flutter Widget Renderer** — fixed renderer only (no eval / no dynamic Dart execution).
5. **Live preview** — Flutter schema preview in Studio; HTML WebView preview for HTML targets; React is export-only.
6. **Component Studio** — preview / schema / code tabs, rename, regenerate, export ZIP.
7. **Local library** — Drift/SQLite persistence, search, open, duplicate, delete.
8. **Code editor** — `re_editor` + `re_highlight`, multi-file tabs, copy/save/share.
9. **Export** — per-component folder + ZIP; collection ZIP; Flutter / HTML / React sources.
10. **GitHub Actions APK** — analyze, test, build release APK artifact.

## Architecture

```
lib/
  ai/           providers, prompts, generation, parsing
  schema/       Universal UI models + validator + style mapper
  renderers/    Flutter widget renderer + HTML WebView preview
  data/         Drift DB, secure storage, repositories
  domain/       entities + repository interfaces
  export/       file + ZIP export
  features/     home, generator, library, studio, editor, settings, chat
```

## Supported schema node types

container, text, button, image, icon, row, column, stack, card, textField, checkbox, switch, divider, padding, scrollView, sizedBox, spacer, center, expanded, flexible

## Preview limitations (honest)

- Flutter preview uses **schema only**, never AI Dart source execution.
- Editing source in the editor **does not** rewrite the schema preview automatically.
- React has **no** in-app runtime preview in this MVP.
- HTML preview uses a sandboxed WebView (`data:` documents; external navigation blocked).
- Complex UIs may be returned as source-only when schema cannot represent them.

## Security

- API keys: Flutter Secure Storage only.
- Keys never stored in Drift tables or provider JSON metadata.
- Logs redact Authorization / x-api-key / sk- patterns.
- Schema validated before render.
- HTTP custom endpoints require explicit Settings opt-in.

## Build / APK

See `docs/GITHUB_ACTIONS_APK.md` and README.
