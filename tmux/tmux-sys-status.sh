#!/usr/bin/env bash

# 引数が足りない場合は空を出力
if [ $# -lt 2 ]; then
    echo ""
    exit 0
fi

# 引数のクリーンアップ（パーセンテージ記号とスペースを削除）
cpu_raw=$(echo "$1" | tr -d '% ')
mem_raw=$(echo "$2" | tr -d '% ')

# 整数に変換（空または不正な値の場合は 0 にフォールバック）
cpu_val=$(printf "%.0f" "$cpu_raw" 2>/dev/null || echo 0)
mem_val=$(printf "%.0f" "$mem_raw" 2>/dev/null || echo 0)

# 10段階のバーを生成する関数
make_bar() {
    local percent=$1
    local filled=$(( (percent + 5) / 10 )) # 四捨五入して10段階にする
    if [ $filled -gt 10 ]; then filled=10; fi
    if [ $filled -lt 0 ]; then filled=0; fi
    local empty=$(( 10 - filled ))
    
    local bar=""
    for ((i=0; i<filled; i++)); do
        bar="${bar}■"
    done
    for ((i=0; i<empty; i++)); do
        bar="${bar}░"
    done
    echo "[$bar]"
}

cpu_bar=$(make_bar "$cpu_val")
mem_bar=$(make_bar "$mem_val")

# 整えて出力
echo "CPU: $(printf "%s" "$1") $cpu_bar | Mem: $(printf "%s" "$2") $mem_bar"
