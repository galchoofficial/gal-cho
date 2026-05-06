# TODO（未実装の改善ネタ）

## 🎯 記事ごとのOG画像を自動生成したい

### 背景
- 現状: 全記事が `og-default.png`（ブランドだけ）
- 理想: **記事タイトル＋カテゴリ色のOG画像**を記事ごとに自動生成
  - リンク貼った時に「あ、この記事面白そう」感が爆上がり
  - X/Discord/LINE 流入の CTR が伸びる

### 実装案

#### 方針: PowerShell + System.Drawing で `hugo` ビルド前に自動生成

すでに `og-default.png` の生成で実証済みの方法をベースに、各記事の front matter を読んでループ生成。

#### 出力先
```
site/static/images/og/{slug}.png   ← 記事ごと
site/static/images/og-default.png  ← 既存（ホーム・固定ページ用）
```

#### Hugo 側の挙動（既に対応済）
`head.html` は以下の優先順で og:image を選ぶ:
1. 記事の front matter `og_image:` 指定
2. サイトデフォルト `site.Params.ogImage`

→ 自動生成スクリプトで front matter に `og_image: /images/og/{slug}.png` を埋め込めば、何もしなくても動く。

#### 自動生成スクリプトの仕様（案）

`site/scripts/generate-og-images.ps1`（仮称）:

1. `site/content/posts/*.md` を全部スキャン
2. front matter から取り出す:
   - `title`（記事タイトル）
   - `categories[0]`（カテゴリ → 色決定）
   - `thumb_emoji`（記事の絵文字）
3. 1200×630 のPNG を生成:
   - **背景**: ダークインク + カテゴリ色のアクセントストライプ
   - **左下**: ギャル庁ロゴ
   - **中央〜右下**: 記事タイトル（折り返し）
   - **右上**: カテゴリ絵文字（大）
4. `site/static/images/og/{slug}.png` に保存
5. （任意）front matter に `og_image:` を自動挿入

#### カテゴリ別の色（C-1 デザインから流用）
- tame (ためになる系) → パープル `#6b5bff`
- omo (面白い系) → オレンジ `#ff8c42`
- emo (エモい系) → コーラル `#ff7589`
- anime (アニメ・ゲーム系) → ライム `#5cc63d`

### 運用
- 新記事追加時に `pwsh ./scripts/generate-og-images.ps1` を実行
- 生成された PNG を `git add` してコミット
- もしくは GitHub Actions で push 時に自動実行（中級）

### 参考（次回着手時のヒント）

PowerShell System.Drawing で長文を折り返す書き方:
```powershell
$rect = New-Object System.Drawing.RectangleF 80, 200, 1040, 350
$format = New-Object System.Drawing.StringFormat
$format.LineAlignment = 'Near'
$g.DrawString($title, $titleFont, $brush, $rect, $format)
```

タイトルが長い記事は自動的に複数行になる。

### 優先度
中（AdSense審査前なら不要、SNS流入が増えてきたタイミングで実装すると効果実感しやすい）

---

## 📝 その他のメモ

（このセクションは追記用。気になることあったら書き足してね）
