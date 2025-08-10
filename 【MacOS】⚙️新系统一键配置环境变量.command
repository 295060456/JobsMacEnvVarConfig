#!/bin/zsh
# ✅ 脚本功能
# 仅对你一次性拖入的文件进行处理：按文件名匹配固定映射 → 写入固定系统/用户路径（备份 & 提权）。
# 未拖入/不匹配的文件一律忽略，不计失败。

# ✅ 全局变量
typeset -gi OK_COUNT=0
typeset -gi FAIL_COUNT=0
typeset -gi SKIP_COUNT=0
typeset -ga INPUTS=()   # 仅保存“存在且文件名在映射表中的文件”

# ✅ 彩色输出函数
SCRIPT_BASENAME=$(basename "$0" | sed 's/\.[^.]*$//')   # 当前脚本名（去掉扩展名）
LOG_FILE="/tmp/${SCRIPT_BASENAME}.log"                  # 设置对应的日志文件路径

log()            { echo -e "$1" | tee -a "$LOG_FILE"; }
color_echo()     { log "\033[1;32m$1\033[0m"; }         # ✅ 正常绿色输出
info_echo()      { log "\033[1;34mℹ $1\033[0m"; }       # ℹ 信息
success_echo()   { log "\033[1;32m✔ $1\033[0m"; }       # ✔ 成功
warn_echo()      { log "\033[1;33m⚠ $1\033[0m"; }       # ⚠ 警告
warm_echo()      { log "\033[1;33m$1\033[0m"; }         # 🟡 温馨提示（无图标）
note_echo()      { log "\033[1;35m➤ $1\033[0m"; }       # ➤ 说明
error_echo()     { log "\033[1;31m✖ $1\033[0m"; }       # ✖ 错误
err_echo()       { log "\033[1;31m$1\033[0m"; }         # 🔴 错误纯文本
debug_echo()     { log "\033[1;35m🐞 $1\033[0m"; }      # 🐞 调试
highlight_echo() { log "\033[1;36m🔹 $1\033[0m"; }      # 🔹 高亮
gray_echo()      { log "\033[0;90m$1\033[0m"; }         # ⚫ 次要信息
bold_echo()      { log "\033[1m$1\033[0m"; }            # 📝 加粗
underline_echo() { log "\033[4m$1\033[0m"; }            # 🔗 下划线

# ✅ 文件名 → 目标路径映射
typeset -A FILE_MAP=(
  [".bash_profile"]="$HOME/.bash_profile"
  [".bashrc"]="$HOME/.bashrc"
  [".zshrc"]="$HOME/.zshrc"
  [".zprofile"]="$HOME/.zprofile"
  [".zlogin"]="$HOME/.zlogin"
  [".zshenv"]="$HOME/.zshenv"
  [".zlogout"]="$HOME/.zlogout"
  ["profile"]="/etc/profile"
  ["bashrc"]="/etc/bashrc"
  ["zshrc"]="/etc/zshrc"
)

# ✅ 自述（等待回车）
show_intro() {
  title_echo "写入 Shell 配置到系统默认位置"
  note_echo  "• 仅处理你拖入的文件；按文件名匹配映射，其余忽略（不计失败）"
  note_echo  "• 自动备份：*.bak.YYYYmmdd_HHMMSS"
  note_echo  "• 系统级路径自动提权写入（/etc/*）"
  note_echo  "• 支持一次拖入多个文件（空格分隔）"
  echo
  read -r "?👉 按回车键开始，或 Ctrl+C 取消..."
}

# ✅ 路径规范化（去转义/去引号/展开 ~）
normalize_path() {
  local raw="$1"
  local unq="${(Q)raw}"   # 去掉反斜杠和引号
  local exp="${~unq}"     # 展开 ~
  printf "%s" "$exp"
}

# ✅ 备份
backup_if_exists() {
  local dest="$1"
  if [[ -e "$dest" ]]; then
    local ts bak
    ts=$(date +"%Y%m%d_%H%M%S")
    bak="${dest}.bak.${ts}"
    if cp -p "$dest" "$bak" 2>/dev/null || sudo cp -p "$dest" "$bak" 2>/dev/null; then
      note_echo "已备份：$dest → $bak"
    else
      warn_echo "无法备份：$dest"
    fi
  fi
}

