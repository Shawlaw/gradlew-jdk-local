# gradlew-jdk-local

简体中文 | [English](README.en.md)

统一 Gradle Wrapper 基座 JVM 的本地配置来源。

> 本 Patch 让 `gradlew` / `gradlew.bat` 在启动 Gradle Daemon 前，优先从项目本地配置文件读取 JDK 路径，解决 IDE 与命令行 JDK 不一致的问题。

---

## 快速开始

### 方式一：AI Prompt（推荐）

#### 如果你的 AI 支持读取网页

直接把下面这句话和你的 `gradlew` / `gradlew.bat` 所在的目录路径一起发给 AI：

> 请按照 https://raw.githubusercontent.com/Shawlaw/gradlew-jdk-local/main/prompts/zh.md 中的要求，修改 `<你的项目目录>` 下的 gradlew 和 gradlew.bat。

#### 如果你的 AI 不支持读取网页

1. 打开 `prompts/zh.md`，复制全文。
2. 连同你项目的 `gradlew` 和 `gradlew.bat` 一起扔给 AI。
3. AI 返回 patch 后的脚本，覆盖原文件。

#### 后续步骤（两种方式都一样）

4. 参考 `examples/local.properties`，在 `local.properties` 里加上 `java.home`。
5. 运行 `./gradlew --version`（或 `gradlew.bat --version`），确认 `JVM` 一行指向你配置的 JDK。

### 方式二：手动 Patch

1. 打开 `snippets/gradlew-insert.sh` 和 `snippets/gradlew.bat-insert.bat`。
2. 按文件内的注释说明，将代码粘贴到 `gradlew` / `gradlew.bat` 的对应位置。
3. 在 `local.properties` 中加入 `java.home`（参考 `examples/local.properties`）。
4. 运行 `./gradlew --version` 验证。

### 局限性

- Wrapper 层面的 patch，非 Gradle / AGP 官方标准做法。
- `./gradlew wrapper` 升级后需重新 patch。

---

## 功能说明

Android 项目的本地工具链配置是碎片化的：

| 配置项 | 存储位置 | IDE 认 | 命令行认 | 进 Git |
|---|---|---|---|---|
| SDK 路径 | `local.properties` | ✅ | ✅ | ❌ |
| NDK 路径 | `local.properties` | ✅ | ✅ | ❌ |
| JDK 路径（AS 私用） | `.gradle/config.properties` | ✅ | ❌ | ❌ |
| JDK 路径（Gradle） | `gradle.properties` / `org.gradle.java.home` | ✅ | ✅ | ✅（文件进 Git，但 `java.home` 属性因是绝对路径，常被本地覆盖） |
| JDK 路径（系统） | `JAVA_HOME` | ✅ | ✅ | N/A |

### 更具体的痛点

本地多项目开发时，不同项目可能依赖不同 JDK 版本：

- 项目 A 用 JDK 17，项目 B 用 JDK 21
- `JAVA_HOME` 是全局环境变量，切项目就要手动改，极易出错
- `gradle.properties` 里的 `org.gradle.java.home` 虽能项目级隔离，但需要填**绝对路径**，而 `gradle.properties` 是进 Git 的全组成员共享文件，总不能要求所有人（还有 CI 服务器）的 JDK 都装在同一个绝对路径上
- `.gradle/config.properties` 里的 `java.home` 虽然是项目级，但**命令行 `./gradlew` 完全不认**

结果是：IDE 里能编译，命令行 `./gradlew` 却可能用错 JDK；张三的环境能跑，李四 clone 下来就不行。

这个项目提供一段极小的 Gradle Wrapper Patch，让 `gradlew` / `gradlew.bat` 在启动 Gradle Daemon 前，按优先级读取本地配置文件中的 JDK 路径，覆盖或补充 `JAVA_HOME`。

### 优先级与兼容性

当多处都配置了 JDK 路径时，本 Patch 的查找优先级如下：

1. **`local.properties` 中的 `java.home`**（最高优先级）
2. **`.gradle/config.properties` 中的 `java.home`**（Android Studio 的 `GRADLE_LOCAL_JAVA_HOME` 配置）
3. **`JAVA_HOME` 环境变量**（Gradle Wrapper 原生逻辑）
4. **系统 `PATH` 中的 `java`**（最终 fallback）

这样既尊重了 Android 开发者统一配置本地路径的习惯，又兼容了已有 Android Studio 项目的 `.gradle/config.properties` 设置。如果两者都未配置，则完全回退到 Gradle Wrapper 原生的 `JAVA_HOME` → `PATH` 逻辑，**不会破坏任何现有行为**。

---

## 仓库结构

```
├── prompts/        # AI Prompt，复制给 LLM 即可自动 Patch
├── snippets/       # 纯代码插入段，支持手动 Patch
└── examples/       # local.properties 配置示例
```

---

## License

Apache License 2.0
