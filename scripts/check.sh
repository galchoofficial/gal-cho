#!/usr/bin/env bash
# =============================================================================
# scripts/check.sh - ギャル庁サイト全体の検証スクリプト
# =============================================================================
#
# 【何をするスクリプトか】
#   記事の投稿・加筆のあとに実行して、「誰が実行しても同じ基準」でサイト全体を
#   検証する。Hugo ビルドが通るか、生成 HTML が壊れていないか、front matter の
#   必須項目が揃っているか、内部リンクが切れていないか等をまとめてチェックする。
#
# 【使い方】
#   bash scripts/check.sh          # リポジトリ全体を検証（引数なし）
#
#   終了コード 0 … 問題なし（警告のみの場合も 0）
#   終了コード 1 … エラーあり（1件以上）
#
# 【チェック項目】
#    1. hugo --buildFuture のビルドが通るか（通らなければ即失敗）
#    2. 生成HTMLの記事ページに生の ** が残っていないか（太字バグ）
#    3. 生成HTMLに未展開のショートコードが残っていないか
#    4. 記事HTMLの JSON-LD がすべて JSON としてパースできるか
#    5. 内部リンク切れ（href="/posts/xxx/" のリンク先 .md が実在するか）
#    6. 未来日付の記事へのリンク（※警告のみ。シリーズ記事等で運用上ありうる）
#    7. front matter の必須項目の欠落
#       (title/date/publishDate/categories/lead/source/source_url/aashi/tweet)
#    8. date と publishDate の不一致
#    9. categories が tame/omo/emo/anime 以外
#   10. draft: true の取り残し
#   11. 本文に残った編集メモ（AFFI コメントや「記事123」という内部通し番号）
#       ※ aashi フィールド内のものは ★警告のみ（aashi はユーザーの手書きパートで
#         エージェントは1文字も変更できない＝直せないものでエラーを出し続けないため）
#       ※ aashi 内の生の ** は検出対象外。partials/aashi-block.html が markdownify
#         の前に対になった **…** を <strong> に置換するので正しく描画される
#   12. who="kouhai" の使用（後輩キャラは廃止済み）
#   13. git 作業ツリーで aashi 行に差分が無いか（※警告のみ。aashi はユーザーの
#       人間味パートなのでエージェントが勝手に書き換えてはいけない）
#
# 【環境】
#   Windows の Git Bash 前提。hugo と python が PATH に必要。
#   一時ビルド先は $TEMP/galcho-check-build（実行ごとにクリアして使い回す）
# =============================================================================

set -uo pipefail
export PYTHONIOENCODING=utf-8
export PYTHONUTF8=1

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SITE_DIR="$REPO_ROOT/site"
POSTS_DIR="$SITE_DIR/content/posts"

if [ ! -d "$SITE_DIR" ]; then
  echo "❌ site ディレクトリが見つからない: $SITE_DIR" >&2
  exit 1
fi

# 一時ビルド先（$TEMP 配下を使い回す）
TMP_BASE="${TEMP:-${TMPDIR:-/tmp}}"
TMP_BASE="$(printf '%s' "$TMP_BASE" | tr '\\' '/')"
BUILD_DIR="$TMP_BASE/galcho-check-build"
rm -rf "$BUILD_DIR" 2>/dev/null
mkdir -p "$BUILD_DIR"

echo "=============================================="
echo " ギャル庁 サイト検証 (scripts/check.sh)"
echo "=============================================="
echo "リポジトリ : $REPO_ROOT"
echo "ビルド先   : $BUILD_DIR"
echo ""

# ---------------------------------------------------------------------------
# 1. Hugo ビルド
# ---------------------------------------------------------------------------
echo "[1/13] Hugo ビルド (--buildFuture) ..."
BUILD_LOG="$TMP_BASE/galcho-check-hugo.log"
if ! ( cd "$SITE_DIR" && hugo --buildFuture --quiet --destination "$BUILD_DIR" ) >"$BUILD_LOG" 2>&1; then
  echo ""
  echo "❌ Hugo ビルドが失敗した。以下のログを確認して直して。"
  echo "----------------------------------------------"
  cat "$BUILD_LOG"
  echo "----------------------------------------------"
  exit 1
