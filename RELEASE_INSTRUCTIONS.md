# Release Instructions

## Prerequisites
- GitHub CLI installed
- Proper permissions to create releases in the repository
- Built APK files in `build/app/outputs/flutter-apk/`

## Creating a New Release

1. Update the version in `pubspec.yaml` if needed
2. Update `RELEASE_NOTES.md` with the changes for this release
3. Build the APK files using `flutter build apk --split-per-abi`
4. Run the following command from the project root:

```bash
gh release create v0.6.3 \
  --title "v0.6.3" \
  --notes-file RELEASE_NOTES.md \
  build/app/outputs/flutter-apk/app-arm64-v8a-release.apk \
  build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk \
  build/app/outputs/flutter-apk/app-x86_64-release.apk
```

## Release Notes Guidelines

Release notes should include:
- New features that users can directly experience
- Bug fixes that resolve user-facing issues
- Performance improvements
- UI/UX enhancements
- Any breaking changes or important notices

Focus on changes that end users can perceive rather than internal code changes.