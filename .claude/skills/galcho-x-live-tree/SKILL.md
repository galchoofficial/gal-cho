---
name: galcho-x-live-tree
description: ギャル庁の記事をX(@galcho_official)でライブツリー投稿するときの手順とハマりポイント集。本文+URLリプの2段構成で2026年Xアルゴリズム(本文リンク格下げ)を回避する。記事プロモ・予約UI不調時の回避策・アカウント誤爆防止チェック含む
---

# ギャル庁 X ライブツリー投稿スキル

ギャル庁の記事を X（@galcho_official）でプロモする時に呼ぶ。

## 🚨 絶対遵守（事故防止）

### アカウント確認（毎回必ず）
- 投稿アカウント: **@galcho_official のみ**
- ログインに使うGoogleアカウント: **Galcho.official@gmail.com のみ**
- ❌ ちゅぱれーと・聖徳太子のアカウントは絶対触らない
- ブラウザ操作前に**画面右上のアカウントアイコン**で確認

### Gmail/Google ドキュメントは触らない
- mail.google.com / docs.google.com にナビゲートしない
- パスワード入力代行はしない（Google パスワード必要なら user に依頼）
- アカウント切替メニューを触る前に user 確認

## 📋 ライブツリー投稿の手順

### 前提
- **公開済み記事のみプロモする**（Workers Cron 7/11/17 で公開後 → Cloudflare Pages リビルド1〜2分待つ）
- 未公開記事をプロモするとリプの URL が 404 になる
- セッション時点で既に公開済みの記事を**1パスでまとめて投稿**する（キャッチアップ方式）

### 手順
1. https://x.com/home を開く
2. **アカウント名 @galcho_official を画面で確認**
3. 投稿ボックスをクリック
4. 本文を入力（**記事URLは絶対入れない**）
   - 本文末尾に「詳しくはリプから👇」など誘導文
   - ハッシュタグは **1〜2個まで**（基本 `#ギャル庁` ＋ジャンル1個）
   - 140字以内
5. 「ポストする」でライブ投稿
6. 投稿後、そのツイートをクリックして詳細を開く
7. 「返信をポスト」をクリックして、`https://gal-cho.com/posts/{slug}/` を入力
8. 「返信」でリプ投稿
9. 完了 → プロフィール件数 +2 で確認

### 複数記事をまとめる時
- 1記事ずつ「本文 → リプURL」を完了させてから次へ
- 全部終わったらプロフィール一覧で件数を最終確認

### 🌳 ライブツリー実装コード（2026-06-06実証・コピペで動く）

過去セッションで「インライン投稿ボックスは type 空振り」「リプ確定ボタンの testid が見つからない」などハマったので、**実証済みパターン**を記録。

#### 前提準備
```js
// 1. X.com に navigate（既にログイン済み前提）
// navigate('https://x.com/home')

// 2. アカウント確認（毎回必須）
const acct = document.querySelector('[data-testid="AppTabBar_Profile_Link"]')?.getAttribute('href');
// → '/galcho_official' であることを確認
```

#### ステップ1: 本文ツイート投稿（モーダル経由が確実）

**重要**: インライン投稿ボックス `(505, 90)` は type が空振りしやすい。**左サイドバー ✏️ アイコン `(118, 638)` クリックでモーダル展開**するのが確実。

```js
// 1. ✏️アイコンクリックでモーダル展開（座標は実測値）
// computer.left_click(118, 638)
// wait 3s

// 2. モーダル内テキストエリアをクリック (420, 130)
// computer.left_click(420, 130)
// wait 1s

// 3. 本文を type（直接日本語で、unicode escape は使わない）
// computer.type("学校終わり〜🎒\n\n金曜の夕方ってなんかテンション上がるよね✨\n...\n#ギャル庁")
// wait 2s

// 4. 「ポストする」ボタンクリック
const btn = [...document.querySelectorAll('button')]
  .find(b => b.innerText.trim() === 'ポストする' 
         && b.offsetParent !== null 
         && b.getAttribute('aria-disabled') !== 'true');
btn?.click();
// → 'posted' を返したら成功
```

**投稿成功の確認**: screenshot で下部「ポストを送信しました。 表示」トーストが出ているか確認。または プロフィールで最新ツイートが「現在」表示されているか確認。

#### ステップ2: リプにURLを貼る

```js
// 1. 自分のプロフィールに navigate して最新ツイートの status URL を取得
// navigate('https://x.com/galcho_official')
// wait 3s

// 2. JS で最新ツイートのstatus URL取得
const a = document.querySelector('article[data-testid="tweet"]');
const link = a?.querySelector('time')?.closest('a')?.getAttribute('href');
// → '/galcho_official/status/2063111802834350137' のような URL

// 3. その status URL に navigate
// navigate('https://x.com' + link)
// wait 4s

// 4. 返信エリアをクリック (467, 470)
// computer.left_click(467, 470)
// wait 1s

// 5. URL を type
// computer.type('https://gal-cho.com/posts/{slug}/')
// wait 2s

// 6. ★リプ確定ボタンは `tweetButtonInline` testid（重要）
const replyBtn = document.querySelector('[data-testid="tweetButtonInline"]');
replyBtn?.click();
// → 'reply-posted' を返したら成功
```

