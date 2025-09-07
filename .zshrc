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

# ✅ 重启终端
rb() {
  exec "$SHELL"
}

# ✅ 快捷打开系统配置文件 .bash_profile
a(){
  open $HOME/.bash_profile
}

# ✅ 快捷打开系统配置文件 .zshrc
b(){
  open $HOME/.zshrc
}

# ✅ 打开xcode模拟器
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

# ✅ 打包构建前置：清理 & 拉依赖 & doctor（保证一定在项目根执行）
buildCheck() {
  local here="$PWD"
  local project_path

  if is_flutter_project "$here"; then
    project_path="$here"
  else
    project_path="$(get_flutter_project_dir "$here")" || { echo "已取消"; return 1; }
    cd "$project_path" || return 1
  fi

  read -r "?是否执行清理和依赖安装 (回车=执行，任意字符=跳过): " ans
  if [[ -z "$ans" ]]; then
    echo "🧹 flutter clean / pub get / doctor @ $project_path"
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
    read -r "?👉 请输入 Flutter 项目路径（回车=继续询问，q=退出）: " input_path
    [[ "$input_path" == "q" || "$input_path" == "Q" ]] && return 1
    [[ -z "$input_path" ]] && continue
    eval "project_path=\"$input_path\""                       # 展开 ~
    project_path="$(cd "$project_path" 2>/dev/null && pwd || echo "")"
    [[ -z "$project_path" ]] && echo "⚠️ 路径无效，请重试" >&2
  done

  printf "%s\n" "$project_path"
}

# ================================== 构建前置：保证 fvm + 版本 + flutter_cmd ==================================
# ✅ 设定 flutter_cmd 为命令数组（优先 fvm），确保后续以 "${flutter_cmd[@]}" 执行
set_flutter_cmd() {
  export PATH="$HOME/.pub-cache/bin:$PATH"
  if command -v fvm >/dev/null 2>&1; then
    flutter_cmd=(fvm flutter)
  else
    flutter_cmd=(flutter)
  fi
  echo "[INFO] flutter_cmd = ${flutter_cmd[*]}"
}

# ✅ 读取当前项目希望使用的 Flutter 版本（优先 .fvmrc / .fvm/fvm_config.json）
read_project_flutter_version() {
  local v=""
  if [[ -f .fvmrc ]]; then
    v="$(jq -r '.flutterSdkVersion // empty' .fvmrc 2>/dev/null)"
  elif [[ -f .fvm/fvm_config.json ]]; then
    v="$(jq -r '.flutterSdkVersion // empty' .fvm/fvm_config.json 2>/dev/null)"
  fi
  [[ -n "$v" ]] && echo "$v"
}

# ✅ 读取当前项目希望使用的 Flutter 版本（更健壮）
read_project_flutter_version() {
  local v=""

  # 1) 优先：.fvm/version（FVM 3.x/4.x 常见）
  if [[ -f .fvm/version ]]; then
    v="$(tr -d '\r' < .fvm/version | tr -d '[:space:]')"
    [[ -n "$v" ]] && echo "$v" && return 0
  fi

  # 2) .fvmrc：可能是 JSON，也可能是纯文本；键名可能是 "flutter" 或 "flutterSdkVersion"
  if [[ -f .fvmrc ]]; then
    # 2.1 JSON 解析
    if command -v jq >/dev/null 2>&1 && head -c1 .fvmrc | grep -q '{'; then
      v="$(jq -r '.flutter // .flutterSdkVersion // empty' .fvmrc 2>/dev/null | tr -d '[:space:]')"
      [[ -n "$v" ]] && echo "$v" && return 0
    fi
    # 2.2 纯文本（直接写版本号）
    v="$(sed -E 's/^[[:space:]]+|[[:space:]]+$//g' .fvmrc \
        | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+' | head -n1)"
    [[ -n "$v" ]] && echo "$v" && return 0
  fi

  # 3) .fvm/fvm_config.json（旧工具链常见）
  if [[ -f .fvm/fvm_config.json ]] && command -v jq >/dev/null 2>&1; then
    v="$(jq -r '.flutter // .flutterSdkVersion // empty' .fvm/fvm_config.json 2>/dev/null | tr -d '[:space:]')"
    [[ -n "$v" ]] && echo "$v" && return 0
  fi

  # 4) 兜底：如果项目内已经有 .fvm/flutter_sdk/bin/flutter，就直接读取版本号
  if [[ -x .fvm/flutter_sdk/bin/flutter ]]; then
    v="$(.fvm/flutter_sdk/bin/flutter --version 2>/dev/null \
        | grep -Eo 'Flutter [0-9]+\.[0-9]+\.[0-9]+' | awk '{print $2}' | head -n1)"
    [[ -n "$v" ]] && echo "$v" && return 0
  fi

  # 未找到
  return 1
}

