---
title: "{{ replace .Name "-" " " | title }}"
date: {{ .Date }}
draft: true
categories:
  - omo  # tame / omo / emo / anime
tags:
  - 国会答弁
thumb_emoji: "💅"
hero_emoji: "💅"
hero_bg: "blue"  # blue / pink / lime / purple / orange / peach
lead: "ここにリード文（記事冒頭の1〜2行サマリー）"
source: "元ネタの説明文"
source_url: ""
likes: 0
shares: 0
aashi: |
  ここに「あーし的にはさぁ、」のコメント。HTMLタグもOK（mark など）。
---

ここから本文（Markdown）。

【ざっくり何の話？】

リード後の最初のパラグラフ。

## 見出し例

通常の本文。**太字** や *斜体* も使える。

<div class="insight">
  <span class="insight-tag">💎 ぶっちゃけポイント</span>
  <p>ここはステッカー風の強調ボックス。HTMLで書く。</p>
</div>
