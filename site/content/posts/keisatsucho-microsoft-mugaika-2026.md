---
title: "警察庁がマイクロソフトと組んで偽サイト工場を止めた件、能動的サイバー防御じゃないって知ってた？🛡️💻"
date: 2026-10-18T07:00:00+09:00
publishDate: 2026-10-18T07:00:00+09:00
draft: false
categories:
  - tame
tags:
  - サイバー犯罪
  - 警察庁
  - フィッシング
  - 能動的サイバー防御
  - マイクロソフト
thumb_emoji: "🛡️"
hero_emoji: "💻"
hero_bg: "blue"
lead: "10月14日、警察庁が米マイクロソフトなどと連携して、ネット犯罪に使われていたサービスを無害化したって発表したの🛡️ フィッシングの偽サイト作成キットや不正なクラウドアカウントを売ってた業者のドメイン、計34件💻 でもこれ、10月1日に始まった能動的サイバー防御の発動例じゃないのよ。仕組みがぜんぜん違うから、そこを整理するね📋"
source: "警察庁（米マイクロソフトなどと連携し、ネット犯罪に使われていたサービスの無害化措置を実施したと発表・2026-10-14） / 共同通信（偽メール1億通の規模と報じる報道・2026-10-14）"
source_url: "https://www.npa.go.jp/"
likes: 207
shares: 118
points:
  - 警察庁が10月14日に発表。米マイクロソフトなどと連携して犯罪用サービスのドメイン34件を無害化🛡️
  - これは能動的サイバー防御の発動例じゃなくて、米国での民事訴訟を通じた措置なのよ💻
  - 2025年10月から警察庁・マイクロソフト・JC3が連携して業者を特定してた。1年がかりの作業📅
aashi: |
  あーし的にはさぁ、記事241で「10月1日から無害化できるようになった」って書いた時は、正直「いつ使うんだろ？」って思ってたのよ😳⚔️　それが2週間で実践よ？？早すぎない？？🔥　それだけ攻撃がヤバいってことよね💀　マイクロソフトと組むのは賢いと思う🤝✨
tweet: |-
  警察庁が米マイクロソフトと連携して、フィッシング偽サイトの作成キットを売る業者のドメイン34件を無害化🛡️ でもこれ能動的サイバー防御の発動例じゃなくて、米国の裁判所の民事訴訟での措置なのよ💻 しかも1年がかりの特定作業だった👀

  詳しくはリプから👇
  #ギャル庁 #サイバー防御
---

ニュース見た人、たぶん<strong>「能動的サイバー防御が早速使われた！」</strong>って思ったと思う。あーしも最初そう思った😳

<strong>10月14日、警察庁が米マイクロソフトなどと連携して、ネット犯罪に使われていたサービスを無害化した</strong>って発表したの🛡️

でもね。ちゃんと中身を読んだら<em class="kw">ぜんぜん違う仕組み</em>だったのよ。ここを間違えると「新法ってすごい権限なんだ」って誤解したままになるから、今日はまずそこを直すね📋

## ⚠️ 最初に<span class="mk">訂正</span>させて🙏

<div class="gov-block">
  <h3>🙏 今回の措置は「新法の発動例」ではないの</h3>
  <div class="gov-row">
    <div class="gov-who"><small>❌</small>よくある誤解</div>
    <div class="gov-text">10月1日に施行された<strong>能動的サイバー防御（サイバー対処能力強化法）の新しい権限</strong>が使われた、という理解💀</div>
  </div>
  <div class="gov-row">
    <div class="gov-who"><small>⭕</small>実際はこう</div>
    <div class="gov-text">今回は<strong>米国での民事訴訟を通じた対応</strong>。マイクロソフトが米国の裁判所に訴えを起こして、裁判所の命令でドメインが無効化された⚖️</div>
  </div>
  <div class="gov-row">
    <div class="gov-who"><small>🔤</small>なぜ混ざる</div>
    <div class="gov-text">報道でもリリースでも<strong>「無害化」</strong>という同じ言葉が出てくる。でも<strong>言葉が共通してるだけで、根拠になってる仕組みは別物</strong>なの📋</div>
  </div>
  <div class="gov-conclusion">→ <strong>新法で日本の当局がサーバーに踏み込んだ、という話ではない</strong>のよ🙅‍♀️</div>