# ✅ 在 apk 构建前调用：确保 fvm 存在 & 选定并安装好 Flutter 版本（若已有配置则不打扰）
ensure_fvm_and_flutter_version_before_build() {
  if ! command -v fvm >/dev/null 2>&1; then
    echo "[INFO] 未检测到 fvm，准备安装"
    if ! command -v dart >/dev/null 2>&1; then
      echo "[ERROR] 未检测到 dart，请先安装 dart 后重试"
      return 1
    fi
    dart pub global deactivate fvm >/dev/null 2>&1 || true
    dart pub global activate  fvm || { echo "[ERROR] fvm 安装失败"; return 1; }
    echo "[OK] fvm 安装成功"
  else
    # 确保 fvm 是用当前 Dart 重新激活过的，避免 kernel 版本不匹配
    dart pub global activate fvm >/dev/null 2>&1 || true
    echo "[INFO] fvm 已就绪"
  fi

  set_flutter_cmd

  local desired_version=""
  if desired_version="$(read_project_flutter_version)"; then
    echo "[INFO] 项目已绑定 Flutter 版本：$desired_version"
  else
    echo "[INFO] 项目未绑定 Flutter 版本，尝试获取 stable 列表"
    local versions latest
    versions="$(curl -fsSL https://storage.googleapis.com/flutter_infra_release/releases/releases_macos.json \
      | jq -r '.releases[] | select(.channel=="stable") | .version' | sort -V | uniq | tac)"
    latest="$(echo "$versions" | head -n1)"

    if command -v fzf >/dev/null 2>&1; then
      local pick
      pick="$(echo "$versions" | fzf --prompt='选择 Flutter 版本：' --height=50% --border --ansi)"
      desired_version="$(echo "$pick" | grep -Eo '^[0-9]+\.[0-9]+\.[0-9]+$')"
    fi
    desired_version="${desired_version:-$latest}"

    # 同步写入两处配置，兼容新旧工具链
    printf '{ "flutter": "%s" }\n' "$desired_version" > .fvmrc
    mkdir -p .fvm
    printf '{ "flutter": "%s", "flutterSdkVersion": "%s" }\n' "$desired_version" "$desired_version" > .fvm/fvm_config.json
    printf '%s\n' "$desired_version" > .fvm/version
    echo "[OK] 已写入 .fvmrc / .fvm/fvm_config.json / .fvm/version：$desired_version"
  fi

  # 安装 & 切换（install 幂等，直接执行最省事）
  echo "[INFO] 安装 Flutter $desired_version（如已安装会跳过下载）"
  fvm install "$desired_version" || { echo "[ERROR] fvm install 失败"; return 1; }

  fvm use "$desired_version" --force || { echo "[ERROR] fvm use 失败"; return 1; }

  set_flutter_cmd
  echo "[OK] Flutter $desired_version 就绪"
}

# ✅ 打 Android 包需要Java环境@17
ensure_jdk17() {
  if ! /usr/libexec/java_home -v 17 >/dev/null 2>&1; then
    err "系统未安装 JDK 17；请先安装（Temurin 17 / Zulu 17 等）。"
    exit 1
  fi
  jenv add "$(/usr/libexec/java_home -v 17)" >/dev/null 2>&1 || true
  jenv rehash
  local pick_17
  pick_17="$(jenv versions --bare | grep -E '(^|[[:space:]])(.*17(\.|$).*)' | head -n1 || true)"
  [[ -z "${pick_17:-}" ]] && { err "jenv 中未发现 JDK 17。"; exit 1; }

  jenv shell "$pick_17"
  export JENV_VERSION="$pick_17"
  export JAVA_HOME="$(jenv prefix)"
  export PATH="$JAVA_HOME/bin:$PATH"

  echo "$pick_17" > .java-version
  echo "JENV_VERSION=$JENV_VERSION"
  echo "JAVA_HOME=$JAVA_HOME"
  java -version
}

# ✅ 打 Android 包📦
apk() {
  local project_path
  project_path="$(get_flutter_project_dir "$PWD")" || return 1
  echo "[OK] 已确认 Flutter 项目目录: $project_path"
  cd "$project_path" || return 1

  # 现在才执行 buildCheck（保证在项目根）
  if typeset -f buildCheck >/dev/null; then buildCheck || return $?; fi

  ensure_fvm_and_flutter_version_before_build || return $?
  ensure_jdk17 || return $?

  # 子插件依赖更新
  if [[ -f "plugins/htprotect/pubspec.yaml" ]]; then
    echo "[INFO] 执行子插件依赖更新: plugins/htprotect"
    (cd plugins/htprotect && "${flutter_cmd[@]}" pub get) || return $?
  else
    echo "[WARN] 未找到 plugins/htprotect/pubspec.yaml，跳过 pub get"
  fi

  echo "[INFO] 开始构建 APK（release）..."
  "${flutter_cmd[@]}" build apk --release || return $?

  echo "[INFO] 打开输出目录: ./build/app/outputs/"
  open "./build/app/outputs/"
}

