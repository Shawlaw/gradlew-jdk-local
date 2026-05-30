#!/bin/sh
# ============================================================================
# 插入位置说明
# ============================================================================
# 在 gradlew（POSIX shell 版 Gradle Wrapper）中，找到以下注释行：
#
#     # Determine the Java command to use to start the JVM.
#
# 将下面的代码块插入到该行的**上方**（即在此注释之前）。
#
# 前置条件：脚本此时已经解析并设置了 APP_HOME 变量。
# 后置行为：按优先级查找并设置 JAVA_HOME。
# ============================================================================

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
