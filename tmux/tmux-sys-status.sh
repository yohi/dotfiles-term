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
        bar="${bar}■"
    done
    for ((i=0; i<empty; i++)); do
        bar="${bar}□"
    done
    echo "[$bar]"
}

cpu_bar=$(make_bar "$cpu_val")
mem_bar=$(make_bar "$mem_val")

# 整えて出力
echo "CPU: $(printf "%3d" "$cpu_val")% $cpu_bar | Mem: $(printf "%3d" "$mem_val")% $mem_bar"
