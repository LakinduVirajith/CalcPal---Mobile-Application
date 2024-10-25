# CalcPal---Mobile-Application

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## DEV Commands

```
flutter clean
```
**Purpose:** Removes the `build` directory and its contents in your Flutter project.

**Explanation:** Useful for clearing build artifacts and ensuring a clean build environment without affecting your source code.

```
flutter pub get
```
**Purpose:** Fetches dependencies listed in your `pubspec.yaml` file and updates your `pubspec.lock` file.

**Explanation:** Ensures all necessary dependencies are installed and resolves version constraints after modifications to `pubspec.yaml`.

```
dart run build_runner build
```
**Purpose:** Generates code based on annotations in your Dart files using the `build_runner` package.

**Explanation:** Essential for tasks like JSON serialization, Hive type adapters, and other code generation tasks defined in your project.

```
flutter pub run flutter_launcher_icons
```
**Purpose:** Updates Flutter app launcher icons to custom icons specified in `pubspec.yaml`.

**Explanation:** Generates platform-specific launcher icons for Android and iOS based on custom icon paths specified in `pubspec.yaml`.

```
dart run flutter_native_splash:create --flutter_native_splash.yaml
```
  - **Purpose:** Generates native splash screens for your Flutter app.
  - **Explanation:** Uses configuration details from `flutter_native_splash.yaml` to create native splash screens (launch screens) for Android and iOS.

```
flutter build apk --build-name=1.0.0 --build-number=1 --split-per-abi
```
**Purpose:** Builds multiple APKs, one for each CPU architecture (ABI).

**Explanation:** This command generates separate APKs for different Android device architectures like:

- armeabi-v7a (32-bit ARM)
- arm64-v8a (64-bit ARM)
- x86 (32-bit Intel)
- x86_64 (64-bit Intel)

The advantage is smaller APK sizes for each architecture, as the app contains only the necessary native code for the target architecture. This method optimizes app size and performance when distributing the app via the Google Play Store, which automatically serves the appropriate APK for each device. However, it produces multiple APKs.

**Output location:**

build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk
build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
build/app/outputs/flutter-apk/app-x86_64-release.apk

```
flutter build apk --build-name=1.0.0 --build-number=1
```
**Purpose:** Builds a single universal APK that supports all architectures.

**Explanation:** This command generates one APK that contains the compiled native libraries for all supported architectures. While this results in a larger APK file, it's suitable when you want a single APK to distribute manually or when the Google Play Store isn't managing device-specific APK versions.

**Output location:**

build/app/outputs/flutter-apk/app-release.apk
```
flutter gen-l10n
```
**Purpose:** Generates localization files based on ARB files located in the `lib/l10n` directory.

**Explanation:** Updates the localization files to include translations for different languages defined in the ARB files. This command is essential for integrating multi-language support into your Flutter app.