</div>

あーしもさ、<a href="/posts/noudouteki-cyber-bougyo-shikou-2026/">能動的サイバー防御が10月1日に始動した回</a>を書いたばっかりだったから、「2週間で実践！？」って完全に飛びついちゃったの😅

でも調べ直したら違った。<em class="kw">違ったことをちゃんと書くのがギャル庁</em>だと思ってるので、書くね💪

## じゃあ<span class="mk">何が</span>起きたの？時系列で見るね📅

<div class="gov-block">
  <h3>📅 1年がかりだった時系列</h3>
  <div class="gov-row">
    <div class="gov-who"><small>①</small>2025年10月〜</div>
    <div class="gov-text"><strong>警察庁・マイクロソフト・一般財団法人「日本サイバー犯罪対策センター（JC3）」が連携</strong>して、販売業者の特定を進めていた🔍</div>
  </div>
  <div class="gov-row">
    <div class="gov-who"><small>②</small>2026年10月6日</div>
    <div class="gov-text"><strong>マイクロソフトが、警察庁などの情報をもとに米国の裁判所に民事訴訟を起こした</strong>⚖️</div>
  </div>
  <div class="gov-row">
    <div class="gov-who"><small>③</small>2026年10月8日</div>
    <div class="gov-text"><strong>裁判所の命令が出て、ドメインの無効化措置が取られた</strong>💻</div>
  </div>
  <div class="gov-row">
    <div class="gov-who"><small>④</small>2026年10月14日</div>
    <div class="gov-text"><strong>警察庁が発表</strong>。ネット犯罪に使われていたサービスを無害化したと公表📢</div>
  </div>
  <div class="gov-conclusion">→ <strong>スタートは1年前</strong>。2週間でできた話じゃなくて、1年かけて積み上げた話なのよ😳</div>
</div>

ここ、あーしの最初の勘違いの<em class="kw">ちょうど逆</em>だったの💀

「2週間で実践、早すぎ！」じゃなくて、<strong>「1年がかりでやっと止められた」</strong>が正解。サイバー犯罪の摘発って、それくらい時間がかかるってことなんだよね😤

## 止まったのは<span class="mk">偽サイトの工場</span>🏭

何が無害化されたのか、ここが具体的でエグいのよ👀

<div class="gov-block">
  <h3>🏭 無効化されたサービス</h3>
  <div class="gov-row">
    <div class="gov-who"><small>🎣</small>対象</div>
    <div class="gov-text"><strong>フィッシング詐欺に使う偽サイトの作成キット</strong>や、<strong>不正に取得したクラウドアカウント</strong>を売っていた業者のドメイン、<strong>計34件</strong>💻</div>
  </div>
  <div class="gov-row">
    <div class="gov-who"><small>🛠️</small>作成キット</div>
    <div class="gov-text">ツール<strong>「コグイ」</strong>と<strong>「アイアンマン」</strong>🔧</div>
  </div>
  <div class="gov-row">
    <div class="gov-who"><small>☁️</small>アカウント販売</div>
    <div class="gov-text"><strong>「ヤムストア」</strong>。不正に取得したクラウドアカウントを売っていたとされる</div>
  </div>
  <div class="gov-row">
    <div class="gov-who"><small>💀</small>影響の規模</div>
    <div class="gov-text">この業者が販売したシステムは、<strong>2025年に警察庁が確認した国内企業の偽サイト約12万件のうち、半数の作成に使われていた</strong>😱</div>
  </div>
  <div class="gov-row">
    <div class="gov-who"><small>🏦</small>ひな型</div>
    <div class="gov-text"><strong>「アイアンマン」</strong>には、日本の金融機関や医療機関を含む<strong>少なくとも約2,300企業の偽サイトを作るための「ひな型」</strong>が組み込まれていた🏥</div>
  </div>
  <div class="gov-row">
    <div class="gov-who"><small>📧</small>報じられた規模</div>
    <div class="gov-text"><strong>偽メール1億通</strong>という規模で報じられている📨</div>
  </div>
  <div class="gov-conclusion">→ <strong>詐欺が「サービス」として売られてた</strong>のよ。これが止まったのはガチででかい🛡️</div>
