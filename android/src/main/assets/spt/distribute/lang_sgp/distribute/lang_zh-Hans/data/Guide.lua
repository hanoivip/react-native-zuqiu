local null = nil
local var = 
{
	[ [=[1100]=] ]=
	{
		[ [=[text]=] ]=[=[时光飞逝，我们的球队逐渐壮大。终于进入了顶级联赛。]=],
		[ [=[guidance]=] ]=[=[]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[HomePage]=],
		[ [=[returnPoint]=] ]=1100,
		[ [=[type]=] ]=[=[main]=],
		[ [=[textType]=] ]=[=[C1]=],
		[ [=[desc]=] ]=[=[]=]
	},
	[ [=[1150]=] ]=
	{
		[ [=[text]=] ]=[=[厉害了哇！想不到现在我也是一台在顶级联赛俱乐部里工作的饮水机了！咕噜噜……咕噜噜……]=],
		[ [=[guidance]=] ]=[=[]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[HomePage]=],
		[ [=[returnPoint]=] ]=1100,
		[ [=[type]=] ]=[=[main]=],
		[ [=[textType]=] ]=[=[S1]=],
		[ [=[desc]=] ]=[=[]=]
	},
	[ [=[1200]=] ]=
	{
		[ [=[text]=] ]=[=[经过这段时间，我已经调整好了自己的状态。从现在开始我要全力以赴。相信在不久的将来，还会与曾经的爱将相遇啊……]=],
		[ [=[guidance]=] ]=[=[]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[HomePage]=],
		[ [=[returnPoint]=] ]=1100,
		[ [=[type]=] ]=[=[main]=],
		[ [=[textType]=] ]=[=[C1]=],
		[ [=[desc]=] ]=[=[]=]
	},
	[ [=[1300]=] ]=
	{
		[ [=[text]=] ]=[=[这位大叔怎么这么中二啊……]=],
		[ [=[guidance]=] ]=[=[]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[HomePage]=],
		[ [=[returnPoint]=] ]=1100,
		[ [=[type]=] ]=[=[main]=],
		[ [=[textType]=] ]=[=[S1]=],
		[ [=[desc]=] ]=[=[]=]
	},
	[ [=[1350]=] ]=
	{
		[ [=[text]=] ]=[=[点击开始新的征途。]=],
		[ [=[guidance]=] ]=[=[ToStartGamePage]=],
		[ [=[animation]=] ]=1,
		[ [=[page]=] ]=[=[HomePage]=],
		[ [=[returnPoint]=] ]=1100,
		[ [=[type]=] ]=[=[main]=],
		[ [=[textType]=] ]=[=[S23]=],
		[ [=[desc]=] ]=[=[点击“征途”按钮]=]
	},
	[ [=[1400]=] ]=
	{
		[ [=[text]=] ]=[=[]=],
		[ [=[guidance]=] ]=[=[ToMainLine]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[StartGamePage]=],
		[ [=[returnPoint]=] ]=1100,
		[ [=[type]=] ]=[=[main]=],
		[ [=[textType]=] ]=[=[]=],
		[ [=[desc]=] ]=[=[点击“主线”按钮]=]
	},
	[ [=[1410]=] ]=
	{
		[ [=[text]=] ]=[=[新的赛季开始了。这里就是本赛季的主要对手。我们第一场比赛要主场迎战大河队。做好准备应战吧！]=],
		[ [=[guidance]=] ]=[=[WatchEnemies]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[MainLine]=],
		[ [=[returnPoint]=] ]=1410,
		[ [=[type]=] ]=[=[main]=],
		[ [=[textType]=] ]=[=[C3]=],
		[ [=[desc]=] ]=[=[]=]
	},
	[ [=[1420]=] ]=
	{
		[ [=[text]=] ]=[=[噢噢噢噢！比赛开始啦！]=],
		[ [=[guidance]=] ]=[=[]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[MainLine]=],
		[ [=[returnPoint]=] ]=1410,
		[ [=[type]=] ]=[=[main]=],
		[ [=[textType]=] ]=[=[S1]=],
		[ [=[desc]=] ]=[=[]=]
	},
	[ [=[1500]=] ]=
	{
		[ [=[text]=] ]=[=[点击开始比赛。]=],
		[ [=[guidance]=] ]=[=[QuestEnter]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[MainLine]=],
		[ [=[returnPoint]=] ]=1410,
		[ [=[type]=] ]=[=[main]=],
		[ [=[textType]=] ]=[=[S23]=],
		[ [=[desc]=] ]=[=[点击开始比赛。]=]
	},
	[ [=[1600]=] ]=
	{
		[ [=[text]=] ]=[=[赢得比赛可以获得奖励，奖励可以帮助球员提升实力。]=],
		[ [=[guidance]=] ]=[=[NewCloseQuestReward]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[MainLine]=],
		[ [=[returnPoint]=] ]=2700,
		[ [=[type]=] ]=[=[main]=],
		[ [=[textType]=] ]=[=[S22]=],
		[ [=[desc]=] ]=[=[关闭结算页面。]=]
	},
	[ [=[2700]=] ]=
	{
		[ [=[text]=] ]=[=[这里是球员管理页面，您可以在这里看到全队球员。]=],
		[ [=[guidance]=] ]=[=[ToManagement]=],
		[ [=[animation]=] ]=1,
		[ [=[page]=] ]=[=[MainLine]=],
		[ [=[returnPoint]=] ]=2700,
		[ [=[type]=] ]=[=[main]=],
		[ [=[textType]=] ]=[=[S23]=],
		[ [=[desc]=] ]=[=[点击前往球员管理页面]=]
	},
	[ [=[2800]=] ]=
	{
		[ [=[text]=] ]=[=[]=],
		[ [=[guidance]=] ]=[=[Mdestro1]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[Management]=],
		[ [=[returnPoint]=] ]=2800,
		[ [=[type]=] ]=[=[main]=],
		[ [=[textType]=] ]=[=[]=],
		[ [=[desc]=] ]=[=[点击打开Andycarroll1球员大卡。（第一行第4个）]=]
	},
	[ [=[2900]=] ]=
	{
		[ [=[text]=] ]=[=[用刚才获得的<color=#FFCE00>经验饮料</color>为C罗纳尔多升级。]=],
		[ [=[guidance]=] ]=[=[Lvlup]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[Card]=],
		[ [=[returnPoint]=] ]=2800,
		[ [=[type]=] ]=[=[main]=],
		[ [=[textType]=] ]=[=[S21]=],
		[ [=[desc]=] ]=[=[点击升级按钮]=]
	},
	[ [=[3000]=] ]=
	{
		[ [=[text]=] ]=[=[]=],
		[ [=[guidance]=] ]=[=[UseExp]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[CardLvl]=],
		[ [=[returnPoint]=] ]=2800,
		[ [=[type]=] ]=[=[main]=],
		[ [=[textType]=] ]=[=[]=],
		[ [=[desc]=] ]=[=[使用第二个经验药水（中级）。]=]
	},
	[ [=[3100]=] ]=
	{
		[ [=[text]=] ]=[=[]=],
		[ [=[guidance]=] ]=[=[CloseLvlup]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[CardLvl]=],
		[ [=[returnPoint]=] ]=3200,
		[ [=[type]=] ]=[=[main]=],
		[ [=[textType]=] ]=[=[]=],
		[ [=[desc]=] ]=[=[关闭升级组件]=]
	},
	[ [=[3200]=] ]=
	{
		[ [=[text]=] ]=[=[为球员穿戴<color=#FFCE00>专属装备</color>。]=],
		[ [=[guidance]=] ]=[=[Equip1]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[Card]=],
		[ [=[returnPoint]=] ]=3200,
		[ [=[type]=] ]=[=[main]=],
		[ [=[textType]=] ]=[=[S21]=],
		[ [=[desc]=] ]=[=[点击第一个装备栏位。]=]
	},
	[ [=[3300]=] ]=
	{
		[ [=[text]=] ]=[=[]=],
		[ [=[guidance]=] ]=[=[Equip]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[CardEquip]=],
		[ [=[returnPoint]=] ]=3200,
		[ [=[type]=] ]=[=[main]=],
		[ [=[textType]=] ]=[=[]=],
		[ [=[desc]=] ]=[=[点击装备详情的“装备”按钮。]=]
	},
	[ [=[3350]=] ]=
	{
		[ [=[text]=] ]=[=[同时我们可以为球员进行<color=#FFCE00>一键装备</color>。]=],
		[ [=[guidance]=] ]=[=[Upgrade1]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[card]=],
		[ [=[returnPoint]=] ]=3200,
		[ [=[type]=] ]=[=[main]=],
		[ [=[textType]=] ]=[=[S23]=],
		[ [=[desc]=] ]=[=[点击“一键装备：按钮]=]
	},
	[ [=[3400]=] ]=
	{
		[ [=[text]=] ]=[=[球员穿戴装备后，可以<color=#FFCE00>进阶</color>。进阶后，球员会获得<color=#FFCE00>强力技能</color>。]=],
		[ [=[guidance]=] ]=[=[Upgrade]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[Card]=],
		[ [=[returnPoint]=] ]=3400,
		[ [=[type]=] ]=[=[main]=],
		[ [=[textType]=] ]=[=[S23]=],
		[ [=[desc]=] ]=[=[点击进阶按钮。]=]
	},
	[ [=[3500]=] ]=
	{
		[ [=[text]=] ]=[=[]=],
		[ [=[guidance]=] ]=[=[CloseQuestReward]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[Card]=],
		[ [=[returnPoint]=] ]=3600,
		[ [=[type]=] ]=[=[main]=],
		[ [=[textType]=] ]=[=[]=],
		[ [=[desc]=] ]=[=[关闭进阶成功弹板。]=]
	},
	[ [=[3600]=] ]=
	{
		[ [=[text]=] ]=[=[C罗现在厉害多了，连换水都更有劲啦，让我们快去迎接下一场的比赛吧。]=],
		[ [=[guidance]=] ]=[=[]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[Card]=],
		[ [=[returnPoint]=] ]=3600,
		[ [=[type]=] ]=[=[main]=],
		[ [=[textType]=] ]=[=[S1]=],
		[ [=[desc]=] ]=[=[]=]
	},
	[ [=[3700]=] ]=
	{
		[ [=[text]=] ]=[=[]=],
		[ [=[guidance]=] ]=[=[CloseCard]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[Card]=],
		[ [=[returnPoint]=] ]=3900,
		[ [=[type]=] ]=[=[main]=],
		[ [=[textType]=] ]=[=[]=],
		[ [=[desc]=] ]=[=[关闭球员大卡]=]
	},
	[ [=[3800]=] ]=
	{
		[ [=[text]=] ]=[=[]=],
		[ [=[guidance]=] ]=[=[CloseManagement]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[Management]=],
		[ [=[returnPoint]=] ]=3900,
		[ [=[type]=] ]=[=[main]=],
		[ [=[textType]=] ]=[=[]=],
		[ [=[desc]=] ]=[=[返回主线关卡列表]=]
	},
	[ [=[3900]=] ]=
	{
		[ [=[text]=] ]=[=[这场比赛一定要拿下来，这可是保级对手之间的直接较量。]=],
		[ [=[guidance]=] ]=[=[]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[MainLine]=],
		[ [=[returnPoint]=] ]=3900,
		[ [=[type]=] ]=[=[main]=],
		[ [=[textType]=] ]=[=[C1]=],
		[ [=[desc]=] ]=[=[]=]
	},
	[ [=[4000]=] ]=
	{
		[ [=[text]=] ]=[=[C罗已经掌握了重炮手技能，就让我们期待他的表现吧！]=],
		[ [=[guidance]=] ]=[=[]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[MainLine]=],
		[ [=[returnPoint]=] ]=3900,
		[ [=[type]=] ]=[=[main]=],
		[ [=[textType]=] ]=[=[S1]=],
		[ [=[desc]=] ]=[=[]=]
	},
	[ [=[4100]=] ]=
	{
		[ [=[text]=] ]=[=[]=],
		[ [=[guidance]=] ]=[=[QuestEnter]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[MainLine]=],
		[ [=[returnPoint]=] ]=3900,
		[ [=[type]=] ]=[=[main]=],
		[ [=[textType]=] ]=[=[]=],
		[ [=[desc]=] ]=[=[点击开始比赛。]=]
	},
	[ [=[4200]=] ]=
	{
		[ [=[text]=] ]=[=[]=],
		[ [=[guidance]=] ]=[=[NewCloseQuestReward]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[MainLine]=],
		[ [=[returnPoint]=] ]=4300,
		[ [=[type]=] ]=[=[main]=],
		[ [=[textType]=] ]=[=[]=],
		[ [=[desc]=] ]=[=[关闭结算页面。]=]
	},
	[ [=[4300]=] ]=
	{
		[ [=[text]=] ]=[=[终于拿下了这场关键的胜利。球队的形势有了一些好转。不过连胜的势头并没有持续下去。球队依然处在降级区。]=],
		[ [=[guidance]=] ]=[=[]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[MainLine]=],
		[ [=[returnPoint]=] ]=4300,
		[ [=[type]=] ]=[=[main]=],
		[ [=[textType]=] ]=[=[C1]=],
		[ [=[desc]=] ]=[=[]=]
	},
	[ [=[4400]=] ]=
	{
		[ [=[text]=] ]=[=[大叔，不要担心。人呐，最重要的就是开心。我带你去个能让你开心的地方，嚎~]=],
		[ [=[guidance]=] ]=[=[]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[MainLine]=],
		[ [=[returnPoint]=] ]=4300,
		[ [=[type]=] ]=[=[main]=],
		[ [=[textType]=] ]=[=[S1]=],
		[ [=[desc]=] ]=[=[]=]
	},
	[ [=[4500]=] ]=
	{
		[ [=[text]=] ]=[=[]=],
		[ [=[guidance]=] ]=[=[CloseManagement]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[MainLine]=],
		[ [=[returnPoint]=] ]=4600,
		[ [=[type]=] ]=[=[main]=],
		[ [=[textType]=] ]=[=[]=],
		[ [=[desc]=] ]=[=[]=]
	},
	[ [=[4600]=] ]=
	{
		[ [=[text]=] ]=[=[]=],
		[ [=[guidance]=] ]=[=[ToGacha]=],
		[ [=[animation]=] ]=1,
		[ [=[page]=] ]=[=[HomePage]=],
		[ [=[returnPoint]=] ]=4600,
		[ [=[type]=] ]=[=[main]=],
		[ [=[textType]=] ]=[=[]=],
		[ [=[desc]=] ]=[=[点开抽卡页面]=]
	},
	[ [=[4700]=] ]=
	{
		[ [=[text]=] ]=[=[这里是商店，会有很多强大的球员出没。而且我听说，新手菜鸟教练第一次招募免费哇！不去就亏大了！咕噜噜……]=],
		[ [=[guidance]=] ]=[=[]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[Gacha]=],
		[ [=[returnPoint]=] ]=4600,
		[ [=[type]=] ]=[=[main]=],
		[ [=[textType]=] ]=[=[S1]=],
		[ [=[desc]=] ]=[=[]=]
	},
	[ [=[4800]=] ]=
	{
		[ [=[text]=] ]=[=[你说谁是新手菜鸟教练！我带过那么多世界巨星，还夺……差一点就夺得了世界冠军好不好！]=],
		[ [=[guidance]=] ]=[=[]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[Gacha]=],
		[ [=[returnPoint]=] ]=4600,
		[ [=[type]=] ]=[=[main]=],
		[ [=[textType]=] ]=[=[C1]=],
		[ [=[desc]=] ]=[=[]=]
	},
	[ [=[4900]=] ]=
	{
		[ [=[text]=] ]=[=[现在时代发展得这么快，你又告别了顶级足球舞台这么多年，有些新时代的东西你懂得可能还不如一台饮水机多呢。不服你咬我呀。咕噜噜。]=],
		[ [=[guidance]=] ]=[=[]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[Gacha]=],
		[ [=[returnPoint]=] ]=4600,
		[ [=[type]=] ]=[=[main]=],
		[ [=[textType]=] ]=[=[S1]=],
		[ [=[desc]=] ]=[=[]=]
	},
	[ [=[5000]=] ]=
	{
		[ [=[text]=] ]=[=[点击招募球员，本次免费。]=],
		[ [=[guidance]=] ]=[=[Gacha]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[Gacha]=],
		[ [=[returnPoint]=] ]=4600,
		[ [=[type]=] ]=[=[main]=],
		[ [=[textType]=] ]=[=[S23]=],
		[ [=[desc]=] ]=[=[点击抽卡]=]
	},
	[ [=[5100]=] ]=
	{
		[ [=[text]=] ]=[=[]=],
		[ [=[guidance]=] ]=[=[CloseQuestReward]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[Gacha]=],
		[ [=[returnPoint]=] ]=5300,
		[ [=[type]=] ]=[=[main]=],
		[ [=[textType]=] ]=[=[]=],
		[ [=[desc]=] ]=[=[关闭恭喜获得页面。]=]
	},
	[ [=[5200]=] ]=
	{
		[ [=[text]=] ]=[=[]=],
		[ [=[guidance]=] ]=[=[CloseGacha]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[Gacha]=],
		[ [=[returnPoint]=] ]=5300,
		[ [=[type]=] ]=[=[main]=],
		[ [=[textType]=] ]=[=[]=],
		[ [=[desc]=] ]=[=[点击关闭抽卡页面]=]
	},
	[ [=[5300]=] ]=
	{
		[ [=[text]=] ]=[=[太棒了，超级巨星厄齐尔竟然加盟了我们球队。看来大叔，你还是有点人品的。]=],
		[ [=[guidance]=] ]=[=[]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[HomePage]=],
		[ [=[returnPoint]=] ]=5300,
		[ [=[type]=] ]=[=[main]=],
		[ [=[textType]=] ]=[=[S1]=],
		[ [=[desc]=] ]=[=[]=]
	},
	[ [=[5400]=] ]=
	{
		[ [=[text]=] ]=[=[将厄齐尔排进首发名单。]=],
		[ [=[guidance]=] ]=[=[ToFormation]=],
		[ [=[animation]=] ]=1,
		[ [=[page]=] ]=[=[HomePage]=],
		[ [=[returnPoint]=] ]=5300,
		[ [=[type]=] ]=[=[main]=],
		[ [=[textType]=] ]=[=[S23]=],
		[ [=[desc]=] ]=[=[打开阵型页面]=]
	},
	[ [=[5500]=] ]=
	{
		[ [=[text]=] ]=[=[把下方替补席中的厄齐尔<color=#FFCE00>拖拽</color>至场上。]=],
		[ [=[guidance]=] ]=[=[SwitchCard]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[Fomation]=],
		[ [=[returnPoint]=] ]=5300,
		[ [=[type]=] ]=[=[main]=],
		[ [=[textType]=] ]=[=[S24]=],
		[ [=[desc]=] ]=[=[将新获得的铜卡球员，换到右前锋的位置。]=]
	},
	[ [=[5600]=] ]=
	{
		[ [=[text]=] ]=[=[]=],
		[ [=[guidance]=] ]=[=[SaveFormation]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[Fomation]=],
		[ [=[returnPoint]=] ]=5300,
		[ [=[type]=] ]=[=[main]=],
		[ [=[textType]=] ]=[=[]=],
		[ [=[desc]=] ]=[=[点击保存阵型按钮。]=]
	},
	[ [=[5700]=] ]=
	{
		[ [=[text]=] ]=[=[]=],
		[ [=[guidance]=] ]=[=[CloseFormation]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[Fomation]=],
		[ [=[returnPoint]=] ]=5800,
		[ [=[type]=] ]=[=[main]=],
		[ [=[textType]=] ]=[=[]=],
		[ [=[desc]=] ]=[=[关闭阵型页面。]=]
	},
	[ [=[5800]=] ]=
	{
		[ [=[text]=] ]=[=[啊，这样一来我对周末的比赛就信心百倍了。]=],
		[ [=[guidance]=] ]=[=[]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[HomePage]=],
		[ [=[returnPoint]=] ]=5800,
		[ [=[type]=] ]=[=[main]=],
		[ [=[textType]=] ]=[=[C1]=],
		[ [=[desc]=] ]=[=[]=]
	},
	[ [=[5900]=] ]=
	{
		[ [=[text]=] ]=[=[你都不知道感谢我一下，好吧那你去打吧，再也不帮你忙了。哼~]=],
		[ [=[guidance]=] ]=[=[]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[HomePage]=],
		[ [=[returnPoint]=] ]=5800,
		[ [=[type]=] ]=[=[main]=],
		[ [=[textType]=] ]=[=[S1]=],
		[ [=[desc]=] ]=[=[点击开始比赛。]=]
	},
	[ [=[6000]=] ]=
	{
		[ [=[text]=] ]=[=[]=],
		[ [=[guidance]=] ]=[=[ToStartGamePage]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[HomePage]=],
		[ [=[returnPoint]=] ]=5800,
		[ [=[type]=] ]=[=[main]=],
		[ [=[textType]=] ]=[=[]=],
		[ [=[desc]=] ]=[=[关闭结算页面。]=]
	},
	[ [=[6100]=] ]=
	{
		[ [=[text]=] ]=[=[]=],
		[ [=[guidance]=] ]=[=[ToMainLine]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[StartGamePage]=],
		[ [=[returnPoint]=] ]=5800,
		[ [=[type]=] ]=[=[main]=],
		[ [=[textType]=] ]=[=[]=],
		[ [=[desc]=] ]=[=[点击关闭升级页面。]=]
	},
	[ [=[10500]=] ]=
	{
		[ [=[text]=] ]=[=[咦，这里有一封信啊。饮水机是你帮我签收的吗？]=],
		[ [=[guidance]=] ]=[=[]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[PlayerLetterDetail]=],
		[ [=[returnPoint]=] ]=10500,
		[ [=[type]=] ]=[=[letter]=],
		[ [=[textType]=] ]=[=[C1]=],
		[ [=[desc]=] ]=[=[]=]
	},
	[ [=[10600]=] ]=
	{
		[ [=[text]=] ]=[=[当然，除了我还有谁啊，我是这个俱乐部的头号元老，从前台小妹到打更老头啥都能干，身兼数职，24小时工作，全年无休，从不请假，绝对尽职尽责。咕噜噜……]=],
		[ [=[guidance]=] ]=[=[]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[PlayerLetterDetail]=],
		[ [=[returnPoint]=] ]=10500,
		[ [=[type]=] ]=[=[letter]=],
		[ [=[textType]=] ]=[=[S1]=],
		[ [=[desc]=] ]=[=[]=]
	},
	[ [=[10700]=] ]=
	{
		[ [=[text]=] ]=[=[张玉宁这小子还真的很有志气呢。不枉我在他小时候带了他几个月。现在想加盟球队，居然向我提出了要求啊。]=],
		[ [=[guidance]=] ]=[=[]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[PlayerLetterDetail]=],
		[ [=[returnPoint]=] ]=10500,
		[ [=[type]=] ]=[=[letter]=],
		[ [=[textType]=] ]=[=[C3]=],
		[ [=[desc]=] ]=[=[]=]
	},
	[ [=[10800]=] ]=
	{
		[ [=[text]=] ]=[=[达成条件，来信球员就会加盟球队。]=],
		[ [=[guidance]=] ]=[=[LetterQuest]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[PlayerLetterDetail]=],
		[ [=[returnPoint]=] ]=10500,
		[ [=[type]=] ]=[=[letter]=],
		[ [=[textType]=] ]=[=[S24]=],
		[ [=[desc]=] ]=[=[高亮展示强调来信达成条件]=]
	},
	[ [=[10900]=] ]=
	{
		[ [=[text]=] ]=[=[怎么样，泄气了吧？被晚辈质疑能力，丢脸了吧？完不成目标了吧？！]=],
		[ [=[guidance]=] ]=[=[]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[PlayerLetterDetail]=],
		[ [=[returnPoint]=] ]=10500,
		[ [=[type]=] ]=[=[letter]=],
		[ [=[textType]=] ]=[=[S1]=],
		[ [=[desc]=] ]=[=[]=]
	},
	[ [=[11000]=] ]=
	{
		[ [=[text]=] ]=[=[你到底是哪一伙的……不过他的来信也提醒了我，只要稳扎稳打地提升球队成绩，就会有越来越多的明星球员愿意加入我们！]=],
		[ [=[guidance]=] ]=[=[]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[PlayerLetterDetail]=],
		[ [=[returnPoint]=] ]=10500,
		[ [=[type]=] ]=[=[letter]=],
		[ [=[textType]=] ]=[=[C1]=],
		[ [=[desc]=] ]=[=[]=]
	},
	[ [=[11100]=] ]=
	{
		[ [=[text]=] ]=[=[教练你的中二病又犯了……咕噜噜……]=],
		[ [=[guidance]=] ]=[=[]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[PlayerLetterDetail]=],
		[ [=[returnPoint]=] ]=10500,
		[ [=[type]=] ]=[=[letter]=],
		[ [=[textType]=] ]=[=[S1]=],
		[ [=[desc]=] ]=[=[]=]
	},
	[ [=[20100]=] ]=
	{
		[ [=[text]=] ]=[=[今天天气不错啊……咕噜噜……咕噜噜……]=],
		[ [=[guidance]=] ]=[=[]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[LeagueWelcome]=],
		[ [=[returnPoint]=] ]=20100,
		[ [=[type]=] ]=[=[league]=],
		[ [=[textType]=] ]=[=[S1]=],
		[ [=[desc]=] ]=[=[]=]
	},
	[ [=[20200]=] ]=
	{
		[ [=[text]=] ]=[=[我怎么感觉这里的画风有点不一样啊？]=],
		[ [=[guidance]=] ]=[=[]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[LeagueWelcome]=],
		[ [=[returnPoint]=] ]=20100,
		[ [=[type]=] ]=[=[league]=],
		[ [=[textType]=] ]=[=[C1]=],
		[ [=[desc]=] ]=[=[]=]
	},
	[ [=[20300]=] ]=
	{
		[ [=[text]=] ]=[=[哦，这样啊。我看你在平时的葡萄牙联赛里有点过于轻松了，于是跟几个球员商量了一下，又帮你在这个联赛里报了名。这里你可以和来自世界各地的豪强球队直接较量！是不是很拉风！]=],
		[ [=[guidance]=] ]=[=[]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[LeagueWelcome]=],
		[ [=[returnPoint]=] ]=20100,
		[ [=[type]=] ]=[=[league]=],
		[ [=[textType]=] ]=[=[S1]=],
		[ [=[desc]=] ]=[=[]=]
	},
	[ [=[20310]=] ]=
	{
		[ [=[text]=] ]=[=[拉你妹的风啊，我才是这里的主教练！你就是个饮水机，谁让你这么做的！说，你到底串通了谁！]=],
		[ [=[guidance]=] ]=[=[]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[LeagueWelcome]=],
		[ [=[returnPoint]=] ]=20100,
		[ [=[type]=] ]=[=[league]=],
		[ [=[textType]=] ]=[=[C1]=],
		[ [=[desc]=] ]=[=[]=]
	},
	[ [=[20320]=] ]=
	{
		[ [=[text]=] ]=[=[咕噜噜……咕噜噜……]=],
		[ [=[guidance]=] ]=[=[]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[LeagueWelcome]=],
		[ [=[returnPoint]=] ]=20100,
		[ [=[type]=] ]=[=[league]=],
		[ [=[textType]=] ]=[=[S1]=],
		[ [=[desc]=] ]=[=[]=]
	},
	[ [=[20330]=] ]=
	{
		[ [=[text]=] ]=[=[……]=],
		[ [=[guidance]=] ]=[=[]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[LeagueWelcome]=],
		[ [=[returnPoint]=] ]=20100,
		[ [=[type]=] ]=[=[league]=],
		[ [=[textType]=] ]=[=[C1]=],
		[ [=[desc]=] ]=[=[]=]
	},
	[ [=[20340]=] ]=
	{
		[ [=[text]=] ]=[=[咕噜噜……咕噜噜……]=],
		[ [=[guidance]=] ]=[=[]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[LeagueWelcome]=],
		[ [=[returnPoint]=] ]=20100,
		[ [=[type]=] ]=[=[league]=],
		[ [=[textType]=] ]=[=[S1]=],
		[ [=[desc]=] ]=[=[]=]
	},
	[ [=[20350]=] ]=
	{
		[ [=[text]=] ]=[=[……]=],
		[ [=[guidance]=] ]=[=[]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[LeagueWelcome]=],
		[ [=[returnPoint]=] ]=20100,
		[ [=[type]=] ]=[=[league]=],
		[ [=[textType]=] ]=[=[C1]=],
		[ [=[desc]=] ]=[=[]=]
	},
	[ [=[20360]=] ]=
	{
		[ [=[text]=] ]=[=[咕噜噜……咕噜噜……]=],
		[ [=[guidance]=] ]=[=[]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[LeagueWelcome]=],
		[ [=[returnPoint]=] ]=20100,
		[ [=[type]=] ]=[=[league]=],
		[ [=[textType]=] ]=[=[S1]=],
		[ [=[desc]=] ]=[=[]=]
	},
	[ [=[20370]=] ]=
	{
		[ [=[text]=] ]=[=[好了我真服了你了。也罢也罢，反正要称霸世界，早晚也要踏出这么一步。]=],
		[ [=[guidance]=] ]=[=[]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[LeagueWelcome]=],
		[ [=[returnPoint]=] ]=20100,
		[ [=[type]=] ]=[=[league]=],
		[ [=[textType]=] ]=[=[C1]=],
		[ [=[desc]=] ]=[=[]=]
	},
	[ [=[20400]=] ]=
	{
		[ [=[text]=] ]=[=[呼，一场虚惊。那我来给你简单介绍一下吧。这里的联赛分有不同级别，在当前级别夺冠才有机会升入更高级联赛。一步步向着顶峰迈进吧。现在你知道感谢我了吧？]=],
		[ [=[guidance]=] ]=[=[]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[LeagueWelcome]=],
		[ [=[returnPoint]=] ]=20100,
		[ [=[type]=] ]=[=[league]=],
		[ [=[textType]=] ]=[=[S1]=],
		[ [=[desc]=] ]=[=[]=]
	},
	[ [=[20500]=] ]=
	{
		[ [=[text]=] ]=[=[]=],
		[ [=[guidance]=] ]=[=[CloseQuestReward]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[LeagueWelcome]=],
		[ [=[returnPoint]=] ]=20100,
		[ [=[type]=] ]=[=[league]=],
		[ [=[textType]=] ]=[=[]=],
		[ [=[desc]=] ]=[=[点击进入联赛欢迎第二页]=]
	},
	[ [=[20600]=] ]=
	{
		[ [=[text]=] ]=[=[没把你拆了卖废品算不错了，还有脸让我感谢。那个，这些球队就是我们这个赛季的竞争对手了吧？]=],
		[ [=[guidance]=] ]=[=[]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[LeagueWelcomeInfo]=],
		[ [=[returnPoint]=] ]=20100,
		[ [=[type]=] ]=[=[league]=],
		[ [=[textType]=] ]=[=[C1]=],
		[ [=[desc]=] ]=[=[]=]
	},
	[ [=[20700]=] ]=
	{
		[ [=[text]=] ]=[=[嗯对，让他们看看我们的厉害吧。如果拿到好名次的话，奖金也是很丰厚的，到时候可以好好升级一下你办公室的设备了，搞个好看点的传真机妹子啥的，没事还能陪我聊聊天。]=],
		[ [=[guidance]=] ]=[=[]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[LeagueWelcomeInfo]=],
		[ [=[returnPoint]=] ]=20100,
		[ [=[type]=] ]=[=[league]=],
		[ [=[textType]=] ]=[=[S1]=],
		[ [=[desc]=] ]=[=[]=]
	},
	[ [=[20750]=] ]=
	{
		[ [=[text]=] ]=[=[嗯，等到时候第一个把你换掉，拿去卖废品。]=],
		[ [=[guidance]=] ]=[=[]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[]=],
		[ [=[returnPoint]=] ]=20100,
		[ [=[type]=] ]=[=[league]=],
		[ [=[textType]=] ]=[=[C1]=],
		[ [=[desc]=] ]=[=[]=]
	},
	[ [=[20800]=] ]=
	{
		[ [=[text]=] ]=[=[]=],
		[ [=[guidance]=] ]=[=[CloseQuestReward]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[LeagueWelcomeInfo]=],
		[ [=[returnPoint]=] ]=20100,
		[ [=[type]=] ]=[=[league]=],
		[ [=[textType]=] ]=[=[]=],
		[ [=[desc]=] ]=[=[点击进入赞助商选择]=]
	},
	[ [=[20900]=] ]=
	{
		[ [=[text]=] ]=[=[我知道你舍不得的。再跟你说一下赞助商的事情吧。现在有两家企业向我们提出了本赛季的赞助意向，只要在赛季内达成赞助商的要求就能获得可观的赞助费了。你来选一选吧。]=],
		[ [=[guidance]=] ]=[=[]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[LeagueSponsor]=],
		[ [=[returnPoint]=] ]=20100,
		[ [=[type]=] ]=[=[league]=],
		[ [=[textType]=] ]=[=[S1]=],
		[ [=[desc]=] ]=[=[]=]
	},
	[ [=[21000]=] ]=
	{
		[ [=[text]=] ]=[=[有企业想赞助我们一台新的饮水机吗？我真的很想换一台……]=],
		[ [=[guidance]=] ]=[=[]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[LeagueSponsor]=],
		[ [=[returnPoint]=] ]=20100,
		[ [=[type]=] ]=[=[league]=],
		[ [=[textType]=] ]=[=[C1]=],
		[ [=[desc]=] ]=[=[]=]
	},
	[ [=[21100]=] ]=
	{
		[ [=[text]=] ]=[=[]=],
		[ [=[guidance]=] ]=[=[ChooseSponsor]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[LeagueSponsor]=],
		[ [=[returnPoint]=] ]=20100,
		[ [=[type]=] ]=[=[league]=],
		[ [=[textType]=] ]=[=[]=],
		[ [=[desc]=] ]=[=[选择赞助商]=]
	},
	[ [=[21200]=] ]=
	{
		[ [=[text]=] ]=[=[好了，签了赞助商，报名的手续已经完全搞定啦……咕噜噜……咕噜噜……]=],
		[ [=[guidance]=] ]=[=[]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[LeagueMain]=],
		[ [=[returnPoint]=] ]=21200,
		[ [=[type]=] ]=[=[league]=],
		[ [=[textType]=] ]=[=[S1]=],
		[ [=[desc]=] ]=[=[]=]
	},
	[ [=[21300]=] ]=
	{
		[ [=[text]=] ]=[=[点这里就能开始联赛的征程了，真人对战哦，别被打得妈都不认识就好啦……]=],
		[ [=[guidance]=] ]=[=[LeagueMatchStart]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[LeagueMain]=],
		[ [=[returnPoint]=] ]=21200,
		[ [=[type]=] ]=[=[league]=],
		[ [=[textType]=] ]=[=[S1c]=],
		[ [=[desc]=] ]=[=[高亮强调开始下场比赛按钮]=]
	},
	[ [=[21400]=] ]=
	{
		[ [=[text]=] ]=[=[你等着，我去联系废品收购站……]=],
		[ [=[guidance]=] ]=[=[]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[LeagueMain]=],
		[ [=[returnPoint]=] ]=21200,
		[ [=[type]=] ]=[=[league]=],
		[ [=[textType]=] ]=[=[C1]=],
		[ [=[desc]=] ]=[=[]=]
	},
	[ [=[21500]=] ]=
	{
		[ [=[text]=] ]=[=[今天天气不错哈……咕噜噜……咕噜噜……]=],
		[ [=[guidance]=] ]=[=[]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[LeagueMain]=],
		[ [=[returnPoint]=] ]=21200,
		[ [=[type]=] ]=[=[league]=],
		[ [=[textType]=] ]=[=[S1]=],
		[ [=[desc]=] ]=[=[]=]
	},
	[ [=[30100]=] ]=
	{
		[ [=[text]=] ]=[=[这里就是转会市场了哈。]=],
		[ [=[guidance]=] ]=[=[]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[TransferMarket]=],
		[ [=[returnPoint]=] ]=30100,
		[ [=[type]=] ]=[=[transfermarket]=],
		[ [=[textType]=] ]=[=[C1]=],
		[ [=[desc]=] ]=[=[]=]
	},
	[ [=[30200]=] ]=
	{
		[ [=[text]=] ]=[=[我为什么也会出现在这里……咕噜噜……]=],
		[ [=[guidance]=] ]=[=[]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[TransferMarket]=],
		[ [=[returnPoint]=] ]=30100,
		[ [=[type]=] ]=[=[transfermarket]=],
		[ [=[textType]=] ]=[=[S1]=],
		[ [=[desc]=] ]=[=[]=]
	},
	[ [=[30210]=] ]=
	{
		[ [=[text]=] ]=[=[是啊，为啥我会带着饮水机一起来转会市场啊？喂！游戏策划你脑残吧？这样显得我很白痴哎！]=],
		[ [=[guidance]=] ]=[=[]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[TransferMarket]=],
		[ [=[returnPoint]=] ]=30100,
		[ [=[type]=] ]=[=[transfermarket]=],
		[ [=[textType]=] ]=[=[C1]=],
		[ [=[desc]=] ]=[=[]=]
	},
	[ [=[30220]=] ]=
	{
		[ [=[text]=] ]=[=[（游戏策划：哦，不好意思，这段是我当初熬夜写出来的，大意了。）]=],
		[ [=[guidance]=] ]=[=[]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[TransferMarket]=],
		[ [=[returnPoint]=] ]=30100,
		[ [=[type]=] ]=[=[transfermarket]=],
		[ [=[textType]=] ]=[=[C1]=],
		[ [=[desc]=] ]=[=[]=]
	},
	[ [=[30230]=] ]=
	{
		[ [=[text]=] ]=[=[要不……没什么事我先回去了？]=],
		[ [=[guidance]=] ]=[=[]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[TransferMarket]=],
		[ [=[returnPoint]=] ]=30100,
		[ [=[type]=] ]=[=[transfermarket]=],
		[ [=[textType]=] ]=[=[S1]=],
		[ [=[desc]=] ]=[=[]=]
	},
	[ [=[30240]=] ]=
	{
		[ [=[text]=] ]=[=[别别别，来都来了，简单跟我说一下吧，阔别职业足球这么多年，我也不是很懂现在的转会市场是怎么操作的了。时代发展得太快了啊。]=],
		[ [=[guidance]=] ]=[=[]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[TransferMarket]=],
		[ [=[returnPoint]=] ]=30100,
		[ [=[type]=] ]=[=[transfermarket]=],
		[ [=[textType]=] ]=[=[C1]=],
		[ [=[desc]=] ]=[=[]=]
	},
	[ [=[30250]=] ]=
	{
		[ [=[text]=] ]=[=[哈哈，嘲笑你的时间又到了，新手菜鸟教练。]=],
		[ [=[guidance]=] ]=[=[]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[TransferMarket]=],
		[ [=[returnPoint]=] ]=30100,
		[ [=[type]=] ]=[=[transfermarket]=],
		[ [=[textType]=] ]=[=[S1]=],
		[ [=[desc]=] ]=[=[]=]
	},
	[ [=[30260]=] ]=
	{
		[ [=[text]=] ]=[=[……]=],
		[ [=[guidance]=] ]=[=[]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[TransferMarket]=],
		[ [=[returnPoint]=] ]=30100,
		[ [=[type]=] ]=[=[transfermarket]=],
		[ [=[textType]=] ]=[=[C1]=],
		[ [=[desc]=] ]=[=[]=]
	},
	[ [=[30270]=] ]=
	{
		[ [=[text]=] ]=[=[简单地来说，随着联赛等级的提升，呃，就是我给你报名的那个真人联赛哈，转会市场的等级也会随着提高。想要引入强援的话，你得努力在联赛里取得好成绩才行。]=],
		[ [=[guidance]=] ]=[=[]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[TransferMarket]=],
		[ [=[returnPoint]=] ]=30100,
		[ [=[type]=] ]=[=[transfermarket]=],
		[ [=[textType]=] ]=[=[S1]=],
		[ [=[desc]=] ]=[=[]=]
	},
	[ [=[30300]=] ]=
	{
		[ [=[text]=] ]=[=[嗯，在联赛中赚取资金，在转会市场里合理利用，有针对性地引进强援是我们球队快速提升的关键啊。]=],
		[ [=[guidance]=] ]=[=[TMPlayer]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[TransferMarket]=],
		[ [=[returnPoint]=] ]=30100,
		[ [=[type]=] ]=[=[transfermarket]=],
		[ [=[textType]=] ]=[=[C3]=],
		[ [=[desc]=] ]=[=[高亮强调转会球员列表]=]
	},
	[ [=[30500]=] ]=
	{
		[ [=[text]=] ]=[=[看来你虽然头发不多了但智商还在啊。那个，转会球员列表是可以刷新的，如果看不到特别心仪的球员，可以刷新试试……咕噜噜……]=],
		[ [=[guidance]=] ]=[=[TMRefresh]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[TransferMarket]=],
		[ [=[returnPoint]=] ]=30100,
		[ [=[type]=] ]=[=[transfermarket]=],
		[ [=[textType]=] ]=[=[S1c]=],
		[ [=[desc]=] ]=[=[高亮强调【刷新】按钮]=]
	},
	[ [=[30700]=] ]=
	{
		[ [=[text]=] ]=[=[好的懂了。一会儿我还得想办法把你这台饮水机抬回办公室去……脑残策划我跟你没完……]=],
		[ [=[guidance]=] ]=[=[]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[TransferMarket]=],
		[ [=[returnPoint]=] ]=30100,
		[ [=[type]=] ]=[=[transfermarket]=],
		[ [=[textType]=] ]=[=[C1]=],
		[ [=[desc]=] ]=[=[]=]
	},
	[ [=[40100]=] ]=
	{
		[ [=[text]=] ]=[=[听说你刚刚为我们的球队盖了一块专属的训练基地啊，不错，挺能干的。]=],
		[ [=[guidance]=] ]=[=[]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[Training]=],
		[ [=[returnPoint]=] ]=40100,
		[ [=[type]=] ]=[=[training]=],
		[ [=[textType]=] ]=[=[S1]=],
		[ [=[desc]=] ]=[=[]=]
	},
	[ [=[40200]=] ]=
	{
		[ [=[text]=] ]=[=[嗯。通过训练能获得训练点数，是让现有球员快速提高的好方法。现在是为球员指定训练项目的时间了啊。你有什么建议吗？]=],
		[ [=[guidance]=] ]=[=[]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[Training]=],
		[ [=[returnPoint]=] ]=40100,
		[ [=[type]=] ]=[=[training]=],
		[ [=[textType]=] ]=[=[C1]=],
		[ [=[desc]=] ]=[=[]=]
	},
	[ [=[40300]=] ]=
	{
		[ [=[text]=] ]=[=[呦，这次是你主动向我求助啊。真的感觉自己越来越不可或缺了呢……咕噜噜。]=],
		[ [=[guidance]=] ]=[=[]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[Training]=],
		[ [=[returnPoint]=] ]=40100,
		[ [=[type]=] ]=[=[training]=],
		[ [=[textType]=] ]=[=[S1]=],
		[ [=[desc]=] ]=[=[]=]
	},
	[ [=[40350]=] ]=
	{
		[ [=[text]=] ]=[=[这叫不耻下问。]=],
		[ [=[guidance]=] ]=[=[]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[Training]=],
		[ [=[returnPoint]=] ]=40100,
		[ [=[type]=] ]=[=[training]=],
		[ [=[textType]=] ]=[=[C1]=],
		[ [=[desc]=] ]=[=[]=]
	},
	[ [=[40400]=] ]=
	{
		[ [=[text]=] ]=[=[下……问……总觉得怪怪的……]=],
		[ [=[guidance]=] ]=[=[]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[Training]=],
		[ [=[returnPoint]=] ]=40100,
		[ [=[type]=] ]=[=[training]=],
		[ [=[textType]=] ]=[=[S1]=],
		[ [=[desc]=] ]=[=[]=]
	},
	[ [=[40500]=] ]=
	{
		[ [=[text]=] ]=[=[我想想哈，就这样吧，前锋就进行射门训练，中场来说的话球感比较重要，就进行颠球训练吧，后卫的话，我们总被对手打反击，回追速度很重要啊，进行回追训练，门将就做基础的扑救训练吧！]=],
		[ [=[guidance]=] ]=[=[TrainingType]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[Training]=],
		[ [=[returnPoint]=] ]=40100,
		[ [=[type]=] ]=[=[training]=],
		[ [=[textType]=] ]=[=[S1b]=],
		[ [=[desc]=] ]=[=[高亮强调四种训练]=]
	},
	[ [=[40700]=] ]=
	{
		[ [=[text]=] ]=[=[……]=],
		[ [=[guidance]=] ]=[=[]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[Training]=],
		[ [=[returnPoint]=] ]=40100,
		[ [=[type]=] ]=[=[training]=],
		[ [=[textType]=] ]=[=[C1]=],
		[ [=[desc]=] ]=[=[]=]
	},
	[ [=[40800]=] ]=
	{
		[ [=[text]=] ]=[=[啊……好紧张……我说错什么了吗……咕噜噜……]=],
		[ [=[guidance]=] ]=[=[]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[Training]=],
		[ [=[returnPoint]=] ]=40100,
		[ [=[type]=] ]=[=[training]=],
		[ [=[textType]=] ]=[=[S1]=],
		[ [=[desc]=] ]=[=[]=]
	},
	[ [=[40900]=] ]=
	{
		[ [=[text]=] ]=[=[……]=],
		[ [=[guidance]=] ]=[=[]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[Training]=],
		[ [=[returnPoint]=] ]=40100,
		[ [=[type]=] ]=[=[training]=],
		[ [=[textType]=] ]=[=[C1]=],
		[ [=[desc]=] ]=[=[]=]
	},
	[ [=[41000]=] ]=
	{
		[ [=[text]=] ]=[=[完了完了……要发火了……]=],
		[ [=[guidance]=] ]=[=[]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[Training]=],
		[ [=[returnPoint]=] ]=40100,
		[ [=[type]=] ]=[=[training]=],
		[ [=[textType]=] ]=[=[S1]=],
		[ [=[desc]=] ]=[=[]=]
	},
	[ [=[41100]=] ]=
	{
		[ [=[text]=] ]=[=[太出色了！]=],
		[ [=[guidance]=] ]=[=[]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[Training]=],
		[ [=[returnPoint]=] ]=40100,
		[ [=[type]=] ]=[=[training]=],
		[ [=[textType]=] ]=[=[C1]=],
		[ [=[desc]=] ]=[=[]=]
	},
	[ [=[41200]=] ]=
	{
		[ [=[text]=] ]=[=[啊？]=],
		[ [=[guidance]=] ]=[=[]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[Training]=],
		[ [=[returnPoint]=] ]=40100,
		[ [=[type]=] ]=[=[training]=],
		[ [=[textType]=] ]=[=[S1]=],
		[ [=[desc]=] ]=[=[]=]
	},
	[ [=[41300]=] ]=
	{
		[ [=[text]=] ]=[=[跟我预想中的一模一样！甚至还要更好！就按你说的办！]=],
		[ [=[guidance]=] ]=[=[]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[Training]=],
		[ [=[returnPoint]=] ]=40100,
		[ [=[type]=] ]=[=[training]=],
		[ [=[textType]=] ]=[=[C1]=],
		[ [=[desc]=] ]=[=[]=]
	},
	[ [=[41400]=] ]=
	{
		[ [=[text]=] ]=[=[一惊一乍的，吓死我了……记住，每种训练只有擅长此位置的球员才能参加，训练成绩出色的话还可以获得更多的技能点数哇！]=],
		[ [=[guidance]=] ]=[=[]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[Training]=],
		[ [=[returnPoint]=] ]=40100,
		[ [=[type]=] ]=[=[training]=],
		[ [=[textType]=] ]=[=[S1]=],
		[ [=[desc]=] ]=[=[]=]
	},
	[ [=[41500]=] ]=
	{
		[ [=[text]=] ]=[=[知道了，我去训练场了，你把制冷功能打开，一会儿回来我要喝冰水！]=],
		[ [=[guidance]=] ]=[=[]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[Training]=],
		[ [=[returnPoint]=] ]=40100,
		[ [=[type]=] ]=[=[training]=],
		[ [=[textType]=] ]=[=[C1]=],
		[ [=[desc]=] ]=[=[]=]
	},
	[ [=[41600]=] ]=
	{
		[ [=[text]=] ]=[=[不带我一起去吗？忘恩负义……咕噜噜……咕噜噜……]=],
		[ [=[guidance]=] ]=[=[]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[Training]=],
		[ [=[returnPoint]=] ]=40100,
		[ [=[type]=] ]=[=[training]=],
		[ [=[textType]=] ]=[=[S1]=],
		[ [=[desc]=] ]=[=[]=]
	},
	[ [=[50100]=] ]=
	{
		[ [=[text]=] ]=[=[球队发展的不错，终于拥有自己的主场了。]=],
		[ [=[guidance]=] ]=[=[]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[Court]=],
		[ [=[returnPoint]=] ]=50100,
		[ [=[type]=] ]=[=[court]=],
		[ [=[textType]=] ]=[=[C1]=],
		[ [=[desc]=] ]=[=[]=]
	},
	[ [=[50200]=] ]=
	{
		[ [=[text]=] ]=[=[]=],
		[ [=[guidance]=] ]=[=[EnterCourt]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[Court]=],
		[ [=[returnPoint]=] ]=50100,
		[ [=[type]=] ]=[=[court]=],
		[ [=[textType]=] ]=[=[]=],
		[ [=[desc]=] ]=[=[点击进入体育场]=]
	},
	[ [=[50300]=] ]=
	{
		[ [=[text]=] ]=[=[升级体育场和附属设施可以提高联赛比赛的<color=#FFCE00>主场收入</color>哦。教练，你第一次来。带你体验一下吧。]=],
		[ [=[guidance]=] ]=[=[]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[StadiumLevelUp]=],
		[ [=[returnPoint]=] ]=50100,
		[ [=[type]=] ]=[=[court]=],
		[ [=[textType]=] ]=[=[S1]=],
		[ [=[desc]=] ]=[=[]=]
	},
	[ [=[50400]=] ]=
	{
		[ [=[text]=] ]=[=[]=],
		[ [=[guidance]=] ]=[=[CourtStore]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[StadiumLevelUp]=],
		[ [=[returnPoint]=] ]=50100,
		[ [=[type]=] ]=[=[court]=],
		[ [=[textType]=] ]=[=[]=],
		[ [=[desc]=] ]=[=[点击打开零售商店页面]=]
	},
	[ [=[50500]=] ]=
	{
		[ [=[text]=] ]=[=[点击升级按钮，提升零售商店等级。本次免费。]=],
		[ [=[guidance]=] ]=[=[BuildingLevelUp]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[SubsidiaryBuildLevelUp]=],
		[ [=[returnPoint]=] ]=50100,
		[ [=[type]=] ]=[=[court]=],
		[ [=[textType]=] ]=[=[S21]=],
		[ [=[desc]=] ]=[=[点击升级按钮]=]
	},
	[ [=[50600]=] ]=
	{
		[ [=[text]=] ]=[=[点击立即完成按钮。本次免费。]=],
		[ [=[guidance]=] ]=[=[HurryUp]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[SubsidiaryBuildLevelUp]=],
		[ [=[returnPoint]=] ]=50600,
		[ [=[type]=] ]=[=[court]=],
		[ [=[textType]=] ]=[=[S21]=],
		[ [=[desc]=] ]=[=[点击立即完成]=]
	},
	[ [=[50700]=] ]=
	{
		[ [=[text]=] ]=[=[]=],
		[ [=[guidance]=] ]=[=[LevelUpConfirm]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[SubsidiaryBuildLevelUp]=],
		[ [=[returnPoint]=] ]=51000,
		[ [=[type]=] ]=[=[court]=],
		[ [=[textType]=] ]=[=[]=],
		[ [=[desc]=] ]=[=[关闭升级成功弹板（目前缺失）]=]
	},
	[ [=[50800]=] ]=
	{
		[ [=[text]=] ]=[=[]=],
		[ [=[guidance]=] ]=[=[CloseStore]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[SubsidiaryBuildLevelUp]=],
		[ [=[returnPoint]=] ]=51000,
		[ [=[type]=] ]=[=[court]=],
		[ [=[textType]=] ]=[=[]=],
		[ [=[desc]=] ]=[=[关闭零售商店页面]=]
	},
	[ [=[50900]=] ]=
	{
		[ [=[text]=] ]=[=[]=],
		[ [=[guidance]=] ]=[=[CloseCourt]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[StadiumLevelUp]=],
		[ [=[returnPoint]=] ]=51000,
		[ [=[type]=] ]=[=[court]=],
		[ [=[textType]=] ]=[=[]=],
		[ [=[desc]=] ]=[=[关闭体育场页面]=]
	},
	[ [=[51000]=] ]=
	{
		[ [=[text]=] ]=[=[球探社的等级影响转会市场可以招募到的球员哦。]=],
		[ [=[guidance]=] ]=[=[]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[Court]=],
		[ [=[returnPoint]=] ]=51000,
		[ [=[type]=] ]=[=[court]=],
		[ [=[textType]=] ]=[=[S1]=],
		[ [=[desc]=] ]=[=[]=]
	},
	[ [=[51100]=] ]=
	{
		[ [=[text]=] ]=[=[]=],
		[ [=[guidance]=] ]=[=[EnterScout]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[Court]=],
		[ [=[returnPoint]=] ]=51000,
		[ [=[type]=] ]=[=[court]=],
		[ [=[textType]=] ]=[=[]=],
		[ [=[desc]=] ]=[=[点击进入球探社]=]
	},
	[ [=[51200]=] ]=
	{
		[ [=[text]=] ]=[=[不过想要升级球探社，联赛需要晋级到更高的级别才行啊。]=],
		[ [=[guidance]=] ]=[=[]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[ScoutLevelUp]=],
		[ [=[returnPoint]=] ]=51000,
		[ [=[type]=] ]=[=[court]=],
		[ [=[textType]=] ]=[=[S1]=],
		[ [=[desc]=] ]=[=[]=]
	},
	[ [=[51300]=] ]=
	{
		[ [=[text]=] ]=[=[]=],
		[ [=[guidance]=] ]=[=[PlayerList]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[ScoutLevelUp]=],
		[ [=[returnPoint]=] ]=51000,
		[ [=[type]=] ]=[=[court]=],
		[ [=[textType]=] ]=[=[]=],
		[ [=[desc]=] ]=[=[点击进入球员转会解锁]=]
	},
	[ [=[51400]=] ]=
	{
		[ [=[text]=] ]=[=[这里可以看到不同球探社等级解锁的转会球员哦。下面就交给你自己探索了。]=],
		[ [=[guidance]=] ]=[=[]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[ScoutPlayerInfo]=],
		[ [=[returnPoint]=] ]=51000,
		[ [=[type]=] ]=[=[court]=],
		[ [=[textType]=] ]=[=[S1]=],
		[ [=[desc]=] ]=[=[]=]
	},
	[ [=[70100]=] ]=
	{
		[ [=[text]=] ]=[=[咕噜噜~我又回来啦！这次回归，为各位经理人们带来了全新的大地图探索玩法——绿茵征途，让我们来了解一下基本的玩法吧！]=],
		[ [=[guidance]=] ]=[=[]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[]=],
		[ [=[returnPoint]=] ]=70100,
		[ [=[type]=] ]=[=[adventureF1]=],
		[ [=[textType]=] ]=[=[S1]=],
		[ [=[desc]=] ]=[=[起点处]=]
	},
	[ [=[70200]=] ]=
	{
		[ [=[text]=] ]=[=[大地图上会有很多迷雾地块，迷雾地块是无法解锁的。]=],
		[ [=[guidance]=] ]=[=[Adventure/GridGuide]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[]=],
		[ [=[returnPoint]=] ]=70100,
		[ [=[type]=] ]=[=[adventureF1]=],
		[ [=[textType]=] ]=[=[S1b]=],
		[ [=[desc]=] ]=[=[将地图上的一块白雾用引导框框起来]=]
	},
	[ [=[70300]=] ]=
	{
		[ [=[text]=] ]=[=[当迷雾地块四周有被解锁出来的地块后，迷雾地块会转变为可解锁的状态，此时点击迷雾会消散掉，就可以看到隐藏在底下的事件啦！
那些<color=#FFCE00>彩色的迷雾，就是可以解锁的迷雾</color>，要牢牢记住哦~]=],
		[ [=[guidance]=] ]=[=[Adventure/GridGuide]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[]=],
		[ [=[returnPoint]=] ]=70100,
		[ [=[type]=] ]=[=[adventureF1]=],
		[ [=[textType]=] ]=[=[S1b]=],
		[ [=[desc]=] ]=[=[将地图上的一块彩雾用引导框框起来]=]
	},
	[ [=[70301]=] ]=
	{
		[ [=[text]=] ]=[=[咕噜噜~这里是各位经理人的士气值。<color=#FFCE00>解锁迷雾和完成事件会消耗士气</color>，可是相当珍贵的呢~]=],
		[ [=[guidance]=] ]=[=[Adventure/MoraleGuide]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[]=],
		[ [=[returnPoint]=] ]=70301,
		[ [=[type]=] ]=[=[adventureF1]=],
		[ [=[textType]=] ]=[=[S1b]=],
		[ [=[desc]=] ]=[=[将上面的士气资源条用引导框框起来]=]
	},
	[ [=[70302]=] ]=
	{
		[ [=[text]=] ]=[=[征途中会进入不同的周期，<color=#FFCE00>每个周期内大地图都将受到固定的天气和星象影响。</color>
天气会影响比赛内的球员技能等级，而星象则会带来很多随机的变化，比如消耗士气的增减、球队属性的增减等等。<color=#FFCE00>合理的利用星象效果，能够更好的通关！</color>]=],
		[ [=[guidance]=] ]=[=[Adventure/StarGuide]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[]=],
		[ [=[returnPoint]=] ]=70302,
		[ [=[type]=] ]=[=[adventureF1]=],
		[ [=[textType]=] ]=[=[S1b]=],
		[ [=[desc]=] ]=[=[将左面周期天气星象那块用引导框框起来]=]
	},
	[ [=[70400]=] ]=
	{
		[ [=[text]=] ]=[=[来到终点啦~征途一共有9层，击败每一层终点处的<color=#FFCE00>王牌经理人</color>，就可以进入下一层探索啦！]=],
		[ [=[guidance]=] ]=[=[Adventure/GridGuide]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[]=],
		[ [=[returnPoint]=] ]=70400,
		[ [=[type]=] ]=[=[adventureF1]=],
		[ [=[textType]=] ]=[=[S1b]=],
		[ [=[desc]=] ]=[=[将王牌经理人用引导框框起来]=]
	},
	[ [=[70500]=] ]=
	{
		[ [=[text]=] ]=[=[咕噜噜~基本的操作介绍完毕啦，更多的乐趣就等着各位经理人自己探索啦！开始征程，Go!Go!Go!]=],
		[ [=[guidance]=] ]=[=[Adventure/GridSwitch]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[]=],
		[ [=[returnPoint]=] ]=70500,
		[ [=[type]=] ]=[=[adventureF1]=],
		[ [=[textType]=] ]=[=[S1]=],
		[ [=[desc]=] ]=[=[拉回起点处]=]
	},
	[ [=[70600]=] ]=
	{
		[ [=[text]=] ]=[=[咕噜噜~，这一层开始，有个叫<color=#FFCE00>拦路者</color>的家伙出现啦，会给我们带来不少的麻烦呢，让我看看他在哪~]=],
		[ [=[guidance]=] ]=[=[]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[]=],
		[ [=[returnPoint]=] ]=70600,
		[ [=[type]=] ]=[=[adventureF2]=],
		[ [=[textType]=] ]=[=[S1]=],
		[ [=[desc]=] ]=[=[起点处]=]
	},
	[ [=[70700]=] ]=
	{
		[ [=[text]=] ]=[=[]=],
		[ [=[guidance]=] ]=[=[Adventure/GridGuide]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[]=],
		[ [=[returnPoint]=] ]=70600,
		[ [=[type]=] ]=[=[adventureF2]=],
		[ [=[textType]=] ]=[=[]=],
		[ [=[desc]=] ]=[=[引导手指指向一个拦路者图标，引导玩家点开面板]=]
	},
	[ [=[70800]=] ]=
	{
		[ [=[text]=] ]=[=[发现啦，原来躲在这！拦路者自身携带特殊效果：<color=#FFCE00>每过一定回合，降低挑战者一定士气！</color>
战胜拦路者后，这个负面效果自然也就消失啦，各位经理人要多多注意哦~咕噜噜~]=],
		[ [=[guidance]=] ]=[=[Adventure/EffectGuide]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[]=],
		[ [=[returnPoint]=] ]=70600,
		[ [=[type]=] ]=[=[adventureF2]=],
		[ [=[textType]=] ]=[=[S1b]=],
		[ [=[desc]=] ]=[=[将特殊效果那块用引导框框起来]=]
	},
	[ [=[70900]=] ]=
	{
		[ [=[text]=] ]=[=[咕噜噜~，来到第3层啦，真是厉害呢！这一层开始，地图上可能会出现叫<color=#FFCE00>经理人助理</color>的家伙，就是王牌经理人的忠实跟班儿啦~]=],
		[ [=[guidance]=] ]=[=[]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[]=],
		[ [=[returnPoint]=] ]=70900,
		[ [=[type]=] ]=[=[adventureF3]=],
		[ [=[textType]=] ]=[=[S1]=],
		[ [=[desc]=] ]=[=[起点处]=]
	},
	[ [=[71000]=] ]=
	{
		[ [=[text]=] ]=[=[经理人助理会藏在漩涡迷雾下，<color=#FFCE00>有他们出现的楼层，需要根据特殊要求，将所有的经理人助理都击败，之后才能挑战王牌经理人！</color>
具体的击杀要求，还请各位经理人自行探索吧~咕噜噜~]=],
		[ [=[guidance]=] ]=[=[Adventure/GridGuide]=],
		[ [=[animation]=] ]=0,
		[ [=[page]=] ]=[=[]=],
		[ [=[returnPoint]=] ]=70900,
		[ [=[type]=] ]=[=[adventureF3]=],
		[ [=[textType]=] ]=[=[S1b]=],
		[ [=[desc]=] ]=[=[将地图上一个漩涡地块用引导框框起来]=]
	}
}
return var