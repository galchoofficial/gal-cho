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

## ⚡ 2026-10-02 に確立した「壊れない手順」（★これが現行のやり方）

X の投稿が壊れる事故を3回起こしたあと、原因が全部つぶれた手順。**この順番でやれば事故らない。**

### ★Step 0：フォーカスを取る（これが全部の前提）
ブラウザのウィンドウが背面（`document.hasFocus() === false`）だと、Xのエディタ（Draft.js）が壊れる。
入力が2回反映される／ハッシュタグ補完が暴走して同じタグを15回以上複製する／投稿直前にJSで読んだ内容と実際に投稿される内容が食い違う／クリアしても残骸が復活する、といった事故が起きる。

```js
// まず確認
({focus: document.hasFocus(), vis: document.visibilityState})
```

- `focus: false` だったら、**`computer` の `left_click` でページを1回クリックする**。これでウィンドウにフォーカスが入る
- ⚠️ **JS の `window.focus()` は効かない**（効くのはOSレベルのクリックだけ）
- ✅ **一度フォーカスを取れば、`navigate` してもタブ内で維持される**。だから**クリックは最初の1回だけ**でよく、8本連続で投稿してもクリック1回で足りた
- ユーザーが他のアプリ（DAWなど）で作業中にクリックするとその作業を中断させるので、**毎回クリックせず、記事ごとに `hasFocus` を確認して false のときだけ**クリックする

### ★Step 0-A：タブが背面（hidden）なら `window.open` で開き直す（2026-10-03 解決）

`document.visibilityState` が `hidden` のタブでは、**何をしても入力が入らない**（`insertText` も `type` も無反応）。
そして **Claude in Chrome の拡張機能には「タブを選択してアクティブにする」ツールが無い**。`tabs_create_mcp` で作った新規タブも背面で開くので解決しない。

**解決策：すでにグループ内にあるタブで、JS の `window.open()` を実行する。**

```js
window.open('https://x.com/compose/post', '_blank')
```

- こうして開いたタブは **アクティブタブになり、`visibilityState: "visible"` ＋ `hasFocus: true`** になる
- しかも**そのタブは Claude のタブグループに自動で入る**ので、そのまま `tabId` を指定して操作できる
- 2026-10-03、Chromeのアクティブタブが「もしもアフィリエイト」で、こちらのタブが全部背面だった状況を、これ1つで解決した

**手順**
1. `tabs_context_mcp` でグループのタブを取得（無ければ `createIfEmpty: true`）
2. そのタブで `visibilityState` を確認
3. `hidden` だったら、そのタブで `window.open('<開きたいURL>', '_blank')` を実行
4. 新しく出てきた `tabId` に対して `visibilityState` を確認 → `visible` になっているはず
5. 以降はその tabId で作業する

**それでもダメなときの手順**
- Chromeのウィンドウ自体が別モニターにいたり背面だったりする場合がある。`mcp__computer-use__request_access` で Google Chrome を許可（ブラウザは read 権限しか降りないが、それで足りる）→ `open_application` で Chrome を前面に出す → 上の `window.open` をやる
- `switch_display` ＋ `screenshot` で、どのモニターにいて何のタブが選ばれているかを目で確認できる
- ⚠️ computer-use はブラウザに対して**クリックもキー入力もできない**（read 専用）。AutoHotkey や PowerShell でキーを送って迂回するのは**禁止**

### ★Step 1：本文を入れる（`insertText` ではなく **合成 paste イベント**）（2026-10-05 全面更新）

```js
const ed = document.querySelector('div[data-testid="tweetTextarea_0"]');
ed.focus();
const dt = new DataTransfer();
dt.setData('text/plain', 本文全文);
ed.dispatchEvent(new ClipboardEvent('paste', {clipboardData: dt, bubbles: true, cancelable: true}));
```

