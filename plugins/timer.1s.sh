#!/bin/bash

# タイマーファイルを格納するディレクトリ
TIMER_DIR="/tmp/xbar_timers"
mkdir -p "$TIMER_DIR"

# --- タイマー開始処理 (例: ./script.sh Name 30) ---
if [ "$#" -eq 2 ]; then
  NAME=$1
  SECONDS=$2
  # 秒数を現在の時刻に加算して保存
  # macOSのdateコマンドを使用: -v+30S
  date -v+"${SECONDS}"S +%s >"$TIMER_DIR/$NAME"
  exit 0
fi

# --- 表示処理 ---
TIMERS=$(ls "$TIMER_DIR" 2>/dev/null)

if [ -z "$TIMERS" ]; then
  echo "⏱️"
  exit 0
fi

NOW=$(date +%s)
TOTAL_DISPLAY=""

for NAME in $TIMERS; do
  [ -f "$TIMER_DIR/$NAME" ] || continue
  END_TIME=$(cat "$TIMER_DIR/$NAME")
  LEFT=$((END_TIME - NOW))

  if [ $LEFT -gt 0 ]; then
    # 表示文字列を構築 (⏳ Name 00:30)
    # 60秒以上の表示にも対応
    TIME_STR=$(printf "%s %02d:%02d" "$NAME" $((LEFT / 60)) $((LEFT % 60)))
    TOTAL_DISPLAY="$TOTAL_DISPLAY ⏳ $TIME_STR"
  else
    # 時間切れ処理
    osascript -e "display notification \"$NAME finished!\" with title \"xbar Timer\""
    rm "$TIMER_DIR/$NAME"
  fi
done

# 表示が空（すべて終了した直後など）ならデフォルトアイコン
echo "${TOTAL_DISPLAY:-⏱️}"
echo "---"

# 各タイマーを個別に停止するメニュー
for NAME in $TIMERS; do
  echo "Stop $NAME | terminal=false bash=rm param1=$TIMER_DIR/$NAME"
done

if [ ! -z "$TIMERS" ]; then
  echo "Stop All | terminal=false bash=rm param1=-rf param2=$TIMER_DIR"
fi
