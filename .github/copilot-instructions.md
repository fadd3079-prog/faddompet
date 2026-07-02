# GitHub Copilot Instructions

FadDompet is a Flutter/Dart Android app for offline-first personal finance tracking.

Follow these rules when suggesting changes:

- Use the existing feature-first architecture.
- Keep app logic offline-first and local by default.
- Do not add backend, cloud sync, login, ads, analytics, or tracking.
- Use Riverpod providers and repositories for data/state access.
- Keep database logic out of UI widgets.
- Use existing theme tokens, spacing, radius, typography, and shared components.
- Keep user-facing UI copy in Bahasa Indonesia.
- Keep the public app name as `FadDompet`.
- Avoid unnecessary dependencies and Android permissions.
- Consider low-end Android performance.
- Avoid broad rewrites of working systems.
- Treat backup/import, app lock, permissions, and update/download flows as security-sensitive.
- Keep privacy and security claims accurate.
- Run `flutter analyze` and `flutter test` before marking work complete.
