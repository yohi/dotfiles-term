#!/usr/bin/env zsh

# 起動元のペインIDが取れない場合は終了
if [[ -z "$TMUX_PANE" ]]; then
    exit 0
fi

# 選択肢
choices=(
    "1. Kill Pane (Close)"
    "2. Horizontal Split (Left/Right)"
    "3. Vertical Split (Top/Bottom)"
    "4. Zoom / Unzoom (Maximize)"
    "5. Cancel"
)

# fzfで選択
choice=$(printf "%s\n" "${choices[@]}" | fzf --prompt="Select action: " --height=100% --reverse --border=none)

case "$choice" in
    "1. Kill Pane (Close)")
        tmux kill-pane -t "$TMUX_PANE"
        ;;
    "2. Horizontal Split (Left/Right)")
        # 元のペインのパスを取得して、同じディレクトリで分割する
        current_path=$(tmux display-message -t "$TMUX_PANE" -p "#{pane_current_path}")
        tmux split-window -h -t "$TMUX_PANE" -c "$current_path"
        ;;
    "3. Vertical Split (Top/Bottom)")
        current_path=$(tmux display-message -t "$TMUX_PANE" -p "#{pane_current_path}")
        tmux split-window -v -t "$TMUX_PANE" -c "$current_path"
        ;;
    "4. Zoom / Unzoom (Maximize)")
        tmux resize-pane -t "$TMUX_PANE" -Z
        ;;
    *)
        exit 0
        ;;
esac
