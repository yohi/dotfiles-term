#!/usr/bin/python3
import sys
import os
import curses

# PATH環境変数にLinuxbrewを追加してtmuxコマンドが使えるようにする
linuxbrew_path = "/home/linuxbrew/.linuxbrew/bin"
if os.path.exists(linuxbrew_path):
    os.environ["PATH"] = linuxbrew_path + os.pathsep + os.environ.get("PATH", "")

def main(stdscr):
    # マウストラッキングを有効にする
    curses.mousemask(curses.ALL_MOUSE_EVENTS | curses.REPORT_MOUSE_POSITION)
    # マウス移動イベント(MouseMove)をターミナルから送信させるためのANSIエスケープシーケンス
    try:
        sys.stdout.write('\033[?1003h')
        sys.stdout.flush()
    except Exception:
        pass

    target_pane = sys.argv[1] if len(sys.argv) > 1 else ""
    current_path = sys.argv[2] if len(sys.argv) > 2 else ""

    menu_items = [
        " 1. Kill Pane (Close)  ",
        " 2. Horizontal Split   ",
        " 3. Vertical Split     ",
        " 4. Zoom / Unzoom      ",
        " 5. Cancel             "
    ]
    current_row = 0

    while True:
        stdscr.clear()
        
        # メニュー描画 (上下に1行ずつの余白を持たせて配置)
        for idx, item in enumerate(menu_items):
            if idx == current_row:
                stdscr.attron(curses.A_REVERSE)
                stdscr.addstr(idx + 1, 2, item)
                stdscr.attroff(curses.A_REVERSE)
            else:
                stdscr.addstr(idx + 1, 2, item)

        stdscr.refresh()

        key = stdscr.getch()

        if key == curses.KEY_MOUSE:
            try:
                _, mx, my, _, bstate = curses.getmouse()
                # メニューのY座標範囲内（行1から5）か判定
                menu_y = my - 1
                if 0 <= menu_y < len(menu_items):
                    current_row = menu_y
                
                # 左クリック（BUTTON1_PRESSED や BUTTON1_CLICKED や BUTTON1_RELEASED）された場合、選択を実行
                if bstate & (curses.BUTTON1_CLICKED | curses.BUTTON1_PRESSED | curses.BUTTON1_RELEASED):
                    break
            except curses.error:
                pass
        elif key == curses.KEY_UP:
            current_row = (current_row - 1) % len(menu_items)
        elif key == curses.KEY_DOWN:
            current_row = (current_row + 1) % len(menu_items)
        elif key in (10, 13): # Enter
            break
        elif key == 27: # Esc
            current_row = 4 # Cancel
            break

    # マウストラッキングを無効化する
    try:
        sys.stdout.write('\033[?1003l')
        sys.stdout.flush()
    except Exception:
        pass

    # アクションの実行
    if current_row == 0:
        os.system(f"tmux kill-pane -t {target_pane}")
    elif current_row == 1:
        os.system(f"tmux split-window -h -t {target_pane} -c {current_path}")
    elif current_row == 2:
        os.system(f"tmux split-window -v -t {target_pane} -c {current_path}")
    elif current_row == 3:
        os.system(f"tmux resize-pane -t {target_pane} -Z")

def run_curses(stdscr):
    try:
        curses.curs_set(0)
    except Exception:
        pass
    main(stdscr)

if __name__ == "__main__":
    try:
        curses.wrapper(run_curses)
    except Exception as e:
        try:
            sys.stdout.write('\033[?1003l')
            sys.stdout.flush()
        except Exception:
            pass
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)
