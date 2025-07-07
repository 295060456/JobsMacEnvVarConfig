#!/bin/zsh

# 当前用户名
CURRENT_USER=$(whoami)

# 查找所有 md 文件
MD_FILES=(*.md)
COUNT=${#MD_FILES[@]}

# 无文件处理
if (( COUNT == 0 )); then
  echo "❌ 当前目录下没有 .md 文件"
  exit 1
fi

# 选择目标文件
if (( COUNT == 1 )); then
  TARGET_MD_FILE="${MD_FILES[1]}"
else
  echo "📄 请选择要替换用户名路径的 Markdown 文件："
  TARGET_MD_FILE=$(printf "%s\n" "${MD_FILES[@]}" | fzf --prompt="选择文件 > ")
  [[ -z "$TARGET_MD_FILE" ]] && echo "❌ 未选择文件，退出。" && exit 1
fi

echo "✅ 选中文件：$TARGET_MD_FILE"
echo "👤 当前用户名为：$CURRENT_USER"

# 提取文件中所有 file:///Users/XXX 的用户名（去重）
OLD_USERS=$(grep -oE "file:///Users/[^/]+" "$TARGET_MD_FILE" | sed 's|file:///Users/||' | sort -u)

# 如果只有一个旧用户名，默认替换；否则用 fzf 选一个
if [[ $(echo "$OLD_USERS" | wc -l | xargs) -eq 1 ]]; then
  OLD_USER="$OLD_USERS"
else
  echo "👤 检测到多个用户名，请选择要替换的旧用户名："
  OLD_USER=$(echo "$OLD_USERS" | fzf --prompt="旧用户名 > ")
  [[ -z "$OLD_USER" ]] && echo "❌ 未选择用户名，退出。" && exit 1
fi

# 替换内容（保留原文件备份）
cp "$TARGET_MD_FILE" "$TARGET_MD_FILE.bak"
sed -i '' "s|file:///Users/$OLD_USER|file:///Users/$CURRENT_USER|g" "$TARGET_MD_FILE"

echo "✅ 替换完成，所有 file:///Users/$OLD_USER → file:///Users/$CURRENT_USER"
echo "📄 原文件已备份为：$TARGET_MD_FILE.bak"

