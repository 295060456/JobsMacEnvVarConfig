# 📁 每次启动默认进入桌面目录
cd ~/Desktop

# 🔥配置 Jenv
export PATH="$HOME/.jenv/bin:$PATH"
eval "$(jenv init -)"
export JAVA_HOME="$HOME/.jenv/versions/$(jenv version-name)"
export PATH="$JAVA_HOME/bin:$PATH"

# 🔥配置 sdkman
## // TODO

# 🔥配置 pipx
export PATH="$PATH:$HOME/.local/bin"

# 🔥配置 Gradle
export PATH="$HOME/Documents/Gradle/gradle-8.7/bin:$PATH"

# 🔥配置 JDK
export JAVA_HOME=$(/usr/libexec/java_home)
export PATH="$JAVA_HOME/bin:$PATH"

# 🔥配置 FVM
export PATH="$HOME/.pub-cache/bin:$PATH"
# 保留 flutter() { fvm flutter "$@"; } 的习惯，但做成健壮版
flutter() {
  # 项目里有 .fvm 就优先用项目 SDK；没有就走系统 flutter
  if [[ -f .fvm/fvm_config.json && -x .fvm/flutter_sdk/bin/flutter ]]; then
    # 先试 fvm 是否可用，不可用就修复快照（VSCode 里最容易坏）
    if ! command -v fvm >/dev/null 2>&1 || ! fvm --version >/dev/null 2>&1; then
      if command -v dart >/dev/null 2>&1; then
        dart pub global deactivate fvm >/dev/null 2>&1 || true
        dart pub global activate  fvm >/dev/null 2>&1 || true
        hash -r
      fi
    fi

    # 如果 fvm 现在可用，就走 fvm；否则直接用项目本地 flutter 二进制兜底
    if command -v fvm >/dev/null 2>&1 && fvm --version >/dev/null 2>&1; then
      command fvm flutter "$@"
    else
      command .fvm/flutter_sdk/bin/flutter "$@"
    fi
  else
    # 非 fvm 项目：调用系统里的 flutter（避免递归用 `command`）
    command flutter "$@"
  fi
}

# 🔥配置 Android SDK
export ANDROID_SDK_ROOT="$HOME/Library/Android/sdk"
export PATH="$PATH:$ANDROID_SDK_ROOT/platform-tools"
export PATH="$ANDROID_SDK_ROOT/emulator:$ANDROID_SDK_ROOT/platform-tools:$ANDROID_SDK_ROOT/tools:$PATH"

# 🔥配置 Flutter 环境变量
export PATH="$HOME/flutter/bin:$PATH"
export PUB_HOSTED_URL=https://pub.dev
export FLUTTER_STORAGE_BASE_URL=https://storage.googleapis.com

# 🔥配置 VSCode 命令行
export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"

# 🔥配置 Curl 环境变量
export PATH="/usr/local/opt/curl/bin:$PATH"

# 🔥配置 Rbenv / Ruby
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"
