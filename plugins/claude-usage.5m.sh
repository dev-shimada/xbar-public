#!/bin/bash

# パス設定
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

# 今月の年月を取得
TARGET_MONTH=$(date "+%Y-%m")

# npx で JSON データを取得
RAW_DATA=$(/opt/homebrew/bin/npx --yes ccusage monthly -j 2>/dev/null)

if [ $? -eq 0 ] && [ -n "$RAW_DATA" ]; then
  # メッセージを排除し、最初の { 以降のみを抽出してパース
  COST=$(echo "$RAW_DATA" | sed -n '/{/,$p' | osascript -l JavaScript -e "
    function run(argv) {
      try {
        var data = JSON.parse(argv[0]);
        var current = data.monthly.find(m => m.month === '$TARGET_MONTH');
        return current ? '$' + current.totalCost.toFixed(2) : '$0.00';
      } catch (e) {
        return 'Parse Error';
      }
    }
  " -- "$RAW_DATA")

  # ステータスバー表示
  echo "Claude: $COST"

  # ドロップダウンメニュー
  echo "---"
  # メニュー用には通常の表形式を取得（ここでもnpxを叩くのは非効率なので、JSONが取れているならメニューもそこから出すのが理想ですが、まずは安定性重視で再取得します）
  /opt/homebrew/bin/npx --yes ccusage monthly --no-color 2>/dev/null | sed 's/$/ | font=Menlo size=11/'
else
  echo "Claude: ⚠️ Fetch Error"
fi

echo "---"
echo "Refresh | refresh=true"
