# Security Policy

## Supported Versions

Security fixes are focused on the latest public release of FadDompet.

| Version | Supported |
| --- | --- |
| Latest release | Yes |
| Older releases | Best effort |

## Security Model

FadDompet is an offline-first Android app for personal finance tracking.

- No account is required.
- No cloud sync is used.
- No ads are included.
- No analytics or tracking is included.
- Core financial data is stored locally on the device.
- Local app lock uses a PIN and optional biometric unlock when enabled.
- PIN data is not stored as raw text.
- App lock is not full database encryption.
- Backup files contain financial data and should be stored safely.
- APK files installed from GitHub may trigger Android or Play Protect sideload warnings.

Do not treat FadDompet as a replacement for device-level security, encrypted storage, or a password manager.

## Reporting a Vulnerability

For non-sensitive bugs, open a GitHub issue.

For sensitive security issues, contact the maintainer privately through the maintainer's GitHub profile before publishing details.

Please include:

- A clear description of the issue
- Steps to reproduce
- Affected app version
- Android version and device model
- Any relevant logs or screenshots with personal data removed

## Backup Safety

Backup and restore are user-controlled. FadDompet validates backup files before restore, but users should keep backup files in a safe place and avoid sharing them publicly.

## APK Verification

When a release includes a SHA256 checksum, verify the APK before installing it:

```powershell
Get-FileHash .\FadDompet-vX.X.X-arm64.apk -Algorithm SHA256
```

FadDompet does not claim to be "100% secure". Security is handled as an ongoing maintenance responsibility.
