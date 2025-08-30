# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# ✅ 配置 jenv 路径（必须在函数之前）
export PATH="$HOME/.jenv/bin:$PATH"
eval "$(jenv init -)"

# ✅ 一键重新加载常见配置文件
save() {
  local files=(
    "$HOME/.bash_profile"
    "$HOME/.bashrc"
    "$HOME/.zshrc"
    "$HOME/.profile"
    "$HOME/.oh-my-zsh/oh-my-zsh.sh"  # Oh My Zsh 主文件
  )

  for file in "${files[@]}"; do
    if [[ -f "$file" ]]; then
      source "$file"
      echo -e "\033[1;32m✅ 已加载配置文件：file://$file\033[0m"
    else
      echo -e "\033[1;33m⚠️ 未找到配置文件：file://$file\033[0m"
    fi
  done

  echo -e "\n📎 ⌘Command + 点击路径可打开对应文件（macOS Terminal 支持）"
}

# ✅ 仅首次执行 save 函数，防止递归
if [[ -z "$JOBS_ALREADY_RUN" ]]; then
  export JOBS_ALREADY_RUN=1
  command -v save &>/dev/null && save
fi

# ✅ 更新
update() {
    flutter upgrade
    brew update && brew upgrade && brew cleanup && brew doctor && brew -v # Homebrew
    dart pub global activate fvm                                          # fvm
    gem update && gem clean
    pod repo update --verbose
}

# ✅ Flutter 命令重载（优先 FVM）
# 功能：
#   1. 如果项目目录存在 `.fvm/fvm_config.json`，优先使用该项目绑定的 FVM Flutter SDK。
#   2. 检测 FVM 是否可用（VSCode 内最容易失效的情况）：
#        - 如果 `fvm` 命令不可用，自动执行：
#            a) dart pub global deactivate fvm    # 卸载现有 FVM 快照
#            b) dart pub global activate fvm      # 重新全局激活 FVM
#            c) hash -r                           # 刷新命令缓存
#   3. 如果 FVM 可用，使用 `fvm flutter` 执行；
#      如果 FVM 依然不可用，则直接调用 `.fvm/flutter_sdk/bin/flutter` 兜底。
#   4. 如果当前目录不是 FVM 项目，调用系统全局 Flutter。
# 作用：
#   - 保证无论是终端、VSCode 还是脚本运行，始终优先用项目内的 Flutter SDK，
#     并且自动修复 FVM 失效问题，避免因为环境切换导致构建失败。
# 注意：
#   - 避免递归调用，使用 `command` 明确调用系统命令。
#   - 要放在 `~/.zshrc` 或 `~/.bashrc` 中，确保所有 shell 会话生效。
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

# ✅ 修复 fvm 与 Dart SDK 不匹配问题
# 场景：
#   当执行 flutter / fvm 时出现以下错误：
#     "Can't load Kernel binary: Invalid kernel binary format version."
#     "fvm as globally activated doesn't support Dart X.X.X"
#   原因：
#     全局安装的 fvm 是用旧版本 Dart SDK 编译的，与当前 Dart SDK 内核版本不匹配。
#   解决：
#     1. 卸载旧的全局 fvm
#     2. 用当前 Dart SDK 重新全局安装 fvm（会重新编译成当前版本可用的 kernel）
#     3. 清除 shell 的命令缓存，让新安装的 fvm 生效
fixfvm() {
  echo "🔍 检查并修复 fvm 与 Dart SDK 的内核版本不匹配问题..."
  
  # 1️⃣ 卸载旧的全局 fvm
  dart pub global deactivate fvm || true
  rm -rf ~/.pub-cache/bin/fvm* ~/.pub-cache/global_packages/fvm

  # 2️⃣ 使用当前 Dart SDK 重新安装 fvm
  dart pub global activate fvm 

  # 3️⃣ 清空 shell 命令缓存，确保调用到新版本
  hash -r
  
  echo "✅ fvm 已重新安装并与当前 Dart SDK 匹配"
}

# ✅ 检查 Dart / FVM / Flutter 版本信息
check1() {
  echo "===================================================================="
  echo " 1️⃣ Dart 位置 & 版本"
  echo "===================================================================="
  echo "📍 which dart:"; which dart
  echo "🔖 dart --version:"; dart --version
  echo ""

  echo "===================================================================="
  echo " 2️⃣ FVM 位置 & 版本"
  echo "===================================================================="
  echo "📍 which fvm:"; which fvm
  echo "🔖 fvm --version:"; fvm --version
  echo ""

  echo "===================================================================="
  echo " 3️⃣ Flutter 位置 & 版本（通过 fvm/flutter）"
  echo "===================================================================="
  # zsh: 判断 flutter 是否为函数
  if whence -v flutter | grep -q "shell function"; then
    echo "📍 flutter 是 shell function(打印函数体（便于排查重载逻辑）)："
    functions flutter
    echo "📍 flutter 可执行路径（忽略函数优先找可执行文件）："
    whence -p flutter || echo "（无同名可执行文件，只有函数）"
  else
    echo "📍 flutter 路径："
    whence -p flutter      # 等价于只查 PATH 中的可执行文件
  fi

  echo "🔖 flutter --version:"; flutter --version
  echo "===================================================================="
}

