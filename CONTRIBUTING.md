# Contributing to FadDompet

Thanks for your interest in improving FadDompet.

FadDompet is an offline-first Android personal finance app. Contributions should keep the app simple, lightweight, private by default, and comfortable on lower-end Android devices.

## Local Setup

```bash
flutter pub get
flutter analyze
flutter test
```

To build a release APK locally:

```bash
flutter build apk --release --split-per-abi
```

## Branch Naming

Use short, descriptive names:

```txt
feat/update-checker
fix/wallet-balance
docs/readme-polish
refactor/settings-sheet
```

## Commit Style

Use clear commit messages:

```txt
feat: add budget reset flow
fix: prevent transfer to same wallet
docs: update release checklist
test: cover version comparison
```

## Development Principles

- Keep the app offline-first.
- Avoid unnecessary dependencies.
- Do not add accounts, backend sync, ads, analytics, or tracking.
- Keep Android as the main target.
- Keep Bahasa Indonesia for app UI.
- Keep public documentation clear and direct.
- Do not commit secrets, keystores, local config, backups, or exported financial data.

## UI and UX

- Follow the existing design system.
- Keep controls readable and comfortable to tap.
- Avoid heavy blur, excessive shadows, and expensive animations.
- Use simple, beginner-friendly wording in the app.

## AI-Assisted Contributions

AI-assisted pull requests are welcome when they are reviewed, scoped, and tested. Contributors are responsible for everything they submit.

- Do not submit unreviewed AI output.
- Mention AI assistance in the pull request if it materially affected the change.
- Do not use AI output to add secrets, tracking, unnecessary permissions, or undocumented behavior.
- Follow [AGENTS.md](AGENTS.md) and [docs/ai-assisted-development.md](docs/ai-assisted-development.md).
- Run the required checks before opening a pull request.

## Before Opening a Pull Request

Run:

```bash
flutter analyze
flutter test
```

Update documentation when behavior, permissions, release process, or security assumptions change.
