# gal-cho-cron-trigger（Cloudflare Workers Cron）

ギャル庁の予約投稿用 Cloudflare Pages 再ビルドを **Cron Triggers** で発火させる Worker。

## なぜこの Worker が必要か

GitHub Actions の scheduled cron は無料tierで慢性的に大遅延（数時間〜半日）する。
朝7時に公開予定の記事が夜にやっと公開されるなど、運用に支障があるため
信頼性の高い **Cloudflare Workers Cron Triggers** に移行する。

- ✅ 秒精度の発火（GitHub Actions のように遅延しない）
- ✅ 99.99% 稼働 SLA
- ✅ 無料tier 100,000 リクエスト/日 → ギャル庁の用途では月 90 回程度しか使わない
- ✅ Cloudflare 内完結なので Pages との通信が高速

## 仕組み

```
JST 7:00 / 11:00 / 17:00 ─→ Workers Cron Trigger
                                   │
                                   ▼
                          Pages Deploy Hook URL に POST
                                   │
                                   ▼
                          Cloudflare Pages リビルド
                                   │
                                   ▼
                          Hugo build → 予約記事公開
```

## セットアップ手順（初回のみ）

### 1. Deploy Hook を作成（Cloudflare Pages ダッシュボード）

1. https://dash.cloudflare.com → Workers & Pages → `gal-cho` プロジェクト
2. Settings → Builds & deployments → **Deploy hooks**
3. **Add deploy hook** をクリック
   - 名前: `cron-worker-rebuild`
   - ブランチ: `main`
4. 発行された URL（`https://api.cloudflare.com/client/v4/pages/webhooks/deploy_hooks/XXXX`）をコピー

### 2. ローカルで wrangler ログイン

```bash
cd workers/cron-trigger
npx wrangler login
# ブラウザで Cloudflare アカウントへのアクセスを許可
```

### 3. Secret を設定

```bash
# 必須: Deploy Hook URL
npx wrangler secret put DEPLOY_HOOK_URL
# プロンプトで Step 1 でコピーした URL を貼り付け → Enter

# 任意: 手動 trigger 用トークン（URL 経由で手動発火させたい場合）
npx wrangler secret put MANUAL_TRIGGER_TOKEN
# 任意の長いランダム文字列を貼り付け
```

### 4. デプロイ

```bash
npx wrangler deploy
```

成功すると Worker が稼働開始する。次の cron 時刻に自動発火される。

## 動作確認

### Cron で発火するか確認

Cloudflare ダッシュボード → Workers & Pages → `gal-cho-cron-trigger`
→ Logs タブでリアルタイム実行ログを確認できる。

### 手動トリガー（緊急時）

`MANUAL_TRIGGER_TOKEN` を設定済みなら、HTTP で直接叩ける：

```bash
curl -X POST "https://gal-cho-cron-trigger.<your-subdomain>.workers.dev/trigger?token=YOUR_TOKEN"
```

## Cron スケジュール

`wrangler.toml` の `[triggers].crons` で定義。

| Cron expression | UTC | JST | 用途 |
|---|---|---|---|
| `0 22 * * *` | 22:00 | 7:00 | 朝の予約記事公開 |
| `0 2 * * *`  | 02:00 | 11:00 | 昼の予約記事公開 |
| `0 8 * * *`  | 08:00 | 17:00 | 夕方の予約記事公開 |

変更したら `npx wrangler deploy` でデプロイ反映。

## 既存の GitHub Actions cron との関係

`.github/workflows/scheduled-rebuild.yml` の cron は**保険として残す**：

- Cloudflare Workers が万が一止まっても GitHub Actions が拾える
- `scheduled-rebuild.yml` の `concurrency` + 10分skip機構で重複ビルドは回避済み

将来 Cloudflare Workers の安定運用が確認できたら GitHub Actions cron を削減してOK。