- **`document.execCommand('insertText', ...)` はもう使わない。** 末尾がハッシュタグの本文を入れると、X のハッシュタグ補完が暴走して **1行目を `#ハッシュタグ ` の繰り返しで丸ごと上書きする**。2026-10-05 に5回連続で再現した（毎回きっちり同じ結果になる＝確定的なバグ）
  - `document.hasFocus() === true` でも `visibilityState === 'visible'` でも起きる。**フォーカスの問題ではない**（2026-09-29 の記録はここが誤り）
  - 末尾に半角スペースを足しても、ハッシュタグだけ別 `insertText` に分けても防げなかった
  - ハッシュタグを含まない本文だけなら `insertText` でも壊れない。**トリガーは「末尾のハッシュタグ」**
- **合成 paste なら Draft.js が1回の貼り付けとして処理する**ので補完が発火しない。2026-10-05 は本文2本・リプ2本すべて1発で成功
- **`computer` の `type` アクションも使わない**（日本語が化ける。「週」U+9031 →「遑」U+9051 の誤字投稿事故あり）。`ctrl+End` でカーソルを末尾に送ってから type する手も試したが、**1行目を置換してしまった**
- **エディタは必ず「まっさら」な状態で使う。** 一度暴走したエディタは `selectAll` + `delete` をしても残骸（`#金利 ` など）が数十文字残り、次の貼り付けまで汚染される
  - → **汚れたら新しい compose タブを開き直す**（→ Step 0-A）。同じタブで直そうとしない
  - 貼り付け前に `ed.innerText.length` を見て、**1以下（空の `\n` だけ）であることを確認**する

### ★Step 1-B：`window.open` が効かないときは「リンクを注入してクリック」（2026-10-05 追加）

Step 0-A の `window.open(url,'_blank')` は、**JS から直接呼ぶとポップアップブロックで無視されることがある**（2026-10-05 に発生。新タブが作られず、タブは `hidden` のまま）。

その場合は **ページに `<a target="_blank">` を注入して `computer` でクリックする**。実クリック＝ユーザージェスチャー扱いになるのでブロックされない。

```js
document.getElementById('__gal_open')?.remove();
const a = document.createElement('a');
a.id = '__gal_open'; a.href = 'https://x.com/compose/post'; a.target = '_blank';
a.textContent = 'OPEN';
a.style.cssText = 'position:fixed;left:40px;top:300px;width:220px;height:70px;z-index:2147483647;'
  + 'background:#ff0066;color:#fff;font-size:28px;display:flex;align-items:center;'
  + 'justify-content:center;border-radius:10px;';
document.body.appendChild(a);
```

→ スクショを撮ってピンクの `OPEN` の座標を確認し、`computer` の `left_click` で踏む。新タブが **`focus: true` かつ `visibilityState: 'visible'`** で開く。

- **注入したリンクは X の再描画で消えることがある。** クリックしたのに新タブが増えず、サイドバーの「チャット」を踏んで `/i/chat` に飛ぶ事故が2回起きた。**クリック後は必ずタブ一覧で新タブが増えたか確認する**
- **すでにアクティブなタブを `navigate` するだけなら focus も visible も保たれる。** リプを書くときのように「今見ているタブで status ページへ移動する」場合は、この注入は不要（2026-10-05 確認）

### ★Step 1-A：化けやすい漢字は `String.fromCodePoint()` で組み立てる（2026-10-03 更新）

`insertText` を使っても、**こちらから送る文字列の時点で化けている**ことがある。`type` だけの問題ではない。

**実際に化けた字**
| 正しい字 | コード | 化けた字 | コード | 発生 |
|---|---|---|---|---|
| 週 | U+9031 | 遑 | U+9051 | 2026-09-29（type） |
| 週 | U+9031 | 遒 | U+9052 | 2026-10-03（insertText） |

**「週」は2回とも化けている。最重要の要注意文字。**

**対策**
```js
const W = String.fromCodePoint(0x9031);   // 週
const t = "小学校が" + W + "52.1時間・中学校が" + W + "55.1時間…";
```
ASCII だけで文字を組み立てるので、送信経路で化けようがない。

