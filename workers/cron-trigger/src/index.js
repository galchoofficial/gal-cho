/**
 * ギャル庁 予約投稿用 Cron Trigger Worker
 *
 * Cloudflare Pages の Deploy Hook を POST して再ビルドを発火させる。
 * 発火タイミング：JST 7:00 / 11:00 / 17:00（wrangler.toml の crons で定義）
 *
 * GitHub Actions の cron が不安定なので、Cloudflare Workers Cron で代替。
 * Workers Cron は秒精度・99.99% 稼働の SLA で動く。
 *
 * 必須 secret: DEPLOY_HOOK_URL
 *   Cloudflare Pages > gal-cho > Settings > Builds & deployments > Deploy hooks
 *   で発行した URL を `npx wrangler secret put DEPLOY_HOOK_URL` で設定。
 */
export default {
  async scheduled(event, env, ctx) {
    const url = env.DEPLOY_HOOK_URL;
    if (!url) {
      console.error('[cron-trigger] DEPLOY_HOOK_URL secret not configured');
      return;
    }
    const startTime = Date.now();
    try {
      const res = await fetch(url, { method: 'POST' });
      const elapsed = Date.now() - startTime;
      console.log(
        `[cron-trigger] Deploy hook triggered (${res.status} ${res.statusText}, ${elapsed}ms) at cron=${event.cron}`
      );
      if (!res.ok) {
        const body = await res.text();
        console.error(`[cron-trigger] Non-2xx response body: ${body.slice(0, 500)}`);
      }
    } catch (e) {
      console.error(`[cron-trigger] Failed to trigger deploy hook: ${e.message}`);
    }
  },

  // 動作確認用の HTTP エンドポイント（任意・手動 trigger に使える）
  async fetch(request, env, ctx) {
    const url = new URL(request.url);
    if (url.pathname === '/trigger' && request.method === 'POST') {
      // 認証用シンプル token（クエリ ?token=XXX）
      const token = url.searchParams.get('token');
      if (!env.MANUAL_TRIGGER_TOKEN || token !== env.MANUAL_TRIGGER_TOKEN) {
        return new Response('Unauthorized', { status: 401 });
      }
      if (!env.DEPLOY_HOOK_URL) {
        return new Response('DEPLOY_HOOK_URL not configured', { status: 500 });
      }
      const res = await fetch(env.DEPLOY_HOOK_URL, { method: 'POST' });
      return new Response(
        `Deploy hook triggered: ${res.status} ${res.statusText}`,
        { status: res.ok ? 200 : 502 }
      );
    }
    return new Response(
      'ギャル庁 Cron Trigger Worker\n\nCron: JST 7:00 / 11:00 / 17:00\nDeploy Hook: configured via secret\n',
      { headers: { 'content-type': 'text/plain; charset=utf-8' } }
    );
  }
};