clear

# ================================== ✅ 重启终端 ==============================================
rb() {
  exec "$SHELL"
}

# ✅ 快捷打开系统配置文件
a(){
  open $HOME/.bash_profile
}

b(){
  open $HOME/.zshrc
}

# ✅ 快捷打开软件
i(){
  open -a Simulator
}

# ✅ 终端快捷打开项目文件夹@编辑完后用命令已定义的命令rb重启终端使之生效
check(){
  # 验证
  echo ""
  java -version
  echo ""
  echo "JAVA_HOME=$JAVA_HOME"
  echo ""

  fvm use 3.24.5 --force
  flutter doctor -v
}

d(){
  # 锁定项目
  cd /Users/jobs/Documents/Github/flutter_tiyu_app
}

c(){
  # 锁定项目
  cd /Users/jobs/Documents/Github/flutter_tiyu_app

  # 删除构建失败的 jenv 中间件
  rm -f ~/.jenv/shims/.jenv-shim

  # 1、让 jenv 在当前 shell 生效
  eval "$(jenv init -)"

  # 2、启用 export 插件（自动导出 JAVA_HOME）
  jenv enable-plugin export

  # 3、让 jenv 识别本机 JDK 17（若已识别可跳过）
  jenv add "$(/usr/libexec/java_home -v 17)" >/dev/null 2>&1

  # 4、更新 shims（新增 JDK 后建议做一次）
  jenv rehash

  # 5、在项目内锁定到 JDK 17（JDK 版本号按 jenv versions 里显示来）
  jenv local openjdk64-17.0.16 # 或者 17.0.16

  # 6、重新加载环境（让 export 插件立刻生效）
  jenv shell openjdk64-17.0.16

  check
}

# ✅ 为Flutter打包📦作准备
buildCheck() {
  read -r "?是否执行清理和依赖安装 (回车=执行，任意字符=跳过): " ans
  if [[ -z "$ans" ]]; then
    echo "🧹 flutter clean / pub get / doctor"
    flutter clean || return $?
    flutter pub get || return $?
    flutter doctor -v || return $?
  else
    echo "⏩ 跳过 flutter clean / pub get / doctor"
  fi
}

# ✅ Flutter 项目识别
is_flutter_project() {
  local dir="$1"
  [[ -d "$dir/lib" && -f "$dir/pubspec.yaml" ]]
}

# ✅ 获取 Flutter 项目目录（仅把“最后的路径”输出到 stdout）
# 用法：
#   local project_path; project_path="$(get_flutter_project_dir "$PWD")" || return 1
#   cd "$project_path" || return 1
get_flutter_project_dir() {
  local start="${1:-$PWD}"
  local project_path="$start"

  while ! is_flutter_project "$project_path"; do
    echo "❌ [$project_path] 不是合法的 Flutter 项目目录（缺少 lib/ 或 pubspec.yaml）" >&2
    read -r "?👉 请输入 Flutter 项目路径: " input_path
    # 空输入：继续循环
    [[ -z "$input_path" ]] && continue

    # 支持 ~ 展开；保持对空格路径友好
    eval "project_path=\"$input_path\""
    project_path="$(cd "$project_path" 2>/dev/null && pwd || echo "")"

    if [[ -z "$project_path" ]]; then
      echo "⚠️ 输入的路径无效，请重新输入" >&2
      project_path="$start"
    fi
  done

  # 只输出最终路径到 stdout
  printf "%s\n" "$project_path"
}

# ================================== 构建 APK（复用目录函数） ==================================
apk() {
  # 可选：存在 buildCheck 就执行
  if typeset -f buildCheck >/dev/null; then buildCheck || return $?; fi

  local project_path
  project_path="$(get_flutter_project_dir "$PWD")" || return 1
  echo "✅ 已确认 Flutter 项目目录: $project_path"
  cd "$project_path" || return 1

  echo "🚀 开始构建 APK（release）..."
  flutter build apk --release || return $?

  echo "📂 打开输出目录: ./build/app/outputs/"
  open "./build/app/outputs/"
}

