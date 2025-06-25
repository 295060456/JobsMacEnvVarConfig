###############################################################################
# 🍺 Homebrew 环境变量配置（统一写入 ~/.bash_profile）
###############################################################################
# 配置 💎 Rbenv.ruby 环境变量 (2 选 1)
###############################################################################
# export PATH="$HOME/.rbenv/bin:$PATH"
# eval "$(rbenv init -)"
###############################################################################
# 配置 💎 Homebrew.ruby 环境变量 (2 选 1)
###############################################################################
export PATH="/usr/local/opt/ruby/bin:$PATH"
export LDFLAGS="-L/usr/local/opt/ruby/lib"
export CPPFLAGS="-I/usr/local/opt/ruby/include"
export PKG_CONFIG_PATH="/usr/local/opt/ruby/lib/pkgconfig"
###############################################################################
# 🌐 配置 Curl 环境变量（Homebrew 安装）
###############################################################################
export PATH="/usr/local/opt/curl/bin:$PATH"
export LDFLAGS="-L/usr/local/opt/curl/lib"
export CPPFLAGS="-I/usr/local/opt/curl/include"
export PKG_CONFIG_PATH="/usr/local/opt/curl/lib/pkgconfig"
###############################################################################
# 配置 🧠 VSCode 环境变量
###############################################################################
export PATH="$PATH":/usr/local/bin
export PATH="$PATH":/usr/local/bin/code
###############################################################################
# 配置 🚀 Flutter + Dart 环境变量
# 这里的路径即为Dart.Flutter.SDK名下的为bin目录（主要取决于你下载的SDK的绝对路径）
###############################################################################
export PATH="$PATH:`pwd`/flutter/bin"
export PATH=/Users/$(whoami)/Documents/GitHub.Jobs/Flutter.SDK/Flutter.SDK.last/bin:$PATH
#【相关阅读：Flutter切换源】https://juejin.cn/post/7204285137047257148
# 防止域名在中国大陆互联网环境下的被屏蔽
# export PUB_HOSTED_URL=https://pub.flutter-io.cn
# Flutter官方正版源（温馨提示：海外IP访问大陆源，不开VPN会拉取失败）
export PUB_HOSTED_URL=https://pub.dartlang.org
# FLUTTER_STORAGE_BASE_URL 告诉 SDK 去哪里拉 Flutter 依赖
# export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn
export FLUTTER_STORAGE_BASE_URL=https://storage.googleapis.com # 官方源
###############################################################################
# 配置 🤖 Android 环境变量
###############################################################################
export ANDROID_SDK_ROOT=/Users/$(whoami)/Library/Android/sdk
export PATH=${PATH}:${ANDROID_SDK_ROOT}/platform-tools
export PATH=${PATH}:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin
export PATH=$ANDROID_HOME/emulator:$ANDROID_SDK_ROOT/tools:$ANDROID_SDK_ROOT/tools/bin:$ANDROID_SDK_ROOT/platform-tools:$PATH # Android 模拟器
export PATH=$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$PATH
###############################################################################
# 配置 📦 FVM 环境变量
###############################################################################
export PATH="$HOME/.pub-cache/bin:$PATH"
# 重定义 flutter 命令，使其实际调用 fvm flutter
flutter() { fvm flutter "$@"; }
###############################################################################
# 配置 ☕️ JDK 环境变量
###############################################################################
export JAVA_HOME=$(/usr/libexec/java_home)
export PATH=$JAVA_HOME/bin:$PATH
###############################################################################
# 配置 ☕️ OpenJDK 环境变量
###############################################################################
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"
###############################################################################
# 配置 ⚙️ Gradle 环境变量
###############################################################################
export PATH="/Users/$(whoami)/Documents/Gradle/gradle-8.7/bin:$PATH"
###############################################################################
# 配置 🐍 pipx 环境变量
###############################################################################
export PATH="$PATH:/Users/$(whoami)/.local/bin"
###############################################################################
#💡默认终端启动目录:定位📌当前路径为系统桌面（仅适用于非 VSCode 启动）
#【❤️细节处理❤️】cd ~/Desktop 这么写的话，虽然新开的Mac终端定位📌于系统桌面，但是VSCode里面的终端路径定位📌就不是工程当前目录
###############################################################################
cd ./Desktop
###############################################################################
# 温馨提示：打开这一句会形成死循环 source ~/.bash_profile
# 如果希望 .zshrc 加载此文件内容，请在 .zshrc 中添加：source ~/.bash_profile
###############################################################################
