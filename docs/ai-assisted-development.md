# AI-Assisted Development

FadDompet may use AI-assisted tooling for development, review, documentation, and maintenance. AI assistance is treated as a workflow aid, not as a replacement for human review.

## Review Standard

All AI-assisted changes require human review before they are merged or released. Contributors are responsible for the code, documentation, and configuration they submit.

AI-generated changes must:

- Stay within the requested scope
- Avoid secrets and local credentials
- Avoid tracking, ads, backend services, and unnecessary permissions
- Keep privacy and security claims accurate
- Pass `flutter analyze`
- Pass `flutter test`

## Appropriate Uses

AI assistance can help with:

- Code cleanup
- Tests
- Documentation
- UI consistency
- Bug fixes
- Small refactors
- Release checklist updates
- Repository hygiene

## Extra Review Required

The following changes need careful human review:

- Database migrations
- Release signing configuration
- App lock and PIN flows
- Biometric behavior
- Android permission changes
- Backup and import logic
- Update and APK download logic
- Security-sensitive documentation

## Documentation Rules

AI must not fabricate features in documentation. Documentation should describe behavior that exists in the app or is clearly marked as planned.

AI must not claim that FadDompet is more secure than it is. App lock is local protection, not full database encryption. Backup files contain financial data and should be stored safely.

## Repository Instructions

AI coding agents should read `AGENTS.md` before changing the project. GitHub Copilot should follow `.github/copilot-instructions.md`.
