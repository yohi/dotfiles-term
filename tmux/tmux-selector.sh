#!/usr/bin/env zsh

# すでに tmux の中にいる場合は二重起動を防ぐために通常のシェルを起動
if [[ -n "$TMUX" ]]; then
    exec zsh
fi

# fzf が存在しない場合のフォールバック
if ! command -v fzf &> /dev/null; then
    echo "fzf is not installed. Falling back to normal tmux session."
    exec tmux
fi

# 選択肢の作成
# 1. 新規セッション
# 2. 通常のzsh
# 3. 既存のtmuxセッション一覧
menu_options=("[New Session]" "[Normal Shell]")

if command -v tmux &> /dev/null; then
    # 既存セッションの取得
    while IFS= read -r line; do
        if [[ -n "$line" ]]; then
            menu_options+=("$line")
        fi
    done < <(tmux list-sessions 2>/dev/null)
fi

# fzfで選択
choice=$(printf "%s\n" "${menu_options[@]}" | fzf --prompt="Select tmux action/session: " --height=40% --reverse --border)

# 選択に応じた処理
if [[ -z "$choice" ]]; then
    # キャンセル（Escなど）された場合は通常の zsh を起動
    exec zsh
elif [[ "$choice" == "[New Session]" ]]; then
    echo -n "Enter new session name (or press Enter for default): "
    read name
    if [[ -z "$name" ]]; then
        exec tmux new-session
    else
        exec tmux new-session -s "$name"
    fi
elif [[ "$choice" == "[Normal Shell]" ]]; then
    exec zsh
else
    # 既存セッションにアタッチ（コロンより前がセッション名）
    session_name=$(echo "$choice" | cut -d':' -f1)
    exec tmux attach-session -t "$session_name"
fi