fi
if [ -s "$BUILD_LOG" ]; then
  echo "  （ビルド時の出力）"
  sed 's/^/    /' "$BUILD_LOG"
fi
echo "  ✅ ビルド成功"
echo ""

# ---------------------------------------------------------------------------
# 2〜13. 内容チェック（python でまとめて実施）
# ---------------------------------------------------------------------------
POSTS_DIR="$POSTS_DIR" BUILD_DIR="$BUILD_DIR" REPO_ROOT="$REPO_ROOT" python - <<'PYEOF'
# -*- coding: utf-8 -*-
import datetime
import io
import json
import os
import re
import subprocess
import sys

try:
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except Exception:
    pass

POSTS_DIR = os.environ["POSTS_DIR"]
BUILD_DIR = os.environ["BUILD_DIR"]
REPO_ROOT = os.environ["REPO_ROOT"]

try:
    import yaml
except ImportError:
    yaml = None

JST = datetime.timezone(datetime.timedelta(hours=9))
VALID_CATEGORIES = {"tame", "omo", "emo", "anime"}
REQUIRED_FIELDS = ["title", "date", "publishDate", "categories",
                   "lead", "source", "source_url", "aashi", "tweet"]
MAX_SHOW = 15  # 詳細表示の上限件数

errors = []    # [(項目名, [詳細...])]
warnings = []  # [(項目名, [詳細...])]


def add(bucket, name, details):
    if details:
        bucket.append((name, details))


# ---------------------------------------------------------------------------
# 記事 .md を読み込んで front matter をパース
# ---------------------------------------------------------------------------
def split_front_matter(text):
    if not text.startswith("---"):
        return None, text
    m = re.match(r"^---\r?\n(.*?)\r?\n---\r?\n?(.*)$", text, re.S)
    if not m:
        return None, text
    return m.group(1), m.group(2)


def to_dt(value):
    """front matter の日付値を tz 付き datetime にする"""
    if isinstance(value, datetime.datetime):
        return value if value.tzinfo else value.replace(tzinfo=JST)
    if isinstance(value, datetime.date):
        return datetime.datetime(value.year, value.month, value.day, tzinfo=JST)
    if isinstance(value, str):
        try:
            dt = datetime.datetime.fromisoformat(value.strip().replace("Z", "+00:00"))
            return dt if dt.tzinfo else dt.replace(tzinfo=JST)
        except Exception:
            return None
    return None


posts = {}
md_files = sorted(f for f in os.listdir(POSTS_DIR)
                  if f.endswith(".md") and f != "_index.md")
fm_parse_errors = []

for fn in md_files:
    path = os.path.join(POSTS_DIR, fn)
    with io.open(path, encoding="utf-8", errors="replace") as fh:
        raw = fh.read()
    fm_str, body = split_front_matter(raw)
    fm = {}
    if fm_str is None:
        fm_parse_errors.append("%s : front matter (--- 区切り) が見つからない" % fn)
    elif yaml is None:
        fm_parse_errors.append("%s : pyyaml が入っていないので front matter を検証できない" % fn)
    else:
        try:
            loaded = yaml.safe_load(fm_str)
            if isinstance(loaded, dict):
                fm = loaded
            else:
                fm_parse_errors.append("%s : front matter が辞書にならない" % fn)
        except Exception as exc:
            fm_parse_errors.append("%s : YAML パース失敗 (%s)" % (fn, exc))
    posts[fn[:-3]] = {"file": fn, "path": path, "fm": fm, "body": body, "raw": raw}

add(errors, "front matter のパース", fm_parse_errors)

