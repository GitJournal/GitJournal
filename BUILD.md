# Building Instructions

Current verified macOS flow for building the Android `dev/debug APK` is documented in [`docs/android-dev-build.md`](docs/android-dev-build.md). The instructions below are older and should be treated as historical context.

Android 打包版本号的当前说明也以 [`docs/android-dev-build.md`](docs/android-dev-build.md) 为准。简要规则是：

- 默认版本来源于 [`pubspec.yaml`](pubspec.yaml) 的 `version: x.y.z+N`
- 其中 `x.y.z` 对应 Android `versionName`
- `N` 对应 Android `versionCode`
- `dev` flavor 会额外追加 `-dev`，因此 `1.89.0+10` 会打成 `1.89.0-dev (10)`
- 如果构建命令显式传入 `--build-number`，它会覆盖默认的 `versionCode`

- It's best to just work on this on Android - the ios setup is far more complicated and I haven't managed to automate it.

## Environment Setup

1. Install [Flutter](https://flutter.dev/docs/get-started/install) v1 through official guidelines. The last v1.22.6 will do.
1. As a part of flutter installation, you will need to install [Android Studio](https://developer.android.com/studio)
1. Use [AVD manager](https://developer.android.com/studio/run/managing-avds) from Android Studio, to create device for local development.
1. Run command `flutter run --flavor dev --debug`: it will connect to available device and run program.

   1. Or you can run `flutter build apk --flavor dev --debug` and see apk under `build/app/outputs/apk/` folder

1. You will see application on emulator, you are all setup. You can start with [app.dart](lib/app.dart) file to exploring code.

## Trouble Shooting

## IDE Setup

VS Code has great plugin for flutter, but you need to add args to launch.json.
Example launch.json:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Flutter",
      "request": "launch",
      "type": "dart",
      "args": ["--flavor", "dev"]
    }
  ]
}
```

### Debugging with breakpoints

To use Android Studio's debugger with breakpoints:

- Open your local repo with Android Studio.
- Android Studio should already have a Flutter Run Configuration named "main.dart", visible at the top of the window.
- Edit this run configuration. For "Build flavor", type "dev" and save the configuration.
- On the top bar of Android Studio, with "main.dart" selected, click the debug button (it has hover text "Debug main.dart").
