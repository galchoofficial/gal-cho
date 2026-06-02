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