</div>

<strong>約2,300企業のひな型</strong>って、つまり<em class="kw">選ぶだけで偽サイトが作れる</em>状態だったってことじゃん😱

銀行の偽サイトも、病院の偽サイトも、カタログから選ぶみたいに。だから被害があんなに広がってたのよ💀

⚠️ ちなみに凍結・無効化されたアカウントの数は<strong>報道によって数字の幅がある</strong>の。「関連する約2,500アカウントを凍結」としている報道もあるし、マイクロソフトの調査報告を伝える記事では「2万件超を無効化」とされてるものもある📋　ギャル庁はどっちか一方を断定しないで、<em class="kw">報道で数字が揺れてる</em>って書き方にしておくね🙏

## 新法の「無害化」と<span class="mk">今回</span>はどう違うの？🤔

ここが今日のメイン。かすみちゃんに硬いところ出してもらうね👓

{{< hukidashi who="aashi" >}}かすみちゃん、能動的サイバー防御の「無害化」ってそもそも何なの？🤔{{< /hukidashi >}}

{{< hukidashi who="kasumi" >}}能動的サイバー防御は、サイバー対処能力強化法等に基づく枠組みであります。重大なサイバー攻撃に対して、被害の発生を防ぐために攻撃に用いられるサーバー等へアクセスし、その機能を妨げる措置を講じ得るとする仕組みと承知しております。すなわち、日本の行政機関が自らの権限として行う措置であります。{{< /hukidashi >}}

{{< hukidashi who="aashi" >}}え、じゃあ今回のはそれじゃないの？😳{{< /hukidashi >}}

{{< hukidashi who="kasumi" >}}今回の措置は、米国において民事訴訟が提起され、裁判所の命令に基づきドメインが無効化されたものと説明されております。日本の新たな法的権限の行使ではなく、米国の司法手続を通じた対応であると整理されます。{{< /hukidashi >}}

{{< hukidashi who="aashi" >}}てことは「国が自分でサーバーを止めた」じゃなくて、「会社が裁判所にお願いして止めてもらった」ってこと？？{{< /hukidashi >}}

{{< hukidashi who="kasumi" >}}概ねその通りでございます。手続の主体は民間企業であり、措置の根拠は裁判所の命令であります。警察庁は、把握していた情報の提供等を通じて連携した立場と説明されております。{{< /hukidashi >}}

{{< hukidashi who="aashi" >}}なるほど…同じ「無害化」って言葉でも、<strong>誰が・何を根拠に止めたか</strong>が全然違うんだね💡{{< /hukidashi >}}

{{< hukidashi who="kasumi" >}}その点が重要であると存じます。なお、能動的サイバー防御のうち、通信情報の利用に関する規定の施行は2027年秋からとされており、制度全体が稼働している段階ではないと承知しております。{{< /hukidashi >}}

{{< hukidashi who="aashi" >}}あ、そこまだ動いてないんだ。じゃあ「新法がもう全開で回ってる」っていうのも違うのね📋{{< /hukidashi >}}

## 整理するとこう📋

<div class="gov-block">
  <h3>⚖️ 2つの「無害化」の違い</h3>
  <div class="gov-row">
    <div class="gov-who"><small>🛡️</small>能動的サイバー防御</div>
    <div class="gov-text">主体は<strong>日本の行政機関</strong>。根拠は<strong>日本の法律</strong>。2026年10月1日に主要規定が施行、<strong>通信情報の利用は2027年秋から</strong></div>
  </div>
  <div class="gov-row">
    <div class="gov-who"><small>⚖️</small>今回の措置</div>
    <div class="gov-text">主体は<strong>マイクロソフト（民間企業）</strong>。根拠は<strong>米国の裁判所の命令</strong>。警察庁は情報提供などで連携した立場</div>
  </div>
  <div class="gov-row">
    <div class="gov-who"><small>⏰</small>かかった時間</div>
    <div class="gov-text">今回は<strong>2025年10月から約1年</strong>。新法の施行（10月1日）とは期間がまったく重ならない📅</div>
  </div>
  <div class="gov-conclusion">→ <strong>言葉が同じでも中身は別。混ぜると制度の理解がズレる</strong>のよ📋</div>
</div>