**投稿前の検証（必須）**
化けやすい字の**直後にある固定文字列**を手がかりに、コードポイントを16進で出して目視する。
```js
const v = document.querySelector('[data-testid="tweetTextarea_0"]').innerText;
const i = v.indexOf('52.1');
({ code: v.slice(i-1, i).codePointAt(0).toString(16) })   // "9031" なら正しい
```
- ⚠️ **`v.includes('週…')` のような自作の判定は使えない**。判定に使う文字列リテラルも同じように化けるので、化けた本文と化けた判定文字列が一致して**すり抜ける**（2026-09-29にこれで誤字のまま投稿した）
- **投稿した後にも同じ検証をする**。エディタ上は正しくても投稿時に化ける可能性があるため

**化けを見つけたときの手順**
1. ユーザーに報告して、削除していいか確認を取る（削除は取り消せない）
2. 承認が出たら `article [data-testid="caret"]` → メニューの「削除」→ `confirmationSheetConfirm` の順にクリック
3. `fromCodePoint` で組み直して投稿し、**投稿後にもう一度コードポイントを検証**する

### ★Step 2：5秒待ってから検証する（投稿前）
挿入直後は正しくても、**3〜5秒後にハッシュタグ補完が書き換えることがある**（フォーカスがないとき）。必ず待ってから読む。

```js
const v = document.querySelector('[data-testid="tweetTextarea_0"]').innerText;
const b = document.querySelector('[data-testid="tweetButton"]');
({v, len: [...v].length, hash: (v.match(/#/g)||[]).length, btn: b.getAttribute('aria-disabled')})
```
- **`btn` が `null` なら投稿可、`"true"` なら文字数オーバーか空**
- ★**字数の判定は `len` ではなく `btn`（`aria-disabled`）で行う**。X は半角文字を 0.5 と数えるので、数字や英字が多い文面は `len` が 155 でも投稿できる（2026-10-03 に実例あり）。逆に全部全角なら 141 で弾かれる。**`len` は目安、`btn` が正解**
- `len` が 140 を超えていて `btn` も `"true"` なら短縮する。超えていたら短縮する（2026-10-02 にポケモンの記事の tweet が164字でオーバーした）
- 返した `v` は**目で読んで元の文面と照合する**。`v.includes('週…')` のような自作の判定は、判定文字列ごと化けるので当てにならない

### ★Step 3：投稿する
```js
// 条件を満たしたときだけクリックする、を1回のJSで完結させると安全
const ok = (v.match(/#/g)||[]).length === 2 && v.includes('本文の特徴的な語') && b && b.getAttribute('aria-disabled') !== 'true';
if (ok) b.click();
```
- **投稿ボタンの testid は場所で違う**：新規ポスト＝`tweetButton` ／ 返信＝`tweetButtonInline`
- ⚠️ **`Escape` キーは押さない**。ハッシュタグ補完を閉じるつもりで押すと compose モーダルごと閉じて入力が全部消える

### ★Step 4：status ID を取って、リプに記事URLをぶら下げる
```js
// プロフィールで最新ツイートのIDを取る
[...document.querySelectorAll('article')].slice(0,1).map(a => ({
  link: [...a.querySelectorAll('a')].map(x=>x.getAttribute('href')).find(h=>h&&/\/status\/\d+$/.test(h)),
  txt: a.innerText.slice(0,40).replace(/\n/g,' ')
}))
```
- **プロフィールへの反映は20〜30秒遅れることがある**。出てこないことを理由に**再投稿しない**（2026-09-28 に重複投稿を作った）
- 取れた ID で `https://x.com/galcho_official/status/{id}` へ行き、リプ欄に `insertText` で記事URLだけを入れて `tweetButtonInline` をクリック
- リプは URL 1本だけでいい（「記事はこちら👇」を付けると絵文字の分だけ事故のリスクが増える。URLだけでもリンクカードが展開される）

### 1記事あたりのバッチ構成（実測で1本あたり3バッチ）
1. `navigate(compose)` → 待つ → クリア＋`insertText` → 5秒待つ → 検証
2. 投稿 → 10秒待つ → `navigate(プロフィール)` → 9秒待つ → status ID 取得
3. `navigate(status)` → 待つ → リプに `insertText` → 検証して投稿

