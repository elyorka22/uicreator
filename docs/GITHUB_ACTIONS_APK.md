# Building and downloading the Android APK

## GitHub Actions (recommended)

Workflow file: [`.github/workflows/android-apk.yml`](../.github/workflows/android-apk.yml)

### Triggers

- Push to `main`
- Pull requests
- Manual run via **Actions → Android APK → Run workflow** (`workflow_dispatch`)

### What the workflow does

1. Sets up Java 17 and Flutter **3.24.5**
2. `flutter pub get`
3. `flutter analyze`
4. `flutter test`
5. `flutter build apk --release`
6. Uploads artifact `ai-ui-studio-apk` containing:

`build/app/outputs/flutter-apk/app-release.apk`

### Download steps

1. Open the GitHub repository in a browser.
2. Go to **Actions**.
3. Select the latest successful **Android APK** run.
4. In **Artifacts**, download **ai-ui-studio-apk**.
5. Unzip the artifact to get `app-release.apk`.
6. Copy the APK to your Android phone and open it to install.
7. If needed, enable **Install unknown apps** for your file manager/browser.

### Signing note

This project’s `android/app/build.gradle` currently signs the release build with the **debug keystore** so CI can produce an installable APK without secret keystores.

That is fine for personal testing. For Play Store / production distribution, replace `signingConfig signingConfigs.debug` with a real release keystore provided through GitHub Secrets — do **not** commit keystores or passwords.

### Secrets

The workflow does **not** need AI API keys. End users enter keys inside the app Settings.

## Local APK build

```bash
export PATH="/path/to/flutter/bin:$PATH"
cd /path/to/uicreator
flutter pub get
flutter analyze
flutter test
flutter build apk --release
```

Output:

`build/app/outputs/flutter-apk/app-release.apk`
