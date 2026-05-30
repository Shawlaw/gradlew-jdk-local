# 快速开始

## 方式一：AI Prompt（推荐）

1. 打开 `prompts/zh.md`（或 `prompts/en.md`）。
2. 复制全文，连同你项目的 `gradlew` 和 `gradlew.bat` 一起扔给 AI（ChatGPT、Claude、Gemini、Haiku 均可）。
3. AI 返回 patch 后的脚本，覆盖原文件。
4. 参考 `examples/local.properties`，在 `local.properties` 里加上 `java.home`。

## 方式二：手动 Patch

打开 `snippets/gradlew-insert.sh` 和 `snippets/gradlew.bat-insert.bat`，按文件内的注释说明，将代码粘贴到对应位置。

## 局限性

- Wrapper 层面的 patch，非 Gradle / AGP 官方标准做法。
- `./gradlew wrapper` 升级后需重新 patch。
