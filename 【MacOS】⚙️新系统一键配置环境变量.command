#!/bin/zsh

echo ""
echo "===================================================================="
echo "🧰 脚本功能说明："
echo "✅ 自动检测并安装 Homebrew（如未安装）"
echo "✅ 自动升级 Homebrew（如已安装）"
echo "✅ 使用 fzf 多选打开配置文件（回车跳过）"
echo "✅ 支持条件复制配置文件到系统配置目录"
echo "✅ 环境变量配置统一写入 ~/.bash_profile"
echo "===================================================================="
echo ""
read "?👉 请按下回车键继续，或 Ctrl+C 取消..."

# 全局变量
CURRENT_DIRECTORY=$(dirname "$(readlink -f "$0")")

# 打印方法
_JobsPrint() { echo -e "$1$2\033[0m"; }
_JobsPrint_Red() { _JobsPrint "\033[1;31m" "$1"; }
_JobsPrint_Green() { _JobsPrint "\033[1;32m" "$1"; }

# 打印 Logo
jobs_logo() {
    local logo="
||=================================================||
||  JJJJJJJJ     oooooo    bb          SSSSSSSSSS  ||
||        JJ    oo    oo   bb          SS      SS  ||
||        JJ    oo    oo   bb          SS          ||
||        JJ    oo    oo   bbbbbbbbb   SSSSSSSSSS  ||
||  J     JJ    oo    oo   bb      bb          SS  ||
||  JJ    JJ    oo    oo   bb      bb  SS      SS  ||
||   JJJJJJ      oooooo     bbbbbbbb   SSSSSSSSSS  ||
||=================================================||"
    _JobsPrint_Green "$logo"
}

# 检查并安装/升级 brew
check_or_install_brew() {
    if ! command -v brew >/dev/null 2>&1; then
        _JobsPrint_Red "❌ 未检测到 Homebrew，开始安装..."
        NONINTERACTIVE=1 /bin/bash -c \
            "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        local BREW_ENV=$(eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)")
        if ! grep -q "brew shellenv" "$HOME/.bash_profile"; then
            echo "$BREW_ENV" >> "$HOME/.bash_profile"
            _JobsPrint_Green "✅ 已将 brew 环境变量写入 ~/.bash_profile"
        fi
        eval "$BREW_ENV"
        source "$HOME/.bash_profile"
    else
        _JobsPrint_Green "✅ Homebrew 已安装，执行更新..."
        brew update && brew upgrade && brew doctor
    fi
}

# 使用 fzf 打开配置文件
open_files_with_fzf() {
    if ! command -v fzf >/dev/null 2>&1; then
        _JobsPrint_Red "❌ fzf 未安装，尝试使用 brew 安装中..."
        brew install fzf
    fi

    _JobsPrint_Green "📂 使用 fzf 多选配置文件进行打开（回车跳过）："
    local options=(
        "$HOME/.bash_profile"
        "$HOME/.bashrc"
        "$HOME/.zshrc"
    )

    local selected_files
    selected_files=$(printf "%s\n" "${options[@]}" | fzf --multi --prompt="📌 选择配置文件：" --border --height=10)

    if [[ -z "$selected_files" ]]; then
        _JobsPrint_Red "⚠️ 未选择任何文件，跳过打开操作。"
    else
        while IFS= read -r file; do
            open "$file"
        done <<< "$selected_files"
    fi
}

# 条件复制配置文件
copy_file_with_prompt() {
    local src_file="$1"
    local dest_file="$2"
    if [[ -f "$src_file" ]]; then
        _JobsPrint_Green "📝 发现 $src_file，是否复制到 $dest_file？按回车复制，其他键跳过："
        read user_input
        if [[ -z "$user_input" ]]; then
            cp "$src_file" "$dest_file"
            _JobsPrint_Green "✅ 已复制 $src_file 到 $dest_file"
        else
            _JobsPrint_Red "❎ 跳过复制 $src_file"
        fi
    else
        _JobsPrint_Red "❌ 源文件 $src_file 不存在，跳过..."
    fi
}

# 主函数
main() {
    jobs_logo
    check_or_install_brew
    open_files_with_fzf
    copy_file_with_prompt "$CURRENT_DIRECTORY/.bash_profile" "$HOME/.bash_profile"
    copy_file_with_prompt "$CURRENT_DIRECTORY/.bashrc" "$HOME/.bashrc"
    copy_file_with_prompt "$CURRENT_DIRECTORY/.zshrc" "$HOME/.zshrc"
}

main