※ 2と3の間、3と次の記事の1は**同じバッチにまとめられる**ので、慣れたら1本2バッチで回せる。

### ★tweet 本文は「絵文字を行頭に置かない」書式にする（2026-10-03）
- Xの入力欄は**絵文字を打つとフォーカスが外れて続きが入らない**。行頭に絵文字があると入力を細かく分割して毎回クリックし直すことになる（2026-09-28は1投稿あたり **6分割＋クリック6回**）。**行末だけなら2分割**で済む
- 記事側の `tweet:` は [[galcho-article-format]] で「絵文字は行末だけ」に統一してある。古い記事で**行頭に絵文字がある tweet をプロモするときは、投稿前に絵文字を行末へ移す**（意味が変わらない範囲で）
- 上の `insertText` 方式なら基本は1回で全文入るが、うまく入らずに `type` や分割入力にフォールバックしたときに効いてくる保険

### ⚠️ 記事側の tweet フィールドが140字を超えていることがある
`galcho-article-format` の指示にも入れているが、生成時に超えることがある。**投稿時に `len` でチェックして、超えていたら短縮して投稿する**。ハッシュタグを `#ギャル庁` の1個だけにすると10字前後縮む。

---

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

#### 投稿ボックスの座標は動的取得＋画面実測で再調整（2026-06-08 補強）
- `(350, 76)` 固定だと**フォーカスが取れず type が空振り**することがある
- **動的取得**:
```js
const ta = document.querySelector('[data-testid="tweetTextarea_0"]');
const r = ta.getBoundingClientRect();
const x = Math.round(r.x + r.width/2);
const y = Math.round(r.y + r.height/2);
```
- ⚠️ **重要**：JS が返す座標が `(505, 90)` でも、**画面のモーダル内 textarea は (420, 130) や (560, 130) にある**ケースを確認（背景の隠れ textarea とモーダル内 textarea で querySelector が混乱する）
- type 後に `btnDisabled: "true"` なら→**画面で実際の textarea 位置を screenshot 確認 → 座標を変えて再クリック**
- 6/8 ミュトス事故では：JS座標 `(505, 90)`→失敗 / `(420, 130)`→失敗 / `(560, 130)`→成功
- **3回失敗したら座標を変える**（505→420→560 の順で試す価値あり）

#### Unicode escape 書き間違い問題（2026-06-08 確認）
- type に `衰` を書くと「衰」、`衝` だと「衝」。**Unicode を書き間違えると別の漢字になる事故**あり（6/8 ミュトスツイート「衝撃→衰撃」事件）
- **対策**: type の text フィールドは**直接日本語で書く**ことを徹底。Unicode escape は使わない
- どうしても escape が必要な場合は、書く前に Unicode コードポイントを必ず確認

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

### 🗑️ ツイート削除手順（2026-06-08 実証）

投稿後に誤字発覚→無料アカは編集不可なので削除→再投稿しかない。手順：

```js
// 1. 削除したいツイートの詳細ページに navigate
// navigate(`https://x.com/galcho_official/status/{tweet_id}`)
// wait 4s

// 2. caret(...) ボタンクリックでメニュー表示
const caret = document.querySelector('article[data-testid="tweet"] [data-testid="caret"]');
caret?.click();
// wait 2s

// 3. メニュー内の「削除」項目をクリック
const item = [...document.querySelectorAll('[role="menuitem"]')]
  .find(m => m.innerText.trim() === '削除');
item?.click();
// wait 2s

// 4. 確認ダイアログで「削除」確定
const confirmBtn = document.querySelector('[data-testid="confirmationSheetConfirm"]');
confirmBtn?.click();
// wait 4s
// → 下部に「ポストを削除しました」トースト、ホームにリダイレクト
```

**重要ポイント**:
- 親ツイート削除すると**リプ（ライブツリーのURL部分）も自動削除**される
- 削除後に再投稿する場合は**新しい status_id** が発行されるので、リプ用の URL navigate でも新 id を使う
- 削除トースト確認後すぐに `/compose/post` に navigate して再投稿フロー開始でOK

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
