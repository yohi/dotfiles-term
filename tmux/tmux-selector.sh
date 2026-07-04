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

    # ディレクトリ候補のリスト作成
    local -a dir_candidates
    dir_candidates=(
        "$HOME"
        "$HOME/dotfiles"
        "$HOME/dotfiles-core"
    )

    # ~/program 配下のディレクトリを追加
    if [[ -d "$HOME/program" ]]; then
        for d in "$HOME/program"/*(/N); do
            dir_candidates+=("$d")
        done
    fi

    # ~/dotfiles/components 配下のディレクトリを追加
    if [[ -d "$HOME/dotfiles/components" ]]; then
        for d in "$HOME/dotfiles/components"/*(/N); do
            dir_candidates+=("$d")
        done
    fi

    # fzf でディレクトリを選択
    local selected_dir
    selected_dir=$(printf "%s\n" "${dir_candidates[@]}" | fzf --prompt="Select work directory: " --height=40% --reverse --border)

    # キャンセル（Escなど）された場合はホームディレクトリをデフォルトにする
    if [[ -z "$selected_dir" ]]; then
        selected_dir="$HOME"
    fi

    # セッションをバックグラウンドで作成し、指定ディレクトリを開始位置にする
    tmux new-session -d -s "$session_name" -c "$selected_dir"
    # 左右に2:1 (右ペインを33%) の比率で分割（新しくできた右ペインにフォーカス移動）
    tmux split-window -h -p 33 -t "$session_name" -c "$selected_dir"
    # 右ペインを上下に2:1 (下ペインを33%) の比率で分割（フォーカスは右下ペインに移動）
    tmux split-window -v -p 33 -t "$session_name" -c "$selected_dir"
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
