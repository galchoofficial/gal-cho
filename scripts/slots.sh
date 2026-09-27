#!/usr/bin/env bash
# =============================================================================
# scripts/slots.sh - 公開枠（朝7:00 / 昼11:00 / 夕17:00 JST）の空き確認
# =============================================================================
#
# 【何をするスクリプトか】
#   content/posts/*.md の publishDate を集計して、今日以降の定時公開枠
#   （朝 07:00 / 昼 11:00 / 夕 17:00 JST）が埋まっているかを一覧表示する。
#   毎回手で grep して数え間違える事故を防ぐのが目的。
#   最後に「次に空いている枠」を3つ、コピペできる形で出す。
#
# 【使い方】
#   bash scripts/slots.sh            # 今日から14日分の枠を表示（既定）
#   bash scripts/slots.sh 7          # 今日から7日分だけ表示
#
# 【出力】
#   - 現在の JST（Windows のローカル時計から取得。Bash の date は UTC なので使わない）
#   - 今日以降の各日の 07:00 / 11:00 / 17:00 の埋まり状況（埋まっていれば title）
#   - 定時枠以外の時刻で公開されている記事（即時公開したもの）を「即時」として別枠表示
#   - 次に空いている枠3つ（例: 2026-09-30T07:00:00+09:00）
#
# 【環境】
#   Windows の Git Bash 前提。python が PATH に必要。
#   JST は powershell の Get-Date（ローカル時計）から取得し、取れなければ
#   UTC+9 計算にフォールバックする。
# =============================================================================

set -uo pipefail
export PYTHONIOENCODING=utf-8
export PYTHONUTF8=1

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
POSTS_DIR="$REPO_ROOT/site/content/posts"

if [ ! -d "$POSTS_DIR" ]; then
  echo "❌ 記事ディレクトリが見つからない: $POSTS_DIR" >&2
  exit 1
fi

DAYS="${1:-14}"

# --- 現在の JST を Windows のローカル時計から取得（Bash の date は UTC）-------
NOW_JST="$(powershell.exe -NoProfile -Command \
  "(Get-Date).ToString('yyyy-MM-ddTHH:mm:ss')" 2>/dev/null | tr -d '\r')"

POSTS_DIR="$POSTS_DIR" NOW_JST="${NOW_JST:-}" DAYS="$DAYS" python - <<'PYEOF'
# -*- coding: utf-8 -*-
import datetime
import io
import os
import re
import sys

try:
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except Exception:
    pass

POSTS_DIR = os.environ["POSTS_DIR"]
NOW_RAW = os.environ.get("NOW_JST", "").strip()
try:
    DAYS = max(1, int(os.environ.get("DAYS", "14")))
except ValueError:
    DAYS = 14

JST = datetime.timezone(datetime.timedelta(hours=9))
SLOT_HOURS = [7, 11, 17]
SLOT_LABEL = {7: "朝 07:00", 11: "昼 11:00", 17: "夕 17:00"}
TITLE_LEN = 30

# --- 現在 JST -------------------------------------------------------------
now = None
if NOW_RAW:
    try:
        now = datetime.datetime.fromisoformat(NOW_RAW).replace(tzinfo=JST)
    except Exception:
        now = None
if now is None:
    # powershell が使えない場合のフォールバック（UTC+9 で計算）
    now = datetime.datetime.now(datetime.timezone.utc).astimezone(JST)

print("==============================================")
print(" ギャル庁 公開枠チェック (scripts/slots.sh)")
print("==============================================")
print("現在 JST : %s (%s)"
      % (now.strftime("%Y-%m-%d %H:%M:%S"),
         "日月火水木金土"[(now.weekday() + 1) % 7]))
print("記事DIR  : %s" % POSTS_DIR)
print("")

# --- front matter から publishDate と title を拾う --------------------------
FM_SPLIT = re.compile(r"^---\r?\n(.*?)\r?\n---", re.S)
PUB_RE = re.compile(r"^publishDate:\s*(.+?)\s*$", re.M)
TITLE_RE = re.compile(r"^title:\s*(.+?)\s*$", re.M)
DRAFT_RE = re.compile(r"^draft:\s*true\s*$", re.M)


def parse_dt(text):
    text = text.strip().strip('"').strip("'")
    try:
        dt = datetime.datetime.fromisoformat(text.replace("Z", "+00:00"))
    except Exception:
        return None
    if dt.tzinfo is None:
        dt = dt.replace(tzinfo=JST)
    return dt.astimezone(JST)


