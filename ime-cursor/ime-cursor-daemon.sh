#!/usr/bin/env bash
#
# ime-cursor-daemon.sh
#
# IBus の入力エンジン切替 (GlobalEngineChanged) を監視し、日本語入力 (mozc) が
# 有効なときと直接入力 (xkb) のときで端末カーソル色を OSC 12 で切り替える。
# Vim の IME 連動カーソルを、シェルを含む端末全体へ拡張したもの。
#
#   検知: gdbus monitor で org.freedesktop.IBus の GlobalEngineChanged を購読。
#   反映: 制御端末へ OSC 12 を送出する。
#         制御端末または環境変数 TTY で明示された端末のみに送る。
#         制御端末がない場合は送出せず、別セッションの pts への誤送信を防ぐ。
#         (IBus のグローバルエンジンはセッション全体で 1 つだが、
#          実際に入力を受けているのはアクティブな端末のみ。)
#         制御端末が特定できない場合のみ、自ユーザの pts を列挙してフォールバックする。
#         (IBus のグローバルエンジンはセッション全体で 1 つだが、
#          実際に入力を受けているのはアクティブな端末のみ。)
#
# 環境変数で色を上書き可能:
#   IME_ON_COLOR  (default: #F92672)  日本語入力  (mozc-jp / mozc-on)
#   IME_OFF_COLOR (default: #F8F8F2)  直接入力    (xkb:* / mozc-off)
#
set -euo pipefail

IME_ON_COLOR="${IME_ON_COLOR:-#F92672}"
IME_OFF_COLOR="${IME_OFF_COLOR:-#F8F8F2}"

log() {
	printf '%s ime-cursor: %s\n' "$(date '+%H:%M:%S')" "$*" >&2
}

# 現在の IBus エンジン名から適用すべきカーソル色を決定する。
#   mozc-off … mozc の直接入力モード → OFF 扱い
#   mozc*    … mozc-jp / mozc-on = 日本語入力 → ON
#   それ以外 … xkb:* などキーボードレイアウト = 直接入力 → OFF
color_for_engine() {
	case "$1" in
	mozc-off) printf '%s' "$IME_OFF_COLOR" ;;
	mozc*) printf '%s' "$IME_ON_COLOR" ;;
	*) printf '%s' "$IME_OFF_COLOR" ;;
	esac
}

# 制御端末を返す。取得できなければ空文字列。
# process substitution 等で stdin が端末でなくなっていても /dev/tty が制御端末を
# 指すため、まず /dev/tty を試す。/dev/tty が使えない場合のみ、テスト・手動
# 呼び出し用の TTY 環境変数、または tty コマンドをフォールバックする。
# shellcheck disable=SC2329 # invoked by broadcast_cursor_color
current_tty() {
	local tty
	# /dev/tty は存在していても制御端末がない場合に開けないことがあるため、
	# 実際に書き込みオープンできるかをサブシェルで確認する。
	if (exec 3>/dev/tty) 2>/dev/null; then
		printf '%s' /dev/tty
		return 0
	fi
	if [ -n "${TTY:-}" ] && [ -w "${TTY:-}" ]; then
		printf '%s' "$TTY"
		return 0
	fi
	tty="$(tty 2>/dev/null || true)"
	[ -n "$tty" ] && [ -w "$tty" ] || return 0
	printf '%s' "$tty"
}
# 単一の write システムコールで seq を pts に書き込む。
# Bash 組み込み printf からのリダイレクトでも大抵は atomic だが、
# 確実性を高めるため /usr/bin/printf を優先する。
# 詰まった pts への書き込みが無限にブロックしないよう timeout 0.2 で保護する。
# 失敗時は exit 1 を返す。
# shellcheck disable=SC2329 # invoked by broadcast_cursor_color
write_seq_atomic() {
	local seq="$1"
	local pts="$2"
	if [ -x /usr/bin/printf ]; then
		timeout 0.2 /usr/bin/printf '%s' "$seq" >"$pts" 2>/dev/null
	else
		timeout 0.2 printf '%s' "$seq" >"$pts" 2>/dev/null
	fi
}
# OSC 12 (カーソル色設定) を制御端末または TTY 環境変数で明示された端末へ送出する。
# /dev/pts/N への書き込みは端末出力として解釈され、シェルの stdin には注入されない。
# 制御端末がなく、TTY も設定されていない場合は送出せず、別セッションの pts への
# 誤送信を防ぐ。
broadcast_cursor_color() {
	local color="$1"
	local seq pts
	seq="$(printf '\033]12;%s\007' "$color")"
	pts="$(current_tty)"

	if [ -n "$pts" ] && [ -w "$pts" ]; then
		if write_seq_atomic "$seq" "$pts"; then
			log "applied $color to $pts"
		else
			log "failed to apply $color to $pts"
		fi
	elif [ -n "$pts" ]; then
		log "skipped $color (not writable: $pts)"
	else
		log "skipped $color (no controlling terminal)"
	fi
}

apply_engine() {
	local engine="$1"
	[ -n "$engine" ] || return 0
	broadcast_cursor_color "$(color_for_engine "$engine")"
}
# gdbus monitor の GlobalEngineChanged 行から engine 名を抽出する。
# 出力例: /org/freedesktop/IBus: org.freedesktop.IBus.GlobalEngineChanged ('mozc-jp',)
# 行内の他の引用符付き値があっても、第 1 引数部分だけを取り出す。
extract_engine_from_line() {
	local line="$1"
	local engine
	engine="$(printf '%s' "$line" | sed -n "s/.*GlobalEngineChanged[^']*'\([^']*\)'.*/\1/p")"
	printf '%s' "$engine"
}
# IBus のプライベートバスアドレスを解決する。
# `ibus address` が使えないセッション (DISPLAY 未設定等) では
# ~/.cache/ibus/dbus-* ソケットから最新のものをフォールバックで拾う。
resolve_ibus_address() {
	local a sock
	a="$(ibus address 2>/dev/null || true)"
	case "$a" in
	unix:*)
		printf '%s' "$a"
		return 0
		;;
	esac

	sock="$(find "${XDG_CACHE_HOME:-$HOME/.cache}/ibus" -maxdepth 1 -name 'dbus-*' -type s -printf '%T@ %p\n' 2>/dev/null | sort -rn | head -n1 | cut -d' ' -f2- || true)"
	if [ -n "$sock" ]; then
		printf 'unix:path=%s' "$sock"
		return 0
	fi
	return 1
}

main() {
	log "starting (ON=$IME_ON_COLOR OFF=$IME_OFF_COLOR)"

	local addr line engine
	while true; do
		if ! addr="$(resolve_ibus_address)"; then
			log "ibus address not found; retrying in 3s"
			sleep 3
			continue
		fi

		# 起動直後に現在のエンジンを反映する。
		apply_engine "$(ibus engine 2>/dev/null || true)"

		log "monitoring GlobalEngineChanged via ${addr%%,*}"
		# gdbus monitor はブロッキング。ibus 再起動等で終了したら再接続する。
		while IFS= read -r line; do
			case "$line" in
			*GlobalEngineChanged*)
				# 例: /org/freedesktop/IBus: org.freedesktop.IBus.GlobalEngineChanged ('mozc-jp',)
				engine="$(extract_engine_from_line "$line")"
				apply_engine "$engine"
				;;
			esac
		done < <(gdbus monitor --address "$addr" --dest org.freedesktop.IBus --object-path /org/freedesktop/IBus 2>/dev/null)

		log "monitor ended; reconnecting in 2s"
		sleep 2
	done
}

main "$@"
