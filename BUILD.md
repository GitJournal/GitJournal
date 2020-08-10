# Building Instructions

* It's best to just work on this on Android - the ios setup is far more complicated and I haven't managed to automate it.

## Environment setup

1. Install [Flutter](https://flutter.dev/docs/get-started/install) through official guidilines
2. As a part of flutter installation, you will need to install [Android Studio](https://developer.android.com/studio)
3. Use [AVD manager](https://developer.android.com/studio/run/managing-avds) from Android Studio, to create device for local development.
4. Project contains `:git_binding` dependency, so it needs Android NDK. You need to install through [SDK Manager](https://developer.android.com/studio/projects/install-ndk).
5. Run the `scripts/setup_env.dart` script
6. Run command `flutter run --flavor dev --debug`: it will connect to available device and run program.

   1. Or you can run `flutter build apk --flavor dev --debug` and see apk under `build/app/outputs/apk/` folder

7. You will see application on emulator, you are all setup. You can start with [app.dart](lib/app.dart) file to exploring code.

## IDE Setup

VS Code has great plugin for flutter, but you need to add args to launch.json.
Example launch.json:

``` json
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

