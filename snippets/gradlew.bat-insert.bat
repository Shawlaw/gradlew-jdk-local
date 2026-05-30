@rem ============================================================================
@rem 插入位置说明
@rem ============================================================================
@rem 在 gradlew.bat（Windows Batch 版 Gradle Wrapper）中，找到以下注释行：
@rem
@rem     @rem Find java.exe
@rem
@rem 将下面的代码块插入到该行的**上方**（即在此注释之前）。
@rem
@rem 前置条件：脚本此时已经解析并设置了 APP_HOME 变量。
@rem 后置行为：按优先级查找并设置 JAVA_HOME。
@rem ============================================================================

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
