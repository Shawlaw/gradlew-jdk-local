## 任务：修改 Gradle Wrapper 启动脚本，使其支持从 local.properties 读取 JDK 路径

### 背景

Android 项目的 `local.properties` 已经用来配置 `sdk.dir` 和 `ndk.dir`，但 JDK 路径却散落在 `JAVA_HOME`、`gradle.properties` 或 `.gradle/config.properties` 中，导致 IDE 和命令行经常不一致。

### 目标

修改项目中的 `gradlew`（Unix）和 `gradlew.bat`（Windows），在启动 Gradle Daemon 之前，先读取 `local.properties` 中的 `java.home` 属性。如果存在，则用它来覆盖 `JAVA_HOME`。

### 要求

1. 不破坏原有脚本逻辑。
2. 保持 POSIX shell 兼容性（`gradlew`）。
3. 保持 Windows Batch 兼容性（`gradlew.bat`）。
4. 插入位置必须在脚本已经确定 `APP_HOME` 之后、开始使用 `JAVA_HOME` 之前。
5. 需要处理 `local.properties` 中的 Windows 路径转义（`\:` 和 `\\`）。

### 验证要求

修改完成后，请按以下要求自检并给出验证说明：

1. **位置检查**：确认插入的代码块位于 `APP_HOME` 已解析之后、`JAVA_HOME` 被使用之前。
2. **语法检查**：确认 `gradlew` 中的代码符合 POSIX shell 语法，`gradlew.bat` 中的代码符合 Windows Batch 语法。
3. **效果验证**：
   - 如果你能在项目目录执行命令，请分别在 patch 前后运行 `./gradlew --version`（Windows 运行 `gradlew.bat --version`），并在回复中展示两次 `JVM:` 行的对比，证明 patch 生效。
   - 如果你无法执行命令，请在回复末尾提供以下手动验证步骤：
     - **Patch 前**：运行 `./gradlew --version`，记录 `JVM:` 一行显示的 JDK 路径（此时通常为系统 `JAVA_HOME`）。
     - **Patch 后**：在 `local.properties` 中加入 `java.home`（参考上面的配置方式），再次运行 `./gradlew --version`。
     - **对比**：确认 `JVM:` 一行已变为 `local.properties` 中配置的 JDK 路径。
4. **优先级说明**：在回复末尾简要说明 patch 后的 JDK 查找优先级：`local.properties` 中的 `java.home` > `.gradle/config.properties` 中的 `java.home` > 环境变量 `JAVA_HOME` > 系统 `PATH` 中的 `java`。
5. **回退行为说明**：在回复末尾简要说明：
   - 如果 `local.properties` 不存在或没有 `java.home`，会回退到 `.gradle/config.properties`。
   - 如果两者都没有，则完全回退到原生的 `JAVA_HOME` / `PATH` 逻辑。
   - 如果读取到 `java.home`，会直接覆盖 `JAVA_HOME`；路径是否有效由 Gradle Wrapper 原生逻辑检查。

### 参考实现

**在 `gradlew` 中**，于 `# Determine the Java command to use to start the JVM.` 这一行的上方插入：

```sh
# Read java.home with priority: local.properties > .gradle/config.properties > JAVA_HOME (env)
local_java_home=""

# 1. Try local.properties
local_props="$APP_HOME/local.properties"
if [ -f "$local_props" ] ; then
    local_java_home=$(awk -F= '/^java.home=/ {sub(/^java.home=/, ""); gsub(/\\:/, ":"); gsub(/\\\\/, "\\"); print; exit}' "$local_props")
fi

# 2. Fallback to .gradle/config.properties (Android Studio's GRADLE_LOCAL_JAVA_HOME)
if [ -z "$local_java_home" ] ; then
    gradle_config="$APP_HOME/.gradle/config.properties"
    if [ -f "$gradle_config" ] ; then
        local_java_home=$(awk -F= '/^java.home=/ {sub(/^java.home=/, ""); gsub(/\\:/, ":"); gsub(/\\\\/, "\\"); print; exit}' "$gradle_config")
    fi
fi

# 3. Apply if found
if [ -n "$local_java_home" ] ; then
    JAVA_HOME=$local_java_home
    export JAVA_HOME
fi
```

**在 `gradlew.bat` 中**，于 `@rem Find java.exe` 这一行的上方插入：

```batch
@rem Read java.home with priority: local.properties > .gradle/config.properties > JAVA_HOME (env)
set "_LOCAL_JAVA_HOME="

@rem 1. Try local.properties
if exist "%APP_HOME%\local.properties" (
    for /f "usebackq tokens=1* delims==" %%a in ("%APP_HOME%\local.properties") do (
        if "%%a"=="java.home" (
            set "_LOCAL_JAVA_HOME=%%b"
            goto :applyLocalJavaHome
        )
    )
)

@rem 2. Fallback to .gradle/config.properties (Android Studio's GRADLE_LOCAL_JAVA_HOME)
if not defined _LOCAL_JAVA_HOME (
    if exist "%APP_HOME%\.gradle\config.properties" (
        for /f "usebackq tokens=1* delims==" %%a in ("%APP_HOME%\.gradle\config.properties") do (
            if "%%a"=="java.home" (
                set "_LOCAL_JAVA_HOME=%%b"
                goto :applyLocalJavaHome
            )
        )
    )
)

:applyLocalJavaHome
if defined _LOCAL_JAVA_HOME (
    set "JAVA_HOME=%_LOCAL_JAVA_HOME:\:=:%"
    set "JAVA_HOME=%JAVA_HOME:\\=\%"
    set "_LOCAL_JAVA_HOME="
    goto :findJavaFromJavaHome
)

@rem 3. If not found, continue to original JAVA_HOME / PATH logic
```

### 配置方式

修改项目根目录的 `local.properties`，加入：

```properties
sdk.dir=C\:\\Users\\xxx\\AppData\\Local\\Android\\Sdk
java.home=C\:\\Program Files\\Android\\Android Studio\\jbr
```

注意：`local.properties` 是 Java Properties 文件，Windows 反斜杠需要双写。

请根据以上要求，修改目标项目中的 `gradlew` 和 `gradlew.bat`，并在回复中附带验证说明。如果你已经获得项目目录路径，请直接读取该目录下的文件；如果用户已贴出文件内容，请直接修改贴出的内容。
