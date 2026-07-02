# Release Checklist

Use this checklist before publishing a FadDompet GitHub Release.

## Before Build

- Confirm `pubspec.yaml` version and build number.
- Run `flutter pub get`.
- Run `flutter analyze`.
- Run `flutter test`.
- Confirm `android/key.properties` exists locally.
- Confirm no keystore or signing secrets are staged.

## Build

```bash
flutter build apk --release --split-per-abi
```

Expected APK outputs:

- `build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk`
- `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk`
- `build/app/outputs/flutter-apk/app-x86_64-release.apk`

## Rename APKs

Use release-friendly names:

```txt
FadDompet-vX.X.X-armeabi-v7a.apk
FadDompet-vX.X.X-arm64.apk
FadDompet-vX.X.X-x86_64.apk
```

## Generate SHA256

PowerShell:

```powershell
Get-FileHash .\FadDompet-vX.X.X-arm64.apk -Algorithm SHA256
```

Add checksums to the GitHub Release notes.

## Publish

- Upload APK files to GitHub Releases.
- Include a short changelog.
- Include SHA256 checksums.
- Mark the release as latest when appropriate.
- Download the `arm64` APK from the release and smoke test install on Android.