# ---------------------------------------------------------------------------
# 生成 HTML の収集
# ---------------------------------------------------------------------------
post_html = []   # 記事ページ: (表示名, フルパス)
posts_out = os.path.join(BUILD_DIR, "posts")
if os.path.isdir(posts_out):
    for slug in sorted(os.listdir(posts_out)):
        f = os.path.join(posts_out, slug, "index.html")
        if os.path.isfile(f):
            post_html.append(("posts/%s/index.html" % slug, f))

all_html = []    # サイト全体の HTML
for dirpath, _dirnames, filenames in os.walk(BUILD_DIR):
    for fn in filenames:
        if fn.endswith(".html"):
            full = os.path.join(dirpath, fn)
            all_html.append((os.path.relpath(full, BUILD_DIR).replace("\\", "/"), full))
all_html.sort()

_html_cache = {}


def read_html(path):
    if path not in _html_cache:
        with io.open(path, encoding="utf-8", errors="replace") as fh:
            _html_cache[path] = fh.read()
    return _html_cache[path]


def strip_script_style(text):
    text = re.sub(r"<script\b.*?</script>", "", text, flags=re.S | re.I)
    return re.sub(r"<style\b.*?</style>", "", text, flags=re.S | re.I)


# ---------------------------------------------------------------------------
# 2. 生の ** が記事HTMLに残っていないか
# ---------------------------------------------------------------------------
print("[2/13] 生成HTMLの生の ** をチェック ...")
bad = []
for rel, full in post_html:
    txt = read_html(full)
    m = re.search(r"<article\b.*?</article>", txt, re.S | re.I)
    target = strip_script_style(m.group(0) if m else txt)
    if "**" in target:
        bad.append("%s （%d箇所）" % (rel, target.count("**")))
add(errors, "生の ** が残っている記事", bad)

# ---------------------------------------------------------------------------
# 3. 未展開ショートコード
# ---------------------------------------------------------------------------
print("[3/13] 未展開ショートコードをチェック ...")
SHORTCODE_OPEN = "{{" + "<"
SHORTCODE_PCT = "{{" + "%"
bad = []
for rel, full in all_html:
    txt = read_html(full)
    if SHORTCODE_OPEN in txt or SHORTCODE_PCT in txt:
        bad.append(rel)
add(errors, "未展開ショートコードが残っているHTML", bad)

# ---------------------------------------------------------------------------
# 4. JSON-LD がパースできるか
# ---------------------------------------------------------------------------
print("[4/13] 記事HTMLの JSON-LD をチェック ...")
LD_RE = re.compile(
    r"<script[^>]*type=[\"']application/ld\+json[\"'][^>]*>(.*?)</script>",
    re.S | re.I)
bad = []
for rel, full in post_html:
    blocks = LD_RE.findall(read_html(full))
    if not blocks:
        bad.append("%s : JSON-LD ブロックが無い" % rel)
        continue
    for i, block in enumerate(blocks, 1):
        try:
            json.loads(block)
        except Exception as exc:
            bad.append("%s : JSON-LD #%d パース失敗 (%s)" % (rel, i, exc))
add(errors, "JSON-LD が壊れている記事", bad)

# ---------------------------------------------------------------------------
# 5. 内部リンク切れ / 6. 未来日付の記事へのリンク
# ---------------------------------------------------------------------------
print("[5/13] 内部リンク切れをチェック ...")
LINK_RE = re.compile(r"href=\"/posts/([^\"/#?]+)/?[^\"]*\"")
broken = []
future_links = []

for slug in sorted(posts):
    p = posts[slug]
    src_dt = to_dt(p["fm"].get("publishDate") or p["fm"].get("date"))
    seen = set()
    for target in LINK_RE.findall(p["raw"]):
        if target in seen:
            continue
        seen.add(target)
        if target not in posts:
            broken.append("%s → /posts/%s/ （リンク先の .md が無い）" % (p["file"], target))
            continue
        dst_dt = to_dt(posts[target]["fm"].get("publishDate")
                       or posts[target]["fm"].get("date"))
        if src_dt and dst_dt and dst_dt > src_dt:
            future_links.append(
                "%s → /posts/%s/ （リンク先 %s が自分 %s より後）"
                % (p["file"], target,
                   dst_dt.strftime("%Y-%m-%d %H:%M"),
                   src_dt.strftime("%Y-%m-%d %H:%M")))

