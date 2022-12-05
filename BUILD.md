# How to build OpenStop

## Prerequisites

Install and setup the [Flutter SDK](https://docs.flutter.dev/get-started/install).

## Build process

To build/run the app, navigate into the project and run the following commands:

### Get the necessary dependencies
```console
flutter pub get
```
### Create any generated code files
Visit the [build_runner package](https://pub.dev/packages/build_runner#built-in-commands) for more information.
```console
flutter pub run build_runner build --delete-conflicting-outputs
```
### Build and run the app
You can also omit the entire API key parameter. In this case the underlying map tiles won't be available in your build.
```console
flutter run --dart-define THUNDERFOREST_API_KEY=${api key}
```
Building for **Android** requires a build flavor to be specified as the app currently has two different Android flavors: `standard` and `fdroid`.

```console
flutter run --flavor standard --dart-define THUNDERFOREST_API_KEY=${api key}
```

## Additional notes

By default the app uses the [openstreetmap development server](https://master.apis.dev.openstreetmap.org) for login and upload. In order to use the live servers the custom parameter `--dart-define=IS_RELEASE=true` has to be set when running/building the app. Note that this has nothing to do with flutter *release*, *profile* and *debug* mode.

To build the app for a specific platform (apk, appbundle, ios, web) in its ultimate form (except code signing), use the following command:
```console
flutter build ${platform} --release --dart-define=THUNDERFOREST_API_KEY=${api key} --dart-define=IS_RELEASE=true [--flavor standard]
```
