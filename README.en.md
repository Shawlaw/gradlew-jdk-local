# gradlew-jdk-local

English | [简体中文](README.md)

Unify the local configuration source for the Gradle Wrapper base JVM.

> This patch makes `gradlew` / `gradlew.bat` read the JDK path from local configuration files before launching the Gradle Daemon, resolving inconsistencies between IDE and command-line JDK versions.

---

## Quick Start

### Option 1: AI Prompt (Recommended)

#### If your AI can fetch web pages

Send the following line to the AI, along with the directory path where your `gradlew` / `gradlew.bat` are located:

> Please follow the instructions in https://raw.githubusercontent.com/Shawlaw/gradlew-jdk-local/main/prompts/en.md to modify the gradlew and gradlew.bat in `<your-project-directory>`.

#### If your AI cannot fetch web pages

1. Open `prompts/en.md` and copy the entire content.
2. Send it to the AI, along with your project's `gradlew` and `gradlew.bat`.
3. The AI returns the patched scripts; overwrite the original files.

#### Next steps (same for both)

4. Refer to `examples/local.properties` and add `java.home` to your `local.properties`.
5. Run `./gradlew --version` (or `gradlew.bat --version`) and verify the `JVM` line points to your configured JDK.

### Option 2: Manual Patch

1. Open `snippets/gradlew-insert.txt` and `snippets/gradlew.bat-insert.txt` (these are text snippets, not executable scripts; copy and paste according to the comments).
2. Follow the comments in each file to paste the code into the corresponding locations in `gradlew` / `gradlew.bat`.
3. Add `java.home` to `local.properties` (see `examples/local.properties`).
4. Run `./gradlew --version` to verify.

### Limitations

- This is a wrapper-level patch, not an official Gradle / AGP standard practice.
- You need to re-patch after running `./gradlew wrapper` to upgrade Gradle.

---

## What Problem It Solves

The local toolchain configuration in Android projects is fragmented:

| Config Item | Storage Location | IDE Recognizes | CLI Recognizes | In Git |
|---|---|---|---|---|
| SDK path | `local.properties` | ✅ | ✅ | ❌ |
| NDK path | `local.properties` | ✅ | ✅ | ❌ |
| JDK path (AS private) | `.gradle/config.properties` | ✅ | ❌ | ❌ |
| JDK path (Gradle) | `gradle.properties` / `org.gradle.java.home` | ✅ | ✅ | ✅ (file in Git, but `java.home` is often locally overridden because it's an absolute path) |
| JDK path (system) | `JAVA_HOME` | ✅ | ✅ | N/A |

### The Real Pain Point

When developing multiple projects locally, different projects may depend on different JDK versions:

- Project A uses JDK 17, Project B uses JDK 21.
- `JAVA_HOME` is a global environment variable; switching projects means manually changing it, which is error-prone.
- `org.gradle.java.home` in `gradle.properties` supports project-level isolation, but it requires an **absolute path**, and `gradle.properties` is a team-shared file tracked in Git. You can't expect everyone (including CI servers) to install their JDK at the exact same absolute path.
- `java.home` in `.gradle/config.properties` is project-level, but **the command-line `./gradlew` completely ignores it**.

The result: the IDE builds fine, but `./gradlew` from the command line may use the wrong JDK. It works on Alice's machine but breaks when Bob clones the repo.

This project provides a minimal Gradle Wrapper patch that makes `gradlew` / `gradlew.bat` read `java.home` from local configuration files before launching the Gradle Daemon, overriding or supplementing `JAVA_HOME`.

### Priority & Compatibility

When multiple JDK paths are configured, this patch looks them up in the following priority:

1. **`java.home` in `local.properties`** (highest priority)
2. **`java.home` in `.gradle/config.properties`** (Android Studio's `GRADLE_LOCAL_JAVA_HOME` config)
3. **`JAVA_HOME` environment variable** (Gradle Wrapper native logic)
4. **`java` in system `PATH`** (final fallback)

This respects the Android developer's habit of keeping all local paths in one place, while remaining compatible with existing Android Studio projects that use `.gradle/config.properties`. If neither is configured, it fully falls back to the Gradle Wrapper's native `JAVA_HOME` → `PATH` logic, **without breaking any existing behavior**.

---

## Repository Structure

```
├── prompts/        # AI Prompts; copy and paste into an LLM to auto-patch
├── snippets/       # Pure code snippets for manual patching
└── examples/       # Example local.properties configuration
```

---

## License

Apache License 2.0
