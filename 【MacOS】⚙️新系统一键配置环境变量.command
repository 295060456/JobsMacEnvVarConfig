#!/bin/zsh

# ==========🧾 脚本说明 ==========
echo ""
echo "🛠️ 环境变量同步工具（用户级 + 系统级）"
echo "1️⃣ 自动安装并更新 Homebrew、fzf"
echo "2️⃣ 使用 fzf 多选配置文件（顺序保持 + 空行分组）"
echo "3️⃣ 自动补齐模板：用户模板写注释，系统模板为空"
echo "4️⃣ 同步逻辑："
echo "    ✅ 用户文件：本地 → 覆盖用户路径"
echo "    ✅ 系统文件："
echo "       • 模板为空 → 系统文件 → 反向备份到本地模板"
echo "       • 模板非空 → 本地模板 → 覆盖系统路径（需 sudo + 自动备份）"
echo "5️⃣ 所有操作后自动 open 文件"
echo ""
read "?👉 请按回车继续，或 Ctrl+C 退出..."

# ==========📁 路径定义==========
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_ENV_FILE="$SCRIPT_DIR/env_config_root.txt"

# ==========🔍 安装 Homebrew + fzf ==========
if ! command -v brew >/dev/null 2>&1; then
  echo "📦 未检测到 Homebrew，正在安装..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  echo "✅ Homebrew 安装完成，请重新运行脚本以生效路径。"
  exit 0
else
  echo "✅ 检测到 Homebrew，执行升级..."
  brew update && brew upgrade && brew cleanup
fi

if ! command -v fzf >/dev/null 2>&1; then
  echo "📦 未检测到 fzf，正在安装..."
  brew install fzf
else
  echo "✅ 检测到 fzf，尝试升级..."
  brew upgrade fzf
fi

# ==========📋 配置文件清单（原始顺序 + 空行分组）==========
CONFIG_KEYS=(
  "用户 Bash 登录配置 ~/.bash_profile"
  "用户 Bash 交互配置 ~/.bashrc"
  "Zsh 配置 ~/.zshrc"
  "Zsh 登录配置 ~/.zprofile"
  "Zsh 登录后配置 ~/.zlogin"
  "Zsh 通用配置 ~/.zshenv"
  "Zsh 登出后配置 ~/.zlogout"
  ""
  "系统 Bash 登录配置 /etc/profile"
  "系统 Bash 交互配置 /etc/bashrc"
  "系统 Zsh 配置 /etc/zshrc"
)

typeset -A CONFIG_MAP
CONFIG_MAP=(
  ["用户 Bash 登录配置 ~/.bash_profile"]="$HOME/.bash_profile"
  ["用户 Bash 交互配置 ~/.bashrc"]="$HOME/.bashrc"
  ["Zsh 配置 ~/.zshrc"]="$HOME/.zshrc"
  ["Zsh 登录配置 ~/.zprofile"]="$HOME/.zprofile"
  ["Zsh 登录后配置 ~/.zlogin"]="$HOME/.zlogin"
  ["Zsh 通用配置 ~/.zshenv"]="$HOME/.zshenv"
  ["Zsh 登出后配置 ~/.zlogout"]="$HOME/.zlogout"

  ["系统 Bash 登录配置 /etc/profile"]="/etc/profile"
  ["系统 Bash 交互配置 /etc/bashrc"]="/etc/bashrc"
  ["系统 Zsh 配置 /etc/zshrc"]="/etc/zshrc"
)

# ==========📂 自动补齐模板文件 ==========
echo "\n📂 检查模板文件是否存在..."

for key in "${CONFIG_KEYS[@]}"; do
  [[ -z "$key" ]] && continue
  target_path="${CONFIG_MAP[$key]}"
  file_name="$(basename "$target_path")"
  local_file="$SCRIPT_DIR/$file_name"

  if [[ ! -f "$local_file" ]]; then
    echo "⚠️ 缺失模板：$file_name → 自动创建..."
    if [[ "$target_path" == /etc/* ]]; then
      touch "$local_file"  # 系统模板留空
    else
      echo "# ⚠️ 自动创建的模板文件，请根据需要填写内容" > "$local_file"
    fi
  else
    echo "✅ 模板已存在：$file_name"
  fi
done

# ==========📋 使用 fzf 选择配置文件 ==========
SELECTED_KEYS=$(printf '%s\n' "${CONFIG_KEYS[@]}" | fzf --multi --header="🔧 请选择要同步的配置文件：" --prompt="👉 ")

if [[ -z "$SELECTED_KEYS" ]]; then
  echo "❌ 未选择任何配置文件，已退出。"
  exit 0
fi

# ==========📥 执行同步逻辑 ==========
for key in ${(f)SELECTED_KEYS}; do
  [[ -z "$key" ]] && continue

  TARGET_PATH="${CONFIG_MAP[$key]}"
  FILE_NAME="$(basename "$TARGET_PATH")"
  LOCAL_FILE="$SCRIPT_DIR/$FILE_NAME"

  if [[ "$TARGET_PATH" == /etc/* && ! -s "$LOCAL_FILE" ]]; then
    echo "\n🔄 反向备份（系统模板为空）：$TARGET_PATH → $LOCAL_FILE"
  else
    echo "\n🔧 正在同步：$LOCAL_FILE → $TARGET_PATH"
  fi

  if [[ "$TARGET_PATH" == /etc/* ]]; then
    if [[ ! -s "$LOCAL_FILE" ]]; then
      echo "🛑 本地模板为空 → 为保护系统文件，执行反向备份..."
      cp -f "$TARGET_PATH" "$LOCAL_FILE"
      echo "✅ 已将系统文件备份为本地模板：$LOCAL_FILE"
      open "$LOCAL_FILE"
      continue
    fi

    if [[ -f "$TARGET_PATH" ]]; then
      BACKUP="$TARGET_PATH.backup.$(date +%Y%m%d%H%M%S)"
      sudo cp "$TARGET_PATH" "$BACKUP"
      echo "📦 系统原文件已备份：$BACKUP"
    fi

    sudo cp -f "$LOCAL_FILE" "$TARGET_PATH"
    echo "✅ 已将模板覆盖到系统文件：$TARGET_PATH"
  else
    cp -f "$LOCAL_FILE" "$TARGET_PATH"
    echo "✅ 已将模板覆盖到用户文件：$TARGET_PATH"
  fi

  open "$TARGET_PATH"
done

echo "\n🎉 ✅ 所有配置文件同步操作已完成！"
read "?📦 按回车退出..."
