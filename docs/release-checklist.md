# Release Checklist

Use this checklist before publishing the FadDompet v1.3.0 GitHub Release.

## Before Build

- Confirm `pubspec.yaml` version is `1.3.0+5000`.
- Run `flutter pub get`.
- Run `flutter analyze`.
- Run `flutter test`.
- Confirm release build passed.
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
FadDompet-v1.3.0-armeabi-v7a.apk
FadDompet-v1.3.0-arm64.apk
FadDompet-v1.3.0-x86_64.apk
```

PowerShell:

```powershell
Copy-Item "build\app\outputs\flutter-apk\app-arm64-v8a-release.apk" "build\app\outputs\flutter-apk\FadDompet-v1.3.0-arm64.apk"
Copy-Item "build\app\outputs\flutter-apk\app-armeabi-v7a-release.apk" "build\app\outputs\flutter-apk\FadDompet-v1.3.0-armeabi-v7a.apk"
Copy-Item "build\app\outputs\flutter-apk\app-x86_64-release.apk" "build\app\outputs\flutter-apk\FadDompet-v1.3.0-x86_64.apk"
```

## Generate SHA256

PowerShell:

```powershell
Get-FileHash .\FadDompet-v1.3.0-arm64.apk -Algorithm SHA256
```

Add checksums to the GitHub Release notes.

## Publish

- Upload APK files to GitHub Releases.
- Push tag `v1.3.0`.
- Create GitHub Release `FadDompet v1.3.0`.
- Include a short changelog.
- Include SHA256 checksums.
- Include SHA256 in release notes.
- Mark the release as latest when appropriate.
- Download the `arm64` APK from the release and smoke test install on Android.
