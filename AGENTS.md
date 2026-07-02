# AGENTS.md

This file is the primary guide for AI coding agents working on FadDompet.

## Project Overview

FadDompet is an offline-first Android personal finance tracker built with Flutter. The app helps users manage income, expenses, transfers, wallets, budgets, backups, and app updates locally on their device.

## Tech Stack

- Flutter
- Dart
- Drift
- SQLite
- Riverpod
- fl_chart
- Android

## Architecture Map

- `lib/app` for app bootstrap, theme, and global providers
- `lib/data` for database, repositories, and data models
- `lib/features` for feature-first UI and flows
- `lib/shared` for reusable UI components
- `lib/core` for constants, enums, formatters, and helpers
- `test` for unit and widget tests
- `android` for Android platform configuration

Keep database and platform logic out of UI widgets. Use repositories and providers for app state and data access.

## Commands

Run these checks before reporting completion:

```bash
flutter pub get
flutter analyze
flutter test
```

For release builds:

```bash
flutter build apk --release --split-per-abi
```

## Coding Rules

- Keep FadDompet offline-first.
- Keep data local by default.
- Keep user-facing app name as `FadDompet`.
- Technical slug and package names may remain `faddompet`.
- Keep UI text in Bahasa Indonesia.
- Prefer small, reviewable changes.
- Use existing repositories, providers, theme tokens, and shared components.
- Do not rewrite working systems without a clear reason.
- Do not add unnecessary dependencies.
- Do not add backend, login, cloud sync, ads, tracking, or analytics.
- Do not commit generated junk, local exports, backups, or temporary reports.

## UI and UX Rules

- Keep the visual direction Apple-like/iOS modern, but lightweight.
- Use existing design tokens and reusable components.
- Keep touch targets comfortable for Android.
- Maintain contrast and readability.
- Keep interactions fast and subtle.
- Avoid excessive blur, glass effects, shadows, gradients, or animation.
- Avoid generic Material defaults when an existing premium component exists.
- Keep copy clear, short, beginner-friendly, and professional.

## Security Rules

- Do not store raw PINs.
- App lock is local protection, not full database encryption.
- Backup files contain financial data.
- Treat backup/import and update/download flows as security-sensitive.
- Do not install APKs silently.
- Do not add suspicious or unnecessary Android permissions.
- Do not commit `android/key.properties`, `.jks`, `.keystore`, or signing secrets.
- Keep security and privacy claims accurate.

## Privacy Rules

- No account requirement.
- No cloud sync for core features.
- No ads.
- No analytics or tracking.
- No hidden network activity.
- Internet access should remain tied to user-triggered actions such as update checks, APK downloads, external links, or sharing exports.

## Data Rules

- Use integer values for Rupiah.
- Keep Drift queries in repositories or DAOs, not directly in UI.
- Validate imports before destructive restore.
- Transfers must not count as income or expense.
- Preserve migration safety for existing local data.

## Release Rules

- Release APKs must be built intentionally.
- Release signing secrets stay local.
- Generate SHA256 checksums for published APKs.
- Keep release notes concise and accurate.
- Do not publish debug-signed APKs as official releases.

## Do Not Do

- Do not add backend services.
- Do not add login or online accounts.
- Do not add cloud sync.
- Do not add ads, analytics, or tracking.
- Do not add chatbot or AI features to the app.
- Do not add broad storage, overlay, accessibility, SMS, contacts, or location permissions.
- Do not silently install updates.
- Do not fabricate features in documentation.

## Report Format

When an AI agent changes code or repository files, report:

- Summary
- Changed files
- Tests run
- Build result
- New dependencies
- Permissions changed
- Known limitations