add(errors, "内部リンク切れ", broken)
print("[6/13] 未来日付の記事へのリンクをチェック ...")
add(warnings, "未来日付の記事へのリンク（警告のみ）", future_links)

# ---------------------------------------------------------------------------
# 7〜10. front matter 系
# ---------------------------------------------------------------------------
print("[7/13] front matter の必須項目をチェック ...")
missing, mismatch, bad_cat, drafts = [], [], [], []

for slug in sorted(posts):
    p = posts[slug]
    fm = p["fm"]
    if not fm:
        continue

    lack = [f for f in REQUIRED_FIELDS
            if f not in fm or fm.get(f) in (None, "", [], {})]
    if lack:
        missing.append("%s : %s" % (p["file"], " / ".join(lack)))

    raw_d, raw_pd = fm.get("date"), fm.get("publishDate")
    if raw_d is not None and raw_pd is not None:
        a, b = to_dt(raw_d), to_dt(raw_pd)
        if a and b and a != b:
            mismatch.append("%s : date=%s / publishDate=%s"
                            % (p["file"],
                               a.strftime("%Y-%m-%dT%H:%M%z"),
                               b.strftime("%Y-%m-%dT%H:%M%z")))

    cats = fm.get("categories")
    if isinstance(cats, str):
        cats = [cats]
    if isinstance(cats, list):
        ng = [str(c) for c in cats if str(c) not in VALID_CATEGORIES]
        if ng:
            bad_cat.append("%s : %s" % (p["file"], ", ".join(ng)))

    if fm.get("draft") is True:
        drafts.append(p["file"])

add(errors, "front matter の必須項目が欠落", missing)
print("[8/13] date と publishDate の不一致をチェック ...")
add(errors, "date と publishDate の不一致", mismatch)
print("[9/13] categories の値をチェック ...")
add(errors, "categories が tame/omo/emo/anime 以外", bad_cat)
print("[10/13] draft: true の取り残しをチェック ...")
add(errors, "draft: true が残っている記事", drafts)

# ---------------------------------------------------------------------------
# 11. 編集メモの残り
# ---------------------------------------------------------------------------
print("[11/13] 編集メモ（AFFIコメント・内部通し番号）をチェック ...")
AFFI_MARK = "<!--" + " AFFI:"
SERIAL_RE = re.compile(r"記事[0-9]+")


def aashi_line_range(raw):
    """front matter の aashi フィールドが占める行番号（1始まり）の集合を返す。

    aashi はユーザーの手書きパートでエージェントは1文字も変更できないため、
    ここにある内部通し番号は「絶対に直せないもの」＝エラーではなく警告にする。
    """
    lines = raw.splitlines()
    if not lines or lines[0].strip() != "---":
        return set()
    rng = set()
    in_aashi = False
    for i, line in enumerate(lines[1:], start=2):
        if line.strip() == "---":             # front matter の終わり
            break
        if re.match(r"^aashi\s*:", line):     # aashi の開始行
            in_aashi = True
            rng.add(i)
            continue
        if in_aashi:
            # インデント行・空行は aashi の続き。インデント無しの行＝次のキー
            if line.strip() == "" or line[:1] in (" ", "\t"):
                rng.add(i)
            else:
                in_aashi = False
    return rng


def fmt_hits(fname, items):
    shown = " / ".join(items[:4])
    if len(items) > 4:
        shown += " / ...他%d件" % (len(items) - 4)
    return "%s : %s" % (fname, shown)


