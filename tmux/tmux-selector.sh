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
# 2. デフォルトレイアウト (左1、右上下2)
# 3. 通常のzsh
# 4. 既存のtmuxセッション一覧
menu_options=("[New Session]" "[Default Layout]" "[Normal Shell]")

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
elif [[ "$choice" == "[Default Layout]" ]]; then
    # 重複しないセッション名を決定
    base_name="default"
    session_name="$base_name"
    idx=1
    while tmux has-session -t "$session_name" 2>/dev/null; do
        session_name="${base_name}-${idx}"
        idx=$((idx + 1))
    done

    # セッションをバックグラウンドで作成
    tmux new-session -d -s "$session_name"
    # 左右に50%ずつ分割（デフォルトでフォーカスは新しくできた右ペインに移動します）
    tmux split-window -h -t "$session_name"
    # 右ペインを上下に分割（フォーカスは新しくできた右下ペインに移動します）
    tmux split-window -v -t "$session_name"
    # フォーカスを左のメインペインに戻す
    tmux select-pane -L -t "$session_name"
    # アタッチ
    exec tmux attach-session -t "$session_name"
elif [[ "$choice" == "[Normal Shell]" ]]; then
    exec zsh
else
    # 既存セッションにアタッチ（コロンより前がセッション名）
    session_name=$(echo "$choice" | cut -d':' -f1)
    exec tmux attach-session -t "$session_name"
fi
