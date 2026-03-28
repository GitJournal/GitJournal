# Android dev 包构建流程

本文档记录当前仓库在 macOS 上构建 `dev/debug APK` 的可用流程。下面的命令已经在本仓库验证通过，产物为 `build/app/outputs/flutter-apk/app-dev-debug.apk`。

## 适用范围

- 构建目标：`dev` flavor 的 `debug APK`
- 产物路径：`build/app/outputs/flutter-apk/app-dev-debug.apk`
- 适用场景：本地调试、功能验证、非正式分发

`dev/debug` 构建不依赖 release 签名。`android/app/build.gradle` 中只有 `release` buildType 使用了 `signingConfigs.release`。

## 版本号管理

Android 版本号默认由 [`pubspec.yaml`](../pubspec.yaml) 管理：

```yaml
version: 1.89.0+10
```

对应关系如下：

- `1.89.0` -> Android `versionName`
- `10` -> Android `versionCode`

[`android/app/build.gradle`](../android/app/build.gradle) 通过 Flutter 注入的值读取：

```gradle
versionCode flutter.versionCode
versionName flutter.versionName
```

`dev` flavor 还会额外附加：

```gradle
versionNameSuffix "-dev"
```

所以 `dev/debug APK` 实际版本通常会显示为 `1.89.0-dev`，版本号为 `10`。

如果构建命令显式传入 `--build-number`，则会覆盖默认的 `versionCode`。例如 [`scripts/build_android.sh`](../scripts/build_android.sh) 会把 Git 提交数作为 `--build-number` 传给 Flutter。

## 前置条件

当前仓库要求：

- Flutter `>=3.41.5`，见 `pubspec.yaml`
- Android Gradle Plugin `8.9.1`
- Gradle Wrapper `8.12`
- 建议使用 JDK 21。JDK 25 在本仓库构建时触发过 `Unsupported class file major version 69`

## 1. 安装工具

推荐在 macOS + Homebrew 下执行：

```bash
brew install --cask android-commandlinetools
brew install openjdk@21
```

如果本机没有 Flutter，可在仓库根目录放一个本地 Flutter SDK：

```bash
git clone --depth 1 --branch 3.41.5 https://github.com/flutter/flutter.git .flutter
```

## 2. 配置环境变量

先进入仓库根目录：

```bash
ROOT="$(pwd)"
export JAVA_HOME="/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home"
export ANDROID_HOME="/opt/homebrew/share/android-commandlinetools"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export PATH="$JAVA_HOME/bin:$ANDROID_HOME/platform-tools:$ROOT/.flutter/bin:$PATH"
```

如果网络较慢，可加本地代理：

```bash
export http_proxy="http://127.0.0.1:7897"
export https_proxy="http://127.0.0.1:7897"
export GRADLE_OPTS="-Dhttp.proxyHost=127.0.0.1 -Dhttp.proxyPort=7897 -Dhttps.proxyHost=127.0.0.1 -Dhttps.proxyPort=7897"
```

Flutter Android Maven 依赖建议走镜像，避免 `storage.googleapis.com` 握手失败：

```bash
export FLUTTER_STORAGE_BASE_URL="https://storage.flutter-io.cn"
```

## 3. 安装 Android SDK 组件

```bash
yes | sdkmanager --sdk_root="$ANDROID_HOME" --licenses
sdkmanager --sdk_root="$ANDROID_HOME" \
  "platform-tools" \
  "platforms;android-36" \
  "build-tools;36.0.0"
```

首次构建时 Gradle 还可能自动安装 `cmake;3.22.1`，这是正常现象。

## 4. 写入 `android/local.properties`

`android/settings.gradle` 强依赖 `flutter.sdk`，因此需要配置：

```properties
flutter.sdk=/绝对路径/GitJournal/.flutter
sdk.dir=/opt/homebrew/share/android-commandlinetools
```

如果你使用全局 Flutter，把 `flutter.sdk` 改成全局 SDK 绝对路径即可。

## 5. 构建 dev/debug APK

```bash
flutter pub get
flutter build apk --flavor dev --debug
```

如果你使用仓库内的 Flutter SDK，也可以显式写成：

```bash
./.flutter/bin/flutter --suppress-analytics build apk --flavor dev --debug
```

## 6. 构建结果

成功后 APK 位于：

```bash
build/app/outputs/flutter-apk/app-dev-debug.apk
```

## 常见问题

### `flutter.sdk not set in local.properties`

说明 `android/local.properties` 缺少 `flutter.sdk`，见 `android/settings.gradle`。

### `No Android SDK found`

说明 `ANDROID_HOME` 或 `sdk.dir` 未配置，或 Android SDK 组件未安装完成。

### `Unsupported class file major version 69`

说明当前使用了过新的 JDK。切换到 JDK 21 后再试。

### `storage.googleapis.com` 或 `download.flutter.io` 下载失败

保留代理环境变量，同时设置：

```bash
export FLUTTER_STORAGE_BASE_URL="https://storage.flutter-io.cn"
```

### NDK 版本警告

当前仓库已经在 [`android/app/build.gradle`](../android/app/build.gradle) 中固定：

```gradle
ndkVersion "28.2.13676358"
```

如果本机没有安装这个 NDK 版本，可执行：

```bash
sdkmanager --sdk_root="$ANDROID_HOME" "ndk;28.2.13676358"
```
