## Task: Patch Gradle Wrapper scripts to read JDK path from local.properties

### Background

Android projects use `local.properties` for `sdk.dir` and `ndk.dir`, but the JDK path is scattered across `JAVA_HOME`, `gradle.properties`, or `.gradle/config.properties`, causing inconsistencies between IDE and CLI builds.

### Goal

Modify `gradlew` (Unix) and `gradlew.bat` (Windows) to read `java.home` from `local.properties` before launching the Gradle Daemon. If present, it should override `JAVA_HOME`.

### Requirements

1. Do not break existing script logic.
2. Maintain POSIX shell compatibility for `gradlew`.
3. Maintain Windows Batch compatibility for `gradlew.bat`.
4. Insert after `APP_HOME` is resolved but before `JAVA_HOME` is used.
5. Handle Windows path escaping (`\:` and `\\`) in `local.properties`.

### Verification

After patching, please self-check and include the following verification notes in your response:

1. **Placement check**: Confirm that the inserted code block is placed after `APP_HOME` is resolved but before `JAVA_HOME` is used.
2. **Syntax check**: Confirm that the `gradlew` code is POSIX shell compatible and the `gradlew.bat` code is Windows Batch compatible.
3. **Effect verification**:
   - If you can execute commands in the project directory, run `./gradlew --version` (on Windows run `gradlew.bat --version`) before and after the patch, and show the comparison of the two `JVM:` lines in your response to prove the patch is effective.
   - If you cannot execute commands, provide the following manual verification steps at the end of your response:
     - **Before patch**: Run `./gradlew --version` (on Windows run `gradlew.bat --version`) and note the JDK path shown in the `JVM:` line (usually the system `JAVA_HOME`).
     - **After patch**: Add `java.home` to `local.properties` (see the configuration example above) and run `./gradlew --version` again.
     - **Compare**: Confirm that the `JVM:` line now shows the JDK path configured in `local.properties`.
4. **Priority note**: Briefly explain the patched JDK lookup priority at the end of your response: `java.home` in `local.properties` > `java.home` in `.gradle/config.properties` > environment variable `JAVA_HOME` > `java` in system `PATH`.
5. **Fallback behavior note**: Briefly explain that:
   - If `local.properties` is missing or has no `java.home`, the script falls back to `.gradle/config.properties`.
   - If neither is configured, it fully falls back to the native `JAVA_HOME` / `PATH` logic.
   - If `java.home` is read, it directly overrides `JAVA_HOME`; path validity is checked by the Gradle Wrapper's native logic.

### Reference Implementation

**In `gradlew`**, insert before the line `# Determine the Java command to use to start the JVM.`:

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

**In `gradlew.bat`**, insert before the line `@rem Find java.exe`:

```batch
@rem Read java.home with priority: local.properties > .gradle/config.properties > JAVA_HOME (env)
set "_LOCAL_JAVA_HOME="

@rem 1. Try local.properties
if exist "%APP_HOME%\local.properties" (
    for /f "usebackq tokens=1* delims==" %%a in ("%APP_HOME%\local.properties") do (
        if "%%a"=="java.home" (
            if not "%%b"=="" (
                set "_LOCAL_JAVA_HOME=%%b"
                goto :applyLocalJavaHome
            )
        )
    )
)

@rem 2. Fallback to .gradle/config.properties (Android Studio's GRADLE_LOCAL_JAVA_HOME)
if not defined _LOCAL_JAVA_HOME (
    if exist "%APP_HOME%\.gradle\config.properties" (
        for /f "usebackq tokens=1* delims==" %%a in ("%APP_HOME%\.gradle\config.properties") do (
            if "%%a"=="java.home" (
                if not "%%b"=="" (
                    set "_LOCAL_JAVA_HOME=%%b"
                    goto :applyLocalJavaHome
                )
            )
        )
    )
)

:applyLocalJavaHome
if not defined _LOCAL_JAVA_HOME goto :continueOriginalJavaLookup
set "JAVA_HOME=%_LOCAL_JAVA_HOME:\:=:%"
set "JAVA_HOME=%JAVA_HOME:\\=\%"
set "_LOCAL_JAVA_HOME="
goto :findJavaFromJavaHome

@rem 3. If not found, continue to original JAVA_HOME / PATH logic
:continueOriginalJavaLookup
```

### Configuration

Add to your project root `local.properties`:

```properties
sdk.dir=C\:\\Users\\xxx\\AppData\\Local\\Android\\Sdk
java.home=C\:\\Program Files\\Android\\Android Studio\\jbr
```

Note: `local.properties` is a Java Properties file. Windows backslashes must be doubled.

Please apply the above changes to the `gradlew` and `gradlew.bat` in the target project, and include the verification notes in your response. If you have been given the project directory path, read the files directly from that directory; if the user has pasted the file contents below, modify the pasted content directly.
