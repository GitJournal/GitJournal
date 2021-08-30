# Building Instructions

* It's best to just work on this on Android - the ios setup is far more complicated and I haven't managed to automate it.

## Environment Setup

1. Install [Flutter](https://flutter.dev/docs/get-started/install) v1 through official guidelines. The last v1.22.6 will do.
1. As a part of flutter installation, you will need to install [Android Studio](https://developer.android.com/studio)
1. Use [AVD manager](https://developer.android.com/studio/run/managing-avds) from Android Studio, to create device for local development.
1. Project contains `:git_binding` dependency, so it needs Android NDK. You need to install through [SDK Manager](https://developer.android.com/studio/projects/install-ndk). GitJournal has only been tested with NDK release 19. It would be best to install that.
1. Run command `flutter run --flavor dev --debug`: it will connect to available device and run program.

   1. Or you can run `flutter build apk --flavor dev --debug` and see apk under `build/app/outputs/apk/` folder

1. You will see application on emulator, you are all setup. You can start with [app.dart](lib/app.dart) file to exploring code.

## Trouble Shooting

### Build fails on project `git_bindings` with a `NullPointerException`:
```
FAILURE: Build failed with an exception.

* What went wrong:
A problem occurred configuring project ':git_bindings'.
> java.lang.NullPointerException (no error message)

* Try:
Run with --stacktrace option to get the stack trace. Run with --info or --debug option to get more log output. Run with --scan to get full insights.

* Get more help at https://help.gradle.org
```

Try if changing the version of `com.android.tools.build:gradle` in the buildscript dependencies of [android/build.gradle:13](android/build.gradle) from
```gradle
classpath 'com.android.tools.build:gradle:3.3.2'
```
to
```gradle
classpath 'com.android.tools.build:gradle:3.5.0'
```
fixes your issue.

### Build fails with a lots of errors from linking:

```
ld: error: relocation R_AARCH64_PREL64 cannot be used against symbol OPENSSL_armcap_P; recompile with -fPIC
```

Make sure you install NDK release 19, to do this you need to enable `Show Package Details` to show the available Versions.

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