**重要**: リプ確定ボタンは `[data-testid="tweetButton"]` ではなく **`[data-testid="tweetButtonInline"]`**。本文投稿の検索（`innerText === 'ポストする'`）とは別。

#### ステップ3: プレミアム勧誘ダイアログを閉じる

リプ投稿成功後、X が「返信を多くのユーザーに見てもらいましょう」というプレミアム勧誘モーダルを出すことがある。

```js
// 「後で試す」ボタンクリック (560, 745) で閉じる
// computer.left_click(560, 745)
// wait 2s
```

#### 投稿の最終確認

```js
// プロフィールページで最新3件確認
const tweets = [...document.querySelectorAll('article[data-testid="tweet"]')].slice(0, 3);
tweets.map(t => ({
  text: t.querySelector('[data-testid="tweetText"]')?.innerText?.slice(0, 60),
  time: t.querySelector('time')?.getAttribute('datetime')
}));
```

### 🚨 ライブツリーで遭遇したハマり集

| 問題 | 原因 | 解決 |
|---|---|---|
| インライン投稿ボックスで type が空振り | textarea が focus取れていない | ✏️アイコンでモーダル展開する |
| `aria-disabled: "true"` でボタン押せない | 本文が空（type 失敗） | モーダル展開してから type |
| `tweetButton` testid が見つからない | リプ確定ボタンは別 testid | `tweetButtonInline` を使う |
| 「返信」ボタンの座標 `(640, 558)` が外れる | UI 微妙にズレる | 座標じゃなく `tweetButtonInline` testid で取る |
| トーストが見えない | タイミングずれ or 投稿失敗 | プロフィールで最新ツイート確認 |
| プレミアム勧誘モーダルで遮られる | リプ成功後に X 自動表示 | 「後で試す」(560, 745) で閉じる |

## ⚠️ ハマりポイントと回避策

### ✅ X 予約UI 突破方法（2026-06-03確立）— React state対策
過去4回失敗してた予約UI、Reactのvalue setter経由で完全に突破した。日常ツイートも記事プロモも予約代行可能。

**完全な予約フロー（コード付き）**:
```js
// 1. 本文 type 後、「ポストを予約」aria-labelボタン click でダイアログを開く
const openBtn = [...document.querySelectorAll('button[aria-label]')]
  .find(b => b.getAttribute('aria-label') === 'ポストを予約');
openBtn.click();

// 2. select 取得（重要：[role="dialog"]内ではなくdocument全体から最後の5つ）
const sels = [...document.querySelectorAll('select')].slice(-5);
// sels[0]=月 [1]=日 [2]=年 [3]=時 [4]=分

// 3. React-friendly value setter で時/分変更
const setter = Object.getOwnPropertyDescriptor(HTMLSelectElement.prototype, 'value').set;
setter.call(sels[3], '17');                                    // 時
sels[3].dispatchEvent(new Event('change', {bubbles: true}));
setter.call(sels[4], '30');                                    // 分
sels[4].dispatchEvent(new Event('change', {bubbles: true}));

// 4. 確認テキスト読み取り（任意・デバッグ用）
document.querySelector('[role="dialog"]')?.innerText?.split('\n').slice(0,3).join(' | ');
// → "予約設定 | 確認する | 2026年6月3日(水)の午後5:30に送信されます"

// 5. 「確認する」button click → ダイアログ閉じる
[...document.querySelectorAll('button')]
  .find(b => b.innerText.trim() === '確認する')?.click();

// (wait 2s)

// 6. 「予約設定」button click → 投稿確定
[...document.querySelectorAll('button')]
  .find(b => b.innerText.trim() === '予約設定')?.click();

// 7. 下部に「ポストの送信日時: ...」トースト出れば成功
```

**なぜ React state 突破が必要だったか**:
- `select.value = '30'` だと React 内部の `valueTracker` をバイパス → state 検知されず即ロールバックされる
- `Object.getOwnPropertyDescriptor(HTMLSelectElement.prototype, 'value').set.call(select, '30')` だと valueTracker 経由で正しく state 更新される（React-friendly setter）

**ハマリポイント**:
- **SELECTOR_N の ID は毎回インクリメント**: `SELECTOR_1`→`SELECTOR_6`→`SELECTOR_11`... 予約ダイアログ開くたびに変わる。ID直接指定だと2本目以降で `Illegal invocation` エラー → `slice(-5)` で動的取得が安全
- **`[role="dialog"] select` は空配列**: 予約ダイアログの select は dialog の DOM ツリー外（フロート構造）→ document 全体から `querySelectorAll('select')` で取る
- **「確認する」と「予約設定」の2段階押下が必要**: 1回押しただけだと予約されてない。両方押す
- **アカウント確認**: ブラウザ操作前に `document.querySelector('[data-testid="AppTabBar_Profile_Link"]')?.getAttribute('href')` で `/galcho_official` を確認

### ⚠️ batch 内のタイミング落とし穴（2026-06-04 確認）

