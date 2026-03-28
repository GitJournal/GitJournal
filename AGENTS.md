# Repository Guidelines

## 项目结构与模块组织
GitJournal 是一个 Flutter 应用。主要业务代码位于 `lib/`，按领域拆分为 `core/`、`editors/`、`settings/`、`screens/`、`widgets/` 等目录。测试代码位于 `test/`，通常与生产代码结构对应，例如 `test/core/`、`test/editors/`。静态资源放在 `assets/` 和 `fonts/`，补充文档在 `docs/`，自动化脚本在 `scripts/`，可复用子包在 `packages/git_setup/`。

生成代码位于 `lib/generated/`、`lib/**/generated/` 以及 `*.g.dart`；不要手改，统一通过生成命令更新。

## 构建、测试与开发命令
- `flutter pub get`：安装项目依赖。
- `dart scripts/setup_env.dart gen`：生成本地开发用的 `lib/.env.dart` 空占位配置。
- `flutter run --flavor dev --debug`：使用 `dev` flavor 本地运行应用。
- `make lint` 或 `melos run analyze`：执行静态检查。
- `make test` 或 `flutter test`：运行完整测试套件。
- `make build_runner`：重新生成 build_runner 产物，并清理冲突输出。
- `make protos`：重新生成 protobuf 相关 Dart 文件。

## 代码风格与命名规范
遵循 Dart 和 Flutter 默认风格，使用 2 空格缩进，提交前运行 `dart format .`。Lint 规则基于 `flutter_lints`，并在 `analysis_options.yaml` 中做了仓库级覆盖。类和 Widget 使用 `PascalCase`，方法与变量使用 `camelCase`，文件名使用 `snake_case.dart`。代码应按领域目录归类，生成文件禁止手动修改。

仓库在源码和脚本中使用 REUSE 风格的 SPDX 文件头；修改现有文件时保留原头部，新文件也应按需要补充。

## 测试规范
所有改动都应至少运行 `flutter test`。测试文件统一使用 `_test.dart` 后缀，测试数据放在 `test/testdata/`。新增或修改功能时，优先在对应领域目录补测试，例如编辑器逻辑应更新 `test/editors/`。涉及 UI、同步或平台行为时，在 PR 中写明手动验证步骤，`docs/qa.md` 可作为基础检查清单。

## 提交与合并请求规范
近期提交信息以简短祈使句为主，常见前缀包括 `feat:`、`fix:`、`chore:`、`ci:`、`android:`、`linux:`。单次提交应聚焦单一改动，避免混入无关重构。

Pull Request 应遵循 `.github/PULL_REQUEST_TEMPLATE.md`：关联 issue（如 `Resolve #...` 或 `Connected to #...`），补充测试与评审说明，涉及界面改动时附上截图或视频。

## 安全与配置提示
不要提交明文密钥。环境变量由 `secrets/env.json` 生成，部分签名材料由 CI 单独管理。修改构建或发布流程前，请同时核对 `scripts/` 下对应脚本与 `.github/workflows/` 中关联工作流。