# ✅ 打 iOS 包📦
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

# ✅ 时间戳 ↔ 时间
t() {
  convert_timestamp() {
    local ts="$1"
    # 判断是否是毫秒
    if [[ ${#ts} -gt 10 ]]; then
      ts=$((ts / 1000))
    fi
    date -r "$ts" "+%Y-%m-%d %H:%M:%S"
  }

  while true; do
    echo ""
    read "?👉 请输入时间戳 (Ctrl+C 退出): " input
    if [[ -z "$input" ]]; then
      echo "❌ 未输入，跳过..."
      continue
    fi
    result=$(convert_timestamp "$input" 2>/dev/null)
    if [[ -z "$result" ]]; then
      echo "❌ 无效时间戳: $input"
    else
      echo "✅ 转换结果: $result"
    fi
  done
}

# ✅ 系统命令的二次封装
alias n='touch'

# ✅ 批量赋予执行权限：x
# 用法：在终端输入 `x` → 按提示把目录拖进来或手动输入路径
x() {
  local _raw _dir _count=0

  print -n "👉 请拖入目录或输入路径（q 退出）： "
  # -r: 原样读取，不转义；支持拖拽路径
  read -r _raw || { echo "❌ 读取输入失败"; return 1; }
  [[ -z "$_raw" || "$_raw" == "q" || "$_raw" == "Q" ]] && { echo "🙆 已退出"; return 0; }

  # 去掉首尾空白
  _raw="${_raw#"${_raw%%[![:space:]]*}"}"
  _raw="${_raw%"${_raw##*[![:space:]]}"}"

  # 处理拖拽/引号/反斜杠转义：zsh 的 (Q) 可反转义，随后做 ~ 展开
  _dir="${(Q)_raw}"
  _dir="${_dir%/}"     # 去掉末尾斜杠
  _dir=${~_dir}        # 允许 ~ 展开为家目录

  if [[ ! -d "$_dir" ]]; then
    echo "❌ 目录不存在：$_dir"
    return 1
  fi

  echo "🔎 目标目录：$_dir"
  echo "🚀 正在赋予可执行权限（.sh / .command）..."

  # 用 -print0 + 读空字节，稳妥处理所有奇怪文件名
  while IFS= read -r -d '' f; do
    if chmod +x "$f"; then
      ((_count++))
      echo "✅ 已处理：$f"
    else
      echo "⚠️  失败：$f"
    fi
  done < <(find "$_dir" -type f \( -name '*.sh' -o -name '*.command' \) -print0)

  if (( _count == 0 )); then
    echo "ℹ️  未发现 .sh 或 .command 文件。"
  else
    echo "✔ 完成，共处理 ${_count} 个文件。"
  fi
}

# ✅ 交互式颜色查看器：（带终端色块预览；真彩/256自动选择；安全放入 ~/.zshrc ；输入 cor 后按提示输入颜色）
cor() {
  emulate -L zsh
  set +x +v
  unsetopt XTRACE VERBOSE

  # ---- 后端选择：auto | truecolor | 256（默认 auto，可 export COR_MODE=256 强制）----
  : "${TERM:=xterm-256color}"
  local COR_MODE="${COR_MODE:-auto}"

  supports_truecolor() {
    case "$COR_MODE" in
      truecolor) return 0 ;;
      256)       return 1 ;;
    esac
    [[ "${COLORTERM:-}" == *truecolor* || "${COLORTERM:-}" == *24bit* ]] && return 0
    case "${TERM_PROGRAM:-}${TERM:-}" in
      *iTerm*|*WezTerm*|*Ghostty*|*kitty*|*xterm-kitty*|*Windows_Terminal*) return 0 ;;
    esac
    [[ "${TERM:-}" == *-truecolor || "${TERM:-}" == *direct ]] && return 0
    return 1
  }

  # ---------- 基础工具 ----------
  to_hex() { printf "%02X" "$1"; }
  alpha_f_to_255() { awk 'BEGIN{v='"$1"'; if(v<0)v=0;if(v>1)v=1; printf("%d",(v*255)+0.5)}'; }
  alpha_255_to_f() { awk 'BEGIN{printf("%.2f",'"$1"'/255)}'; }
  sanitize() { echo "$1" | tr -d '[:space:]' | tr -d '"' | tr -d "'"; }
  upper_hex() { echo "$1" | tr '[:lower:]' '[:upper:]'; }

  # ---------- 显示工具 ----------
  rel_luma() { awk 'BEGIN{r='"$1"';g='"$2"';b='"$3"'; printf("%.0f",0.2126*r+0.7152*g+0.0722*b)}'; }
  pick_fg() { local l; l=$(rel_luma "$1" "$2" "$3"); (( l > 186 )) && echo 30 || echo 97; }

  rgb_to_ansi256() {
    local r=$1 g=$2 b=$3
    if (( r==g && g==b )); then
      if   (( r < 8 ));   then echo 16
      elif (( r > 248 )); then echo 231
      else echo $((232 + ( (r-8) * 24 / 247 )))
      fi; return
    fi
    local rc=$(( (r * 5) / 255 ))
    local gc=$(( (g * 5) / 255 ))
    local bc=$(( (b * 5) / 255 ))
    echo $(( 16 + 36*rc + 6*gc + bc ))
  }

  show_block() {
    local rr=$1 gg=$2 bb=$3 label=$4 fg; fg=$(pick_fg "$rr" "$gg" "$bb")
    if supports_truecolor; then
      printf "\e[48;2;%d;%d;%dm" "$rr" "$gg" "$bb"
    else
      local idx; idx=$(rgb_to_ansi256 "$rr" "$gg" "$bb")
      printf "\e[48;5;%sm" "$idx"
    fi
    printf "\e[%sm" "$fg"
    printf "  %-18s  " "$label"
    printf "\e[0m"
  }

  # ---------- 解析器 ----------
  local r g b a_float aa_hex
  parse() {
    local raw="$1" input rr gg bb aa
    input=$(sanitize "$raw")

    if [[ "$input" == 0x???????? ]]; then
      local hex="${input:2}"; hex=$(upper_hex "$hex")
      aa=${hex:0:2}; rr=${hex:2:2}; gg=${hex:4:2}; bb=${hex:6:2}
      r=$((16#$rr)); g=$((16#$gg)); b=$((16#$bb))
      aa_hex="$aa"; a_float=$(alpha_255_to_f $((16#$aa))); return 0
    fi
    if [[ "$input" == \#???????? ]]; then
      local hex="${input:1}"; hex=$(upper_hex "$hex")
      rr=${hex:0:2}; gg=${hex:2:2}; bb=${hex:4:2}; aa=${hex:6:2}
      r=$((16#$rr)); g=$((16#$gg)); b=$((16#$bb))
      aa_hex="$aa"; a_float=$(alpha_255_to_f $((16#$aa))); return 0
    fi
    if [[ "$input" == \#?????? ]]; then
      local hex="${input:1}"; hex=$(upper_hex "$hex")
      rr=${hex:0:2}; gg=${hex:2:2}; bb=${hex:4:2}
      r=$((16#$rr)); g=$((16#$gg)); b=$((16#$bb))
      aa_hex="FF"; a_float="1.00"; return 0
    fi
    if [[ "$input" == rgb\(* || "$input" == rgba\(* ]]; then
      local nums; nums=$(echo "$input" | sed -E 's/^rgba?\(|\)$//g')
      local R G B A; IFS=',' read -r R G B A <<<"$nums"
      r=${R%%.*}; g=${G%%.*}; b=${B%%.*}
      [[ -z "$A" ]] && A="1"
      a_float=$(awk 'BEGIN{v='"$A"'; if(v<0)v=0;if(v>1)v=1; printf("%.2f",v)}')
      aa_hex=$(to_hex "$(alpha_f_to_255 "$a_float")"); return 0
    fi
    return 1
  }

  # ---------- 交互 ----------
  echo "🎨 颜色查看器：支持 #RRGGBB[AA] / 0xAARRGGBB / rgb / rgba"
  echo "ℹ️  这里只输入颜色本体"
  echo "🔗 在线取色器：https://photokit.com/colors/color-picker/?lang=zh"
  while true; do
    echo
    builtin read -r "inp?请输入颜色值（q 退出）： " < /dev/tty
    [[ "$inp" == [Qq] ]] && { echo "✅ 已退出"; break; }
    [[ -z "$inp" ]] && continue

    if parse "$inp"; then
      local RR=$(to_hex "$r") GG=$(to_hex "$g") BB=$(to_hex "$b") AA="$aa_hex"
      echo
      echo "----------------------------------------"
      echo "HEX（不透明）:  #${RR}${GG}${BB}"
      echo "HEX（含透明） :  #${RR}${GG}${BB}${AA}"
      echo "RGB           :  rgb(${r}, ${g}, ${b})"
      echo "RGBA          :  rgba(${r}, ${g}, ${b}, $(printf '%.2f' "$a_float"))"
      echo "0x 格式       :  0x${AA}${RR}${GG}${BB}"
      show_block "$r" "$g" "$b" "原色 #${RR}${GG}${BB}"; echo
    else
      echo "❌ 无法识别：$inp"
    fi
  done
}