#### setter sels:0 エラー
`[click 「ポストを予約」, wait 5s, JS setter]` を batch でまとめると、**setter 実行時に `select` がまだ DOM になく `sels:0`** で失敗することがある。特に `/compose/post/schedule` への navigation を伴うとき。

**対策**:
- setter は**単独 `javascript_tool` 呼び出し**で実行（batch から切り離す）
- batch でやるなら try-catch + sels.length チェックで失敗検知 → 次の単独 call で再実行

```js
// 防御的な setter テンプレ
try {
  const setter = Object.getOwnPropertyDescriptor(HTMLSelectElement.prototype, 'value').set;
  const sels = [...document.querySelectorAll('select')].slice(-5);
  if (!sels[3] || !sels[4]) throw new Error('sels:' + sels.length);
  setter.call(sels[3], '17'); sels[3].dispatchEvent(new Event('change',{bubbles:true}));
  setter.call(sels[4], '30'); sels[4].dispatchEvent(new Event('change',{bubbles:true}));
  document.querySelector('[role="dialog"]')?.innerText?.split('\n').slice(0,3).join(' | ');
} catch(e) { 'ERROR:'+e.message; }
```

### ✏️ 本文入力の事故防止（2026-06-04 確認）

#### Unicode escape sequence は使わない
- type の text を `棅雨` と書くと「**棅雨**」（梅雨じゃない別字）になる事故あり
- **直接日本語で書く**: `text: "梅雨"` ← これが正解、`text: "棅雨"` ← NG
- 私（assistant）が unicode を書き間違える事故が複数回発生してるので、原則 unicode は使わない

#### ZWJ シーケンス絵文字は壊れる
- `💇‍♀️`（U+1F487+ZWJ+U+2640+VS = 女性が髪をブラシ）→ type 経由で `🙎`（口尖らせ女性）に化ける
- 複合絵文字（ZWJ）は CDP の type で1つに統合されず別字になることがある
- **対策**: 投稿前に**単一絵文字を選ぶ**。ZWJ 含む絵文字は避ける
- 投稿後 screenshot で絵文字確認、化けてたら削除→再投稿

#### 投稿ボックスの座標は動的取得
- `(350, 76)` 固定だと**フォーカスが取れず type が空振り**することがある
- **動的取得**:
```js
const ta = document.querySelector('[data-testid="tweetTextarea_0"]');
const r = ta.getBoundingClientRect();
const x = Math.round(r.x + r.width/2);
const y = Math.round(r.y + r.height/2);
```
- 取得した (x, y) でクリック → type → 安定

### ✅ 投稿成功判定（重要）

「投稿ボックスがクリアされた」**だけでは判定不十分**（ライブ投稿失敗でもクリアされることがある）。

**正しい判定方法**:
1. screenshot 撮って下部の **「ポストを送信しました。 表示」トースト**が出てるか確認
2. または、プロフィール開いて最新ツイートが投稿時刻と一致してるか確認:
   ```js
   const tweets = [...document.querySelectorAll('article[data-testid="tweet"]')].slice(0, 3);
   tweets.map(t => ({
     text: t.querySelector('[data-testid="tweetText"]')?.innerText?.slice(0, 60),
     time: t.querySelector('time')?.getAttribute('datetime')
   }));
   ```

### ハッシュタグの autocomplete 誤選択
- `#ギャル庁 #国会` と打つと自動補完で「国会情報局設置法案に反対します」など長文タグを選んでしまう
- **対策**: ハッシュタグ入力後すぐに Escape キー、または Ctrl+A → 再入力

### URLが検索バーに入る
- JS click 後にタブがフリーズすると、URL 入力が検索バーに行く
- **対策**: 新規タブで開き直す、または座標クリックでなく要素 click を確実に

### 投稿ボックスのフォーカス
- 投稿ボックスが React 制御で `.focus()` が効かないことがある
- **対策**: 一度マウスクリック → keyboard で入力

## 📝 投稿後の記録

`C:\Users\circl\Desktop\Code\gal\tweets-schedule.md` に追記:
```
## YYYY-MM-DD

### {時刻} 🏪 {ジャンル絵文字} 記事プロモ（ライブツリー）
本文: {本文の冒頭}
リプ: https://gal-cho.com/posts/{slug}/
```

## 🌐 2026年Xアルゴリズム対応（背景）

- 2026年3月以降、無料アカウントが**本文にリンクを貼ると表示数がほぼゼロ**まで減る（外部リンク格下げ）
- リプ欄のリンクはペナルティが軽い → 本文リンクなし + リプにURLが現状の最適解
- 単発予約は無料アカで可能だが、ツリー（リプ）の予約は不可 → ライブ投稿が必要
- 将来 X Premium 加入時は本文リンクOK＋表示4倍ブースト → 単発予約に戻せる

## 🤝 関連スキル

- [[galcho-daily-flow]] — 毎日の制作運用フロー全体（記事 → アフィ → push → ツイート）
- [[galcho-article-format]] — 記事の front matter に `tweet:` フィールドを書くのはこっち