# ✅ 📦打 iOS 包
ipa() {
  if typeset -f buildCheck >/dev/null; then buildCheck; fi

  local project_path
  project_path="$(get_flutter_project_dir "$PWD")" || return 1
  echo "✅ 已确认 Flutter 项目目录: $project_path"
  cd "$project_path" || return 1

  echo "🚀 开始构建 iOS（release）..."
  flutter build ipa --release || return $?

  echo "📂 打开输出目录: ./build/ios/ipa/"
  open "./build/ios/ipa/"
}

# ✅ 万能颜色格式转换器
cor() {
  # ---------- 基础工具 ----------
  to_hex() { printf "%02X" "$1"; }
  alpha_float_to_255() { awk 'BEGIN{v='"$1"'; if(v<0)v=0;if(v>1)v=1; printf("%d",(v*255)+0.5)}'; }
  alpha_255_to_float() { awk 'BEGIN{printf("%.2f",'"$1"'/255)}'; }
  sanitize_input() { echo "$1" | tr -d '[:space:]' | tr -d '"' | tr -d "'"; }
  upper_hex() { echo "$1" | tr '[:lower:]' '[:upper:]'; }

  # ---------- 全局变量 ----------
  local r g b a_float aa_hex user_input

  # ---------- 解析输入 ----------
  parse_input() {
    local raw="$1" input
    input=$(sanitize_input "$raw")

    # 0xAARRGGBB
    if [[ "$input" =~ ^0x[0-9a-fA-F]{8}$ ]]; then
      local hex="${input:2}"; hex=$(upper_hex "$hex")
      local aa=${hex:0:2} rr=${hex:2:2} gg=${hex:4:2} bb=${hex:6:2}
      r=$((16#$rr)); g=$((16#$gg)); b=$((16#$bb))
      aa_hex="$aa"
      a_float=$(alpha_255_to_float $((16#$aa)))
      return 0
    fi

    # #RRGGBB / #RRGGBBAA
    if [[ "$input" =~ ^#[0-9a-fA-F]{6}([0-9a-fA-F]{2})?$ ]]; then
      local hex="${input:1}"; hex=$(upper_hex "$hex")
      local rr=${hex:0:2} gg=${hex:2:2} bb=${hex:4:2}
      r=$((16#$rr)); g=$((16#$gg)); b=$((16#$bb))
      if [[ ${#hex} -eq 8 ]]; then
        aa_hex=${hex:6:2}
        a_float=$(alpha_255_to_float $((16#$aa_hex)))
      else
        aa_hex="FF"
        a_float="1.00"
      fi
      return 0
    fi

    # rgb(...) / rgba(...)
    if [[ "$input" =~ ^rgba?\( ]]; then
      local nums; nums=$(echo "$input" | sed -E 's/rgba?\(|\)//g')
      IFS=',' read -r R G B A <<<"$nums"
      r=${R%%.*}; g=${G%%.*}; b=${B%%.*}
      [[ -z "$A" ]] && A="1"
      a_float=$(awk 'BEGIN{printf("%.2f",'"$A"')}')
      local A255; A255=$(alpha_float_to_255 "$a_float")
      aa_hex=$(to_hex "$A255")
      return 0
    fi

    return 1
  }

  # ---------- 格式化输出 ----------
  format_and_print_all() {
    local RR=$(to_hex "$r") GG=$(to_hex "$g") BB=$(to_hex "$b")
    local AA="$aa_hex"
    echo
    echo "输入：$user_input"
    echo "----------------------------------------"
    echo "HEX（不透明）:  #${RR}${GG}${BB}"
    echo "HEX（含透明） :  #${RR}${GG}${BB}${AA}"
    echo "RGB           :  rgb(${r}, ${g}, ${b})"
    echo "RGBA          :  rgba(${r}, ${g}, ${b}, $(printf '%.2f' "$a_float"))"
    echo "0x 格式       :  0x${AA}${RR}${GG}${BB}"
    echo
  }

  # ---------- 执行逻辑 ----------
  if [[ $# -ge 1 ]]; then
    # 有参数：逐个转换
    for user_input in "$@"; do
      if parse_input "$user_input"; then
        format_and_print_all
      else
        echo "❌ 无法识别：$user_input"
      fi
    done
  else
    # 无参数：交互模式
    while true; do
      echo
      printf "请输入颜色值（q 退出）： "
      IFS= read -r user_input
      [[ -z "$user_input" ]] && continue
      [[ "$user_input" == [Qq] ]] && { echo "✅ 已退出"; break; }
      if parse_input "$user_input"; then
        format_and_print_all
      else
        echo "❌ 无法识别：$user_input"
      fi
    done
  fi
}

# ✅ 打开xcode模拟器
a(){
  open -a Simulator
}
