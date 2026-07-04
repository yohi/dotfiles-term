#!/usr/bin/env bash

# 1. CPU使用率の計算 (キャッシュ方式で超軽量・スリープなし)
CACHE_FILE="/tmp/tmux-cpu-stat-cache"
read -r _ user nice system idle iowait irq softirq steal guest guest_nice < /proc/stat

total_current=$((user + nice + system + idle + iowait + irq + softirq + steal))
idle_current=$((idle + iowait))

cpu_val=0
if [ -f "$CACHE_FILE" ]; then
    read -r total_prev idle_prev < "$CACHE_FILE"
    total_diff=$((total_current - total_prev))
    idle_diff=$((idle_current - idle_prev))
    if [ $total_diff -gt 0 ]; then
        cpu_val=$(( 100 - (idle_diff * 100 / total_diff) ))
    fi
fi
echo "$total_current $idle_current" > "$CACHE_FILE"

# 2. メモリ使用率の計算
mem_info=($(free | awk '/Mem:/ {print $3, $2}'))
if [ ${#mem_info[@]} -eq 2 ] && [ ${mem_info[1]} -gt 0 ]; then
    mem_val=$(( mem_info[0] * 100 / mem_info[1] ))
else
    mem_val=0
fi

# 10段階のバーを生成する関数
make_bar() {
    local percent=$1
    local filled=$(( (percent + 5) / 10 )) # 四捨五入
    if [ $filled -gt 10 ]; then filled=10; fi
    if [ $filled -lt 0 ]; then filled=0; fi
    local empty=$(( 10 - filled ))
    
    local bar=""
    for ((i=0; i<filled; i++)); do
        bar="${bar}|"
    done
    for ((i=0; i<empty; i++)); do
        bar="${bar} "
    done
    echo "[$bar]"
}

cpu_bar=$(make_bar "$cpu_val")
mem_bar=$(make_bar "$mem_val")

# 使用率に応じて色コード（黄色・赤）を決定する関数
get_color_tag() {
    local percent=$1
    if [ $percent -ge 90 ]; then
        echo "#[fg=red,bold]"
    elif [ $percent -ge 80 ]; then
        echo "#[fg=yellow,bold]"
    else
        echo "" # 80%未満はデフォルト色
    fi
}

cpu_color=$(get_color_tag "$cpu_val")
mem_color=$(get_color_tag "$mem_val")

# 文字化けや環境による化けを防ぐため、Unicodeのコードポイントから直接アイコンを生成
# CPU (U+F4BC: nf-oct-cpu), RAM (U+F035B: nf-md-memory)
cpu_icon=$(printf "\uF4BC")
mem_icon=$(printf "\uF035B")

# 文字化けや環境による化けを防ぐため、Unicodeのコードポイントから直接アイコンを生成
# CPU (U+F4BC: nf-oct-cpu), RAM (U+EFC5: ユーザー環境のRAMモジュールアイコン)
cpu_icon=$(printf "\uF4BC")
mem_icon=$(printf "\uEFC5")

# 各セグメントの末尾で #[default] を指定して色をリセットする (左側にNerd Fontsのアイコンを追加、文字との間に余白を確保するためスペースを2つにする)
echo "${cpu_color}${cpu_icon}  CPU: $(printf "%3d" "$cpu_val")% $cpu_bar#[default] | ${mem_color}${mem_icon}  Mem: $(printf "%3d" "$mem_val")% $mem_bar#[default]"