def clip(s, n=TITLE_LEN):
    s = s.strip().strip('"').strip("'")
    return s if len(s) <= n else s[:n] + "…"


entries = []   # (datetime, title, filename, is_draft)
no_pub = []
for fn in sorted(os.listdir(POSTS_DIR)):
    if not fn.endswith(".md") or fn == "_index.md":
        continue
    with io.open(os.path.join(POSTS_DIR, fn), encoding="utf-8", errors="replace") as fh:
        raw = fh.read()
    m = FM_SPLIT.match(raw)
    fm = m.group(1) if m else raw[:4000]
    pm = PUB_RE.search(fm)
    if not pm:
        no_pub.append(fn)
        continue
    dt = parse_dt(pm.group(1))
    if dt is None:
        no_pub.append("%s （publishDate が読めない: %s）" % (fn, pm.group(1).strip()))
        continue
    tm = TITLE_RE.search(fm)
    entries.append((dt, clip(tm.group(1)) if tm else "(title なし)", fn,
                    bool(DRAFT_RE.search(fm))))

entries.sort(key=lambda e: e[0])

# --- 定時枠マップ ----------------------------------------------------------
taken = {}     # (date, hour) -> [(title, fn, draft)]
offslot = []   # 定時枠以外（即時公開）
for dt, title, fn, draft in entries:
    if dt.hour in SLOT_HOURS and dt.minute == 0:
        taken.setdefault((dt.date(), dt.hour), []).append((title, fn, draft))
    else:
        offslot.append((dt, title, fn, draft))

# --- 今日以降の枠を表示 ----------------------------------------------------
today = now.date()
print("---- 定時枠の埋まり状況（今日から %d日分）----" % DAYS)
free_slots = []
for i in range(DAYS):
    day = today + datetime.timedelta(days=i)
    wd = "日月火水木金土"[(day.weekday() + 1) % 7]
    tag = " ← 今日" if i == 0 else ""
    print("")
    print("■ %s (%s)%s" % (day.isoformat(), wd, tag))
    for hour in SLOT_HOURS:
        slot_dt = datetime.datetime(day.year, day.month, day.day, hour, tzinfo=JST)
        items = taken.get((day, hour), [])
        if items:
            for idx, (title, _fn, draft) in enumerate(items):
                extra = " ⚠️draft:true" if draft else ""
                if idx == 0:
                    print("  [埋] %s  %s%s" % (SLOT_LABEL[hour], title, extra))
                else:
                    print("      +         %s%s" % (title, extra))
            if len(items) > 1:
                print("      ⚠️ この枠に %d本 入っている（重複）" % len(items))
        else:
            past = slot_dt <= now
            print("  [%s] %s  %s"
                  % ("済" if past else "空", SLOT_LABEL[hour],
                     "（時刻が過ぎている）" if past else "空き"))
            if not past:
                free_slots.append(slot_dt)

# --- 次に空いている枠3つ ---------------------------------------------------
print("")
print("---- 次に空いている枠 3つ（コピペ用）----")
if free_slots:
    for slot_dt in free_slots[:3]:
        wd = "日月火水木金土"[(slot_dt.weekday() + 1) % 7]
        print("  %s   # %s(%s) %s"
              % (slot_dt.strftime("%Y-%m-%dT%H:%M:%S+09:00"),
                 slot_dt.strftime("%m/%d"), wd, SLOT_LABEL[slot_dt.hour]))
else:
    print("  （表示範囲 %d日以内に空き枠なし。日数を増やして再実行: bash scripts/slots.sh 30）"
          % DAYS)

# --- 即時公開（定時枠以外）-------------------------------------------------
print("")
print("---- 即時（定時枠以外の時刻で公開した記事）----")
if offslot:
    print("  合計 %d本。直近10本：" % len(offslot))
    for dt, title, fn, draft in offslot[-10:]:
        extra = " ⚠️draft:true" if draft else ""
        print("  %s  %s%s" % (dt.strftime("%Y-%m-%d %H:%M"), title, extra))
else:
    print("  なし")

# --- publishDate が無い記事 ------------------------------------------------
if no_pub:
    print("")
    print("---- ⚠️ publishDate が無い/読めない記事 %d本 ----" % len(no_pub))
    for fn in no_pub[:10]:
        print("  %s" % fn)
    if len(no_pub) > 10:
        print("  ... 他 %d本" % (len(no_pub) - 10))

print("")
print("==============================================")
print("記事総数 %d本 / 定時枠 %d枠 / 即時 %d本"
      % (len(entries), sum(len(v) for v in taken.values()), len(offslot)))
print("==============================================")
PYEOF