# ✅ 确保目录
ensure_parent_dir() {
  local dest="$1" parent
  parent="$(dirname "$dest")"
  [[ -d "$parent" ]] || mkdir -p "$parent" 2>/dev/null || sudo mkdir -p "$parent" 2>/dev/null
}

# ✅ 写入（含提权兜底）
write_with_privilege() {
  local src="$1" dest="$2"
  cp -f "$src" "$dest" 2>/dev/null || \
  sudo cp -f "$src" "$dest" 2>/dev/null || \
  sudo sh -c "cat \"$src\" > \"$dest\"" 2>/dev/null
}

# ✅ 写入单个匹配文件
install_one() {
  local src="$1"
  local base dest
  base="$(basename "$src")"
  dest="${FILE_MAP[$base]}"
  [[ -n "$dest" ]] || return 0  # 理论上不会走到：collect_inputs 已过滤未映射项

  info_echo "准备写入：$base → $dest"
  ensure_parent_dir "$dest"
  backup_if_exists "$dest"

  if write_with_privilege "$src" "$dest"; then
    success_echo "写入成功：$dest"
    ((OK_COUNT++))
  else
    error_echo "写入失败：$dest"
    ((FAIL_COUNT++))
  fi
}

# ✅ 交互式收集（直到得到 ≥1 个“存在且映射内”的文件）
read_inputs_interactively_once() {
  INPUTS=()    # 清空
  note_echo "将文件一次性拖入此窗口（可多个，空格分隔）；Ctrl+C 退出。"
  local line; read -r "?👉 等你拖入: " line || return 1
  [[ -z "$line" ]] && return 1

  # token 化（zsh：保留 Finder 反斜杠转义）
  local -a tokens; tokens=(${=line})
  local t norm base
  for t in "${tokens[@]}"; do
    norm="$(normalize_path "$t")"
    [[ -f "$norm" ]] || continue                 # 仅要“真实存在的常规文件”
    base="$(basename "$norm")"
    [[ -n "${FILE_MAP[$base]}" ]] || { ((SKIP_COUNT++)); continue; }   # 未映射：忽略
    INPUTS+=("$norm")
  done

  (( ${#INPUTS[@]} > 0 )) || return 1
  return 0
}

# ✅ 收集输入（命令行或交互；只保留“存在且映射内”的文件）
collect_inputs() {
  INPUTS=()
  SKIP_COUNT=0

  if (( $# > 0 )); then
    local a norm base
    for a in "$@"; do
      norm="$(normalize_path "$a")"
      [[ -f "$norm" ]] || continue
      base="$(basename "$norm")"
      [[ -n "${FILE_MAP[$base]}" ]] || { ((SKIP_COUNT++)); continue; }
      INPUTS+=("$norm")
    done
    (( ${#INPUTS[@]} > 0 )) && return 0
    warn_echo "命令行参数中没有任何可处理的文件，将进入交互。"
  fi

  # 交互循环直到拿到 ≥1 个“存在且映射内”的文件
  while ! read_inputs_interactively_once; do
    warn_echo "没有可处理的文件，请重新拖入（或 Ctrl+C 退出）。"
  done
}

# ✅ 批量处理（只处理 INPUTS）
process_all() {
  local it
  for it in "${INPUTS[@]}"; do
    install_one "$it"
  done
}

# ✅ 汇总（未匹配/无效项仅计入“跳过”，不算失败）
summarize_result() {
  [[ $SKIP_COUNT -gt 0 ]] && note_echo "已忽略未匹配/无效条目：$SKIP_COUNT"
  info_echo "成功: $OK_COUNT，失败: $FAIL_COUNT"
  (( FAIL_COUNT == 0 )) && success_echo "全部完成 ✅  （日志：$LOG_FILE）" || warn_echo "部分失败，请检查日志：$LOG_FILE"
}

# ✅ main
main() {
  # 1) 自述 + 等待确认
  show_intro
  # 2) 收集输入（命令行或交互；仅保留“存在且映射内”的文件）
  collect_inputs "$@" || { error_echo "未收到可处理的文件，已取消。"; exit 1; }
  # 3) 批量处理拖入的文件（仅处理映射内文件名）
  process_all
  # 4) 汇总结果（未匹配的文件不计失败）
  summarize_result
}

main "$@"