<a href="/posts/cyber-active-defense-law-2026/">日本政府が「サイバー攻撃を仕掛け返す」法律を作ってた件</a>を書いた6月から、あーしはこの制度をずっと追いかけてるんだけど、<em class="kw">制度ができたことと、制度が使われたこと</em>は別の話だから丁寧に分けたいのよね📋

## なんでマイクロソフトと<span class="mk">組む</span>のが合理的なの？🤝

ここは素直にうまいと思った✨

<div class="gov-block">
  <h3>🤝 民間と組む3つの理由</h3>
  <div class="gov-row">
    <div class="gov-who"><small>①</small>インフラを持ってる</div>
    <div class="gov-text">クラウド・OS・メールサービスを握ってるのは民間企業。<strong>犯罪者も当然それを使ってる</strong>から、持ち主が動けば一気に止められる☁️</div>
  </div>
  <div class="gov-row">
    <div class="gov-who"><small>②</small>技術力と情報量</div>
    <div class="gov-text">世界中のサイバー攻撃のデータを持ってるから、<strong>どのサーバーが怪しいかが分かる</strong>🔍</div>
  </div>
  <div class="gov-row">
    <div class="gov-who"><small>③</small>国境を越えられる</div>
    <div class="gov-text">犯罪者が海外のサーバーを使うのは普通。<strong>国の権限だけでは手が届かない</strong>ところに、グローバル企業の手続なら届く🌏</div>
  </div>
  <div class="gov-conclusion">→ <strong>今回のドメイン停止がまさに③の実例</strong>。米国の裁判所を使って海外のドメインを止めた⚖️</div>
</div>

あと、キットの販売には<strong>中国系の犯罪組織が関与しているとみられる</strong>と報じられてる🀄　攻撃する側がもう完全に国際的なビジネスになってるんだよね💀

この「犯罪が組織化・サービス化してる」構造って、<a href="/posts/tokuryu-yamibaito-2026/">「トクリュウ」って何？の回</a>で書いた話とまったく同じ形なの。<a href="/posts/sns-toushi-sagi-1414oku-2026/">SNS投資詐欺の被害額が過去最悪の1,414億円</a>になったのも、こういう道具が安く買える状態と地続きなのよ😤

## あーしたちの<span class="mk">実生活</span>とのつながり🔗

偽サイトのキットが止まったって聞いても最初はピンとこなかったんだけど、ここ最近の流出事件と並べると意味が分かるのよ😳

- <a href="/posts/times-car-jouhou-rouei-2026/">タイムズカーで免許証の画像が約160万件流出した件</a>🪪
- <a href="/posts/sagawa-fusei-access-2026/">佐川急便に不正アクセスがあった件</a>📦
- <a href="/posts/yamato-sagawa-fusei-access-2026/">ヤマトと佐川の両方に不正アクセス、詐欺の手口も2種類</a>🚚
- <a href="/posts/daiichi-life-fusei-access-2026/">第一ライフグループで従業員約12万人分が漏えいの可能性</a>🏢

流出した<em class="kw">氏名・住所・荷物の情報</em>と、今回止まった<em class="kw">偽サイトを量産する道具</em>がセットになると、めちゃくちゃリアルな詐欺が作れちゃうの💀

つまり今回の無害化は、<strong>詐欺の「材料」はもう出回ってる状態で、「道具」の側を1つ潰した</strong>って話なんだよね🛠️

攻撃の効率がAIで上がってる話は<a href="/posts/ai-cyber-mythos-2026/">財務大臣が「今そこにある危機」と言ったミュトスの回</a>に書いたし、守る側の体制づくりだと<a href="/posts/si-force-sousetsu-2026/">アメリカがAI司令塔「SIフォース」を創設した話</a>や<a href="/posts/apple-full-disk-access-ai-2026/">AppleがMacの「全ディスクアクセス」権限を厳格化した話</a>もあったよね🤖

## で、制度そのものには<span class="mk">懸念</span>も残ってる📋

ここ、今回の件とは<strong>切り分けて</strong>書くね。今回はあくまで民事訴訟の話。でも<em class="kw">能動的サイバー防御という制度自体</em>には、別の論点があるのよ🙏

