# ギャル庁 〜あーしが読んどいたよ〜

お堅い公式文書・生活情報・ニュースを **ギャル語で解説** するまとめサイト。

> あーしが読んどいたよ。

## 技術構成

- **静的サイトジェネレーター**: [Hugo](https://gohugo.io/) (Extended)
- **ホスティング**: [Cloudflare Pages](https://pages.cloudflare.com/)
- **カスタムテーマ**: `themes/gal-cho/`（このリポジトリ内）
- **フォント**: Noto Sans JP（中華フォント対策）

## ローカル開発

```powershell
cd site
hugo server
# → http://localhost:1313/
```

## 新しい記事を書く

```powershell
cd site
hugo new posts/your-article-slug.md
```

front matter のテンプレートは `themes/gal-cho/archetypes/posts.md` にあります。

## ディレクトリ構成

```
gal/
├── site/              ← Hugo サイト本体（デプロイ対象）
│   ├── content/posts/    記事 (.md)
│   ├── themes/gal-cho/   カスタムテーマ
│   └── hugo.toml         サイト設定
├── 資料/             ← 企画書・編集方針
├── 記事ストック/      ← 記事の下書き（原稿）
├── 過去/             ← 採用しなかった旧デザイン
└── pattern_c_*.html   デザインモックアップ
```

## ライセンス

- **コード（テーマ・設定）**: [MIT License](LICENSE)
- **記事コンテンツ**: All Rights Reserved（無断転載禁止）

## セキュリティ報告

脆弱性を発見した方は [SECURITY.md](SECURITY.md) を参照してください。
