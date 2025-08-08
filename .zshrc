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

# ================================== ✅ 配置 jenv 路径（必须在函数之前）==================================
export PATH="$HOME/.jenv/bin:$PATH"
eval "$(jenv init -)"

# ================================== ✅ 重启终端 ======================================================
rb() {
  exec "$SHELL"
}

# ================================== ✅ 快捷打开系统配置文件 ============================================
a(){
  open $HOME/.bash_profile
}

b(){
  open $HOME/.zshrc
}

# ================================== ✅ 一键重新加载常见配置文件 ========================================
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

# ================================== ✅ 更新 ==========================================================
update() {
    brew update && brew upgrade && brew cleanup && brew doctor && brew -v # Homebrew
    dart pub global activate fvm                                          # fvm
}

# ================================== ✅ Flutter 命令重载（优先 FVM） ====================================
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

# ================================== ✅ 修复 fvm 与 Dart SDK 不匹配问题 ==================================
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

# ================================== ✅ 检查 Dart / FVM / Flutter 版本信息 ===========================
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

