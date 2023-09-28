# How to build OpenStop

## Prerequisites

Install and setup the [Flutter SDK](https://docs.flutter.dev/get-started/install).

## Build process

To build/run the app, navigate into the project's folder and execute the following commands:

### 1. Get the necessary dependencies
```console
flutter pub get
```
### 2. Create any generated code files
```console
flutter pub run build_runner build --delete-conflicting-outputs
```
Visit the [build_runner package](https://pub.dev/packages/build_runner#built-in-commands) for more information.
### 3. Build and run the app
```console
flutter run --dart-define THUNDERFOREST_API_KEY=${api key}
```
You can also omit the entire API key parameter. In this case the underlying map tiles won't be available in your build.

## Additional notes

By default the app uses the [OpenStreetMap development server](https://master.apis.dev.openstreetmap.org) for login and upload. In order to use the live servers the custom parameter `--dart-define=IS_RELEASE=true` has to be set when running/building the app.
**Note:** This has nothing to do with flutter's *release*, *profile* and *debug* mode.

To build the app for a specific platform (apk, appbundle, ios, web) in its ultimate form (except code signing), use the following command:
```console
flutter build ${platform} --release --dart-define=THUNDERFOREST_API_KEY=${api key} --dart-define=IS_RELEASE=true [--flavor standard]
```

The app uses a package to automatically generate icons for all platforms. If you modify the corresponding entries under `flutter_icons:` in `pubspec.yaml` or replace the icon images, you have to execute the following command for the modifications to take effect:
```console
flutter pub run flutter_launcher_icons
```

## Troubleshooting

### macOS
If `flutter doctor` reports `CocoaPods not installed` and `gem install cocoapods` doesn't resolve the issue, try updating RubyGems by running `gem update --system`.
