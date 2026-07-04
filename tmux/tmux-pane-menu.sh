#!/bin/bash

# 引数からターゲットペインIDとカレントパスを取得
TARGET_PANE="$1"
CURRENT_PATH="$2"

if [[ -z "$TARGET_PANE" ]]; then
    exit 0
fi

# PATHにLinuxbrewを追加してコマンド（fzf, tmux）を使えるようにする
if [[ -d "/home/linuxbrew/.linuxbrew" ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# 選択肢
choices=(
    "1. Kill Pane (Close)"
    "2. Horizontal Split (Left/Right)"
    "3. Vertical Split (Top/Bottom)"
    "4. Zoom / Unzoom (Maximize)"
    "5. Cancel"
)

# fzfで選択 (対象のディレクトリをプロンプトに表示して分かりやすくする)
display_path="${CURRENT_PATH/#$HOME/\~}"
choice=$(printf "%s\n" "${choices[@]}" | fzf --prompt="Action for $display_path: " --height=100% --reverse --border=none 2>/home/y_ohi/fzf-error.log)

case "$choice" in
    "1. Kill Pane (Close)")
        tmux kill-pane -t "$TARGET_PANE"
        ;;
    "2. Horizontal Split (Left/Right)")
        tmux split-window -h -t "$TARGET_PANE" -c "$CURRENT_PATH"
        ;;
    "3. Vertical Split (Top/Bottom)")
        tmux split-window -v -t "$TARGET_PANE" -c "$CURRENT_PATH"
        ;;
    "4. Zoom / Unzoom (Maximize)")
        tmux resize-pane -t "$TARGET_PANE" -Z
        ;;
    *)
        exit 0
        ;;
esac