memo = []        # エラー（本文側＝直せる）
memo_aashi = []  # 警告（aashi 内＝修正不可）
for slug in sorted(posts):
    p = posts[slug]
    aashi_lines = aashi_line_range(p["raw"])
    hits, hits_aashi = [], []
    for ln, line in enumerate(p["raw"].splitlines(), 1):
        bucket = hits_aashi if ln in aashi_lines else hits
        if AFFI_MARK in line:
            bucket.append("L%d: AFFIコメント" % ln)
        for m in SERIAL_RE.finditer(line):
            bucket.append("L%d: %s" % (ln, m.group(0)))
    if hits:
        memo.append(fmt_hits(p["file"], hits))
    if hits_aashi:
        memo_aashi.append(fmt_hits(p["file"], hits_aashi))

add(errors, "編集メモ・内部通し番号が本文に残っている記事", memo)
add(warnings,
    "aashi 内に内部通し番号がある（★aashi はユーザーの手書きなので修正不可・参考情報）",
    memo_aashi)

# ---------------------------------------------------------------------------
# 12. who="kouhai"
# ---------------------------------------------------------------------------
print("[12/13] who=\"kouhai\" の使用をチェック ...")
KOUHAI_RE = re.compile(r"who\s*=\s*\"kouhai\"")
kouhai = []
for slug in sorted(posts):
    p = posts[slug]
    n = len(KOUHAI_RE.findall(p["raw"]))
    if n:
        kouhai.append("%s （%d箇所）" % (p["file"], n))
add(errors, "who=\"kouhai\" が使われている記事（後輩キャラは廃止済み）", kouhai)

# ---------------------------------------------------------------------------
# 13. git diff の aashi 行
# ---------------------------------------------------------------------------
print("[13/13] git 作業ツリーの aashi 行の差分をチェック ...")
aashi_diff = []
try:
    proc = subprocess.run(
        ["git", "-C", REPO_ROOT, "diff", "HEAD", "--unified=0",
         "--", "site/content/posts"],
        capture_output=True, timeout=120)
    if proc.returncode == 0:
        out = proc.stdout.decode("utf-8", "replace")
        cur = "(unknown)"
        for line in out.splitlines():
            if line.startswith("+++ b/"):
                cur = line[6:]
                continue
            if line.startswith("+++") or line.startswith("---"):
                continue
            if line[:1] in "+-":
                content = line[1:].strip()
                if content.startswith("aashi:") or content.startswith("あーし的には"):
                    aashi_diff.append("%s : %s%s"
                                      % (os.path.basename(cur), line[0], content[:60]))
    else:
        aashi_diff.append("git diff が失敗: %s"
                          % proc.stderr.decode("utf-8", "replace").strip()[:120])
except Exception as exc:
    aashi_diff.append("git diff の実行に失敗: %s" % exc)
add(warnings,
    "aashi 行に差分がある（★ユーザーの人間味パート・勝手に書き換えない）",
    aashi_diff)

# ---------------------------------------------------------------------------
# 結果表示
# ---------------------------------------------------------------------------
print("")
print("==============================================")
print(" 検証結果")
print("==============================================")
print("記事ファイル : %d 本" % len(posts))
print("生成HTML     : %d ファイル（うち記事ページ %d 本）"
      % (len(all_html), len(post_html)))
print("")

err_count = sum(len(d) for _, d in errors)
warn_count = sum(len(d) for _, d in warnings)


def dump(bucket, mark):
    for name, details in bucket:
        print("  %s %s : %d件" % (mark, name, len(details)))
        for d in details[:MAX_SHOW]:
            print("       - %s" % d)
        if len(details) > MAX_SHOW:
            print("       - ... 他 %d件" % (len(details) - MAX_SHOW))


if errors:
    print("--- ❌ エラー ---")
    dump(errors, "❌")
    print("")

if warnings:
    print("--- ⚠️ 警告（エラーではない） ---")
    dump(warnings, "⚠️")
    print("")

print("==============================================")
if err_count == 0:
    if warn_count:
        print("✅ 問題なし（警告 %d件 あり）" % warn_count)
    else:
        print("✅ 問題なし")
    print("==============================================")
    sys.exit(0)

print("❌ %d件の問題（警告 %d件）" % (err_count, warn_count))
print("==============================================")
sys.exit(1)
PYEOF

RC=$?
exit $RC