<div class="gov-block">
  <h3>🤔 能動的サイバー防御そのものへの論点</h3>
  <div class="gov-row">
    <div class="gov-who"><small>①</small>国が侵入していいの</div>
    <div class="gov-text">「無害化」は<strong>国が他人のサーバーに入ってその機能を止める</strong>という行為。どこまで認めるかという議論が続いてる⚔️</div>
  </div>
  <div class="gov-row">
    <div class="gov-who"><small>②</small>誤爆のリスク</div>
    <div class="gov-text">無関係なサーバーを止めてしまったらどうするの？それが<strong>病院や公共インフラ</strong>だったら影響は計り知れない🏥</div>
  </div>
  <div class="gov-row">
    <div class="gov-who"><small>③</small>通信の秘密</div>
    <div class="gov-text"><strong>通信情報の利用は2027年秋から</strong>。ここが一番プライバシーとぶつかる部分だと思う📱</div>
  </div>
  <div class="gov-conclusion">→ <strong>制度の評価は、実際にどう運用されるかを見てから</strong>。まだ結論を出せる段階じゃないのよ📋</div>
</div>

③については、<a href="/posts/tokuryu-hikou-tsuushin-kaiseki-2026/">トクリュウの秘匿通信を警察が遠隔解析できるようにする検討</a>の回でも同じ論点が出てきてた。<em class="kw">捜査の力を上げる</em>のと<em class="kw">通信の秘密を守る</em>のは、どうしても引っぱり合うのよね⚖️

<div class="insight">
  <span class="insight-tag">💎 ぶっちゃけポイント</span>
  <p>今回の件、あーしは中身としては評価したい🤝　理由は3つあって、①<strong>民間と組んでるから国だけで暴走してない</strong>、②<strong>対象が犯罪サービスで、一般人の通信じゃない</strong>、③<strong>ちゃんと公表してる</strong>から💪　サイバーの話って「隠れてやる」のが一番ダメだと思うのよ。透明性があるのは良いこと✨</p>
  <p>でも同時に、<em class="kw">「能動的サイバー防御が2週間で実践された」っていう理解は間違い</em>だってことも言いたい🙏　これ、ただの細かい訂正じゃないのよ。「新法ってもうこんなに強い力を使ってるんだ」って思い込むと、これから2027年秋に通信情報の話が来たときに、議論の出発点がズレちゃう📋</p>
  <p>あと逆方向でもっと大事なのは、<strong>1年がかりだった</strong>って事実🔍　2025年10月から警察庁とマイクロソフトとJC3が追いかけて、やっと10月8日にドメインが止まった。<em class="kw">サイバー犯罪を止めるのは、法律が1本できたからすぐできる話じゃない</em>。地道な特定作業と、国際的な手続の積み上げなのよ😤</p>
  <p>だからあーしの結論はこう。<strong>新法に期待しすぎず、怖がりすぎず、実際の運用を見ていく</strong>。ギャル庁はちゃんと追いかけるね🛡️✨</p>
</div>

## まとめ📝

<div class="gov-block">
  <h3>📌 3行まとめ</h3>
  <div class="gov-row">
    <div class="gov-who"><small>🛡️</small>何が起きた</div>
    <div class="gov-text">10月14日に警察庁が発表。米マイクロソフトなどと連携して、偽サイト作成キットやクラウドアカウントを売る業者の<strong>ドメイン34件を無害化</strong></div>
  </div>
  <div class="gov-row">
    <div class="gov-who"><small>⚖️</small>仕組みは</div>
    <div class="gov-text"><strong>能動的サイバー防御の発動例ではない</strong>。マイクロソフトが10月6日に米国の裁判所に民事訴訟を起こし、10月8日の命令でドメインが止まった</div>
  </div>
  <div class="gov-row">
    <div class="gov-who"><small>📅</small>期間は</div>
    <div class="gov-text"><strong>2025年10月から約1年がかり</strong>。警察庁・マイクロソフト・JC3が連携して業者を特定していた</div>
  </div>
  <div class="gov-conclusion">→ <strong>同じ「無害化」でも、誰が何を根拠に止めたのかで全然違う話になる</strong>📋</div>
</div>

制度の話は言葉が硬いけど、間違えたまま覚えると損するのはあーしたちだから、ちゃんと整理していくね🛡️💻✨
