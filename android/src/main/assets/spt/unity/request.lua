-- local PlayerInfoModel = require("ui.models.PlayerInfoModel")
-- local PlayerCardsMapModel = require("ui.models.PlayerCardsMapModel")
-- local PlayerTeamsModel = require("ui.models.PlayerTeamsModel")
local UnityEngine = clr.UnityEngine
local SystemInfo = UnityEngine.SystemInfo
url.login = {}
url.login.device = "device"
url.bulletin = 'device/bulletin'
url.checkAppVersion = 'device/checkAppVersion'
url.heartbeat = 'a/heartbeat'
url.login.unitedlogin = 'a/login'
url.login.ebind = "a/ebind"
url.login.create = "a/create"
url.login.player = "player"
url.login.homeBannerAds = "banner/banner"
url.bi = {}
url.bi.startup = "bi/startup"
url.card = {}
url.card.info = "card/info"
url.card.addExp = "card/addExp"
url.card.upgradeEquips = "card/upgradeEquips"
url.card.upgradeEquipsDirect = "card/upgradeEquipsDirect"
url.card.quickUpgrade = "card/quickUpgrade"
url.card.upgrade = "card/upgrade"
url.card.ascend = "card/ascend"
url.card.advance = "card/advance"
url.card.advanceConfirm = "card/advanceConfirm"
url.card.skillLvlUp = "card/skillLvlUp"
url.card.sell = "card/sell"
url.card.lock = "card/lock"
url.card.getPieceStoreList = "card/getPieceStoreList"
url.card.incorporate = "card/incorporate"
url.card.incorporateSpecial = "card/incorporateSpecial"
url.card.incorporateAssistantCoachInfo = "card/incorporateAssistantCoachInfo"
url.card.cardAccess = "card/cardAccess"
url.card.trainIntellect = "card/smartAdvance"
url.card.changeCardChemicalTab = "card/changeCardChemicalTab"
url.card.revertCardAttr = "card/revertCardAttr"

url.card.training = {}
url.card.training.info = "training/info"
url.card.training.addExp = "training/addExp"
url.card.training.finish = "training/finish"
url.card.training.demand = "training/demand"
url.card.training.changeEffect = "training/changeEffect"
url.card.training.checkSubTrainComplete = "training/checkSubTrainComplete"
url.card.training.open = "training/open"
url.card.training.infoList = "training/infoList"

-- 球员助阵
url.card.supporter = {}
url.card.supporter.equipSupporter = "card/equipSupporter"
url.card.supporter.unEquipSupporter = "card/unEquipSupporter"
url.card.unlockTrainingBase = "card/unlockTrainingBase"
url.card.supporterProgress = "card/supporterProgress"

url.team = {}
url.team.used = "team/used"
url.team.save = "team/save"
url.team.index = "team/index"
url.team.clearTeam = "team/clear"
url.team.setScenario = "team/setScenario"
url.quest = {}
url.quest.info = "quest/info"
url.quest.accept = "quest/accept"
url.quest.finish = "quest/finish"
url.quest.sweep = "quest/sweep"
url.quest.sweepTen = "quest/sweepTen"
url.quest.readStory = "quest/readStory"
url.quest.resetCost = "quest/resetCost"
url.quest.reset = "quest/reset"
url.equip = {}
url.equip.incorporate = "equip/incorporate"
url.mail = {}
url.mail.mail = "mail/"
url.mail.collect = "mail/collect"
url.mail.collectAll = "mail/collectAll"
url.match = {}
url.match.match = "match/match"
-- 录像结果比对 服务器存日志
url.match.recordResult = "match/recordResult"
url.reward = {}
url.reward.info = "reward/info"
url.reward.receive = "reward/receive"
url.reward.finishCondition = "reward/finishCondition"
url.letter = {}
url.letter.info = "letter/info"
url.letter.receive = "letter/receive"
url.letter.read = "letter/read"
url.transfer = {}
url.transfer.info = "transfer/info"
url.transfer.refresh = "transfer/refresh"
url.transfer.sign = "transfer/sign"
url.store = {}
url.store.chargelist = "pay/info"
url.store.itemlist = "mall/info"
url.store.itembuy= "mall/buy"
url.store.info = "store/info"
url.store.view = "store/view"
url.store.one = "store/one"
url.store.ten = "store/ten"
url.store.index = "store/index"
url.store.vipinfo = "vip/info"
url.store.vipbag = "vip/buyBag"
url.store.giftBox = "pay/itemInfo"
url.store.buyGiftBox = "pay/payItemInit"
url.store.buyGiftBoxByBlackDiamond = "pay/payBlackDiamond"
url.store.useItem = "item/useItem"
url.store.multiUseItem = "item/multiUseItem"
url.store.exchangeInfo = "vip/exchangeInfo"
url.store.cardExchange = "vip/cardExchange"
url.store.mysteryInfo = "vip/mysteryInfo"
url.store.refreshMystery = "vip/refreshMystery"
url.store.buyMystery = "vip/buyMystery"
url.store.gachaDetail = "store/gachaDetail"
url.store.vip14Store = "vip/mall"
url.store.vip14ShopBuy = "vip/buyVipShop"

url.pay = {}
url.pay.init = "pay/init"
url.pay.test = "payCallback/payTest"
url.pay.checkArrived = "pay/checkArrived"
url.player = {}
url.player.info = "player/info"
url.player.homeEvent = "player/homepage"
url.player.teaminfo = "player/setTeamInfo"
url.player.teamlogo = "player/setLogo"
url.player.teamname = "player/setName"
url.player.teamuniform = "player/setShirt"
url.player.changeName = "player/changeName"
url.player.setting = "player/setting"
url.player.setLang = "player/setLang"
url.player.changeLogo = "player/changeLogo"
url.player.changeShirt = "player/changeShirt"
url.player.useSpecificTeam = "player/useSpecificTeam"
url.player.shareInfo = "player/shareInfo"
url.player.getEnterSenceList = "player/getPlayerEnterSceneStatus"
url.player.setEnterSenceList = "player/setPlayerEnterSceneStatus"
url.player.getGsSetting = "player/getGsSetting"
url.littleGame = {}
url.littleGame.info = "littleGame/info"
url.littleGame.play = "littleGame/play"
url.littleGame.sweep = "littleGame/sweep"
url.littleGame.questionInfo = "littleGame/questionInfo"
url.littleGame.beginAnswer = "littleGame/beginAnswer"
url.littleGame.answer = "littleGame/answer"
url.littleGame.rankInfo = "littleGame/rankInfo"
url.league = {}
url.league.index = "league/index"
url.league.enter = "league/enter"
url.league.sponsor = "league/sponsor"
url.league.schedule = "league/schedule"
url.league.report = "league/report"
url.league.start = "league/start"
url.league.reward = "league/reward"
url.league.board = "league/board"
url.league.rank = "league/rank"
url.league.newSeason = "league/newSeason"
url.league.buy = "league/buy"
url.league.sweep = "league/sweep"

url.remoteDebug = {}
url.remoteDebug.setResult = "remoteDebug/setResult"
url.remoteDebug.getString = "remoteDebug/getString"
url.user = {}
url.user.spRecover = "player/spRecoverInfo"
url.user.getSPInfo = "player/getBuySPInfo"
url.user.buySP = "player/buySP"
url.player.guide = "player/guide"
url.player.samplematch = "player/sampleMatch"
url.friends = {}
url.friends.listFriends = "friend/listFriends"
url.friends.remove = "friend/remove"
url.friends.donateSp = "friend/donateSp"
url.friends.donateSpAll = "friend/donateSpAll"
url.friends.index = "friend/index"
url.friends.receiveSp = "friend/receiveSp"
url.friends.find = "friend/find"
url.friends.facebookId = "friend/socialFind"
url.friends.request = "friend/request"
url.friends.listRequest = "friend/listRequest"
url.friends.accept = "friend/accept"
url.friends.reject = "friend/reject"
url.friends.match = "friend/match"
url.friends.listRecords = "friend/listRecords"
url.friends.delRecord = "friend/delRecord"
url.friends.detail = "friend/detail"
url.friends.detailGuide = "friend/detailGuide"
url.friends.video = "friend/viewRecord"
url.friends.cardDetail = "friend/cardDetail"
url.album = {}
url.album.get = "album/get"
url.album.edit = "album/edit" -- 【玩家自定义标签】
url.activity = {}
url.activity.activityList = "activity/listInfo"
url.activity.sign = "sign/sign"
url.activity.firstPay = "activity/receive"
url.activity.firstPayInfo = "activity/firstPayInfo"
url.activity.cumulativeLogin = "activity/receive"
url.activity.cumulativeConsume = "activity/receive"
url.activity.read = "activity/read"
url.activity.receive = "activity/receive"
url.activity.activityTimeLimitChallengeInfo = "activity/listQuestLimitInfo"
url.activity.activityTimeLimitChallengeFight = "activity/acceptQuestLimit"
url.activity.activityConfederationsCupFight = "activity/acceptTimeLimitChallenge"
url.activity.activityTimeLimitChallengeReceiveReward = "activity/receive"
url.activity.buyGrowthPlan = "activity/buyGrowthPlan"
url.activity.dropDoubleInfo = "quest/dropDoubleInfo"
url.activity.activityBeginnerCarnival = "activity/listBeginnerCarnival"
url.activity.activityBeginnerCarnivalTotal = "activity/receiveBeginnerCarnivalTotal"
url.activity.buyGiftBag = "vip/buyGiftBag"
url.activity.joinDraw = "activity/joinDraw"
url.activity.draw = "activity/draw"
url.activity.receiveBayernReward = "activity/receive"
url.activity.redirectLink = "activity/redirectLink"
url.activity.worldBossMatch = "worldBoss/match"
url.activity.worldBossPlayerSort = "worldBoss/playerSort"
url.activity.worldBossServerSort = "worldBoss/serverSort"
url.activity.worldBossInfo = "worldBoss/info"
url.activity.worldBossNPCInfo = "worldBoss/NPCInfo"
url.activity.worldBossGrab = "worldBoss/grab"
url.activity.worldBossSweep = "worldBoss/sweep"
url.activity.worldBossExchangeInfo = "exchange/info"
url.activity.worldBossExchange = "exchange/exchange"
url.activity.receiveLateGift = "activity/receiveLateGift"
url.activity.sevenDayLogin = "activity/sevenDayLogin"
url.activity.oldPlayerCallBack = "activity/oldPlayerCallBack"
url.activity.callBackBuy = "activity/callBackBuy"
url.activity.fanShopBuy = "fanShop/buy"
url.activity.fanShopRecycleStore = "fanShop/recycleStore"
url.activity.fanShopSell = "fanShop/sell"
url.activity.careerRace = "activity/getActivityInfo"
url.activity.redeemTeamInvest = "activity/redeemTeamInvest"
url.activity.redeemFreshTeamInvest = "activity/redeemFreshTeamInvest"
--限时抽卡活动
url.activity.collectReward = "activity/receiveByParam"
url.activity.recruitRewardRankingList = "activity/getTimeLimitGachaRankList"
url.activity.pasterSplitActivity = "paster/activityDecomposition"
url.activity.getNewDataByTableName = "device/syncJson"

-- 砸罐子(开宝箱)活动
url.activity.buyPlayerTreasureKey = "activity/buyPlayerTreasureKey"
url.activity.redeemPlayerTreasureTaskBonus = "activity/redeemPlayerTreasureTaskBonus"
url.activity.redeemPlayerCountTreasure = "activity/redeemPlayerCountTreasure"
url.activity.redeemPlayerTreasure = "activity/redeemPlayerTreasure"
url.activity.refreshPlayerTreasure = "activity/refreshPlayerTreasure"
url.activity.getPlayerTreasureTaskInfo = "activity/getPlayerTreasureTasks"

--战力竞赛活动
url.activity.getOpenServerPowerRank = "powerRank/getOpenServerPowerRank"
url.activity.refreshOpenServerPowerRank = "powerRank/refreshOpenServerPowerRank"
url.activity.receiveOpenServerPowerRank = "powerRank/receiveOpenServerPowerRank"

-- 连锁礼盒
url.activity.buyGiftBox = "mall/buyGiftBox"

-- 绿茵终结者
url.activity.powerShootRefresh = "powershoot/refresh"
url.activity.powerShootStartShoot = "powershoot/startShoot"
url.activity.powerShootShooting = "powershoot/shooting"

-- 阶梯商店
url.activity.stageShopGetTaskInfo = "stageShop/getTaskInfo"
url.activity.stageShopReceiveTask = "stageShop/receiveTask"
url.activity.stageShopBuyItem = "stageShop/buyItem"

-- 自选娃娃机
url.activity.dollStart = "doll/start"
url.activity.dollChangedReward = "doll/changedReward"
url.activity.dollReceive = "doll/receive"

url.luckWheel = {}
url.luckWheel.dial = "luckWheel/dial"
url.luckWheel.buy = "luckWheel/buy"
url.luckWheel.refresh = "luckWheel/refresh"
url.snatch = {}
url.snatch.gacha = "snatch/gacha"
url.snatch.receiveReward = "snatch/receiveReward"

url.mall = {}
url.mall.info = "mall/info"
url.mall.buy = "mall/buy"
url.honor = {}
url.honor.info = "honor/info"
url.honor.receive = "honor/receive"
url.honor.useHonor = "honor/useHonor"
url.honor.unUseHonor = "honor/unUseHonor"
url.honor.swapHonor = "honor/swapHonor"
url.honor.rankTop = "honor/rankTop"
url.honor.receiveReward = "honor/receiveReward"
url.activationCode = {}
url.activationCode.exchange = "activationCode/exchange"
url.activationCode.accountTransfer = "activationCode/accountTransfer"
url.activationCode.accountTransferConfirm = "activationCode/accountTransferConfirm"
url.ladder = {}
url.ladder.info = "ladder/info"
url.ladder.reward = "ladder/reward"
url.ladder.updateRival = "ladder/updateRival"
url.ladder.start = "ladder/start"
url.ladder.buyCd = "ladder/buyCd"
url.ladder.rankList = "ladder/rankList"
url.ladder.rank = "ladder/rank"
url.ladder.store = "ladder/store"
url.ladder.storeRefresh = "ladder/storeRefresh"
url.ladder.storeBuy = "ladder/storeBuy"
url.ladder.record = "ladder/record"
url.ladder.video = "ladder/video"
url.ladder.seasonReward = "ladder/seasonReward"
url.build = {}
url.build.info = "build/info"
url.build.upgrade = "build/upgrade"
url.build.upgradeCompleted = "build/upgradeCompleted"
url.build.setMatchWeatherTech = "build/setMatchWeatherTech"
url.build.setMatchGrassTech = "build/setMatchGrassTech"     
url.msg = {}
url.msg.receive = "msg/receive"
url.msg.sendWorld = "msg/sendWorld"
url.msg.sendPlayer = "msg/sendPlayer"
url.msg.sendGuild = "msg/sendGuild"
url.msg.sendAllServer = "msg/sendAllServer"

url.crusade = {}
url.crusade.info = "crusade/info"
url.crusade.store = "crusade/store"
url.crusade.buyCard = "crusade/buyCard"
url.crusade.buyItem = "crusade/buyItem"
url.crusade.match = "crusade/match"
url.crusade.questList = "crusade/questList"
url.crusade.crusadeReceive = "crusade/questReceive"
url.crusade.refreshItem = "crusade/refreshItem"


url.guild = {}
url.guild.index = "guild/index"
url.guild.priorityGuild = "guild/priorityGuild"
url.guild.request = "guild/request"
url.guild.search = "guild/search"
url.guild.create = "guild/create"
url.guild.mlist = "guild/mlist"
url.guild.reqs = "guild/reqs"
url.guild.detail = "guild/detail"
url.guild.accept = "guild/accept"
url.guild.refuse = "guild/refuse"
url.guild.cpos = "guild/cpos"
url.guild.epos = "guild/epos"
url.guild.kick = "guild/kick"
url.guild.cMulitInfo = "guild/cMulitInfo"
url.guild.getAllGuildRecord = "guild/getAllGuildRecord"
url.guild.top = "guild/top"
url.guild.getRankPos = "guild/getRankPos"
url.guild.dismiss = "guild/dismiss"
url.guild.quit = "guild/quit"
url.guild.signInfo = "guild/signInfo"
url.guild.sign = "guild/sign"
url.guild.guildDetail = "guild/guildDetail"
url.guild.sendRedEnvelope = "guild/sendRedEnvelope"
url.guild.openRedEnvelope = "guild/openRedEnvelope"
url.guild.viewRedEnvelope = "guild/viewRedEnvelope"
url.guild.cname = "guild/cname"
url.guild.challengeInfo = "guild/challengeInfo"
url.guild.challengeStart = "guild/challengeStart"
url.guild.challengeSweep = "guild/challengeSweep"
url.guild.powerRank = "guild/powerRank"
url.guild.autoInviteGuilds = "guild/autoInviteGuilds"
url.guild.getDonationInfo = "guild/getDonationInfo"  --工会捐献信息
url.guild.donation = "guild/donation"  --工会捐献
url.guild.powerMistRank = "guild/powerMistRank"  --工会迷雾排行榜

url.guildWar = {}
url.guildWar.info = "guildWar/info"
url.guildWar.sign = "guildWar/sign"
url.guildWar.memberInfo = "guildWar/memberInfo"
url.guildWar.deploy = "guildWar/deploy"
url.guildWar.testSign = "guildWar/testSign"
url.guildWar.testGroup = "guildWar/testGroup"
url.guildWar.warInfo = "guildWar/warInfo"
url.guild.targetGuardDetail = "guildWar/targetGuardDetail"
url.guildWar.selfGuardDetail = "guildWar/selfGuardDetail"
url.guild.buyBuff = "guildWar/buyBuff"
url.guildWar.guardsInfo = "guildWar/guardsInfo"
url.guildWar.scheduleInfo = "guildWar/scheduleInfo"
url.guildWar.testRank = "guildWar/testRank"
url.guildWar.memberInfo = "guildWar/memberInfo"
url.guildWar.targetGuardDetail = "guildWar/targetGuardDetail"
url.guildWar.startWar = "guildWar/start"
url.guildWar.buffInfo = "guildWar/buffInfo"
url.guildWar.recentGuildWar = "guildWar/recentGuildWar"
url.guildWar.viewVideo = "guildWar/viewVideo"
url.guildWar.viewPlayer = "guildWar/viewPlayer"
-- 公会战 迷雾战场
url.guildWar.mistInfo = "guildWar/mistInfo"  --迷雾公会战入口
url.guildWar.guardsInfoMist = "guildWar/guardsInfoMist"  --己方迷雾公会守卫席信息
url.guildWar.memberInfoMist = "guildWar/memberInfoMist"  --迷雾成员信息
url.guildWar.deployMist = "guildWar/deployMist"  --部署迷雾守卫席
url.guildWar.signInfoMist = "guildWar/signInfoMist"  --迷雾公会战报名信息
url.guildWar.signMist = "guildWar/signMist"  --迷雾公会战报名
url.guildWar.warInfoMist = "guildWar/warInfoMist"  --迷雾公会战状况
url.guildWar.buyBuffMist = "guildWar/buyBuffMist"  --迷雾公会战购买buff
url.guildWar.startMist = "guildWar/startMist"  --迷雾公会战攻打守卫席
url.guildWar.scheduleInfoMist = "guildWar/scheduleInfoMist"  --迷雾公会战赛程
url.guildWar.targetGuardDetailMist = "guildWar/targetGuardDetailMist"  --迷雾公会战敌方守卫席详情
url.guildWar.selfGuardDetailMist = "guildWar/selfGuardDetailMist"  --迷雾公会战守卫席详情
url.guildWar.viewVideoMist = "guildWar/viewVideoMist"  --迷雾公会战查看比赛录像
url.guildWar.recentGuildWarMist = "guildWar/recentGuildWarMist"  --迷雾公会战获取最近两期公会战
url.guildWar.viewPlayerMist = "guildWar/viewPlayerMist"  --迷雾公会战查看玩家详情
url.guildWar.mistMapInfo = "guildWar/mistMapInfo"  --迷雾公会战所有地图使用详情

url.guildWar.mistShopInfo = "guildWar/mistShopInfo"  --购买迷雾商品信息  迷雾公会战已购buff信息
url.guildWar.changGuardsInfoDefendLevel = "guildWar/changGuardsInfoDefendLevel"  --改变地图的防御等级
url.guildWar.selectMistMap = "guildWar/selectMistMap"  --迷雾公会战选择地图
url.guildWar.buyMistItem = "guildWar/buyMistItem"  --从迷雾商店购买道具
url.guildWar.mainInfo = "guildWar/mainInfo"  --主入口
url.guildWar.saveGuardsInfoMist = "guildWar/saveGuardsInfoMist"  --保存地图
url.guildWar.guardsInfoMistByRound = "guildWar/guardsInfoMistByRound"  --指定轮次的守卫席信息

url.arena = {}
url.arena.info = "arena/info"
url.arena.sign = "arena/sign"
url.arena.unsign = "arena/unsign"
url.arena.groupInfo = "arena/groupInfo"
url.arena.testMatch = "arena/testMatch"
url.arena.nextRaceInfo = "arena/nextRaceInfo"
url.arena.getArenaGroupScoreAndSchedule = "arena/getArenaGroupScoreAndSchedule"
url.arena.getArenaOutScheduleBoard = "arena/getArenaOutScheduleBoard"
url.arena.arenaBrief = "arena/arenaBrief"
url.arena.buyArenaStore = "arena/buyArenaStore"
url.arena.getTeam = "arena/getTeam"
url.arena.saveTeam = "arena/saveTeam"
url.arena.clearTeam = "arena/clearTeam"
url.arena.arenaHonorInfo = "arena/honorInfo"
url.arena.arenaVideo = "arena/video"
url.arena.arenaReceiveHonor = "arena/receiveHonor"
url.arena.arenaReceiveReward = "arena/receiveReward"
url.arena.arenaQuit = "arena/quit"
url.arena.rankInfo = "arena/rankInfo"
url.arena.viewTeam = "arena/viewTeam"
url.arena.viewMatchTech = "arena/viewMatchTech"
url.arena.playerArenaScheduleBoard = "arena/getPlayerArenaScheduleBoard"
url.video = {}
url.video.info = "video/info"
url.video.video = "video/video"
url.item = {}
url.item.viewItem = "item/viewItem"

url.lottery = {}
url.lottery.history = "lottery/history"
url.lottery.stake = "lottery/stake"
url.lottery.bonus = "lottery/bonus"
url.lottery.bonusAll = "lottery/bonusAll"

url.paster = {}
url.paster.add = "paster/add"
url.paster.equip = "paster/equip"
url.paster.unEquip = "paster/unEquip"
url.paster.useSkill = "paster/useSkill"
url.paster.pieceStore = "paster/pieceStore"
url.paster.incorporate = "paster/incorporate"
url.paster.decomposition = "paster/decomposition"
url.paster.upgrade = "paster/upgrade"


url.visit = {}
url.visit.gacha = "visit/gacha"
url.visit.receiveChestReward = "visit/receiveChestReward"
url.visit.getPlayerVisitRank = "visit/getPlayerVisitRank"

url.specific = {}
url.specific.index = "specific/index"
url.specific.updateMatch = "specific/updateMatch"
url.specific.video = "specific/video"
url.specific.match = "specific/match"
url.specific.sweep = "specific/sweep"
url.specific.getTeam = "specific/getTeam"
url.specific.saveTeam = "specific/saveTeam"
url.specific.clearTeam = "specific/clearTeam"
url.specific.viewTeam = "specific/viewTeam"

url.medal = {}
url.medal.equip = "medal/equip"
url.medal.unload = "medal/unload"
url.medal.unloadMedal = "medal/unloadMedal"
url.medal.upgrade = "medal/upgrade"
url.medal.upgradeBless = "medal/upgradeBless"
url.medal.changeBless  = "medal/changeBless"
url.medal.decomposition = "medal/decomposition"
url.medal.decompositionAll = "medal/decompositionAll"
url.medal.boostUp = "medal/boostUp"

url.peak = {}
url.peak.info = "peak/info"
url.peak.receivePeakPoint = "peak/receivePeakPoint"
url.peak.newOpponent = "peak/newOpponent"
url.peak.swapTeam = "peak/swapTeam"
url.peak.saveTeam = "peak/saveTeam"
url.peak.rank = "peak/rank"
url.peak.seasonRank = "peak/seasonRank"
url.peak.clearTeam = "peak/clearTeam"
url.peak.recordList = "peak/recordList"
url.peak.checkOpen = "peak/checkOpen"
url.peak.viewOpponent = "peak/viewOpponent"
url.peak.challenge = "peak/challenge"
url.peak.sweepChallenge = "peak/sweepChallenge"
url.peak.initChallenge = "peak/initChallenge"
url.peak.challengeOver = "peak/challengeOver"
url.peak.resetPlayCd = "peak/resetPlayCd"
url.peak.viewVideo = "peak/viewVideo"
url.peak.shop = "peak/shop"
url.peak.exchangeNormalItem = "peak/exchangeNormalItem"
url.peak.exchangeMysteryBox = "peak/exchangeMysteryBox"
url.peak.shopRefresh = "peak/shopRefresh"
url.peak.dailyTaskInfo = "peak/dailyTaskInfo"
url.peak.receiveDailyTaskReward = "peak/receiveDailyTaskReward"
url.peak.buyChallenge = "peak/buyChallenge"
url.peak.hideTeam = "peak/hideTeam"
url.peak.canSweepChallenge = "peak/canSweepChallenge"

url.transport = {}
url.transport.index = "transport/index"
url.transport.over = "transport/over"
url.transport.start = "transport/start"
url.transport.requestGuardList = "transport/requestGuardList"
url.transport.acceptGuard = "transport/acceptGuard"
url.transport.sign = "transport/sign"
url.transport.guardApply = "transport/guardApply"
url.transport.guardList = "transport/guardList"
url.transport.changeMaxSponsor = "transport/changeMaxSponsor"
url.transport.changeRandSponsor = "transport/changeRandSponsor"
url.transport.removeMark = "transport/removeMark"
url.transport.guardReceive = "transport/guardReceive"
url.transport.battle = "transport/battle"
url.transport.matchFinish = "transport/matchFinish"
url.transport.battleLog = "transport/battleLog"
url.transport.mark = "transport/mark"
url.transport.receive = "transport/receive"
url.transport.express = "transport/express"

url.rank = {}
url.rank.multiRanksInfo = "rank/multiRanksInfo"

url.voice = {}
url.voice.voicePackInfo = "voicePack/info"
url.voice.voicePackChange = "voicePack/changeVoicePack"

url.topicComment = {}
url.topicComment.topic = "topicComment/topic"
url.topicComment.addNormalComment = "topicComment/addNormalComment"
url.topicComment.queryNormalHotComment = "topicComment/queryNormalHotComment"
url.topicComment.queryNormalNewComment = "topicComment/queryNormalNewComment"
url.topicComment.replyComment = "topicComment/replyComment"
url.topicComment.queryReplyComment = "topicComment/queryReplyComment"
url.topicComment.agreeComment = "topicComment/agreeComment"
url.topicComment.disagreeComment = "topicComment/disagreeComment"
url.topicComment.deleteComment = "topicComment/deleteComment"
url.topicComment.setTopComment = "topicComment/setTopComment"
url.topicComment.unsetTopComment = "topicComment/unsetTopComment"
url.dreamLeague = {}
url.dreamLeague.dreamCardAdd = "dreamCard/add"
url.dreamLeague.dreamCardDecomposition = "dreamCard/decomposition"
url.dreamLeague.dreamCardDecompositionAll = "dreamCard/decompositionAll"
url.dreamLeague.dreamCardLock = "dreamCard/lock"
url.dreamLeague.dreamCardUnlock = "dreamCard/unlock "
url.dreamLeague.dreamShopInfo = "dreamLeagueShop/info"
url.dreamLeague.dreamShopBuy = "dreamLeagueShop/buy"
url.dreamLeague.dreamLeagueMatchIndex = "dreamLeagueMatch/index"
url.dreamLeague.dreamLeagueMatchTeam = "dreamLeagueMatch/team"
url.dreamLeague.dreamLeagueMatchHistory = "dreamLeagueMatch/history"
url.dreamLeague.dreamLeagueMatchInfo = "dreamLeagueMatch/info"
url.dreamLeague.dreamLeagueTeamAddDreamCard = "dreamLeagueTeam/addDreamCard"
url.dreamLeague.dreamLeagueTeamcard = "dreamLeagueTeam/card"
url.dreamLeague.dreamLeagueMatch = "dreamLeagueMatch/rank"

-- mvp竞猜使用
url.dreamLeague.dreamLeagueMatchGuessList = "dreamLeagueMatch/guessList"

url.dreamLeague.dreamLeagueRoomOpen = "dreamLeagueRoom/open"
url.dreamLeague.dreamLeagueRoomInfo = "dreamLeagueRoom/info"
url.dreamLeague.dreamLeagueRoomJoin = "dreamLeagueRoom/join"
url.dreamLeague.dreamLeagueRoomList = "dreamLeagueRoom/list"
url.dreamLeague.dreamLeagueRoomRecord = "dreamLeagueRoom/record"
url.dreamLeague.dreamLeagueRoomReceive = "dreamLeagueRoom/receive"
url.dreamLeague.dreamLeagueRoomPlayerCards = "dreamLeagueRoom/playerCards"
-- 进入创建房间时调用
url.dreamLeague.dreamLeagueRoomNew = "dreamLeagueRoom/new"
-- 创建房间
url.dreamLeague.dreamLeagueRoomCreate = "dreamLeagueRoom/create"
url.dreamLeague.dreamLeagueMatchGuessInfo = "dreamLeagueMatch/guessInfo"
url.dreamLeague.dreamLeagueMatchGuess = "dreamLeagueMatch/guess"
url.dreamLeague.dreamLeagueMatchOpen = "dreamLeagueMatch/open"
-- 争霸赛
url.worldTournament = {}
url.worldTournament.rank = "worldTournament/rank"
url.worldTournament.reward = "worldTournament/reward"
url.worldTournament.crossInfo = "worldTournament/serverRank"
url.worldTournament.collectOneMail = "worldTournament/collect"
url.worldTournament.collectAllMails = "worldTournament/collectAll"

url.worldTournamentShop = {}
url.worldTournamentShop.info = "worldTournamentShop/info"
url.worldTournamentShop.buy = "worldTournamentShop/buy"
url.worldTournament.matchList = "worldTournament/matchList"
url.worldTournament.getTeam = "worldTournament/getTeam"
url.worldTournament.saveTeam = "worldTournament/saveTeam"
url.worldTournament.clearTeam = "worldTournament/clearTeam"
url.worldTournament.serverSchedule = "worldTournament/serverSchedule"
url.worldTournament.match = "worldTournament/match"
url.worldTournament.border = "worldTournament/border"
url.worldTournament.teamMatch = "worldTournament/teamMatch"
url.worldTournament.sortBorder = "worldTournament/sortBorder"
url.worldTournament.video = "worldTournament/video"

--争霸赛竞猜
url.worldTournament.guess = {}
url.worldTournament.guess.guessList = "worldTournament/getCurrentGuessList"
url.worldTournament.guess.guess = "worldTournament/guess"
url.worldTournament.guess.receive = "worldTournament/redeemGuessBonus"
url.worldTournament.guess.confirm = "worldTournament/confirmGuess"

-- 争霸赛冠军墙
url.worldTournament.champions = "worldTournament/champions"

-- 英雄殿堂
url.footballHall = {}
url.footballHall.info = "footballHall/info"      -- 首页信息
url.footballHall.activateHall = "footballHall/activateHall"     -- 激活殿堂
url.footballHall.upgradeStatue = "footballHall/upgradeStatue"   -- 雕像升级

-- 月卡商店
url.monthCardShop = {}
url.monthCardShop.info = "monthCardShop/info"-- 页面信息
url.monthCardShop.buy = "monthCardShop/buy"-- 购买

-- 拍卖行
url.auction = {}
url.auction.info = "auction/info" -- 主页面信息
url.auction.history = "auction/history" -- 我的历史记录
url.auction.gain = "auction/gain" -- 领取奖励
url.auction.detail = "auction/detail" -- 单个物品竞拍大厅信息
url.auction.auction = "auction/auction" -- 玩家出价竞拍
url.auction.rank = "auction/rank" -- 排行榜信息

-- 工会嘉年华
url.guildCarnival = {}
url.guildCarnival.rank = "guildCarnival/rank" -- 积分贡献排行
url.guildCarnival.record = "guildCarnival/record" -- 我的积分日志
url.guildCarnival.buy = "guildCarnival/buy" -- 购买商品

--吉祥物赠礼
url.mascotPresent = {}
url.mascotPresent.guildRankingList = "mascotPresent/rankGuild"
url.mascotPresent.guildMemberContribution = "mascotPresent/rankPersonal"
url.mascotPresent.giftBoxInfo = "mascotPresent/getGiftBox"
url.mascotPresent.refreshTask = "mascotPresent/refreshTask"
url.mascotPresent.collectProgressReward = "mascotPresent/receiveGiftBox"
url.mascotPresent.collectTaskReward = "mascotPresent/finishTask"
url.mascotPresent.OrderOwnerGiftBoxInfo = "mascotPresent/getStaticGiftBox"

--拉新，邀请好友
url.friendsInvite = {}
url.friendsInvite.taskInfo = "inviteNewPlayer/info"
url.friendsInvite.collectNewPlayerReward = "inviteNewPlayer/receive"
url.friendsInvite.collectTaskReward = "inviteNewPlayer/receiveTask"
url.friendsInvite.collectDiaTaskReward = "inviteNewPlayer/receiveDiamond" 
--教练
url.coach = {}
url.coach.getmissioninfo = "coach/getmissioninfo"
url.coach.acceptmission = "coach/acceptmission"
url.coach.buymissiontimes = "coach/buymissiontimes"
url.coach.refreshmission = "coach/refreshmission"
url.coach.getmissionreward = "coach/getmissionreward"
url.coach.getallmissionreward = "coach/getallmissionreward"

-- 基本信息
url.coach.baseInfo = {}
url.coach.baseInfo.info = "coach/info" -- 教练基本信息，经验、等级、阵型、战术等级等
url.coach.baseInfo.addExp = "coach/addExp" -- 使用经验书升级
url.coach.baseInfo.formationUpgrade = "coach/formationUpgrade" -- 阵型升级
url.coach.baseInfo.tacticUpgrade = "coach/tacticUpgrade" -- 战术升级

-- 执教天赋
url.coach.talent = {}
url.coach.talent.upgrade = "coach/talentUpgrade" -- 教练天赋解锁/升级
url.coach.talent.reset = "coach/talentReset" -- 教练天赋重置

-- 教练指导
url.coach.guide = {}
url.coach.guide.guideUnlock = "coach/guideUnlock" -- 教练界面解锁教练指导栏位
url.coach.guide.guideCard = "coach/guideCard" -- 将球员放入指导栏位

-- 教练特性
url.coach.feature = {}
url.coach.feature.guideSkill = "card/guideSkill" -- 使用特性书或者道具升级
url.coach.feature.confirmGuideSkill = "card/confirmGuideSkill"

-- 助理教练阵容
url.coach.assistantCoach = {}
url.coach.assistantCoach.list = "coach/getAssistantCoachList" -- 获取助理教练所有数据
url.coach.assistantCoach.teamInfo = "coach/getAssistantCoachTeamInfo" -- 获取助理教练上阵数据
url.coach.assistantCoach.changeTeam = "coach/changedAssistantCoachTeam" -- 助理教练上阵
url.coach.assistantCoach.update = "coach/upgradeAssistantCoach" -- 升级助理教练
url.coach.assistantCoach.decompose = "coach/decomposeAssistantCoach" -- 分解/解雇助理教练

-- 助理教练情报
url.coach.assistantCoachInfo = {}
url.coach.assistantCoachInfo.list = "coach/getAssistantCoachInfoList" -- 获取所有助教情报
url.coach.assistantCoachInfo.compose = "coach/composeAssistantCoach" -- 合成助理教练
url.coach.assistantCoachInfo.sell = "coach/sellAssistantCoachInfo" -- 出售助理教练情报
url.coach.assistantCoachInfo.decompose = "coach/decomposeAssistantCoachInfo" -- 分解助理教练情报

-- 助理教练情报抽卡
url.coach.assistantCoachGacha = {}
url.coach.assistantCoachGacha.get = "coach/getAssistantCoachGacha" -- 获取助教情报信息Gacha
url.coach.assistantCoachGacha.exchange = "coach/exchangeAssistantCoachGift" -- 幸运值兑换助理教练情报礼包
url.coach.assistantCoachGacha.buy = "coach/buyAssistantCoachGift" -- 购买助理教练情报礼包

-- 金球助力活动
url.goldBall = {}
url.goldBall.buyAdvance = "goldBall/buyAdvanceState" -- 购买进阶奖励资格
url.goldBall.receiveGoldBall = "goldBall/receiveGoldBall" -- 领取位置奖励
url.goldBall.receiveTask = "goldBall/receiveTask" -- 领取任务奖励金球

-- 等级礼包
url.levelBox = {}
url.levelBox.info = "levelBox/info" -- 查看
url.levelBox.receive = "levelBox/receive" -- 领取

-- 传奇记忆
url.card.activeMemory = "card/activeMemory" -- 传奇记忆激活

url.greenswardAdventure = {}
url.greenswardAdventure.info = "adventure/info"
url.greenswardAdventure.open = "adventure/open"
url.greenswardAdventure.trigger = "adventure/trigger"
url.greenswardAdventure.bribe = "adventure/bribe"
url.greenswardAdventure.match = "adventure/match"
url.greenswardAdventure.nextFloor = "adventure/nextFloor"
url.greenswardAdventure.changeFloor = "adventure/changeFloor"
url.greenswardAdventure.viewOpponent = "adventure/viewOpBrief"
url.greenswardAdventure.viewOpDetail = "adventure/viewOpDetail"
url.greenswardAdventure.openLottery = "adventure/openLottery"
url.greenswardAdventure.openWheel = "adventure/openWheel"
url.greenswardAdventure.openStore = "adventure/openMapStore"
url.greenswardAdventure.buyStore = "adventure/buyMapStore"
url.greenswardAdventure.rewardInfo = "adventure/rewardInfo"
url.greenswardAdventure.viewCell = "adventure/viewCell"
url.greenswardAdventure.answerReward = "adventure/answerReward"
url.greenswardAdventure.testCell = "adventure/testCell"
url.greenswardAdventure.openTreasure = "adventure/openTreasure"
url.greenswardAdventure.treasureMap = "adventure/treasureMap"
url.greenswardAdventure.useItem = "adventure/useItem"
url.greenswardAdventure.openItemStore = "adventure/openItemStore"
url.greenswardAdventure.buyItemStore = "adventure/buyItemStore"
url.greenswardAdventure.subway = "adventure/subway"
url.greenswardAdventure.rankBoard = "adventure/rankBoard"
url.greenswardAdventure.rankView = "adventure/rankView"
url.greenswardAdventure.fullStageRewardInfo = "adventure/fullStageRewardInfo"
url.greenswardAdventure.receiveFullStageReward = "adventure/receiveFullStageReward"
url.greenswardAdventure.buyMorale = "adventure/buyMorale"
url.greenswardAdventure.dailyMorale = "adventure/dailyMorale"
url.greenswardAdventure.friend = "adventure/friend" -- 好友赠送领取士气界面
url.greenswardAdventure.rcvMorale = "adventure/receiveFriendMorale" -- 领取单个好友士气
url.greenswardAdventure.sendMorale = "adventure/sendFriendMorale" -- 赠送单个好友士气
url.greenswardAdventure.rcvMorales = "adventure/receiveFriendBatchMorale" -- 一键领取
url.greenswardAdventure.sendMorales = "adventure/sendFriendBatchMorale" -- 一键赠送
url.greenswardAdventure.mysticHint = "adventure/hint" -- 查看神秘指令
url.greenswardAdventure.setImage = "adventure/setImage" -- 设置玩家形象
url.greenswardAdventure.index = "adventure/index" -- 是否已开启
url.greenswardAdventure.treasurePreview = "adventure/treasurePreview" -- 藏宝图奖励预览

-- 球员传奇之路
url.cardLegend = {}
url.cardLegend.unlock = "legend/unlock"
url.cardLegend.upgrade = "legend/upgrade"
url.cardLegend.selectAttr = "legend/selectAttr"
url.cardLegend.selectSkill = "legend/selectSkill"
url.cardLegend.activateExPaster = "legend/activateExPaster"

url.eventGiftBag = {}
url.eventGiftBag.buy = "eventGiftBag/buy"

url.marbles = {}
url.marbles.receiveTask = "marbles/receiveTask"  -- 弹球活动 领取任务奖励
url.marbles.receiveCount = "marbles/receiveCount"  -- 弹球活动 取次数奖励
url.marbles.buyBall = "marbles/buyBall"  -- 弹球活动 购买弹球
url.marbles.exchange = "marbles/exchange"  -- 弹球活动 兑换奖励
url.marbles.shootBall = "marbles/shootBall"  -- 弹球活动 发射弹球
url.marbles.setShootInfo = "marbles/setShootInfo"  -- 弹球活动 设置发射弹球信息
url.marbles.getTaskInfo = "marbles/getTaskInfo"  -- 弹球活动 获取任务信息
url.marbles.getCountInfo = "marbles/getCountInfo"  -- 弹球活动 获取次数奖励信息
url.marbles.getExchangeInfo = "marbles/getExchangeInfo"  -- 弹球活动 获取兑换道具信息

url.freeShoppingCart = {}
url.freeShoppingCart.receiveFree = "freeShoppingCart/receiveFree"  -- 周一免单购物车 领取免费奖励
url.freeShoppingCart.choose = "freeShoppingCart/choose"  -- 周一免单购物车 选择奖励
url.freeShoppingCart.receive = "freeShoppingCart/receive"  -- 周一免单购物车 领取周一奖励

url.multiGetGift = {} -- 超值多日礼盒
url.multiGetGift.receiveTask = "multiGetGift/receiveTask"  -- 领取任务奖励
url.multiGetGift.receiveGift = "multiGetGift/receiveGift"  -- 领取免费奖励
url.multiGetGift.receiveAllGift = "multiGetGift/receiveAllGift"  -- 领取所有免费奖励
url.multiGetGift.buyItem = "multiGetGift/buyItem"  -- 买商城东西

-- 梦幻卡
url.fancyCard = {}
url.fancyCard.gachaInfo = "fancyCard/gachaInfo" -- 招募信息
url.fancyCard.gachaOne = "fancyCard/gachaOne" -- 招募一次
url.fancyCard.gachaTen = "fancyCard/gachaTen" -- 招募十次
url.fancyCard.cardStarUp = "fancyCard/cardStarUp" --升星
url.fancyCard.mallInfo = "fancyCard/mallInfo" -- 商店信息
url.fancyCard.mallBuy = "fancyCard/mallBuy" -- 商店购买
url.fancyCard.decomposition = "fancyCard/decomposition" -- 分解
url.fancyCard.view = "fancyCard/view" --抽卡页签查看
url.fancyCard.gachaPool = "fancyCard/gachaPool" --招募列表


function req.device(itemMaxId, itemContentMaxId, pasterMaxId, redPacketMaxId, medalMaxId, exchangeItemId, worldBossItemId, marblesExchangeItem, oncomplete, onfailed)
    local ratiow, ratioh = luaevt.trig("GetRatio")
    local data = {
        capid = clr.capid(),
        udid = luaevt.trig("GetUDID"),
        osv = luaevt.trig("GetSysVersionNum"),
        model = luaevt.trig("GetPhoneType"),
        oper = luaevt.trig("GetNetOperName"),
        net = luaevt.trig("GetNetType"),
        width = ratiow,
        height = ratioh,
        mac = luaevt.trig("GetMacAddr"),
        imei = luaevt.trig("GetImei"),
        pf = clr.plat,
        bichannel = luaevt.trig("SDK_GetChannel"),
        jsonUpdate = {Item = itemMaxId, ItemContent = itemContentMaxId, Paster = pasterMaxId, RedPacket = redPacketMaxId, Medal = medalMaxId, ExchangeItem = exchangeItemId, WorldBossItem = worldBossItemId,MarblesExchangeItem = marblesExchangeItem},
        lang = luaevt.trig("GetLanguageFlag"),
    }
    return req.post(url.login.device, data, oncomplete, onfailed)
end
reqDefaultListeners[url.login.device] = function(www)
    local data = www.val
    local LoginModel = require("ui.models.login.LoginModel")
    LoginModel.SetServers(data.servers)
    if type(data) == "table" and type(data.account) == "table" and data.account.aid then
        LoginModel.SetAccount(data.account)
    end
    if type(LoginModel.SetCurrentServer) == "function" then
        local players = LoginModel.GetPlayers()
        if type(players) == "table" and #players > 0 then
            LoginModel.SetCurrentServer(players[1])
        else
            local servers = LoginModel.GetServers()
            if type(servers) == "table" and #servers > 1 then
                LoginModel.SetCurrentServer(servers[1])
            else
                LoginModel.SetCurrentServer()
            end
        end
    end
end

function req.bulletin(channel, oncomplete, onfailed)
    local data = {
        capid = clr.capid(),
        pf = clr.plat,
        channel = channel,
        bichannel = luaevt.trig("SDK_GetChannel"),
    }
    return req.post(url.bulletin, data, oncomplete, onfailed)
end

function req.unitedlogin(pf, cuid, channel, bichannel, uinfo, oncomplete, onfailed)
    local data = {
        capid = clr.capid(),
        udid = luaevt.trig("GetUDID") or clr.capid(),
        pf = pf,
        channel = channel,
        cuid = cuid,
        bichannel = bichannel,
        uinfo = uinfo,
    }
    return req.post(url.login.unitedlogin, data, oncomplete, onfailed)
end

reqDefaultListeners[url.login.unitedlogin] = reqDefaultListeners[url.login.device]

function req.eBind(email, password, oncomplete, onfailed)
    local data = {
        capid = clr.capid(),
        email = email,
        pwd = password,
        confirm = password,
        bichannel = luaevt.trig("SDK_GetChannel"),
    }
    return req.post(url.login.ebind, data, oncomplete, onfailed)
end
reqDefaultListeners[url.login.ebind] = reqDefaultListeners[url.login.device]

function req.create(aid, name, tid, logo, province, city, teamName, clothes, oncomplete, onfailed)
    local data = {
        capid = clr.capid(),
        aid = aid,
        name = name,
        tid = tid,
        logo = logo,
        province = province,
        city = city,
        teamName = teamName,
        clothes = clothes,
        bichannel = luaevt.trig("SDK_GetChannel"),
    }
    return req.post(url.login.create, data, oncomplete, onfailed)
end

function req.player(oncomplete, onfailed)
    local data = {
        capid = clr.capid(),
        plat = clr.plat,
        ver = _G["___resver"],
        flags = clr.table(clr.Capstones.UnityFramework.ResManager.GetDistributeFlags()),
        bichannel = luaevt.trig("SDK_GetChannel"),
        jsonUpdate = {},
        app = luaevt.trig('SDK_GetAppId'),
        appver = luaevt.trig('SDK_GetAppVerCode'),
        lang = luaevt.trig("GetLanguageFlag"),
    }
    return req.post(url.login.player, data, oncomplete, onfailed)
end
reqDefaultListeners[url.login.player] = function(www)
    local data = www.val
    cache.setPlayerInfo(data.info)
    cache.setQuestInfo(data.quest)
    if type(data) == 'table' and type(data.info) == 'table' and api.bool(data.info.token) then
        api.setToken(data.info.token)
    end
    if data.guide then
        cache.setPlayerGuide(data.guide)
    end
end

function req.homeBannerAds(oncomplete, onfailed, quiet)
    return req.post(url.login.homeBannerAds, nil, oncomplete, onfailed, quiet)
end

-- bi打点
function req.biStartup(step, seq, extra, oncomplete, onfailed, quiet)
    local ratiow, ratioh = luaevt.trig("GetRatio")
    local ratio = tostring(ratioh) .. "*" .. tostring(ratiow)
    local appVerCode = luaevt.trig("SDK_GetAppVerCode")
    appVerCode = tostring(appVerCode)
    local data = {
        appVer = appVerCode,
        udid = luaevt.trig("GetUDID"),
        osv = luaevt.trig("GetSysVersionNum"),
        model = luaevt.trig("GetPhoneType"),
        oper = luaevt.trig("GetNetOperName"),
        net = luaevt.trig("GetNetType"),
        mac = luaevt.trig("GetMacAddr"),
        imei = luaevt.trig("GetImei"),
        bichannel = luaevt.trig("SDK_GetChannel"),
        phoneTime = luaevt.trig("GetPhoneTime"),
        memTotal = luaevt.trig("GetMemTotal"),
        memAvail = luaevt.trig("GetMemAvail"),
        deviceModel = SystemInfo.deviceModel,
        deviceUniqueIdentifier = SystemInfo.deviceUniqueIdentifier,
        graphicsDeviceName = SystemInfo.graphicsDeviceName,
        graphicsDeviceType = SystemInfo.graphicsDeviceType.ToString(),
        graphicsDeviceVersion = SystemInfo.graphicsDeviceVersion,
        operatingSystem = SystemInfo.operatingSystem,
        processorType = SystemInfo.processorType,
        systemMemorySize = SystemInfo.systemMemorySize,
        ratio = ratio,
        capid = clr.capid(),
        plat = clr.plat,
        step = step,
        seq = seq,
        pid = cache.getPlayerInfo() and cache.getPlayerInfo()._id or "",
        sid = cache.getCurrentServer() and cache.getCurrentServer().id or "",
        cuid = cache.getCuid() or "",
    }
    if type(extra) == "table" then
        table.merge(data, extra)
    end
    return req.post(url.bi.startup, data, oncomplete, onfailed, quiet)
end

function req.cardLock(pcid, changeLock, oncomplete, onfailed)
    local data = {
        tpcid = pcid,
        lock = changeLock,
    }
    return req.post(url.card.lock, data, oncomplete, onfailed)
end

function req.getPieceStoreList(oncomplete, onfailed, quiet)
    return req.post(url.card.getPieceStoreList, nil, oncomplete, onfailed, quiet)
end

function req.cardIncorporate(cid, oncomplete, onfailed)
    local data = {
        cid = cid
    }
    return req.post(url.card.incorporate, data, oncomplete, onfailed)
end

function req.cardIncorporateSpecial(cid, oncomplete, onfailed)
    local data = {
        cid = cid
    }
    return req.post(url.card.incorporateSpecial, data, oncomplete, onfailed)
end

function req.cardIncorporateAssistantCoachInfo(cpid, oncomplete, onfailed)
    local data = {
        cpid = cpid
    }
    return req.post(url.card.incorporateAssistantCoachInfo, data, oncomplete, onfailed)
end

-- 大卡更多信息
function req.cardAccess(cid, oncomplete, onfailed)
    local data = {
        cid = cid
    }
    return req.post(url.card.cardAccess, data, oncomplete, onfailed)
end

function req.cardTrainIntellect(pcid, num, selectAttr, oncomplete, onfailed)
    local data = {
        pcid = pcid,
        num = num, 
        select = selectAttr
    }
    return req.post(url.card.trainIntellect, data, oncomplete, onfailed)
end

function req.cardTrainingInfo(pcid, oncomplete, onfailed)
    local data = {
        pcid = pcid
    }
    return req.post(url.card.training.info, data, oncomplete, onfailed)
end

-- 灌经验
function req.cardTrainingAddExp(pcid, itemId, num, trainId, subId, oncomplete, onfailed)
    local data = {
        pcid = pcid,
        itemId = itemId,
        num = num,
        trainId = trainId,
        subId = subId
    }
    return req.post(url.card.training.addExp, data, oncomplete, onfailed)
end

-- 完成之后回信
function req.cardTrainingFinish(pcid, trainId, subId, option, oncomplete, onfailed)
    local data = {
        pcid = pcid,
        trainId = trainId,
        subId = subId,
        option = option
    }
    return req.post(url.card.training.finish, data, oncomplete, onfailed)
end

-- 球员特训消耗物品
function req.cardTrainingDemand(pcid, trainId, subId, contents, oncomplete, onfailed)
    local data = {
        pcid = pcid,
        trainId = trainId,
        subId = subId,
        item = contents
    }
    return req.post(url.card.training.demand, data, oncomplete, onfailed)
end

function req.changeEffect(pcid, trainId, subId, option, oncomplete, onfailed)
    local data = {
        pcid = pcid,
        trainId = trainId,
        subId = subId,
        option = option
    }
    return req.post(url.card.training.changeEffect, data, oncomplete, onfailed)
end

function req.cardTrainingCheckSubTrainComplete(pcid, trainId, subId, oncomplete, onfailed)
    local data = {
        pcid = pcid,
        trainId = trainId,
        subId = subId,
    }
    return req.post(url.card.training.checkSubTrainComplete, data, oncomplete, onfailed)
end

function req.cardTrainingOpen(pcid, trainId, oncomplete, onfailed)
    local data = {
        pcid = pcid,
        trainId = trainId
    }
    return req.post(url.card.training.open, data, oncomplete, onfailed)
end

function req.cardSell(pcids, oncomplete, onfailed)
    local data = {
        pcids = pcids
    }
    return req.post(url.card.sell, data, oncomplete, onfailed)
end

function req.cardUpgradeEquips(pcid, slots)
    local data = {
        pcid = pcid,
        slots = slots
    }
    return req.post(url.card.upgradeEquips, data)
end

function req.cardUpgradeEquipsDirect(eid, pcid, slots)
    local data = {
        eid = eid,
        pcid = pcid,
        slots = slots
    }
    return req.post(url.card.upgradeEquipsDirect, data)
end

function req.cardOnekeyEquip(pcid, equips, equipPieces)
    local data = {
        pcid = pcid,
        equips = equips,
        equipPieces = equipPieces
    }
    return req.post(url.card.quickUpgrade, data)
end

function req.cardUpgrade(pcid)
    local data = {
        pcid = pcid
    }
    return req.post(url.card.upgrade, data)
end
reqDefaultListeners[url.card.upgrade] = function(www)
    local data = www.val
    local heroHallMapModel = require("ui.models.heroHall.main.HeroHallMapModel").new()
    heroHallMapModel:UpdateUpgradeImproveByCid(data.card.cid, data.card)
end

function req.cardAscend(pcid, targetPcid)
    local data = {
        pcid = pcid,
        targetPcid = targetPcid
    }
    return req.post(url.card.ascend, data)
end
reqDefaultListeners[url.card.ascend] = function(www)
    local data = www.val
    local heroHallMapModel = require("ui.models.heroHall.main.HeroHallMapModel").new()
    heroHallMapModel:UpdateAscendImproveByCid(data.card.cid, data.card)
end

function req.cardAdvance(pcid)
    local data = {
        pcid = pcid
    }
    return req.post(url.card.advance, data)
end

function req.cardAdvanceConfirm(pcid)
    local data = {
        pcid = pcid
    }
    return req.post(url.card.advanceConfirm, data)
end   

-- @param diffLvl 需要加的等级数
function req.cardSkillLvlUp(pcid, slot, costType, diffLvl)
    local data = {
        pcid = pcid,
        slot = slot,
        costType = costType,
        maxlv = diffLvl
    }
    return req.post(url.card.skillLvlUp, data)
end

function req.cardAddExp(pcid, itemID, num)
    local data = {
        pcid = pcid,
        itemID = itemID,
        num = num
    }
    return req.post(url.card.addExp, data)
end

function req.cardChemicalTabChange(pcid, chemicalTab, oncomplete, onfailed, quiet)
    local data = {
        pcid = pcid,
        chemicalTab = chemicalTab,
    }
    return req.post(url.card.changeCardChemicalTab, data, oncomplete, onfailed, quiet)
end

-- 球员助阵
function req.cardEquipSupporter(pcid, spcid, stType, slrType, oncomplete, onfailed, quiet)
    local data = {
        pcid = pcid,
        spcid = spcid,
        stType = stType,
        slrType = slrType,
    }
    return req.post(url.card.supporter.equipSupporter, data, oncomplete, onfailed, quiet)
end

function req.cardUnEquipSupporter(pcid, oncomplete, onfailed, quiet)
    local data = {
        pcid = pcid
    }
    return req.post(url.card.supporter.unEquipSupporter, data, oncomplete, onfailed, quiet)
end

-- 阵型界面：保存阵容
-- @param nowTeamId 阵容Id
-- @param nowFormationId 阵型Id
-- @param initPlayersData 首发球员数据
-- @param replacePlayersData 替补球员数据
-- @param teamType  球队类型定义：普通或者竞技场
function req.saveTeam(nowTeamId, nowFormationId, initPlayersData, replacePlayersData, teamType, keyPlayersData, tacticsData, selectedType, isDefaultFormation, oncomplete, onfailed)
    local data = {
        ptid = nowTeamId,
        formationID = nowFormationId,
        init = initPlayersData,
        rep = replacePlayersData,
        teamType = teamType,
        freeKickShoot = keyPlayersData.freeKickShoot,
        spotKick = keyPlayersData.spotKick,
        captain = keyPlayersData.captain,
        freeKickPass = keyPlayersData.freeKickPass,
        corner = keyPlayersData.corner,
        tactics = tacticsData,
        selectedType = selectedType,
        isDefaultFormation = isDefaultFormation
    }
    return req.post(url.team.save, data, oncomplete, onfailed)
end

-- 设置选择使用的阵容
function req.teamUsed(nowTeamId, teamType, oncomplete, onfailed)
    local data = {
        ptid = nowTeamId,
        teamType = teamType,
    }
    return req.post(url.team.used, data, oncomplete, onfailed)
end

-- 一键清空阵容
function req.teamClear(nowTeamId,teamType,oncomplete,onfailed)
    local data = {
        ptid = nowTeamId,
        teamType = teamType
    }
    return req.post(url.team.clearTeam, data, oncomplete, onfailed)
end

-- 获取阵型数据
function req.teamIndex(oncomplete, onfailed)
    return req.post(url.team.index, nil, oncomplete, onfailed)
end

-- 设置我的场景
function req.setScenario(data, oncomplete, onfailed)
	return req.post(url.team.setScenario, data, oncomplete, onfailed)
end

-- 请求主线关卡信息
function req.questInfo(oncomplete, onfailed)
    return req.post(url.quest.info, nil, oncomplete, onfailed)
end
reqDefaultListeners[url.quest.info] = function(www)
    local data = www.val
    EventSystem.SendEvent("Quest_OnSpanDay", data)
    cache.setQuestInfo(data)
end

-- 主线关卡：开始比赛
-- @param stageId 关卡Id
function req.questAccept(stageId, oncomplete, onfailed)
    local data = {
        qid = stageId,
    }

    return req.post(url.quest.accept, data, oncomplete, onfailed)
end

function req.questSweep(stageId, oncomplete, onfailed)
    local data = {
        qid = stageId,
    }
    return req.post(url.quest.sweep, data, oncomplete, onfailed)
end

function req.questSweepTen(stageId, sweepTime, oncomplete, onfailed)
    local data = {
        qid = stageId,
        cnt = sweepTime,
    }
    return req.post(url.quest.sweepTen, data, oncomplete, onfailed)
end

function req.questReadStory(stageId, showPos, oncomplete, onfailed)
    local data = {
        qid = stageId,
        step = showPos,
    }
    return req.post(url.quest.readStory, data, oncomplete, onfailed)
end

-- 重置副本的条件信息
function req.questResetCost(qid, oncomplete, onfailed)
    local data = {
        qid = qid
    }
    return req.post(url.quest.resetCost, data, oncomplete, onfailed)
end

-- 真正的重置副本
function req.questReset(qid, oncomplete, onfailed)
    local data = {
        qid = qid
    }
    return req.post(url.quest.reset, data, oncomplete, onfailed)
end

-- 装备合成
function req.equipIncorporate(eid, count, oncomplete, onfailed)
    local data = {
        eid = eid,
        num = count
    }
    return req.post(url.equip.incorporate, data, oncomplete, onfailed)
end

-- 邮件列表
function req.mail(oncomplete, onfailed, quiet)
    local data = {}
    return req.post(url.mail.mail, data, oncomplete, onfailed, quiet)
end

-- 邮件读取
function req.mailCollect(mailType, mid)
    local data = {
        ["type"] = mailType,
        mid = mid,
    }
    return req.post(url.mail.collect, data, oncomplete, onfailed)
end

-- 邮件一键读取
function req.mailCollectAll(oncomplete, onfailed)
    return req.post(url.mail.collectAll, nil, oncomplete, onfailed)
end


-- 比赛结束
function req.matchOver(matchResult, oncomplete, onfailed)
    return req.post(url.match.match, matchResult, oncomplete, onfailed)
end

-- 奖励列表
function req.rewardInfo(oncomplete, onfailed)
    local data = {}
    return req.post(url.reward.info, data, oncomplete, onfailed)
end

-- 领取奖励
function req.rewardReceive(rewardID, oncomplete, onfailed)
    local data = {
        rewardID = rewardID,
    }
    return req.post(url.reward.receive, data, oncomplete, onfailed)
end

-- 客户端上报任务完成(share类)
function req.rewardFinish(rewardID, oncomplete, onfailed)
    local data = {
        rewardID = rewardID,
    }
    return req.post(url.reward.finishCondition, data, oncomplete, onfailed)
end

-- 请求球员来信数据
function req.playerLetterInfo(oncomplete, onfailed)
    return req.post(url.letter.info, nil, oncomplete, onfailed)
end

-- 阅读来信
function req.playerLetterRead(letterId, oncomplete, onfailed)
    local data = {
        ID = letterId,
    }
    return req.post(url.letter.read, data, oncomplete, onfailed)
end

-- 球员信函领取奖励
function req.playerLetterReceiveReward(letterId, oncomplete, onfailed)
    local data = {
        ID = letterId,
    }
    return req.post(url.letter.receive, data, oncomplete, onfailed)
end

-- 转会市场信息
function req.transferInfo(oncomplete, onfailed)
    local data = {}
    return req.post(url.transfer.info, data, oncomplete, onfailed)
end

-- 刷新转会市场
function req.transferRefresh(oncomplete, onfailed)
    local data = {}
    return req.post(url.transfer.refresh, data, oncomplete, onfailed)
end

-- 转会市场签约
function req.transferSign(pos, oncomplete, onfailed)
    local data = {
        pos = pos,
    }
    return req.post(url.transfer.sign, data, oncomplete, onfailed)
end

-- 获取充值列表
function req.storeChargeList(oncomplete, onfailed)
    return req.post(url.store.chargelist, nil, oncomplete, onfailed)
end

-- 获取商城商品列表
function req.storeItemList(oncomplete, onfailed, quiet)
    return req.post(url.store.itemlist, nil, oncomplete, onfailed, quiet)
end

-- 购买商品
function req.storeItemBuy(productId, num, oncomplete, onfailed)
    local data = {
        ID = productId,
        cnt = num or 1,
    }
    return req.post(url.store.itembuy, data, oncomplete, onfailed)
end

function req.payInit(productId, full18, oncomplete, onfailed)
    local ratiow, ratioh = luaevt.trig("GetRatio")
    local data = {
        product = productId,
        notfull18 = full18 and 0 or 1,
        device = {
            capid = clr.capid(),
            udid = luaevt.trig("GetUDID"),
            osv = luaevt.trig("GetSysVersionNum"),
            model = luaevt.trig("GetPhoneType"),
            oper = luaevt.trig("GetNetOperName"),
            net = luaevt.trig("GetNetType"),
            width = ratiow,
            height = ratioh,
            mac = luaevt.trig("GetMacAddr"),
            imei = luaevt.trig("GetImei"),
            pf = clr.plat,
            bichannel = luaevt.trig("SDK_GetChannel"),
        }
    }
    return req.post(url.pay.init, data, oncomplete, onfailed)
end

function req.payTest(orderId, oncomplete, onfailed)
    local data = {
        orderID = orderId,
    }
    return req.post(url.pay.test, data, oncomplete, onfailed)
end

function req.payCheckArrived(orderId, oncomplete, onfailed, quiet)
    local data = {
        orderID = orderId,
    }
    return req.post(url.pay.checkArrived, data, oncomplete, onfailed, quiet)
end

function req.setPlayerInfo(oncomplete, onfailed, quiet)
    return req.post(url.player.info, nil, oncomplete, onfailed, quiet)
end

function req.playerHomeEvent(oncomplete, onfailed, quiet)
    return req.post(url.player.homeEvent, nil, oncomplete, onfailed, quiet)
end

function req.getGsSetting(oncomplete, onfailed, quiet)
    return req.post(url.player.getGsSetting, nil, oncomplete, onfailed, quiet)
end

function req.setTeamLogo(logo, oncomplete, onfailed)
    local data
    if type(logo) == "table" then
        data = {
            logo = {
                figureId = logo.iconId,
                boardId = logo.boardId,
                frameId = logo.borderId,
                ribbonId = logo.ribbonId,
                colorId = logo.colorId,
            },
        }
    else
        data = {
            logo = logo,
        }
    end
    return req.post(url.player.teamlogo, data, oncomplete, onfailed)
end

function req.changeTeamLogo(logo, oncomplete, onfailed)
    local data
    if type(logo) == "table" then
        data = {
            logo = {
                figureId = logo.iconId,
                boardId = logo.boardId,
                frameId = logo.borderId,
                ribbonId = logo.ribbonId,
                colorId = logo.colorId,
            },
        }
    else
        data = {
            logo = logo,
        }
    end
    return req.post(url.player.changeLogo, data, oncomplete, onfailed)
end

function req.setTeamName(teamName, oncomplete, onfailed)
    local data = {
        name = teamName,
    }
    return req.post(url.player.teamname, data, oncomplete, onfailed)
end

-- 修改队名
function req.changeTeamName(teamName, oncomplete, onfailed)
    local data = {
        name = teamName,
    }
    return req.post(url.player.changeName, data, oncomplete, onfailed)
end

-- 设置界面的回调，看是否免费更改
function req.setting(oncomplete, onfailed)
    return req.post(url.player.setting, nil, oncomplete, onfailed)
end

-- 设置语言
function req.setLang(lang, oncomplete, onfailed)
    local data = {
        lang = lang,
    }
    return req.post(url.player.setLang, data, oncomplete, onfailed)
end

function req.setTeamUniform(homeUniformData, awayUniformData, homeGkUniformData, awayGkUniformData, smallUniformId, gkSmallUniformId, spectators, oncomplete, onfailed)
    local TeamUniformModel = require("ui.models.common.TeamUniformModel")
    local data = {
        shirt = {
            [TeamUniformModel.UniformType.Home] = homeUniformData,
            [TeamUniformModel.UniformType.Away] = awayUniformData,
            [TeamUniformModel.UniformType.HomeGk] = homeGkUniformData,
            [TeamUniformModel.UniformType.AwayGk] = awayGkUniformData,
            small = smallUniformId,
            gkSmall = gkSmallUniformId,
        },
        spectators = spectators,
    }
    return req.post(url.player.teamuniform, data, oncomplete, onfailed)
end

function req.changeTeamUniform(homeUniformData, awayUniformData, homeGkUniformData, awayGkUniformData, smallUniformId, gkSmallUniformId, spectators, oncomplete, onfailed)
    local TeamUniformModel = require("ui.models.common.TeamUniformModel")
    homeUniformData.logo = nil
    awayUniformData.logo = nil
    homeGkUniformData.logo = nil
    awayGkUniformData.logo = nil
    local data = {
        shirt = {
            [TeamUniformModel.UniformType.Home] = homeUniformData,
            [TeamUniformModel.UniformType.Away] = awayUniformData,
            [TeamUniformModel.UniformType.HomeGk] = homeGkUniformData,
            [TeamUniformModel.UniformType.AwayGk] = awayGkUniformData,
            small = smallUniformId,
            gkSmall = gkSmallUniformId,
        },
        spectators = spectators,
    }
    return req.post(url.player.changeShirt, data, oncomplete, onfailed)
end

function req.useSpecificTeam(id, use, oncomplete, onfailed)
    local data = {
        use = use,
        ID = id
    }
    return req.post(url.player.useSpecificTeam, data, oncomplete, onfailed)
end

function req.playerShareInfo(oncomplete, onfailed)
    local data = {}
    return req.post(url.player.shareInfo, data, oncomplete, onfailed)
end

function req.littleGameInfo(oncomplete, onfailed)
    local data = {}
    return req.post(url.littleGame.info, data, oncomplete, onfailed)
end

function req.littleGamePlay(gameID, pcid, result, oncomplete, onfailed)
    local data = {
        gameID = gameID,
        pcid = pcid,
        result = result
    }
    return req.post(url.littleGame.play, data, oncomplete, onfailed)
end

function req.littleGameSweep(gameID, pcid, oncomplete, onfailed)
    local data = {
        gameID = gameID,
        pcid = pcid
    }
    return req.post(url.littleGame.sweep, data, oncomplete, onfailed)
end

function req.littleGameQuestionInfo(oncomplete, onfailed)
    return req.post(url.littleGame.questionInfo, nil, oncomplete, onfailed)
end

function req.littleGameBeginAnswer(pcid, oncomplete, onfailed)
    local data = {
        pcid = pcid
    }
    return req.post(url.littleGame.beginAnswer, data, oncomplete, onfailed)
end

function req.littleGameAnswer(id, result, useTime, oncomplete, onfailed)
    local data = {
        id = id,
        result = result,
        useTime = useTime,
    }
    return req.post(url.littleGame.answer, data, oncomplete, onfailed)
end

function req.littleGameRankInfo(gameType, oncomplete, onfailed)
    local data = {
        cate = gameType
    }
    return req.post(url.littleGame.rankInfo, data, oncomplete, onfailed)
end

-- 获取联赛基本信息
function req.leagueIndex(oncomplete, onfailed)
    return req.post(url.league.index, nil, oncomplete, onfailed)
end

-- 获取联赛进入信息
function req.leagueEnter(oncomplete, onfailed)
    return req.post(url.league.enter, nil, oncomplete, onfailed)
end

-- 联赛选择赞助商
function req.leagueSponsor(sponsorId, oncomplete, onfailed)
    local data = {
        id = sponsorId,
    }
    return req.post(url.league.sponsor, data, oncomplete, onfailed)
end

-- 获取联赛赛程表
function req.leagueSchedule(oncomplete, onfailed)
    return req.post(url.league.schedule, nil, oncomplete, onfailed)
end

-- 获取联赛赛季信息
function req.leagueSeasonInfo(oncomplete, onfailed)
    return req.post(url.league.report, nil, oncomplete, onfailed)
end

-- 联赛开始比赛
function req.leagueStartMatch(oncomplete, onfailed)
    return req.post(url.league.start, nil, oncomplete, onfailed)
end

-- 联赛扫荡
function req.leagueSweep(oncomplete, onfailed)
    return req.post(url.league.sweep, nil, oncomplete, onfailed)
end

-- 联赛赛季奖励接口
function req.leagueReward(oncomplete, onfailed)
    return req.post(url.league.reward, nil, oncomplete, onfailed)
end

-- 联赛排行榜
function req.leaguRank(oncomplete, onfailed)
    return req.post(url.league.rank, nil, oncomplete, onfailed)
end

-- 联赛榜单
function req.leagueBoard(boardType, oncomplete, onfailed)
    local data = {
        ["type"] = boardType,
    }
    return req.post(url.league.board, data, oncomplete, onfailed)
end

-- 开启新赛季
function req.leagueNewSeason(oncomplete, onfailed)
    return req.post(url.league.newSeason, nil, oncomplete, onfailed)
end

-- 购买联赛挑战次数
function req.leagueBuyChallengeTimes(oncomplete, onfailed)
    return req.post(url.league.buy, nil, oncomplete, onfailed)
end

function req.remoteDebug_setResult(data, oncomplete, onfailed)
    return req.post(url.remoteDebug.setResult, data, oncomplete, onfailed)
end

function req.remoteDebug_getString(oncomplete ,onfailed)
    return req.post(url.remoteDebug.getString, nil, oncomplete, onfailed)
end

function req.spRecover(oncomplete ,onfailed, quiet)
    return req.post(url.user.spRecover, nil, oncomplete, onfailed, quiet)
end

function req.getStrengthInfo(oncomplete ,onfailed, quiet)
    return req.post(url.user.getSPInfo, nil, oncomplete, onfailed, quiet)
end

function req.buyStrength(oncomplete ,onfailed)
    return req.post(url.user.buySP, nil, oncomplete, onfailed)
end

function req.playerGuide(moduleType, step, oncomplete, onfailed, quiet)
    local data = {
        module = moduleType,
        step = step
    }
    return req.post(url.player.guide, data, oncomplete, onfailed, quiet)
end

function req.storeInfo(oncomplete, onfailed)
    local data = {
        -- ids = require("ui.models.gacha.GachaMainModel").StaticType,
        ids = {}
    }
    return req.post(url.store.info, data, oncomplete, onfailed)
end

function req.storeView(tag, oncomplete, onfailed)
    local data = {
        id = tag,
    }
    return req.post(url.store.view, data, oncomplete, onfailed, true)
end

function req.buyOneCard(tag, oncomplete, onfailed)
    local data = {id = tag}
    return req.post(url.store.one, data, oncomplete, onfailed)
end

function req.buyTenCard(tag, oncomplete, onfailed)
    local data = {id = tag}
    return req.post(url.store.ten, data, oncomplete, onfailed)
end

function req.storeDay(oncomplete, onfailed)
    return req.post(url.store.index, nil, oncomplete, onfailed)
end

function req.vipInfo(oncomplete, onfailed)
    return req.post(url.store.vipinfo, nil, oncomplete, onfailed)
end

function req.buyVIPBag(id, oncomplete, onfailed)
    local data = {ID = id}
    return req.post(url.store.vipbag, data, oncomplete, onfailed)
end

function req.giftBoxList(oncomplete, onfailed)
    return req.post(url.store.giftBox, nil, oncomplete, onfailed)
end

function req.buyGiftBox(product, oncomplete, onfailed)
    local data = {
        product = product
    }
    return req.post(url.store.buyGiftBox, data, oncomplete, onfailed)
end

-- 使用豪门币购买商店的礼盒
function req.buyGiftBoxByBlackDiamond(product, oncomplete, onfailed)
    local data = {
        product = product
    }
    return req.post(url.store.buyGiftBoxByBlackDiamond, data, oncomplete, onfailed)
end

function req.useItem(id, count, selectID, oncomplete, onfailed)
    local data = {
        id = id,
        num = count,
        selectID = selectID
    }
    return req.post(url.store.useItem, data, oncomplete, onfailed)
end

-- 一键使用
function req.multiUseItem(id)
    local data = {
        id = id
    }
    return req.post(url.store.multiUseItem, data, oncomplete, onfailed)
end

function req.cardExchange(targetPcid, exchangePcid1, exchangePcid2, oncomplete, onfailed)
    local data = {
        targetPcid = targetPcid,
        sourcePcids = {exchangePcid1, exchangePcid2}
    }
    return req.post(url.store.cardExchange, data, oncomplete, onfailed)
end

function req.mysteryInfo(oncomplete, onfailed)
    return req.post(url.store.mysteryInfo, nil, oncomplete, onfailed, true)
end

function req.refreshMystery(oncomplete, onfailed)
    return req.post(url.store.refreshMystery, nil, oncomplete, onfailed)
end

function req.buyMystery(pos, oncomplete, onfailed)
    local data = 
    {
        pos = pos
    }
    return req.post(url.store.buyMystery, data, oncomplete, onfailed)
end

-- 抽卡的卡库
function req.gachaDetail(gachaId)
    local data = 
    {
        id = gachaId
    }
    return req.post(url.store.gachaDetail, data, oncomplete, onfailed)
end

function req.cardExchangeInfo( oncomplete, onfailed)
    return req.post(url.store.exchangeInfo, nil, oncomplete, onfailed, true)
end

function req.vip14Store( oncomplete, onfailed)
    return req.post(url.store.vip14Store, nil, oncomplete, onfailed)
end

function req.vip14ShopBuy(boxId, num, oncomplete, onfailed)
    local data = 
    {
        boxId = boxId,
        num = num
    }
    return req.post(url.store.vip14ShopBuy, data, oncomplete, onfailed)
end

function req.sampleMatchEnd(oncomplete, onfailed)
    return req.post(url.player.samplematch, nil, oncomplete, onfailed)
end

-- 查看所有好友
function req.friendsListFriends(oncomplete, onfailed)
    return req.post(url.friends.listFriends, nil, oncomplete, onfailed)
end

-- 删除好友
function req.friendsRemove(pid, sid, oncomplete, onfailed)
    local data = {
        pid = pid,
        sid = sid
    }
    return req.post(url.friends.remove, data, oncomplete, onfailed)
end

-- 赠送体力
function req.friendsDonateSp(pid, sid, oncomplete, onfailed)
    local data = {
        pid = pid,
        sid = sid
    }
    return req.post(url.friends.donateSp, data, oncomplete, onfailed)
end

function req.friendsDonateSpAll(oncomplete, onfailed)
    return req.post(url.friends.donateSpAll, nil, oncomplete, onfailed)
end

-- 好友主页
function req.friendsIndex(oncomplete, onfailed)
    return req.post(url.friends.index, nil, oncomplete, onfailed)
end

-- 领取体力
function req.friendsReceiveSp(type, id, oncomplete, onfailed)
    local data = {
        type = type,
        id = id
    }
    return req.post(url.friends.receiveSp, data, oncomplete, onfailed)
end

-- 查找好友
function req.friendsFind(name, sid, oncomplete, onfailed)
    local data = {
        name = name,
        sid = tostring(sid),
        type = 0
    }
    return req.post(url.friends.find, data, oncomplete, onfailed)
end

-- FaceBook好友
function req.facebookList(socialIdList, oncomplete, onfailed)
    local data = {
        socialIdList = socialIdList,
    }
    return req.post(url.friends.facebookId, data, oncomplete, onfailed)
end

-- 发送好友申请
function req.friendsRequest(arrayData, oncomplete, onfailed)
    return req.post(url.friends.request, arrayData, oncomplete, onfailed)
end

-- 查看好友申请
function req.friendsListRequest(oncomplete, onfailed)
    return req.post(url.friends.listRequest, nil, oncomplete, onfailed)
end

-- 通过好友申请
function req.friendsAccept(pid, sid, oncomplete, onfailed)
    local data = {
        pid = pid,
        sid = sid
    }
    return req.post(url.friends.accept, data, oncomplete, onfailed)
end

--拒绝好友申请
function req.friendsReject(pid, sid, oncomplete, onfailed)
    local data = {
        pid = pid,
        sid = sid
    }
    return req.post(url.friends.reject, data, oncomplete, onfailed)
end

-- 发起友谊赛
function req.friendsMatch(pid, sid, oncomplete, onfailed)
    local data = {
        pid = pid,
        sid = sid
    }
    return req.post(url.friends.match, data, oncomplete, onfailed)
end

-- 查看友谊赛记录
function req.friendsListRecords(oncomplete, onfailed)
    return req.post(url.friends.listRecords, nil, oncomplete, onfailed)
end

-- 删除友谊赛记录
function req.friendsDelRecord(type, id, oncomplete, onfailed)
    local data = {
        type = type,
        id = id
    }
    return req.post(url.friends.delRecord, data, oncomplete, onfailed)
end

-- 查看好友详情
function req.friendsDetail(pid, sid, oncomplete, onfailed)
    local data = {
        pid = pid,
        sid = sid
    }
    return req.post(url.friends.detail, data, oncomplete, onfailed)
end

-- 查看主页个人详情（带主场特性）(默认为主阵型，主场，晴天，普通草)
function req.homeDetail(pid, sid, matchType, home, weather, grass, oncomplete, onfailed)
    local data = {
        pid = pid,
        sid = sid,
        matchType = matchType,
        scenario = {
            home = home,
            weather = weather,
            grass = grass,
        }
    }
    return req.post(url.friends.detailGuide, data, oncomplete, onfailed)
end

-- 查看友谊赛比赛录像
function req.friendsVideo(vid, oncomplete, onfailed)
    local data = {
        videoID = vid
    }
    return req.post(url.friends.video, data, oncomplete, onfailed)
end

function req.friendsCardDetail(pid, sid, pcid, oncomplete, onfailed)
    local data = {
        pid = pid,
        sid = sid,
        pcid = pcid
    }
    return req.post(url.friends.cardDetail, data, oncomplete, onfailed)
end

-- 图鉴
function req.cardIndex(oncomplete, onfailed)
    return req.post(url.album.get, nil, oncomplete, onfailed)
end

-- 查看活动列表
function req.activityList(oncomplete, onfailed, quiet)
    return req.post(url.activity.activityList, nil, oncomplete, onfailed, quiet)
end

-- 查看某活动
function req.activityRead(type, pid, oncomplete, onfailed, quiet)
    local data = {
        ["type"] = type,
        id = pid
    }
    return req.post(url.activity.read, data, oncomplete, onfailed, quiet)
end

-- 领取活动奖励
function req.activityReceive(type, subId, oncomplete, onfailed, quiet)
    local data = {
        ["type"] = type,
        id = subId
    }
    return req.post(url.activity.receive, data, oncomplete, onfailed, quiet)
end

-- 每日签到（活动）
function req.activitySign(oncomplete, onfailed, quiet)
    return req.post(url.activity.sign, nil, oncomplete, onfailed, quiet)
end

-- 首充（活动）
function req.activityFirstPay(type, pid, oncomplete, onfailed, quiet)
    local data = {
        ["type"] = type,
        id = pid
    }
    return req.post(url.activity.firstPay, data, oncomplete, onfailed, quiet)
end

-- 首充活動
function req.activityFirstPayInfo(oncomplete, onfailed)
	return req.post(url.activity.firstPayInfo, nil, oncomplete, onfailed)
end

-- 累积消耗（活动）
function req.activityCumulativeConsume(type, subId, oncomplete, onfailed, quiet)
    local data = {
        ["type"] = type,
        id = subId,
    }
    return req.post(url.activity.cumulativeConsume, data, oncomplete, onfailed, quiet)
end

-- 累积充值（活动）
function req.activityCumulativePay(type, sudId, oncomplete, onfailed, quiet)
    local data = {
        ["type"] = type,
        id = sudId
    }
    return req.post(url.activity.cumulativeConsume, data, oncomplete, onfailed, quiet)
end

-- 累积登陆(活动)
function req.activityCumulativeLogin(type, subId, oncomplete, onfailed, quiet)
    local data = {
        ["type"] = type,
        ["id"] = subId
    }
    return req.post(url.activity.cumulativeLogin, data, oncomplete, onfailed, quiet)
end

-- 讨伐战（活动）
function req.activityTimeLimitChallenge(oncomplete, onfailed, quiet)
    return req.post(url.activity.activityTimeLimitChallengeInfo, nil, oncomplete, onfailed, quiet)
end

function req.activityConfederationsCupFight(subId, oncomplete, onfailed, quiet)
    local data = {
        subId = subId
    }
    return req.post(url.activity.activityConfederationsCupFight, data, oncomplete, onfailed, quiet)
end

function req.activityTimeLimitChallengeFight(subId, oncomplete, onfailed, quiet)
    local data = {
        subId = subId
    }
    return req.post(url.activity.activityTimeLimitChallengeFight, data, oncomplete, onfailed, quiet)
end

function req.activityTimeLimitChallengeReceiveReward(type, id, oncomplete, onfailed, quiet)
    local data = {
        ["type"] = type,
        id = id
    }
    return req.post(url.activity.activityTimeLimitChallengeReceiveReward, data, oncomplete, onfailed, quiet)
end

-- 购买成长计划
function req.activityBuyGrowthPlan(type, id, oncomplete, onfailed, quiet)
    local data = {
        ["type"] = type, 
        id = id,
    }
    return req.post(url.activity.buyGrowthPlan, data, oncomplete, onfailed, quiet)
end

-- 点击参与拜仁抽奖活动
function req.activityBayernLuckyDraw(type, id, oncomplete, onfailed, quiet)
    local data = {
        ["type"] = type, 
        id = id,
    }
    return req.post(url.activity.joinDraw, data, oncomplete, onfailed, quiet)
end

-- 拜仁双11请求开奖获取结果
function req.activityBayernLuckyDrawResult(type, id, oncomplete, onfailed, quiet)
    local data = {
        ["type"] = type, 
        id = id,
    }
    return req.post(url.activity.draw, data, oncomplete, onfailed, quiet)
end

-- 拜仁活动获取奖品
function req.activityBayernLuckyDrawReceive(type, id, oncomplete, onfailed, quiet)
    local data = {
        ["type"] = type, 
        id = id,
    }
    return req.post(url.activity.receiveBayernReward, data, oncomplete, onfailed, quiet)
end

-- 拜仁双11统计链接
function req.activityBayernLuckyDrawRedirectLink(type, id, oncomplete, onfailed, quiet)
    local data = {
        ["type"] = type, 
        id = id,
    }
    return req.post(url.activity.redirectLink, data, oncomplete, onfailed, quiet)
end

--打boss
function req.activityWorldBossMatch(opponentId, oncomplete, onfailed, quiet)
    local data = {
        opponentId = opponentId,
    }
    return req.post(url.activity.worldBossMatch, data, oncomplete, onfailed, quiet)
end

function req.activityWorldBossPlayerSort(oncomplete, onfailed, quiet)
    return req.post(url.activity.worldBossPlayerSort, nil, oncomplete, onfailed, quiet)
end

function req.activityWorldBossServerSort(oncomplete, onfailed, quiet)
    return req.post(url.activity.worldBossServerSort, nil, oncomplete, onfailed, quiet)
end

function req.activityWorldBossInfo(oncomplete, onfailed, quiet)
    return req.post(url.activity.worldBossInfo, nil, oncomplete, onfailed, quiet)
end

function req.activityWorldBossNPCInfo(oncomplete, onfailed, quiet)
    return req.post(url.activity.worldBossNPCInfo, nil, oncomplete, onfailed, quiet)
end

function req.activityWorldBossGrab(oncomplete, onfailed, quiet)
    return req.post(url.activity.worldBossGrab, nil, oncomplete, onfailed, quiet)
end

function req.activityWorldBossSweep(opponentId, oncomplete, onfailed, quiet)
    local data = {
        opponentId = opponentId,
    }
    return req.post(url.activity.worldBossSweep, data, oncomplete, onfailed, quiet)
end

function req.activityReceiveLateGift(subId, oncomplete, onfailed, quiet)
    local data = {
        subID = subId
    }
    return req.post(url.activity.receiveLateGift, data, oncomplete, onfailed, quiet)
end

function req.activitySevenDayLogin(oncomplete, onfailed, quiet)
    return req.post(url.activity.sevenDayLogin, nil, oncomplete, onfailed, quiet)
end

function req.oldPlayerCallBack(oncomplete, onfailed, quiet)
    return req.post(url.activity.oldPlayerCallBack, nil, oncomplete, onfailed, quiet)
end

function req.oldPlayerCallBackBuy(subId, oncomplete, onfailed, quiet)
    local data = {
        subId = subId
    }
    return req.post(url.activity.callBackBuy, data, oncomplete, onfailed, quiet)
end

function req.fanShopBuy(id, num, oncomplete, onfailed, quiet)
    local data = {
        id = id,
        num = num
    }
    return req.post(url.activity.fanShopBuy, data, oncomplete, onfailed, quiet)
end

function req.fanShopRecycleStore(period, oncomplete, onfailed, quiet)
    local data = {
        period = period
    }
    return req.post(url.activity.fanShopRecycleStore, data, oncomplete, onfailed, quiet)
end

function req.fanShopSell(id, num, pcid, oncomplete, onfailed, quiet)
    local data = {
        id = id,
        num = num,
        pcid = pcid
    }
    return req.post(url.activity.fanShopSell, data, oncomplete, onfailed, quiet)
end

function req.activityWorldBossExchangeInfo(id, oncomplete, onfailed, quiet)
    local data = {
        id = id
    }
    return req.post(url.activity.worldBossExchangeInfo, data, oncomplete, onfailed, quiet)
end

function req.activityWorldBossExchange(exchangeId, num, oncomplete, onfailed, quiet)
    local data = {
        exchangeId = exchangeId,
        num = num
    }
    return req.post(url.activity.worldBossExchange, data, oncomplete, onfailed, quiet)
end

-- 双倍掉落是否开启
function req.dropDoubleInfo(oncomplete, onfailed, quiet)
    return req.post(url.activity.dropDoubleInfo, nil, oncomplete, onfailed, quiet)
end

-- 新手嘉年华
function req.beginnerCarnivalInfo(oncomplete, onfailed, quiet)
    return req.post(url.activity.activityBeginnerCarnival, nil, oncomplete, onfailed, quiet)
end

-- 新手嘉年华总奖励进度
function req.beginnerCarnivalProgressInfo(type, subId, oncomplete, onfailed, quiet)
    local data = {
        ["type"] = type,
        id = subId
    }
    return req.post(url.activity.activityBeginnerCarnivalTotal, data, oncomplete, onfailed, quiet)
end

-- 开始转盘
function req.luckWheelDial(oncomplete, onfailed, quiet)
    return req.post(url.luckWheel.dial, nil, oncomplete, onfailed, quiet)
end

-- 折扣券购买
function req.luckWheelBuy(cardID, couponID, oncomplete, onfailed, quiet)
    local data = {
        cardId = cardID,
        couponId = couponID,
    }
    return req.post(url.luckWheel.buy, data, oncomplete, onfailed, quiet)
end

-- 刷新折扣商店
function req.luckWheelRefresh(oncomplete, onfailed, quiet)
    return req.post(url.luckWheel.refresh, nil, oncomplete, onfailed, quiet)
end

function req.snatchGacha(periodId, gachaType, oncomplete, onfailed, quiet)
    local data = {
        periodId = periodId,
        gachaType = gachaType,
    }
    return req.post(url.snatch.gacha, data, oncomplete, onfailed, quiet)
end

function req.snatchReceiveReward(periodId, rewardId, oncomplete, onfailed)
    local data = {
        periodId = periodId,
        rewardId = rewardId
    }
    return req.post(url.snatch.receiveReward, data, oncomplete, onfailed)
end

-- 活动礼盒购买
function req.buyGiftBag(boxId, num)
    local data = {
        idBox = boxId,
        num = num
    }
    return req.post(url.activity.buyGiftBag, data, oncomplete, onfailed)
end

-- 商店礼包详情
function req.mallInfo(oncomplete, onfailed, quiet)
    return req.post(url.mall.info, nil, oncomplete, onfailed, quiet)
end

function req.mallBuy(id, oncomplete, onfailed)
    local data = {
        ID = id
    }
    return req.post(url.mall.buy, data, oncomplete, onfailed)
end

function req.honorInfo(oncomplete, onfailed)
    return req.post(url.honor.info, nil, oncomplete, onfailed, quiet)
end

function req.honorReceive(id, oncomplete, onfailed)
    local data = {
        id = id
    }
    return req.post(url.honor.receive, data, oncomplete, onfailed, quiet)
end

function req.useHonor(id, pos, oncomplete, onfailed)
    local data = {
        id = id,
        pos = pos
    }
    return req.post(url.honor.useHonor, data, oncomplete, onfailed, quiet)
end

function req.unUseHonor(pos, oncomplete, onfailed)
    local data = {
        pos = pos
    }
    return req.post(url.honor.unUseHonor, data, oncomplete, onfailed, quiet)
end

function req.swapHonor(sourcePos, targetPos, oncomplete, onfailed)
    local data = {
        sourcePos = sourcePos,
        targetPos = targetPos
    }
    return req.post(url.honor.swapHonor, data, oncomplete, onfailed, quiet)
end

function req.rankTop(oncomplete, onfailed)
    return req.post(url.honor.rankTop, nil, oncomplete, onfailed)
end

function req.receiveReward(lvl)
    local data = {
        level = lvl
    }
    return req.post(url.honor.receiveReward, data, oncomplete, onfailed)
end

function req.activationCode(data, oncomplete, onfailed)
    return req.post(url.activationCode.exchange, data, oncomplete, onfailed)
end

function req.activationCodeAccountTransfer(code, oncomplete, onfailed)
    local data = {
        code = code
    }
    return req.post(url.activationCode.accountTransfer, data, oncomplete, onfailed)
end


function req.activationCodeAccountTransferConfirm(code, oncomplete, onfailed)
    local data = {
        code = code
    }
    return req.post(url.activationCode.accountTransferConfirm, data, oncomplete, onfailed)
end

-- 天梯首页信息
function req.ladderInfo(oncomplete, onfailed)
    return req.post(url.ladder.info, nil, oncomplete, onfailed)
end

-- 天梯领取奖励
function req.ladderReward(oncomplete, onfailed)
    return req.post(url.ladder.reward, nil, oncomplete, onfailed)
end

-- 换一批对手
function req.ladderUpdateRival(oncomplete, onfailed)
    return req.post(url.ladder.updateRival, nil, oncomplete, onfailed)
end

-- 开始比赛
function req.ladderStart(pid, oncomplete, onfailed)
    local data = {
        pid = pid
    }
    return req.post(url.ladder.start, data, oncomplete, onfailed)
end

-- 购买冷却时间
function req.ladderBuyCd(oncomplete, onfailed)
    return req.post(url.ladder.buyCd, nil, oncomplete, onfailed)
end

-- 进入天梯排行榜
function req.ladderRankList(oncomplete, onfailed)
    return req.post(url.ladder.rankList, nil, oncomplete, onfailed)
end

-- 查看天梯排行榜
function req.ladderRank(season, oncomplete, onfailed)
    local data = {
        season = season
    }
    return req.post(url.ladder.rank, data, oncomplete, onfailed)
end

-- 进入天梯商店
function req.ladderStore(oncomplete, onfailed)
    return req.post(url.ladder.store, nil, oncomplete, onfailed)
end

-- 刷新天梯商店
function req.ladderStoreRefresh(oncomplete, onfailed)
    return req.post(url.ladder.storeRefresh, nil, oncomplete, onfailed)
end

-- 天梯商店购买
function req.ladderStoreBuy(slot, id, discount, num, oncomplete, onfailed)
    local data = {
        slot = slot,
        id = id,
        discount = discount,
        num = num
    }
    return req.post(url.ladder.storeBuy, data, oncomplete, onfailed)
end

-- 进入天梯对战记录
function req.ladderRecord(oncomplete, onfailed)
    return req.post(url.ladder.record, nil, oncomplete, onfailed)
end

-- 查看天梯比赛录像
function req.ladderVideo(vid, oncomplete, onfailed)
    local data = {
        vid = vid
    }
    return req.post(url.ladder.video, data, oncomplete, onfailed)
end

-- 进入天梯赛季奖励
function req.ladderSeasonReward(oncomplete, onfailed)
    return req.post(url.ladder.seasonReward, nil, oncomplete, onfailed)
end

function req.buildInfo(data, oncomplete, onfailed)
    return req.post(url.build.info, data, oncomplete, onfailed)
end

function req.buildUpgrade(buildType, oncomplete, onfailed)
    local data = {
        ["type"] = buildType
    }
    return req.post(url.build.upgrade, data, oncomplete, onfailed)
end

function req.buildUpgradeCompleted(oncomplete, onfailed)
    return req.post(url.build.upgradeCompleted, nil, oncomplete, onfailed)
end

function req.setMatchWeatherTech(matchType, typeName, oncomplete, onfailed)
    local data = {
        matchType = matchType,
        type = typeName
    }
    return req.post(url.build.setMatchWeatherTech, data, oncomplete, onfailed)
end

function req.setMatchGrassTech(matchType, typeName, oncomplete, onfailed)
    local data = {
        matchType = matchType,
        type = typeName
    }
    return req.post(url.build.setMatchGrassTech, data, oncomplete, onfailed)
end

--接收所有聊天消息
function req.receiveMessage(worldSeq, guildSeq, playerSeq, allServerSeq, oncomplete, onfailed, quiet)
    local data = {
        channel = {
            world = worldSeq,
            guild = guildSeq,
            player = playerSeq,
            allServer = allServerSeq
        }
    }
    return req.post(url.msg.receive, data, oncomplete, onfailed, quiet)
end

--发送世界聊天
function req.sendWorldMessage(message, oncomplete, onfailed, quiet)
    local data = {
        msg = message
    }
    return req.post(url.msg.sendWorld, data, oncomplete, onfailed, quiet)
end

--发送私聊信息
function req.sendPlayerMessage(mpid, sid, message, oncomplete, onfailed, quiet)
    local data = {
        pid = mpid,
        sid = sid,
        msg = message
    }
    return req.post(url.msg.sendPlayer, data, oncomplete, onfailed, quiet)
end


function req.crusadeInfo()
    return req.post(url.crusade.info, nil, oncomplete, onfailed)
end

function req.crusadeStore()
    return req.post(url.crusade.store, nil, oncomplete, onfailed)
end

function req.crusadeBuyCard(data)
    return req.post(url.crusade.buyCard, data, oncomplete, onfailed)
end

function req.crusadeBuyItem(data)
    return req.post(url.crusade.buyItem, data, oncomplete, onfailed)
end

function req.crusadeMatch(data)
    return req.post(url.crusade.match, data, oncomplete, onfailed)
end

function req.crusadeQuestList()
    return req.post(url.crusade.questList, nil, oncomplete, onfailed)
end

function req.crusadeReceive(data)
    return req.post(url.crusade.crusadeReceive, data, oncomplete, onfailed)
end

function req.crusadeRefreshItem()
    return req.post(url.crusade.refreshItem, nil, oncomplete, onfailed)
end


--发送公会聊天
function req.sendGuildMessage(message, oncomplete, onfailed, quiet)
    local data = {
        msg = message
    }
    return req.post(url.msg.sendGuild, data, oncomplete, onfailed, quiet)
end

function req.sendGlobalMessage(message, oncomplete, onfailed, quiet)
    local data = {
        msg = message
    }
    return req.post(url.msg.sendAllServer, data, oncomplete, onfailed, quiet)
end

--玩家公会详情
function req.guildIndex(oncomplete, onfailed)
    return req.post(url.guild.index, nil, oncomplete, onfailed)
end

--公会优先推荐
function req.getPriorityGuild(oncomplete, onfailed)
    return req.post(url.guild.priorityGuild, nil, oncomplete, onfailed)
end

--加入公会请求
function req.sendGuildRequest(gid, oncomplete, onfailed)
    local data = {
        gid = gid
    }
    return req.post(url.guild.request, data, oncomplete, onfailed)
end

--查找公会
function req.searchGuild(name, oncomplete, onfailed)
    local data = {
        name = name
    }
    return req.post(url.guild.search, data, oncomplete, onfailed)
end

--创建公会
function req.createGuild(name, eid, oncomplete, onfailed)
    local data = {
        name = name,
        eid = eid
    }
    return req.post(url.guild.create, data, oncomplete, onfailed)
end

--公会成员列表
function req.getMemberList(oncomplete, onfailed)
    return req.post(url.guild.mlist, nil, oncomplete, onfailed)
end

--查看入会请求
function req.getRequestList(oncomplete, onfailed)
    return req.post(url.guild.reqs, nil, oncomplete, onfailed)
end

--查看对方信息
function req.guildDetail(pid, oncomplete, onfailed)
    local data = {
        pid = pid
    }
    return req.post(url.guild.detail, data, oncomplete, onfailed)
end

--同意加入公会
function req.guildAccept(pid, oncomplete, onfailed)
    local data = {
        pid = pid
    }
    return req.post(url.guild.accept, data, oncomplete, onfailed)
end

--拒绝加入公会
function req.guildRefuse(pid, oncomplete, onfailed)
    local data = {
        pid = pid
    }
    return req.post(url.guild.refuse, data, oncomplete, onfailed)
end

--调整职务
function req.GuildChangePos(pid, authority, oncomplete, onfailed)
    local data = {
        pid = pid,
        authority = authority
    }
    return req.post(url.guild.cpos, data, oncomplete, onfailed)
end

--卸任会长
function req.GuildChangeAdmin(pid, authority, oncomplete, onfailed)
    local data = {
        pid = pid
    }
    return req.post(url.guild.epos, data, oncomplete, onfailed)
end

--踢出公会
function req.GuildKick(pid, oncomplete, onfailed)
    local data = {
        pid = pid
    }
    return req.post(url.guild.kick, data, oncomplete, onfailed)
end

--公会设置
function req.GuildSetting(name, eid, notice, reqtype, reqlevel, invite, oncomplete, onfailed)
    local data = {
        name = name,
        eid = eid,
        msg = notice,
        isOpen = reqtype,
        lvl = reqlevel,
        invite = invite
    }
    return req.post(url.guild.cMulitInfo, data, oncomplete, onfailed)
end

--修改公会名称
function req.GuildChangeName(name)
    local data = {
        name = name
    }
    return req.post(url.guild.cname, data, oncomplete, onfailed)
end

--公会日志
function req.GetGuildRecord()
    return req.post(url.guild.getAllGuildRecord, nil, oncomplete, onfailed)
end

--公会活跃榜
function req.GetGuildTop()
    return req.post(url.guild.top, nil, oncomplete, onfailed)
end

--公会实力榜
function req.GetGuildPowerTop()
    return req.post(url.guild.powerRank, nil, oncomplete, onfailed)
end

--公会自动邀请
function req.GetGuildAutoInviteGuilds()
    return req.post(url.guild.autoInviteGuilds, nil, oncomplete, onfailed)
end

--公会排行榜首页信息
function req.GetRankPos()
    return req.post(url.guild.getRankPos, nil, oncomplete, onfailed)
end

--退出公会
function req.GuildQuit()
    return req.post(url.guild.quit, nil, oncomplete, onfailed)
end

--解散公会
function req.GuildDismiss()
    return req.post(url.guild.dismiss, nil, oncomplete, onfailed)
end

--公会签到
function req.GuildSign(id)
    local data = {
        id = id
    }
    return req.post(url.guild.sign, data, oncomplete, onfailed)
end

--公会签到页面
function req.GuildSignInfo()
    return req.post(url.guild.signInfo, nil, oncomplete, onfailed)
end

--玩家公会详情
function req.GuildDetail(gid, sid)
    local data = {
        gid = gid
    }
    return req.post(url.guild.guildDetail, data, oncomplete, onfailed)
end

--发公会红包
function req.sendRedEnvelope(index, type, title)
    local data = {
        id = index,
        type = type or "signRedPacket",
        title = title
    }
    return req.post(url.guild.sendRedEnvelope, data, oncomplete, onfailed)
end

--拆红包
function req.openRedEnvelope(id, type)
    local data = {
        id = id,
        type = type
    }
    return req.post(url.guild.openRedEnvelope, data, oncomplete, onfailed)
end

--查看公会红包
function req.viewRedEnvelope(id, type)
    local data = {
        id = id,
        type = type
    }
    return req.post(url.guild.viewRedEnvelope, data, oncomplete, onfailed)
end

--公会挑战赛信息
function req.challengeInfo()
    return req.post(url.guild.challengeInfo, nil, oncomplete, onfailed)
end

--公会挑战赛开始
function req.challengeStart(qid, diff)
    local data = {
        qid = qid,
        diff = diff
    }
    return req.post(url.guild.challengeStart, data, oncomplete, onfailed)
end

--公会挑战赛扫荡
function req.challengeSweep(qid, diff)
    local data = {
        qid = qid,
        diff = diff
    }
    return req.post(url.guild.challengeSweep, data, oncomplete, onfailed)
end

function req.targetGuardDetail(pos)
    local data = {
    pos = pos
    }
    return req.post(url.guild.targetGuardDetail, data, oncomplete, onfailed)
end

-- 开战
function req.startWar(pos)
    local data = {
        pos = pos
    }
    return req.post(url.guildWar.startWar, data, oncomplete, onfailed)
end

function req.buyBuff(round, buffID)
    local data = {
        round = round,
        buffID = buffID
    }
    return req.post(url.guild.buyBuff, data, oncomplete, onfailed)
end

-- 查看当前轮的已购buff
function req.buffInfo(round)
    local data = {
        round = round
    }
    return req.post(url.guildWar.buffInfo, data, oncomplete, onfailed)
end

function req.scheduleInfo()
    return req.post(url.guildWar.scheduleInfo, nil, oncomplete, onfailed)
end

--公会战首页信息
function req.getGuildWarInfo()
    return req.post(url.guildWar.info, nil, oncomplete, onfailed)
end

--公会战报名
function req.guildWarSign(level)
    local data = {
        level = level
    }
    return req.post(url.guildWar.sign, data, oncomplete, onfailed)
end

--公会战获取公会成员信息
function req.getGuildMemberInfo()
    return req.post(url.guildWar.memberInfo, nil, oncomplete, onfailed)
end

-- 进攻详情板
function req.getTargetGuardDetail(pos)
    local data = {
        pos = pos
    }
    return req.post(url.guildWar.targetGuardDetail, data, oncomplete, onfailed)
end

-- 防守详情版
function req.getSelfGuardDetail(pos)
    local data = {
        pos = pos
    }
    return req.post(url.guildWar.selfGuardDetail, data, oncomplete, onfailed)
end

--公会战部署守卫席
function req.deployGuard(pos, pid)
    local data = {
        targetPid = pid,
        targetPos = pos
    }
    return req.post(url.guildWar.deploy, data, oncomplete, onfailed)
end

--Test
function req.testSign(level)
    local data = {
        level = level
    }
    return req.post(url.guildWar.testSign, data, oncomplete, onfailed)
end

--Test
function req.testGroup()
    return req.post(url.guildWar.testGroup, nil, oncomplete, onfailed)
end

--Test
function req.testRank()
    return req.post(url.guildWar.testRank, nil, oncomplete, onfailed)
end

function req.getMemberInfo()
    return req.post(url.guildWar.memberInfo, nil, oncomplete, onfailed)
end

--公会战进攻界面信息
function req.getGuildWarAttackInfo()
    return req.post(url.guildWar.warInfo, nil, oncomplete, onfailed)
end

--公会战防守界面信息
function req.getGuildWarDefenceInfo()
    return req.post(url.guildWar.guardsInfo, nil, oncomplete, onfailed)
end

--最近公会战记录
function req.recentGuildWar()
    return req.post(url.guildWar.recentGuildWar, nil, oncomplete, onfailed)
end

function req.viewGuildWarVideo(ID)
    local data = {
        videoID = ID
    }
    return req.post(url.guildWar.viewVideo, data, oncomplete, onfailed)
end

function req.viewPlayer(pid, sid)
    local data = {
        pid = pid,
        sid = sid
    }
    return req.post(url.guildWar.viewPlayer, data, oncomplete, onfailed)
end

function req.arenaInfo(oncomplete, onfailed)
    return req.post(url.arena.info, nil, oncomplete, onfailed)
end

function req.arenaSign(arenaType, oncomplete, onfailed)
    local data = {
        zone = arenaType,
    }
    return req.post(url.arena.sign, data, oncomplete, onfailed)
end

function req.arenaUnsign(arenaType, oncomplete, onfailed)
	local data = {
        zone = arenaType,
    }
    return req.post(url.arena.unsign, data, oncomplete, onfailed)
end

function req.arenaGroupInfo(arenaType, oncomplete, onfailed)
	local data = {
        zone = arenaType,
    }
    return req.post(url.arena.groupInfo, data, oncomplete, onfailed)
end

function req.arenaRaceInfo(arenaType, oncomplete, onfailed)
	local data = {
        zone = arenaType,
    }
    return req.post(url.arena.nextRaceInfo, data, oncomplete, onfailed, true)
end

function req.getArenaGroupSchedule(arenaType, oncomplete, onfailed)
	local data = {
        zone = arenaType,
    }
    return req.post(url.arena.getArenaGroupScoreAndSchedule, data, oncomplete, onfailed, true)
end

function req.getArenaPlayersBrief(arenaType, oncomplete, onfailed)
	local data = {
        zone = arenaType,
    }
    return req.post(url.arena.arenaBrief, data, oncomplete, onfailed)
end

function req.getArenaOutScheduleBoard(arenaType, oncomplete, onfailed)
	local data = {
        zone = arenaType,
    }
    return req.post(url.arena.getArenaOutScheduleBoard, data, oncomplete, onfailed, true)
end

function req.arenaTestMatch(groupId, round,oncomplete, onfailed)
    local data = {
        groupID = groupId,
        gameOrder = round
    }
    return req.post(url.arena.testMatch, data, oncomplete, onfailed)
end
function req.buyArenaStore(id, num, oncomplete, onfailed)
    data ={
        id = id,
        num = num
    }
    return req.post(url.arena.buyArenaStore, data, oncomplete, onfailed)
end

function req.arenaGetTeam(arenaType, oncomplete, onfailed)
    local data = {
        zone = arenaType,
    }
    return req.post(url.arena.getTeam, data, oncomplete, onfailed)
end

-- 阵型界面：保存竞技场阵容
-- @param nowTeamId 阵容Id
-- @param nowFormationId 阵型Id
-- @param initPlayersData 首发球员数据
-- @param replacePlayersData 替补球员数据
-- @param teamType  球队类型定义：普通或者竞技场
function req.arenaSaveTeam(nowTeamId, nowFormationId, initPlayersData, replacePlayersData, teamType, keyPlayersData, tacticsData, selectedType, oncomplete, onfailed)
    local data = {
        ptid = nowTeamId,
        formationID = nowFormationId,
        init = initPlayersData,
        rep = replacePlayersData,
        teamType = teamType,
        freeKickShoot = keyPlayersData.freeKickShoot,
        spotKick = keyPlayersData.spotKick,
        captain = keyPlayersData.captain,
        freeKickPass = keyPlayersData.freeKickPass,
        corner = keyPlayersData.corner,
        tactics = tacticsData,
        selectedType = selectedType,
    }
    return req.post(url.arena.saveTeam, data, oncomplete, onfailed)
end

function req.arenaClearTeam(arenaType)
    local data = {
        zone = arenaType,
    }
    return req.post(url.arena.clearTeam, data, oncomplete, onfailed)
end

function req.arenaHonorInfo(oncomplete, onfailed)
    return req.post(url.arena.arenaHonorInfo, nil, oncomplete, onfailed)
end

function req.arenaVideo(videoId, oncomplete, onfailed)
    data ={
        id = videoId
    }
    return req.post(url.arena.arenaVideo, data, oncomplete, onfailed)
end

function req.arenaReceiveHonor(id, oncomplete, onfailed)
    data ={
        id = id
    }
    return req.post(url.arena.arenaReceiveHonor, data, oncomplete, onfailed)
end

function req.arenaReceiveReward(arenaType, oncomplete, onfailed)
	local data = {
        zone = arenaType,
    }
    return req.post(url.arena.arenaReceiveReward, data, oncomplete, onfailed)
end

function req.arenaQuit(arenaType, oncomplete, onfailed)
	local data = {
        zone = arenaType,
    }
    return req.post(url.arena.arenaQuit, data, oncomplete, onfailed)
end

-- 竞技场排行榜
function req.arenaRankInfo(zone, type, oncomplete, onfailed)
    local data = {
        zone = zone,
        type = type,
    }
    return req.post(url.arena.rankInfo, data, oncomplete, onfailed)
end

-- 竞技场查看对方阵型
function req.arenaOtherTeam(pid, sid, zone, oncomplete, onfailed)
    local data = {
        pid = pid,
        sid = sid,
        zone = zone,
    }
    return req.post(url.arena.viewTeam, data, oncomplete, onfailed)
end

-- 查看科技馆配置
function req.arenaViewMatchTech(pid, sid, oncomplete, onfailed)
    local data = {
        pid = pid,
        sid = sid,
    }
    return req.post(url.arena.viewMatchTech, data, oncomplete, onfailed)
end

-- 查看个人赛果展示
function req.playerArenaScheduleBoard(zone, oncomplete, onfailed)
	local data = {
        zone = zone,
    }
    return req.post(url.arena.playerArenaScheduleBoard, data, oncomplete, onfailed)
end

-- 录像记录
function req.videoInfo(oncomplete, onfailed)
    return req.post(url.video.info, nil, oncomplete, onfailed)
end

-- 录像回放
function req.videoReplay(vid, oncomplete, onfailed)
    local data = {
        vid = vid
    }
    return req.post(url.video.video, data, oncomplete, onfailed)
end

--获取已经进入场景信息的列表
function req.getEnterSenceList(oncomplete, onfailed)
    return req.post(url.player.getEnterSenceList, nil, oncomplete, onfailed)
end

--设置已经进入的场景信息
function req.setEnterSenceList(sceneName, state, oncomplete, onfailed)
    --设置服务器存储状态，state 1 为已经进入，0 为开启未进入
    local data = {
        scene = sceneName,
        enter = state
    }
    return req.post(url.player.setEnterSenceList, data, oncomplete, onfailed)    
end

function req.viewItem(oncomplete, onfailed)
    return req.post(url.item.viewItem, nil, oncomplete, onfailed, true)    
end

function req.lotteryStake(matchId, stakeNumber, matchResult, oncomplete, onfailed)
    local data = {
        matchId = matchId,
        stakeNumber = stakeNumber,
        matchResult = matchResult
    }
    return req.post(url.lottery.stake, data, oncomplete, onfailed)
end

function req.lotteryHistory(oncomplete, onfailed)
    return req.post(url.lottery.history, nil, oncomplete, onfailed)
end

function req.lotteryBonus(matchId, oncomplete, onfailed)
    local data = {
        matchId = matchId,
    }
    return req.post(url.lottery.bonus, data, oncomplete, onfailed)
end

function req.pasterAdd(ptcid, oncomplete, onfailed)
    local data = {
        ptcid = ptcid,
    }
    return req.post(url.paster.add, data, oncomplete, onfailed)
end

function req.pasterAppend(pcid, ptid, oncomplete, onfailed)
    local data = {
        pcid = pcid,
        ptid = ptid
    }
    return req.post(url.paster.equip, data, oncomplete, onfailed)
end

function req.pasterUnEquip(pcid, ptid, oncomplete, onfailed)
    local data = {
        pcid = pcid,
        ptid = ptid
    }
    return req.post(url.paster.unEquip, data, oncomplete, onfailed)
end

function req.pasterUseSkill(pcid, oldPtid, newPtid, oncomplete, onfailed)
    local data = {
        pcid = pcid,
        oldPtid = oldPtid,
        newPtid = newPtid
    }
    return req.post(url.paster.useSkill, data, oncomplete, onfailed)
end

function req.getPasterPieceStore(oncomplete, onfailed, quiet)
    return req.post(url.paster.pieceStore, nil, oncomplete, onfailed, quiet)
end

function req.pasterIncorporate(ptcid, oncomplete, onfailed)
    local data = {
        ptcid = ptcid
    }
    return req.post(url.paster.incorporate, data, oncomplete, onfailed)
end

function req.pasterDecomposition(ptid, oncomplete, onfailed)
    local data = {
        ptid = ptid
    }
    return req.post(url.paster.decomposition, data, oncomplete, onfailed)
end

function req.visitGacha(periodId, gachaType, oncomplete, onfailed)
    local data = {
        periodId = periodId,
        gachaType = gachaType
    }
    return req.post(url.visit.gacha, data, oncomplete, onfailed)
end

function req.visitReceiveChestReward(periodId, rewardId, oncomplete, onfailed)
    local data = {
        periodId = periodId,
        rewardId = rewardId
    }
    return req.post(url.visit.receiveChestReward, data, oncomplete, onfailed)
end

function req.visitRank(oncomplete, onfailed)
    return req.post(url.visit.getPlayerVisitRank, oncomplete, onfailed)
end

function req.specificIndex(oncomplete, onfailed)
    return req.post(url.specific.index, nil, oncomplete, onfailed)
end

function req.specificUpdateMatch(matchId, oncomplete, onfailed)
    local data = {
        matchId = matchId,
    }
    return req.post(url.specific.updateMatch, data, oncomplete, onfailed)
end

function req.specificGetTeam(eventId, oncomplete, onfailed)
    local data = {
        ptid = eventId,
    }
    return req.post(url.specific.getTeam, data, oncomplete, onfailed)
end

-- 阵型界面：保存特殊赛事阵容
-- @param nowTeamId 阵容Id
-- @param nowFormationId 阵型Id
-- @param initPlayersData 首发球员数据
-- @param replacePlayersData 替补球员数据
-- @param teamType  球队类型定义：FormationConstants.TeamType.SPECIFIC
function req.specificSaveTeam(eventId, nowFormationId, initPlayersData, teamType, replacePlayersData, keyPlayersData, tacticsData, selectedType, oncomplete, onfailed)
    local data = {
        ptid = eventId,
        formationID = nowFormationId,
        init = initPlayersData,
        rep = replacePlayersData,
        teamType = teamType,
        freeKickShoot = keyPlayersData.freeKickShoot,
        spotKick = keyPlayersData.spotKick,
        captain = keyPlayersData.captain,
        freeKickPass = keyPlayersData.freeKickPass,
        corner = keyPlayersData.corner,
        tactics = tacticsData,
        selectedType = selectedType,
    }
    return req.post(url.specific.saveTeam, data, oncomplete, onfailed)
end

function req.specificClearTeam(eventId)
    local data = {
        ptid = eventId,
    }
    return req.post(url.specific.clearTeam, data, oncomplete, onfailed)
end

function req.specificMatch(matchId, oncomplete, onfailed)
    local data = {
        matchId = matchId
    }
    return req.post(url.specific.match, data, oncomplete, onfailed)
end

function req.specificSweep(matchId, oncomplete, onfailed)
    local data = {
        matchId = matchId
    }
    return req.post(url.specific.sweep, data, oncomplete, onfailed)
end

function req.specificViewTeam(pid, sid, ptid, matchId, oncomplete, onfailed)
    local data = {
        pid = pid,
        sid = sid,
        ptid = ptid,
        matchId = matchId
    }
    return req.post(url.specific.viewTeam, data, oncomplete, onfailed)
end

function req.specificVideo(vid, oncomplete, onfailed)
    local data = {
        vid = vid
    }
    return req.post(url.specific.video, data, oncomplete, onfailed)
end

function req.medalEquip(pmid, pcid, pos, oncomplete, onfailed)
    local data = {
        position = pos,
        pmid = pmid,
        pcid = pcid
    }
    return req.post(url.medal.equip, data, oncomplete, onfailed)
end

function req.medalUnload(pcid, oncomplete, onfailed)
    local data = {
        pcid = pcid
    }
    return req.post(url.medal.unload, data, oncomplete, onfailed)
end

function req.medalSingleUnload(pcid, pmid, oncomplete, onfailed)
    local data = {
        pcid = pcid,
        pmid = pmid
    }
    return req.post(url.medal.unloadMedal, data, oncomplete, onfailed)
end

function req.medalUpgrade(pmid, protect, oncomplete, onfailed)
    local data = {
        pmid = pmid,
        protect = protect
    }
    return req.post(url.medal.upgrade, data, oncomplete, onfailed)
end

function req.medalUpgradeBenediction(pmid, oncomplete, onfailed)
    local data = {
        pmid = pmid
    }
    return req.post(url.medal.upgradeBless, data, oncomplete, onfailed)
end

function req.medalChangeBenediction(pmid, oncomplete, onfailed)
    local data = {
        pmid = pmid
    }
    return req.post(url.medal.changeBless, data, oncomplete, onfailed)
end

function req.medalDecomposition(pmid, oncomplete, onfailed)
    local data = {
        pmid = pmid
    }
    return req.post(url.medal.decomposition, data, oncomplete, onfailed)
end

function req.medalBoostUp(pmid, oncomplete, onfailed)
    local data = {
        pmid = pmid
    }
    return req.post(url.medal.boostUp, data, oncomplete, onfailed)
end


function req.decompositionAll(pmids, oncomplete, onfailed)
    local data = {
        pmids = pmids
    }
    return req.post(url.medal.decompositionAll, data, oncomplete, onfailed)
end

function req.peakInfo(oncomplete, onfailed)
    return req.post(url.peak.info, nil, oncomplete, onfailed)
end

function req.peakReceivePeakPoint(oncomplete, onfailed)
    return req.post(url.peak.receivePeakPoint, nil, oncomplete, onfailed)
end

function req.peakNewOpponent(oncomplete, onfailed)
    return req.post(url.peak.newOpponent, nil, oncomplete, onfailed)
end

function req.peakSwapTeam(peak1Pos, peak2Pos, peak3Pos, oncomplete, onfailed)
    local teamOrder = {}
    teamOrder.peak1 = tonumber(peak1Pos)
    teamOrder.peak2 = tonumber(peak2Pos)
    teamOrder.peak3 = tonumber(peak3Pos)
    local data = 
    {
        order = teamOrder
    }
    return req.post(url.peak.swapTeam, data, oncomplete, onfailed)
end

function req.peakHideTeam(peak1Status, peak2Status, peak3Status, oncomplete, onfailed)
    local status = {}
    status.peak1 = tonumber(peak1Status)
    status.peak2 = tonumber(peak2Status)
    status.peak3 = tonumber(peak3Status)
    local data = 
    {
        status = status
    }
    return req.post(url.peak.hideTeam, data, oncomplete, onfailed)
end

function req.peakCanSweepChallenge(oncomplete, onfailed)
    return req.post(url.peak.canSweepChallenge, nil, oncomplete, onfailed)
end

function req.peakRecordList(oncomplete, onfailed)
    return req.post(url.peak.recordList, nil, oncomplete, onfailed)
end

function req.peakViewVideo(formationData, oncomplete, onfailed)
    local data = 
    {
        videoId = formationData
    }
    return req.post(url.peak.viewVideo, data, oncomplete, onfailed)
end

-- 阵型界面：保存竞技场阵容
-- @param nowTeamId 阵容Id
-- @param nowFormationId 阵型Id
-- @param initPlayersData 首发球员数据
-- @param replacePlayersData 替补球员数据
-- @param teamType  球队类型定义：普通或者竞技场
function req.peakSaveTeam(nowTeamId, nowFormationId, initPlayersData, teamType, replacePlayersData, keyPlayersData, tacticsData, selectedType, oncomplete, onfailed)
    local data = {
        ptid = nowTeamId,
        formationID = nowFormationId,
        init = initPlayersData,
        rep = replacePlayersData,
        freeKickShoot = keyPlayersData.freeKickShoot,
        teamType = teamType,
        spotKick = keyPlayersData.spotKick,
        captain = keyPlayersData.captain,
        freeKickPass = keyPlayersData.freeKickPass,
        corner = keyPlayersData.corner,
        tactics = tacticsData,
        selectedType = selectedType,
    }
    return req.post(url.peak.saveTeam, data, oncomplete, onfailed)
end

function req.peakRank(oncomplete, onfailed)
    return req.post(url.peak.rank, nil, oncomplete, onfailed)
end

function req.peakSeasonRank(oncomplete, onfailed)
    return req.post(url.peak.seasonRank, nil, oncomplete, onfailed)
end

function req.peakClearTeam(ptid, oncomplete, onfailed)
    local data = {
        ptid = ptid
    }
    return req.post(url.peak.clearTeam,data, oncomplete, onfailed)
end

function req.peakCheckOpen(oncomplete, onfailed)
    return req.post(url.peak.checkOpen, nil, oncomplete, onfailed)
end

function req.peakViewOpponent(sid, pid, oncomplete, onfailed)
    local data =
    {
        sid = sid,
        pid = pid
    }
    return req.post(url.peak.viewOpponent, data, oncomplete, onfailed)
end

function req.peakInitChallenge(pid, oncomplete, onfailed)
    local data = 
    {
        pid = pid
    }
    return req.post(url.peak.initChallenge, data, oncomplete, onfailed)
end

function req.peakChallenge(pid, challengeId, challengeOrder, oncomplete, onfailed)
    local data =
    {
        pid = pid,
        challengeId = challengeId,
        challengeOrder = challengeOrder
    }
    return req.post(url.peak.challenge, data, oncomplete, onfailed)
end

function req.peakSweepChallenge(pid, challengeId, challengeOrder, oncomplete, onfailed)
    local data =
    {
        pid = pid,
        challengeId = challengeId,
        challengeOrder = challengeOrder
    }
    return req.post(url.peak.sweepChallenge, data, oncomplete, onfailed)
end

function req.peakChallengeOver(pid, challengeId, oncomplete, onfailed)
    local data =
    {
        pid = pid,
        challengeId = challengeId,
    }
    return req.post(url.peak.challengeOver, data, oncomplete, onfailed)
end

function req.peakResetPlayCd(oncomplete, onfailed)
    return req.post(url.peak.resetPlayCd, nil, oncomplete, onfailed)
end

function req.peakShop(oncomplete, onfailed)
    return req.post(url.peak.shop, nil, oncomplete, onfailed)
end

function req.peakExchangeNormalItem(itemId, num, oncomplete, onfailed)
    local data =
    {
        itemId = itemId,
        num = num
    }
    return req.post(url.peak.exchangeNormalItem, data, oncomplete, onfailed)
end

function req.peakExchangeMysteryBox(financeType, num, oncomplete, onfailed)
    local data = 
    {
        financeType = financeType,
        num = num
    }
    return req.post(url.peak.exchangeMysteryBox, data, oncomplete, onfailed)
end

function req.peakShopRefresh(oncomplete, onfailed)
    return req.post(url.peak.shopRefresh, nil, oncomplete, onfailed)
end

function req.peakDailyTaskInfo(oncomplete, onfailed)
    return req.post(url.peak.dailyTaskInfo, nil, oncomplete, onfailed)
end

function req.peakReceiveDailyTaskReward(id, oncomplete, onfailed)
    local data = 
    {
        taskId = id
    }
    return req.post(url.peak.receiveDailyTaskReward, data, oncomplete, onfailed)
end

function req.peakBuyChallengeTimes(oncomplete, onfailed)
    return req.post(url.peak.buyChallenge, nil, oncomplete, onfailed)
end


function req.transportIndex(Refresh, oncomplete, onfailed)
    local data = {
        refresh = Refresh or false
    }
    return req.post(url.transport.index, data, oncomplete, onfailed)
end

function req.transportChangeMaxSponsor(oncomplete, onfailed)
    return req.post(url.transport.changeMaxSponsor, nil, oncomplete, onfailed)
end

function req.transportChangeRandSponsor(oncomplete, onfailed)
    return req.post(url.transport.changeRandSponsor, nil, oncomplete, onfailed)
end

function req.transportSign(oncomplete, onfailed)
    return req.post(url.transport.sign, nil, oncomplete, onfailed)
end

function req.transportRequestGuardList(oncomplete, onfailed)
    return req.post(url.transport.requestGuardList, nil, oncomplete, onfailed)
end

function req.transportStart(oncomplete, onfailed)
    return req.post(url.transport.start, nil, oncomplete, onfailed)
end

function req.transportOver(oncomplete, onfailed)
    return req.post(url.transport.over, nil, oncomplete, onfailed)
end

function req.transportGuardList(oncomplete, onfailed)
    return req.post(url.transport.guardList, nil, oncomplete, onfailed)
end

-- type(idsAndsids) == table
-- idsAndsids.id = sid
function req.transportGuardApply(idsAndsids, oncomplete, onfailed)
    local data = {}
    data.playerIds = idsAndsids
    return req.post(url.transport.guardApply, data, oncomplete, onfailed)
end

function req.transportRemoveMark(id, oncomplete, onfailed)
    local data = {
        markPlayerId = id
    }
    return req.post(url.transport.removeMark, data, oncomplete, onfailed)
end

function req.transportGuardReceive(id, oncomplete, onfailed)
    local data = {
        id = id
    }
    return req.post(url.transport.guardReceive, data, oncomplete, onfailed)
end

function req.transportBattle(id, sid, robberyId, ptid, oncomplete, onfailed)
    local data = {
        transportPlayerId = id,
        sid = sid,
        robberyId = robberyId,
        ptid = ptid
    }
    return req.post(url.transport.battle, data, oncomplete, onfailed)
end

function req.transportMatchFinish(id, sid, robberyId, oncomplete, onfailed)
    local data = {
        transportPlayerId = id,
        sid = sid,
        robberyId = robberyId
    }
    return req.post(url.transport.matchFinish, data, oncomplete, onfailed)
end

function req.transportBattleLog(oncomplete, onfailed)
    return req.post(url.transport.battleLog, nil, oncomplete, onfailed)
end

function req.transportMark(id, sid, oncomplete, onfailed)
    local data = {
        markPlayerId = id,
        sid = sid
    }
    return req.post(url.transport.mark, data, oncomplete, onfailed)
end

function req.transportReceive(oncomplete, onfailed)
    return req.post(url.transport.receive, nil, oncomplete, onfailed)
end

function req.transportAcceptGuard(playerId, sid, oncomplete, onfailed)
    local data = {
        playerId = playerId,
        sid = sid
    }
    return req.post(url.transport.acceptGuard, data, oncomplete, onfailed)
end

function req.transportExpress(pid, oncomplete, onfailed)
    local data = 
    {
        expressPlayerId = pid
    }
    return req.post(url.transport.express, data, oncomplete, onfailed)
end

function req.multiRankInfo(oncomplete, onfailed)
    return req.post(url.rank.multiRanksInfo, nil, oncomplete, onfailed)
end

function req.voicePackInfo(oncomplete, onfailed)
    return req.post(url.voice.voicePackInfo, nil, oncomplete, onfailed)
end

function req.voicePackChange(voicePackID, oncomplete, onfailed)
    local data = {
        voicePack = voicePackID
    }
    return req.post(url.voice.voicePackChange, data, oncomplete, onfailed)
end



function req.topic(oncomplete, onfailed)
    return req.post(url.topicComment.topic, oncomplete, onfailed)
end

function req.addNormalComment(topicID, content, oncomplete, onfailed)
    local tempcid
    if type(topicID) == "string" then
        tempcid = topicID
        topicID = nil
    end
    local data = {
        topic = topicID,
        content = content,
        cid = tempcid,
    }
    return req.post(url.topicComment.addNormalComment, data, oncomplete, onfailed)
end

function req.queryNormalHotComment(topicID, startIndex, num, oncomplete, onfailed)
    local tempcid
    if type(topicID) == "string" then
        tempcid = topicID
        topicID = nil
    end
    local data = {
        topic = topicID,
        startIndex = startIndex,
        num = num,
        cid = tempcid,
    }
    return req.post(url.topicComment.queryNormalHotComment, data, oncomplete, onfailed)
end

function req.queryNormalNewComment(topicID, startIndex, num, oncomplete, onfailed)
    local tempcid
    if type(topicID) == "string" then
        tempcid = topicID
        topicID = nil
    end    
    local data = {
        topic = topicID,
        startIndex = startIndex,
        num = num,
        cid = tempcid,
    }
    return req.post(url.topicComment.queryNormalNewComment, data, oncomplete, onfailed)
end

function req.replyComment(commentID, content, oncomplete, onfailed)
    local data = {
        commentId = commentID,
        content = content,
    }
    return req.post(url.topicComment.replyComment, data, oncomplete, onfailed)
end

function req.queryReplyComment(commentID, startIndex, num, oncomplete, onfailed)
    local data = {
        commentId = commentID,
        startIndex = startIndex,
        num = num,
    }
    return req.post(url.topicComment.queryReplyComment, data, oncomplete, onfailed)
end

function req.agreeComment(commentID, oncomplete, onfailed)
    local data = {
        commentId = commentID
    }
    return req.post(url.topicComment.agreeComment, data, oncomplete, onfailed)
end

function req.disagreeComment(commentID, oncomplete, onfailed)
    local data = {
        commentId = commentID
    }
    return req.post(url.topicComment.disagreeComment, data, oncomplete, onfailed)
end

function req.dreamCardAdd(dreamCardId, oncomplete, onfailed)
    local data = {
        dreamCardId = dreamCardId
    }
    return req.post(url.dreamLeague.dreamCardAdd, data, oncomplete, onfailed)
end

function req.dreamCardDecomposition(dcid, oncomplete, onfailed)
    local data = {
        dcid = dcid
    }
    return req.post(url.dreamLeague.dreamCardDecomposition, data, oncomplete, onfailed)
end

function req.dreamCardDecompositionAll(dcids, oncomplete, onfailed)
    local data = {
        dcids = dcids
    }
    return req.post(url.dreamLeague.dreamCardDecompositionAll, data, oncomplete, onfailed)
end

function req.dreamCardLock(dcid, oncomplete, onfailed)
    local data = {
        dcid = dcid
    }
    return req.post(url.dreamLeague.dreamCardLock, data, oncomplete, onfailed)
end

function req.dreamCardUnlock(dcid, oncomplete, onfailed)
    local data = {
        dcid = dcid
    }
    return req.post(url.dreamLeague.dreamCardUnlock, data, oncomplete, onfailed)
end

function req.dreamShopInfo(oncomplete, onfailed)
    return req.post(url.dreamLeague.dreamShopInfo, nil, oncomplete, onfailed)
end

function req.dreamShopBuy(itemId, oncomplete, onfailed)
    local data = {
        itemId = itemId
    }
    return req.post(url.dreamLeague.dreamShopBuy, data, oncomplete, onfailed)
end

function req.dreamLeagueMatchIndex(oncomplete, onfailed)
    return req.post(url.dreamLeague.dreamLeagueMatchIndex, nil, oncomplete, onfailed)
end

function req.dreamLeagueMatchInfo(oncomplete, onfailed)
    return req.post(url.dreamLeague.dreamLeagueMatchInfo, nil, oncomplete, onfailed)
end

function req.dreamLeagueTeamAddDreamCard(dcid, oncomplete, onfailed)
    local data = {
        dcid = dcid
    }
    return req.post(url.dreamLeague.dreamLeagueTeamAddDreamCard, data, oncomplete, onfailed)
end

function req.dreamLeagueMatchTeam(matchId, oncomplete, onfailed)
    local data = {
        matchId = matchId
    }
    return req.post(url.dreamLeague.dreamLeagueMatchTeam, data, oncomplete, onfailed)
end

function req.dreamLeagueMatchHistory(oncomplete, onfailed)
    return req.post(url.dreamLeague.dreamLeagueMatchHistory, nil, oncomplete, onfailed)
end

function req.dreamLeagueTeamcard(matchTag, dcid, oncomplete, onfailed)
    local data = {
        matchTag = matchTag,
        dcid = dcid
    }
    return req.post(url.dreamLeague.dreamLeagueTeamcard, data, oncomplete, onfailed)
end

function req.dreamLeagueMatchRank(matchTag, oncomplete, onfailed)
    local data = {
        matchTag = matchTag
    }
    return req.post(url.dreamLeague.dreamLeagueMatch, data, oncomplete, onfailed)
end

function req.dreamLeagueRoomCreate(matchId, roomId, dcids, oncomplete, onfailed)
    local data = {
        matchId = matchId,
        roomId = roomId,
        dcids = dcids,
    }
    return req.post(url.dreamLeague.dreamLeagueRoomCreate, data, oncomplete, onfailed)
end

function req.dreamLeagueRoomInfo(id, oncomplete, onfailed)
    local data = {
        id = id
    }
    return req.post(url.dreamLeague.dreamLeagueRoomInfo, data, oncomplete, onfailed)
end

function req.dreamLeagueRoomJoin(id, dcids, oncomplete, onfailed)
    local data = {
        id = id,
        dcids = dcids
    }
    return req.post(url.dreamLeague.dreamLeagueRoomJoin, data, oncomplete, onfailed)
end

function req.dreamLeagueRoomList(roomId, roomNum, oncomplete, onfailed)
    local data = {
        roomId = roomId,
        roomNum = roomNum
    }
    return req.post(url.dreamLeague.dreamLeagueRoomList, data, oncomplete, onfailed)
end

function req.dreamLeagueMatchGuessInfo(matchType, oncomplete, onfailed)
    local data = {
        type = matchType
    }
    return req.post(url.dreamLeague.dreamLeagueMatchGuessInfo, data, oncomplete, onfailed)
end

-- matchId只有mvp需要传入
function req.dreamLeagueMatchGuess(cardName, matchId, type, oncomplete, onfailed)
    local data = {
        cardName = cardName,
        matchId = matchId,
        type = type
    }
    return req.post(url.dreamLeague.dreamLeagueMatchGuess, data, oncomplete, onfailed)
end

function req.dreamLeagueRoomRecord(oncomplete, onfailed)
    return req.post(url.dreamLeague.dreamLeagueRoomRecord, oncomplete, onfailed)
end

function req.dreamLeagueRoomPlayerCards(roomId, pid, oncomplete, onfailed)
    local data = {
        id = roomId,
        pid = pid
    }
    return req.post(url.dreamLeague.dreamLeagueRoomPlayerCards, data, oncomplete, onfailed)
end

function req.dreamLeagueRoomReceive(id, oncomplete, onfailed)
    local data = {
        id = id
    }
    return req.post(url.dreamLeague.dreamLeagueRoomReceive, data, oncomplete, onfailed)
end

function req.dreamLeagueRoomNew(oncomplete, onfailed)
    return req.post(url.dreamLeague.dreamLeagueRoomNew, oncomplete, onfailed)
end

function req.dreamLeagueRoomOpen(oncomplete, onfailed)
    return req.post(url.dreamLeague.dreamLeagueRoomOpen, nil, oncomplete, onfailed)
end

function req.dreamLeagueMatchGuessList(oncomplete, onfailed)
    return req.post(url.dreamLeague.dreamLeagueMatchGuessList, oncomplete, onfailed)
end

function req.dreamLeagueMatchOpen(oncomplete, onfailed)
    return req.post(url.dreamLeague.dreamLeagueMatchOpen, oncomplete, onfailed)
end

function req.worldTournamentShopInfo(oncomplete, onfailed)
    return req.post(url.worldTournamentShop.info, nil, oncomplete, onfailed)
end

function req.worldTournamentShopBuy(id, num, oncomplete, onfailed)
    local data = {
        itemId = id,
        num = num
    }
    return req.post(url.worldTournamentShop.buy, data, oncomplete, onfailed)
end

function req.worldTournamentMatchList(oncomplete, onfailed)
    local data = {
    }
    return req.post(url.worldTournament.matchList, data, oncomplete, onfailed)
end

--[[
-- @seaon 赛季名称，nil为当前赛季
-- @matchType 挑战比赛类型，7、8、9、10、11，默认为7
]]
function req.worldTournamentRank(season, matchType, oncomplete, onfailed)
    local data = {
        season = season,
        matchType = matchType or 7
    }
    return req.post(url.worldTournament.rank, data, oncomplete, onfailed)
end

function req.worldTournamentRewardData(data, oncomplete, onfailed)
    return req.post(url.worldTournament.reward, nil, oncomplete, onfailed)
end

function req.worldTournamentCrossInfo(season, matchType, oncomplete, onfailed)
    local data = {
        season = season,
        item = matchType or 1
    }
    return req.post(url.worldTournament.crossInfo, data, oncomplete, onfailed)
end

function req.worldTournamentRewardCollectOneMail(mid, oncomplete, onfailed)
    local data = {mid = mid}
    return req.post(url.worldTournament.collectOneMail, data, oncomplete, onfailed)
end

function req.worldTournamentRewardCollectAllMails(oncomplete, onfailed)
    return req.post(url.worldTournament.collectAllMails, nil, oncomplete, onfailed)
end

function req.worldTournamentGetTeam(oncomplete, onfailed)
    return req.post(url.worldTournament.getTeam, nil, oncomplete, onfailed)
end

-- 阵型界面：保存竞技场阵容
-- @param nowTeamId 阵容Id
-- @param nowFormationId 阵型Id
-- @param initPlayersData 首发球员数据
-- @param replacePlayersData 替补球员数据
-- @param teamType  球队类型定义：普通或者竞技场
function req.worldTournamentSaveTeam(nowTeamId, nowFormationId, initPlayersData, replacePlayersData, teamType, keyPlayersData, tacticsData, selectedType, oncomplete, onfailed)
    local data = {
        ptid = nowTeamId,
        formationID = nowFormationId,
        init = initPlayersData,
        rep = replacePlayersData,
        teamType = teamType,
        freeKickShoot = keyPlayersData.freeKickShoot,
        spotKick = keyPlayersData.spotKick,
        captain = keyPlayersData.captain,
        freeKickPass = keyPlayersData.freeKickPass,
        corner = keyPlayersData.corner,
        tactics = tacticsData,
        selectedType = selectedType,
    }
    return req.post(url.worldTournament.saveTeam, data, oncomplete, onfailed)
end

-- 一键清空阵容
function req.competeTeamClear(teamType, oncomplete, onfailed)
    local data = {
        teamType = teamType
    }
    return req.post(url.worldTournament.clearTeam, data, oncomplete, onfailed)
end

function req.competeCrossMatch(crossType, oncomplete, onfailed)
    local data = {
        kind = crossType
    }
    return req.post(url.worldTournament.serverSchedule, data, oncomplete, onfailed)
end

function req.competeMatch(pid, matchType, sid, oncomplete, onfailed)
    local data = {
        pid = pid,
        matchType = matchType,
        sid = sid
    }
    return req.post(url.worldTournament.match, data, oncomplete, onfailed)
end

function req.competeBanner(oncomplete, onfailed, quiet)
    return req.post(url.worldTournament.border, nil, oncomplete, onfailed, quiet)
end

-- 查看争霸赛详情
function req.competeFormationDetail(pid, sid, matchType, oncomplete, onfailed)
    local data = {
        pid = pid,
        sid = sid,
        matchType = "worldTournament"
    }
    return req.post(url.friends.detail, data, oncomplete, onfailed)
end

function req.competeSchedule(matchType, oncomplete, onfailed)
    local data = {
        matchType = matchType
    }
    return req.post(url.worldTournament.teamMatch, data, oncomplete, onfailed)
end
function req.recruitRewardRankingList(periodId, oncomplete, onfailed)
    local data = {
        periodId = periodId,
    }
    return req.post(url.activity.recruitRewardRankingList, data, oncomplete, onfailed)
end

function req.collectReward(type, id, param, oncomplete, onfailed)
    local data = {
        id = id,
        param = param,
    }
    data["type"] = type
    return req.post(url.activity.collectReward, data, oncomplete, onfailed)
end

function req.pasterSplitActivity(ptid, costType, oncomplete, onfailed)
    local data = {
        ptid = ptid,
        costType = costType,
    }
    return req.post(url.activity.pasterSplitActivity, data, oncomplete, onfailed)
end

function req.getNewDataByTableName(tableName, maxId)
    local data = {
    }
    data.jsonUpdate = {}
    data.jsonUpdate[tableName] = maxId
    return req.post(url.activity.getNewDataByTableName, data, oncomplete, onfailed)
end

function req.worldTournamentSortBorder(oncomplete, onfailed)
    return req.post(url.worldTournament.sortBorder, nil, oncomplete, onfailed)
end

function req.worldTournamentVideo(vid, oncomplete, onfailed)
    local data = {
        vid = vid
    }
    return req.post(url.worldTournament.video, data, oncomplete, onfailed)
end

function req.RecycleRequest(pcid, costType, revertType, oncomplete, onfailed)
    local data = {
        pcid = pcid,
        costType = costType,
        revertType = revertType,
    }
    return req.post(url.card.revertCardAttr, data, oncomplete, onfailed)
end

-- 英雄殿堂主页信息
function req.heroHallMainInfo(oncomplete, onfailed)
    return req.post(url.footballHall.info, nil, oncomplete, onfailed)
end

-- 激活殿堂
function req.heroHallActivateHall(id, oncomplete, onfailed)
    local data = {
        id = id
    }
    return req.post(url.footballHall.activateHall, data, oncomplete, onfailed)
end

-- 雕像升级
function req.heroHallUpgradeStatue(id, baseId, oncomplete, onfailed)
    local data = {
        id = id,
        baseId = baseId
    }
    return req.post(url.footballHall.upgradeStatue, data, oncomplete, onfailed)
end

-- 生涯竞速活动
function  req.careerRaceInfo(activityType, oncomplete, onfailed, quiet)
    local data = {
        ["type"] = activityType
    }
    return req.post(url.activity.careerRace, data, oncomplete, onfailed, quiet)
end

-- 月卡商店页面信息
function req.monthCardShopInfo(oncomplete, onfailed)
    return req.post(url.monthCardShop.info, nil, oncomplete, onfailed)
end

-- 月卡商店购买
function req.monthCardShopBuy(goodsId, num, oncomplete, onfailed)
    local data = {
        goodsId = goodsId,
        num = num
    }
    return req.post(url.monthCardShop.buy, data, oncomplete, onfailed)
end

-- 购买砸罐子钥匙
function  req.activityBuyPlayerTreasureKey(periodId, count, oncomplete, onfailed)
    local data = {
        periodId = periodId,
        count = count
    }
    return req.post(url.activity.buyPlayerTreasureKey, data, oncomplete, onfailed)
end

-- 领取砸罐子任务奖励
function  req.activityRedeemPlayerTreasureTaskBonus(periodId, taskId, oncomplete, onfailed)
    local data = {
        periodId = periodId,
        taskId = taskId
    }
    return req.post(url.activity.redeemPlayerTreasureTaskBonus, data, oncomplete, onfailed)
end

-- 领取砸罐子活动次数奖励
function  req.activityRedeemPlayerCountTreasure(periodId, count, oncomplete, onfailed)
    local data = {
        periodId = periodId,
        count = count
    }
    return req.post(url.activity.redeemPlayerCountTreasure, data, oncomplete, onfailed)
end

-- 领取砸罐子奖励
function  req.activityRedeemPlayerTreasure(periodId, list, dayTips, oncomplete, onfailed)
    local data = {
        periodId = periodId,
        list = list,
        dayTips = dayTips or false
    }
    return req.post(url.activity.redeemPlayerTreasure, data, oncomplete, onfailed)
end

-- 刷新砸罐子奖励
function  req.activityRefreshPlayerTreasure(periodId, dayTips, oncomplete, onfailed)
    local data = {
        periodId = periodId,
        dayTips = dayTips or false
    }
    return req.post(url.activity.refreshPlayerTreasure, data, oncomplete, onfailed)
end

-- 获取砸罐子任务列表
function  req.activityGetPlayerTreasureTaskInfo(periodId, oncomplete, onfailed)
    local data = {
        periodId = periodId,
    }
    return req.post(url.activity.getPlayerTreasureTaskInfo, data, oncomplete, onfailed)
end

function req.activityGetOpenServerPowerRank(oncomplete, onfailed)
    return req.post(url.activity.getOpenServerPowerRank, nil, oncomplete, onfailed)
end

-- 点击刷新排行榜按钮
function req.activityRefreshOpenServerPowerRank(oncomplete, onfailed)
    return req.post(url.activity.refreshOpenServerPowerRank, nil, oncomplete, onfailed)
end

-- 领取奖励
function req.activityReceiveOpenServerPowerRank(oncomplete, onfailed)
    return req.post(url.activity.receiveOpenServerPowerRank, nil, oncomplete, onfailed)
end

-- 拍卖行主页信息
function req.auctionInfo(oncomplete, onfailed, quiet)
    return req.post(url.auction.info, nil, oncomplete, onfailed, quiet)
end

-- 我的历史记录
function req.auctionHistory(oncomplete, onfailed, quiet)
    return req.post(url.auction.history, nil, oncomplete, onfailed, quiet)
end

-- 领取奖励
function req.auctionReceive(id, subID, oncomplete, onfailed, quiet)
    local data = {
        id = id,
        subId = subID
    }
    return req.post(url.auction.gain, data, oncomplete, onfailed, quiet)
end

-- 拍卖行单个物品竞拍大厅信息
function req.auctionDetail(id, subID, bFirst, oncomplete, onfailed, quiet)
    local data = {
        id = id,
        subId = subID,
        bFirst = bFirst
    }
    return req.post(url.auction.detail, data, oncomplete, onfailed, quiet)
end

-- 拍卖行玩家出价
function req.auctionBid(id, subID, price, oncomplete, onfailed, quiet)
    local data = {
        id = id,
        subId = subID,
        add = price
    }
    return req.post(url.auction.auction, data, oncomplete, onfailed, quiet)
end

-- 拍卖行排行榜
function req.auctionRank(id, subID, oncomplete, onfailed, quiet)
    local data = {
        id = id,
        subId = subID
    }
    return req.post(url.auction.rank, data, oncomplete, onfailed, quiet)
end

-- 公会嘉年华积分贡献排行
function req.guildCarnivalRank(oncomplete, onfailed)
    return req.post(url.guildCarnival.rank, nil, oncomplete, onfailed)
end

-- 公会嘉年华积分贡献排行
function req.guildCarnivalRecord(oncomplete, onfailed)
    return req.post(url.guildCarnival.record, nil, oncomplete, onfailed)
end

-- 公会嘉年华购买物品
function req.guildCarnivalBuy(itemId, num, oncomplete, onfailed)
    local data = {
        itemId = tonumber(itemId),
        num = num
    }
    return req.post(url.guildCarnival.buy, data, oncomplete, onfailed)
end

-- 争霸赛贴纸升级
function req.pasterUpgrade(ptid, costIds, oncomplete, onfailed)
    local data = {
        ptid = ptid,
        costIds = costIds
    }
    return req.post(url.paster.upgrade, data, oncomplete, onfailed)
end

-- 吉祥物赠礼 公会亲密度排行
function req.mascotPresentGuildRankingList(period, oncomplete, onfailed, quiet)
    local data = {
        period = period
    }
    return req.post(url.mascotPresent.guildRankingList, data, oncomplete, onfailed, quiet)
end

-- 吉祥物赠礼 公会成员亲密度贡献排行
function req.mascotPresentGuildMemberContribution(period, oncomplete, onfailed, quiet)
    local data = {
        period = period
    }
    return req.post(url.mascotPresent.guildMemberContribution, data, oncomplete, onfailed, quiet)
end

-- 吉祥物赠礼 获取吉祥物礼盒数据
function req.mascotPresentGiftBoxInfo(period, count, oncomplete, onfailed, quiet)
    local data = {
        period = period,
        count = count,
    }
    return req.post(url.mascotPresent.giftBoxInfo, data, oncomplete, onfailed, quiet)
end

-- 吉祥物赠礼 刷新任务奖励数据
function req.mascotPresentRefreshTask(period, oncomplete, onfailed, quiet)
    local data = {
        period = period,
    }
    return req.post(url.mascotPresent.refreshTask, data, oncomplete, onfailed, quiet)
end

-- 吉祥物赠礼 领取亲密度进度奖励
function req.mascotPresentCollectProgressReward(period, count, index, oncomplete, onfailed, quiet)
    local data = {
        period = period,
        count = count,
        index = index,
    }
    return req.post(url.mascotPresent.collectProgressReward, data, oncomplete, onfailed, quiet)
end

-- 吉祥物赠礼 领取完成任务奖励
function req.mascotPresentCollectTaskReward(period, taskId, oncomplete, onfailed, quiet)
    local data = {
        period = period,
        taskId = taskId,
    }
    return req.post(url.mascotPresent.collectTaskReward, data, oncomplete, onfailed, quiet)
end

-- 吉祥物赠礼 获得有序及拥有者信息大的礼盒数据
function req.mascotPresentStaticGiftBox(period, count, oncomplete, onfailed, quiet)
    local data = {
        period = period,
        count = count,
    }
    return req.post(url.mascotPresent.OrderOwnerGiftBoxInfo, data, oncomplete, onfailed, quiet)
end

-- 招商引资限时活动
function req.redeemTeamInvest(periodId, oncomplete, onfailed)
    local data = {
        periodId = periodId,
    }
    return req.post(url.activity.redeemTeamInvest, data, oncomplete, onfailed)
end

-- 招商引资新手活动
function req.redeemFreshTeamInvest(periodId, oncomplete, onfailed)
    local data = {
        periodId = periodId,
    }
    return req.post(url.activity.redeemFreshTeamInvest, data, oncomplete, onfailed)
end

-- 拉新 拉新任务状态
function req.fiTaskInfo(oncomplete, onfailed, quiet)
    return req.post(url.friendsInvite.taskInfo, nil, oncomplete, onfailed, quiet)
end

-- 拉新 领取新手奖励
function req.fiCollectNewPlayerReward(code, oncomplete, onfailed)
    local data = {
        code = code,
    }
    return req.post(url.friendsInvite.collectNewPlayerReward, data, oncomplete, onfailed)
end

-- 拉新 领取领取非钻石返礼任务奖励
function req.fiCollectOtherTaskReward(id, oncomplete, onfailed)
    local data = {
        id = id,
    }
    return req.post(url.friendsInvite.collectTaskReward, data, oncomplete, onfailed)
end

-- 拉新 领取领取钻石返礼任务奖励
function req.fiCollectDiaTaskReward(pid, oncomplete, onfailed)
    local data = {
        pid = pid,
    }
    return req.post(url.friendsInvite.collectDiaTaskReward, data, oncomplete, onfailed)
end

-- 教练任务列表
function req.coachGetMissionInfo(oncomplete, onfailed)
    return req.post(url.coach.getmissioninfo, nil, oncomplete, onfailed)
end

-- 接受教练任务
function req.coachAcceptmission(id, pcids, oncomplete, onfailed)
    local data = {
        id = id,
        cardinfo = pcids,
    }
    return req.post(url.coach.acceptmission, data, oncomplete, onfailed)
end

-- 教练任务 购买任务次数
function req.coachBuyMissionTimes(oncomplete, onfailed)
    return req.post(url.coach.buymissiontimes, nil, oncomplete, onfailed)
end

-- 教练任务 刷新任务
function req.coachRefreshMission(oncomplete, onfailed)
    return req.post(url.coach.refreshmission, nil, oncomplete, onfailed)
end

-- 教练任务 领取指定任务奖励
function req.coachGetMissionReward(id, oncomplete, onfailed)
    local data = {
        id = id,
    }
    return req.post(url.coach.getmissionreward, data, oncomplete, onfailed)
end

-- 教练任务 一键领取奖励
function req.coachGetAllMissionReward(oncomplete, onfailed)
    return req.post(url.coach.getallmissionreward, nil, oncomplete, onfailed)
end

-- [教练系统]基本信息，经验、等级、阵型、战术等级等
function req.coachBaseInfo(oncomplete, onfailed, quiet)
    return req.post(url.coach.baseInfo.info, nil, oncomplete, onfailed, quiet)
end

-- [教练系统]使用经验书升级
function req.coachBaseInfoAddExp(num, oncomplete, onfailed, quiet)
    local data = {
        num = num
    }
    return req.post(url.coach.baseInfo.addExp, data, oncomplete, onfailed, quiet)
end

-- [教练系统]阵型升级
function req.coachBaseInfoFormationUpgrade(formationId, oncomplete, onfailed, quiet)
    local data = {
        formationId = formationId
    }
    return req.post(url.coach.baseInfo.formationUpgrade, data, oncomplete, onfailed, quiet)
end

-- [教练系统]战术升级
function req.coachBaseInfoTacticUpgrade(tacticName, tacticValue, oncomplete, onfailed, quiet)
    local data = {
        tactic = tacticName, --战术名称
        tacticVal = tacticValue, -- 战术设置值
    }
    return req.post(url.coach.baseInfo.tacticUpgrade, data, oncomplete, onfailed, quiet)
end

-- [教练系统]天赋升级
function req.coachTalentUpgrade(talentId, oncomplete, onfailed, quiet)
    local data = {
        id = talentId
    }
    return req.post(url.coach.talent.upgrade, data, oncomplete, onfailed, quiet)
end

-- [教练系统]天赋重置
function req.coachTalentReset(oncomplete, onfailed, quiet)
    return req.post(url.coach.talent.reset, nil, oncomplete, onfailed, quiet)
end

-- [教练系统]获取助理教练所有数据
function req.assistantCoachList(oncomplete, onfailed, quiet)
    return req.post(url.coach.assistantCoach.list, nil, oncomplete, onfailed, quiet)
end

-- [教练系统]获取助理教练上阵数据
function req.assistantCoachTeamInfo(oncomplete, onfailed, quiet)
    return req.post(url.coach.assistantCoach.teamInfo, nil, oncomplete, onfailed, quiet)
end

-- [教练系统]助理教练上阵
function req.assistantCoachChangeTeam(teamid, acid, oncomplete, onfailed, quiet)
    local data = {
        teamid = teamid,
        acid = acid
    }
    return req.post(url.coach.assistantCoach.changeTeam, data, oncomplete, onfailed, quiet)
end

-- [教练系统]升级助理教练
function req.assistantCoachUpdate(acid, oncomplete, onfailed, quiet)
    local data = {
        acid = acid
    }
    return req.post(url.coach.assistantCoach.update, data, oncomplete, onfailed, quiet)
end

-- [教练系统]分解/解雇助理教练
function req.assistantCoachDecompose(acid, oncomplete, onfailed, quiet)
    local data = {
        acid = acid
    }
    return req.post(url.coach.assistantCoach.decompose, data, oncomplete, onfailed, quiet)
end

-- [教练系统]获取所有助教情报
function req.assistantCoachInfoList(oncomplete, onfailed, quiet)
    return req.post(url.coach.assistantCoachInfo.list, nil, oncomplete, onfailed, quiet)
end

-- [教练系统]合成助理教练
function req.assistantCoachInfoCompose(items, oncomplete, onfailed, quiet)
    local data = {
        items = items
    }
    return req.post(url.coach.assistantCoachInfo.compose, data, oncomplete, onfailed, quiet)
end

-- [教练系统]出售助理教练情报
function req.assistantCoachInfoSell(oncomplete, onfailed, quiet)
    local data = {}
    return req.post(url.coach.assistantCoachInfo.sell, data, oncomplete, onfailed, quiet)
end

-- [教练系统]分解助理教练情报
function req.assistantCoachInfoDecompose(items, oncomplete, onfailed, quiet)
    local data = {
        items = items
    }
    return req.post(url.coach.assistantCoachInfo.decompose, data, oncomplete, onfailed, quiet)
end

--争霸赛竞猜 获取竞猜数据
function req.competeGuessData(oncomplete, onfailed, quiet)
    return req.post(url.worldTournament.guess.guessList, nil, oncomplete, onfailed, quiet)
end

-- 争霸赛竞猜 竞猜
function req.competeGuess(matchType, guessStage, combatIndex, guessPlayer, oncomplete, onfailed, quiet)
    local data = {
        matchType = matchType,
        guessStage = guessStage,
        combatIndex = combatIndex,
        guessPlayer = guessPlayer,
    }
    return req.post(url.worldTournament.guess.guess, data, oncomplete, onfailed, quiet)
end

-- 争霸赛竞猜 领取奖励
function req.competeGuessReceive(season, round, matchType, combatIndex, oncomplete, onfailed, quiet)
    local data = {
        season = season,
        round = round,
        matchType = matchType,
        combatIndex = combatIndex,
    }
    return req.post(url.worldTournament.guess.receive, data, oncomplete, onfailed, quiet)
end

-- 争霸赛冠军墙
function req.competeGuessChampions(oncomplete, onfailed, quiet)
    return req.post(url.worldTournament.champions, nil, oncomplete, onfailed, quiet)
end

-- 教练界面解锁教练指导栏位
function req.coachGuideUnlock(oncomplete, onfailed)
    return req.post(url.coach.guide.guideUnlock, nil, oncomplete, onfailed)
end

-- 将球员放入指导栏位
function req.coachGuideCard(pcid, slot, oncomplete, onfailed)
    local data = {
        pcid = pcid,
        slot = slot,
    }
    return req.post(url.coach.guide.guideCard, data, oncomplete, onfailed)
end

-- 将球员放入指导栏位后使用特性书及道具会生成的特性
function req.cardFeatureByCoach(pcid, book, item, param, oncomplete, onfailed)
    local data = {
        pcid = pcid,
        book = book,
        item = item,
        param = param
    }
    return req.post(url.coach.feature.guideSkill, data, oncomplete, onfailed)
end

function req.cardFeatureChooseByCoach(pcid, book, item, oncomplete, onfailed)
    local data = {
        pcid = pcid,
        book = book,
        item = item,
    }
    return req.post(url.coach.feature.confirmGuideSkill, data, oncomplete, onfailed)
end

-- 获取助教情报信息Gacha
function req.getAssistantCoachGacha(oncomplete, onfailed, quiet)
    return req.post(url.coach.assistantCoachGacha.get, nil, oncomplete, onfailed, quiet)
end

-- 幸运值兑换助理教练情报礼包
function req.exchangeAssistantCoachGift(gachaid, giftid, oncomplete, onfailed, quiet)
    local data = {
        gachaid = gachaid,
        giftid = giftid,
    }
    return req.post(url.coach.assistantCoachGacha.exchange, data, oncomplete, onfailed, quiet)
end

-- 购买助理教练情报礼包
function req.buyAssistantCoachGift(gachaid, times, consumeType, oncomplete, onfailed, quiet)
    local data = {
        gachaid = gachaid,
        times = times,
        consumeType = consumeType,
    }
    return req.post(url.coach.assistantCoachGacha.buy, data, oncomplete, onfailed, quiet)
end

-- 争霸赛竞猜 确认机制
function req.competeGuessConfirm(confirm, oncomplete, onfailed, quiet)
    local data = {
        confirm = confirm,
    }
    return req.post(url.worldTournament.guess.confirm, data, oncomplete, onfailed, quiet)
end

function req.buyChainGiftBox(chainGiftBoxId, count, oncomplete, onfailed)
    local data = {
        ID = chainGiftBoxId,
        cnt = count or 1
    }
    return req.post(url.activity.buyGiftBox, data, oncomplete, onfailed)
end

function req.powerShootRefresh(subID, oncomplete, onfailed)
    local data = {
        subID = subID,
    }
    return req.post(url.activity.powerShootRefresh, data, oncomplete, onfailed)
end

function req.powerShootStartShoot(subID, oncomplete, onfailed)
    local data = {
        subID = subID,
    }
    return req.post(url.activity.powerShootStartShoot, data, oncomplete, onfailed)
end

function req.powerShootShooting(subID, pos, oncomplete, onfailed)
    local data = {
        subID = subID,
        pos = pos,
    }
    return req.post(url.activity.powerShootShooting, data, oncomplete, onfailed)
end

-- 购买进阶奖励资格
function req.goldBallBuyAdvance(oncomplete, onfailed, quiet)
    return req.post(url.goldBall.buyAdvance, nil, oncomplete, onfailed, quiet)
end

-- 领取位置奖励
-- rewardType: 1为普通奖励，2为进阶奖励
function req.goldBallReceiveGoldBall(posId, rewardType, oncomplete, onfailed, quiet)
    local data = {
        posId = posId,
        type = rewardType
    }
    return req.post(url.goldBall.receiveGoldBall, data, oncomplete, onfailed, quiet)
end

-- 领取任务奖励金球
function req.goldBallReceiveTask(taskId, oncomplete, onfailed, quiet)
    local data = {
        taskId = taskId
    }
    return req.post(url.goldBall.receiveTask, data, oncomplete, onfailed, quiet)
end

-- 查看等级礼包
function req.levelBoxInfo(oncomplete, onfailed, quiet)
    return req.post(url.levelBox.info, nil, oncomplete, onfailed, quiet)
end

-- 领取等级礼包
function req.levelBoxReceive(subId, selectId, oncomplete, onfailed, quiet)
    local data = {
        subId = subId,
        selectId = selectId,
    }
    return req.post(url.levelBox.receive, data, oncomplete, onfailed, quiet)
end

-- 激活卡牌传奇记忆
function req.cardActiveMemory(qualityKey, pcid, mPcid, oncomplete, onfailed, quiet)
    local data = {
        quality = qualityKey,
        pcid = pcid,
        mPcid = mPcid
    }
    return req.post(url.card.activeMemory, data, oncomplete, onfailed, quiet)
end

function req.greenswardAdventure(oncomplete, onfailed)
    return req.post(url.greenswardAdventure.info, nil, oncomplete, onfailed)
end

function req.greenswardAdventureOpen(row, col, oncomplete, onfailed)
    local data = {
        row = row,
        column = col,
    }
    return req.post(url.greenswardAdventure.open, data, oncomplete, onfailed)
end

function req.greenswardAdventureTrigger(row, col, costType, oncomplete, onfailed)
    local data = {
        row = row,
        column = col,
		costType = costType,
    }
    return req.post(url.greenswardAdventure.trigger, data, oncomplete, onfailed)
end

function req.greenswardAdventureBribe(row, col, costType, oncomplete, onfailed)
    local data = {
        row = row,
        column = col,
		costType = costType
    }
    return req.post(url.greenswardAdventure.bribe, data, oncomplete, onfailed)
end

function req.greenswardAdventureMatch(row, col, costType, oncomplete, onfailed)
    local data = {
        row = row,
        column = col,
		costType = costType
    }
    return req.post(url.greenswardAdventure.match, data, oncomplete, onfailed)
end

function req.greenswardAdventurePassNextFloor(oncomplete, onfailed)
    local data = {}
    return req.post(url.greenswardAdventure.nextFloor, data, oncomplete, onfailed)
end

function req.greenswardAdventureChangeFloor(floor, oncomplete, onfailed)
    local data = {
		floor = floor
	}
    return req.post(url.greenswardAdventure.changeFloor, data, oncomplete, onfailed)
end

function req.greenswardAdventureOpponent(row, col, oncomplete, onfailed, quiet)
    local data = {
        row = row,
        column = col,
    }
    return req.post(url.greenswardAdventure.viewOpponent, data, oncomplete, onfailed, quiet)
end

function req.greenswardAdventureOpponentDetail(row, col, oncomplete, onfailed, quiet)
    local data = {
        row = row,
        column = col,
    }
    return req.post(url.greenswardAdventure.viewOpDetail, data, oncomplete, onfailed, quiet)
end

function req.greenswardAdventureOpenLottery(row, col, oncomplete, onfailed)
    local data = {
        row = row,
        column = col,
    }
    return req.post(url.greenswardAdventure.openLottery, data, oncomplete, onfailed)
end

function req.greenswardAdventureOpenWheel(row, col, oncomplete, onfailed)
    local data = {
        row = row,
        column = col,
    }
    return req.post(url.greenswardAdventure.openWheel, data, oncomplete, onfailed)
end

function req.greenswardAdventureOpenStore(row, col, oncomplete, onfailed)
    local data = {
        row = row,
        column = col,
    }
    return req.post(url.greenswardAdventure.openStore, data, oncomplete, onfailed)
end

function req.greenswardAdventureBuyStore(row, col, id, num, oncomplete, onfailed)
    local data = {
        row = row,
        column = col,
        id = id,
        num = num,
    }
    return req.post(url.greenswardAdventure.buyStore, data, oncomplete, onfailed)
end

function req.greenswardAdventureRewardInfo(oncomplete, onfailed)
    return req.post(url.greenswardAdventure.rewardInfo, nil, oncomplete, onfailed)
end

function req.greenswardAdventureViewCell(row, col, oncomplete, onfailed)
    local data = {
        row = row,
        column = col,
    }
    return req.post(url.greenswardAdventure.viewCell, data, oncomplete, onfailed)
end

function req.greenswardAdventureAnswerReward(row, col, oncomplete, onfailed)
    local data = {
        row = row,
        column = col,
    }
    return req.post(url.greenswardAdventure.answerReward, data, oncomplete, onfailed)
end

function req.greenswardAdventureTreasureActivation(row, col, oncomplete, onfailed)
    local data = {
        row = row,
        column = col,
    }
    return req.post(url.greenswardAdventure.testCell, data, oncomplete, onfailed)
end

function req.greenswardAdventureTreasureOpen(row, col, costType, oncomplete, onfailed)
    local data = {
        row = row,
        column = col,
		costType = costType
    }
    return req.post(url.greenswardAdventure.openTreasure, data, oncomplete, onfailed)
end

-- 【绿茵征途】查看藏宝图
function req.greenswardAdventureTreasureMap(id, oncomplete, onfailed, quiet)
    local data = {
        id = id
    }
    return req.post(url.greenswardAdventure.treasureMap, data, oncomplete, onfailed, quiet)
end

-- 【绿茵征途】使用道具
function req.greenswardAdventureUseItem(id, row, col, oncomplete, onfailed, quiet)
    local data = {
        id = id,
        row = row,
        column = col
    }
    return req.post(url.greenswardAdventure.useItem, data, oncomplete, onfailed, quiet)
end

-- 【绿茵征途】打开商店请求数据
function req.greenswardAdventureOpenItemStore(oncomplete, onfailed, quiet)
    return req.post(url.greenswardAdventure.openItemStore, nil, oncomplete, onfailed, quiet)
end

-- 【绿茵征途】购买商店中物品
function req.greenswardAdventureBuyItemStore(id, num, oncomplete, onfailed, quiet)
    local data = {
        id = id,
        num = num
    }
    return req.post(url.greenswardAdventure.buyItemStore, data, oncomplete, onfailed, quiet)
end

function req.greenswardAdventureSubway(row, col, oncomplete, onfailed)
    local data = {
        row = row,
        column = col,
    }
    return req.post(url.greenswardAdventure.subway, data, oncomplete, onfailed)
end

function req.greenswardAdventureRankBoard(season, region, oncomplete, onfailed)
    local data = {
        region = region,
        season = season,
    }
    return req.post(url.greenswardAdventure.rankBoard, data, oncomplete, onfailed)
end

function req.greenswardAdventureRankView(oncomplete, onfailed)
    return req.post(url.greenswardAdventure.rankView, nil, oncomplete, onfailed)
end

function req.greenswardAdventureFullStageRewardInfo(oncomplete, onfailed)
    return req.post(url.greenswardAdventure.fullStageRewardInfo, nil, oncomplete, onfailed)
end

function req.greenswardAdventureReceiveFullStageReward(floor, oncomplete, onfailed)
    local data = {
        floor = floor,
    }
    return req.post(url.greenswardAdventure.receiveFullStageReward, data, oncomplete, onfailed)
end

function req.greenswardAdventureMoraleBuy(oncomplete, onfailed)
    return req.post(url.greenswardAdventure.buyMorale, nil, oncomplete, onfailed)
end

function req.greenswardAdventureMoraleDailyRecieve(oncomplete, onfailed)
    return req.post(url.greenswardAdventure.dailyMorale, nil, oncomplete, onfailed)
end

-- 【绿茵征途】获取士气赠送列表
function req.greenswardAdventureFriend(oncomplete, onfailed, quiet)
    return req.post(url.greenswardAdventure.friend, nil, oncomplete, onfailed, quiet)
end

-- 【绿茵征途】领取单个好友士气
function req.greenswardAdventureRcvMorale(pid, sid, oncomplete, onfailed, quiet)
    local data = {
        pid = pid,
        sid = sid
    }
    return req.post(url.greenswardAdventure.rcvMorale, data, oncomplete, onfailed, quiet)
end

-- 【绿茵征途】赠送单个好友士气
function req.greenswardAdventureSendMorale(pid, sid, oncomplete, onfailed, quiet)
    local data = {
        pid = pid,
        sid = sid
    }
    return req.post(url.greenswardAdventure.sendMorale, data, oncomplete, onfailed, quiet)
end

-- 【绿茵征途】一键领取
function req.greenswardAdventureRcvMorales(oncomplete, onfailed, quiet)
    return req.post(url.greenswardAdventure.rcvMorales, nil, oncomplete, onfailed, quiet)
end

-- 【绿茵征途】一键赠送
function req.greenswardAdventureSendMorales(oncomplete, onfailed, quiet)
    return req.post(url.greenswardAdventure.sendMorales, nil, oncomplete, onfailed, quiet)
end

-- 【绿茵征途】产看神秘指令
function req.greenswardAdventureMysticHint(id, oncomplete, onfailed, quiet)
    local data = {
        id = id
    }
    return req.post(url.greenswardAdventure.mysticHint, data, oncomplete, onfailed, quiet)
end

-- 【绿茵征途】设置玩家形象
function req.greenswardAdventureSetImage(setType, itemId, oncomplete, onfailed, quiet)
    local data = {
        type = setType,
        itemId = itemId
    }
    return req.post(url.greenswardAdventure.setImage, data, oncomplete, onfailed, quiet)
end

-- 【绿茵征途】是否已开启
function req.greenswardAdventureIndex(oncomplete, onfailed, quiet)
    return req.post(url.greenswardAdventure.index, nil, oncomplete, onfailed, quiet)
end

-- 【绿茵征途】藏宝图奖励预览
function req.greenswardAdventureTreasurePreview(oncomplete, onfailed, quiet)
    return req.post(url.greenswardAdventure.treasurePreview, nil, oncomplete, onfailed, quiet)
end

function req.cardLegendUnlockChapter(pcid, id, oncomplete, onfailed, quiet)
    local data = {
        pcid = pcid,
        id = id,
    }
    return req.post(url.cardLegend.unlock, data, oncomplete, onfailed, quiet)
end

function req.cardLegendUnlockStage(pcid, chapterId, stageId, oncomplete, onfailed, quiet)
    local data = {
        pcid = pcid,
        memoryID = chapterId,
        pieceID = stageId,
    }
    return req.post(url.cardLegend.upgrade, data, oncomplete, onfailed, quiet)
end

function req.cardLegendSelectAttr(pcid, chapterId, stageId, attr, oncomplete, onfailed, quiet)
    local data = {
        pcid = pcid,
        memoryID = chapterId,
        pieceID = stageId,
        attr = attr,
    }
    return req.post(url.cardLegend.selectAttr, data, oncomplete, onfailed, quiet)
end

function req.cardLegendSelectSkill(pcid, chapterId, stageId, skill, oncomplete, onfailed, quiet)
    local data = {
        pcid = pcid,
        memoryID = chapterId,
        pieceID = stageId,
        skill = skill,
    }
    return req.post(url.cardLegend.selectSkill, data, oncomplete, onfailed, quiet)
end

function req.cardLegendActivateExPaster(pcid, oncomplete, onfailed, quiet)
    local data = {
        pcid = pcid,
    }
    return req.post(url.cardLegend.activateExPaster, data, oncomplete, onfailed, quiet)
end

-- 【公会战 迷雾战场】迷雾公会战入口
function req.guildWarMistInfo(oncomplete, onfailed)
    return req.post(url.guildWar.mistInfo, nil, oncomplete, onfailed)
end

-- 【公会战 迷雾战场】己方迷雾公会守卫席信息
function req.guildWarGuardsInfoMist(round, oncomplete, onfailed)
    local data = {
        round = round,
    }
    return req.post(url.guildWar.guardsInfoMist, data, oncomplete, onfailed)
end

-- 【公会战 迷雾战场】迷雾成员信息
function req.guildWarMemberInfoMist(round, oncomplete, onfailed)
    local data = {
        round = round,
    }
    return req.post(url.guildWar.memberInfoMist, data, oncomplete, onfailed)
end

-- 【公会战 迷雾战场】部署迷雾守卫席
function req.guildWarDeployMist(targetPos, targetPid, round, oncomplete, onfailed)
    local data = {
        targetPos = targetPos,
        targetPid = targetPid,
        round = round
    }
    return req.post(url.guildWar.deployMist, data, oncomplete, onfailed)
end

-- 【公会战 迷雾战场】迷雾公会战报名信息
function req.guildWarSignInfoMist(oncomplete, onfailed)
    return req.post(url.guildWar.signInfoMist, nil, oncomplete, onfailed)
end

-- 【公会战 迷雾战场】迷雾公会战报名
function req.guildWarSignMist(level, oncomplete, onfailed)
    local data = {
        level = level,
    }
    return req.post(url.guildWar.signMist, data, oncomplete, onfailed)
end

-- 【公会战 迷雾战场】公会战状况
function req.guildWarWarInfoMist(oncomplete, onfailed)
    return req.post(url.guildWar.warInfoMist, nil, oncomplete, onfailed)
end

-- 【公会战 迷雾战场】购买buff
function req.guildWarBuyBuffMist(round, buffID, oncomplete, onfailed)
    local data = {
        round = round,
        buffID = buffID
    }
    return req.post(url.guildWar.buyBuffMist, data, oncomplete, onfailed)
end

-- 【公会战 迷雾战场】攻打守卫席
function req.guildWarStartMist(pos, oncomplete, onfailed)
    local data = {
        pos = pos
    }
    return req.post(url.guildWar.startMist, data, oncomplete, onfailed)
end

-- 【公会战 迷雾战场】赛程
function req.guildWarScheduleInfoMist(oncomplete, onfailed)
    return req.post(url.guildWar.scheduleInfoMist, nil, oncomplete, onfailed)
end

-- 【公会战 迷雾战场】敌方守卫席详情
function req.guildWarTargetGuardDetailMist(pos, oncomplete, onfailed)
    local data = {
        pos = pos,
    }
    return req.post(url.guildWar.targetGuardDetailMist, data, oncomplete, onfailed)
end

-- 【公会战 迷雾战场】守卫席详情
function req.guildWarSelfGuardDetailMist(pos, oncomplete, onfailed)
    local data = {
        pos = pos,
    }
    return req.post(url.guildWar.selfGuardDetailMist, data, oncomplete, onfailed)
end

-- 【公会战 迷雾战场】查看比赛录像
function req.guildWarViewVideoMist(videoID, oncomplete, onfailed)
    local data = {
        videoID = videoID
    }
    return req.post(url.guildWar.viewVideoMist, data, oncomplete, onfailed)
end

-- 【公会战 迷雾战场】获取最近两期公会战
function req.guildWarRecentGuildWarMist(oncomplete, onfailed)
    return req.post(url.guildWar.recentGuildWarMist, nil, oncomplete, onfailed)
end

-- 【公会战 迷雾战场】查看玩家详情
function req.guildWarViewPlayerMist(oncomplete, onfailed)
    return req.post(url.guildWar.viewPlayerMist, nil, oncomplete, onfailed)
end

-------------------------------------------
-- 【公会战 迷雾战场】购买迷雾商品信息
function req.guildWarMistShopInfo(round, oncomplete, onfailed)
    local data = {
        round = round,
    }
    return req.post(url.guildWar.mistShopInfo, data, oncomplete, onfailed)
end

-- 【公会战 迷雾战场】改变地图的防御等级
function req.guildWarChangGuardsInfoDefendLevel(mapId, posInfo, oncomplete, onfailed)
    local data = {
        mapId = mapId,
        posInfo = posInfo,
    }
    return req.post(url.guildWar.changGuardsInfoDefendLevel, data, oncomplete, onfailed)
end

-- 【公会战 迷雾战场】从迷雾商店购买道具
function req.guildWarBuyMistItem(itemID, oncomplete, onfailed)
    local data = {
        itemID = itemID,
    }
    return req.post(url.guildWar.buyMistItem, data, oncomplete, onfailed)
end

-- 【公会战 迷雾战场】主入口
function req.guildWarMainInfo(oncomplete, onfailed)
    return req.post(url.guildWar.mainInfo, nil, oncomplete, onfailed)
end

-- 【公会战 迷雾战场】 所有地图使用详情
function req.guildWarMistMapInfo(oncomplete, onfailed)
    return req.post(url.guildWar.mistMapInfo, nil, oncomplete, onfailed)
end

-- 【公会战 迷雾战场】 选择地图
function req.guildWarSelectMistMap(round, mapId, oncomplete, onfailed)
    local data = {
        round = round,
        mapId = mapId,
    }
    return req.post(url.guildWar.selectMistMap, data, oncomplete, onfailed)
end

-- 【公会战 迷雾战场】 保存地图
function req.guildWarSaveGuardsInfoMist(round, posInfo, oncomplete, onfailed)
    local data = {
        round = round,
        posInfo  = posInfo,
    }
    return req.post(url.guildWar.saveGuardsInfoMist, data, oncomplete, onfailed)
end

-- 【公会战 迷雾战场】 获取指定轮次的 守卫席信息
function req.guildWarGuardsInfoMistByRound(round, oncomplete, onfailed)
    local data = {
        round = round,
    }
    return req.post(url.guildWar.guardsInfoMistByRound, data, oncomplete, onfailed)
end

-- 【公会战】 工会捐献信息
function req.guildGetDonationInfo(oncomplete, onfailed)
    return req.post(url.guild.getDonationInfo, nil, oncomplete, onfailed)
end

-- 【公会战】 工会捐献
function req.guildDonation(id , oncomplete, onfailed)
    local data = {
        id  = id ,
    }
    return req.post(url.guild.donation, data, oncomplete, onfailed)
end

-- 工会迷雾排行榜
function req.guildPowerMistRank(oncomplete, onfailed)
    return req.post(url.guild.powerMistRank, nil, oncomplete, onfailed)
end

-- 阶梯商店任务信息
function req.activityStageShopGetTaskInfo(oncomplete, onfailed)
    return req.post(url.activity.stageShopGetTaskInfo, nil, oncomplete, onfailed)
end

-- 阶梯商店领取任务奖励
function req.activityStageShopReceiveTask(taskId, oncomplete, onfailed)
    local data = {
        taskId = taskId,
    }
    return req.post(url.activity.stageShopReceiveTask, data, oncomplete, onfailed)
end

-- 阶梯商店购买商店物品
function req.activityStageShopBuyItem(stageId, num, oncomplete, onfailed)
    local data = {
        stageId = stageId,
        num = num,
    }
    return req.post(url.activity.stageShopBuyItem, data, oncomplete, onfailed)
end

-- 录像结果比对 服务器存日志
function req.matchRecordResult(replayCheck, oncomplete, onfailed)
    return req.post(url.match.recordResult, replayCheck, oncomplete, onfailed, true)
end

--购买事件礼盒
function req.eventGiftBagBuy(id, oncomplete, onfailed)
	local data = {
		id = id
	}
	return req.post(url.eventGiftBag.buy, data, oncomplete, onfailed)
end

function req.checkAppVersion(oncomplete, onfailed)
    local appVerCode = luaevt.trig("SDK_GetAppVerCode")
    local cuid = cache.getCuid()
    local data = {
        capid = clr.capid(),
        pf = clr.plat,
        channel = cache.getChannel(),
        appVer = tostring(appVerCode),
        cuid = cuid,
    }
    return req.post(url.checkAppVersion, data, oncomplete, onfailed)
end

function req.dollStart(periodId, times, oncomplete, onfailed)
    local data = {
        periodId = periodId,
        times = times
    }
    return req.post(url.activity.dollStart, data, oncomplete, onfailed)
end

function req.dollChangedReward(periodId, rewards, oncomplete, onfailed)
    local data = {
        periodId = periodId,
        rewards = rewards
    }
    return req.post(url.activity.dollChangedReward, data, oncomplete, onfailed)
end

function req.dollReceive(periodId, rewardId, oncomplete, onfailed)
    local data = {
        periodId = periodId,
        rewardId = rewardId
    }
    return req.post(url.activity.dollReceive, data, oncomplete, onfailed)
end

function req.heartbeat(isAdult, oncomplete, onfailed)
    local data = {
        isAdult = isAdult,
        channel = cache.getChannel(),
        cuid = cache.getCuid(),
    }
    return req.post(url.heartbeat, data, oncomplete, onfailed, true)
end

function req.marblesReceiveTask(periodId, taskId, oncomplete, onfailed)
    local data = {
        periodId = periodId,
        taskId = taskId,
    }
    return req.post(url.marbles.receiveTask, data, oncomplete, onfailed)
end

function req.marblesReceiveCount(periodId, subID, oncomplete, onfailed)
    local data = {
        periodId = periodId,
        subID = subID,
    }
    return req.post(url.marbles.receiveCount, data, oncomplete, onfailed)
end

function req.marblesBuyBall(periodId, count, oncomplete, onfailed)
    local data = {
        periodId  = periodId,
        num  = count,
    }
    return req.post(url.marbles.buyBall, data, oncomplete, onfailed)
end

function req.marblesExchange(periodId, rewardID, oncomplete, onfailed)
    local data = {
        periodId  = periodId,
        rewardID  = rewardID,
    }
    return req.post(url.marbles.exchange, data, oncomplete, onfailed)
end

function req.marblesShootBall(periodId, rewardList, oncomplete, onfailed)
    local data = {
        periodId  = periodId,
        rewardList  = rewardList,
    }
    return req.post(url.marbles.shootBall, data, oncomplete, onfailed)
end

function req.marblesSetShootInfo(periodId, shootCount, oncomplete, onfailed)
    local data = {
        periodId  = periodId,
        shootCount  = shootCount,
    }
    return req.post(url.marbles.setShootInfo, data, oncomplete, onfailed)
end

function req.marblesGetTaskInfo(periodId, oncomplete, onfailed)
    local data = {
        periodId  = periodId,
    }
    return req.post(url.marbles.getTaskInfo, data, oncomplete, onfailed)
end

function req.marblesGetCountInfo(periodId, oncomplete, onfailed)
    local data = {
        periodId  = periodId,
    }
    return req.post(url.marbles.getCountInfo, data, oncomplete, onfailed)
end

function req.marblesGetExchangeInfo(periodId, oncomplete, onfailed)
    local data = {
        periodId  = periodId,
    }
    return req.post(url.marbles.getExchangeInfo, data, oncomplete, onfailed)
end

function req.freeShoppingCartReceiveFree(periodId, oncomplete, onfailed)
    local data = {
        periodId  = periodId,
    }
    return req.post(url.freeShoppingCart.receiveFree, data, oncomplete, onfailed)
end

function req.freeShoppingCartChoose(periodId, rewardId, oncomplete, onfailed)
    local data = {
        periodId  = periodId,
        rewardId  = rewardId,
    }
    return req.post(url.freeShoppingCart.choose, data, oncomplete, onfailed)
end

function req.freeShoppingCartReceive(periodId, oncomplete, onfailed)
    local data = {
        periodId  = periodId,
    }
    return req.post(url.freeShoppingCart.receive, data, oncomplete, onfailed)
end

function req.multiGetGiftReceiveTask(periodId, taskId, oncomplete, onfailed)
    local data = {
        periodId  = periodId,
        taskId  = taskId,
    }
    return req.post(url.multiGetGift.receiveTask, data, oncomplete, onfailed)
end

function req.multiGetGiftReceiveGift(periodId, giftId, oncomplete, onfailed)
    local data = {
        periodId  = periodId,
        giftId  = giftId,
    }
    return req.post(url.multiGetGift.receiveGift, data, oncomplete, onfailed)
end

function req.multiGetGiftReceiveAllGift(periodId, oncomplete, onfailed)
    local data = {
        periodId  = periodId,
    }
    return req.post(url.multiGetGift.receiveAllGift, data, oncomplete, onfailed)
end

function req.multiGetGiftBuyItem(periodId, itemId, num, oncomplete, onfailed)
    local data = {
        periodId  = periodId,
        itemId  = itemId,
        num  = num,
    }
    return req.post(url.multiGetGift.buyItem, data, oncomplete, onfailed)
end

function req.fancyCardGachaInfo(oncomplete, onfailed)
    return req.post(url.fancyCard.gachaInfo, nil, oncomplete, onfailed)
end

function req.fancyCardGachaOne(gachaId, oncomplete, onfailed)
    local data = {
        gachaId  = gachaId,
    }
    return req.post(url.fancyCard.gachaOne, data, oncomplete, onfailed)
end

function req.fancyCardGachaTen(gachaId, oncomplete, onfailed)
    local data = {
        gachaId  = gachaId,
    }
    return req.post(url.fancyCard.gachaTen, data, oncomplete, onfailed)
end

function req.fancyCardStarUp(groupId, cardId, oncomplete, onfailed)
    local data = {
        groupId  = groupId,
        cardId = cardId
    }
    return req.post(url.fancyCard.cardStarUp, data, oncomplete, onfailed)
end

function req.fancyCardMallInfo( oncomplete, onfailed)
    return req.post(url.fancyCard.mallInfo, nil, oncomplete, onfailed)
end

function req.fancyCardMallBuy(periodId, subId, num, oncomplete, onfailed)
    local data = {
        periodId  = periodId,
        subId = subId,
        num = num
    }
    return req.post(url.fancyCard.mallBuy, data, oncomplete, onfailed)
end

function req.fancyCardDecomposition(cardIdList, oncomplete, onfailed)
    local data = {
        cardIdList  = cardIdList
    }
    return req.post(url.fancyCard.decomposition, data, oncomplete, onfailed)
end

function req.fancyCardView(gachaId, oncomplete, onfailed)
    local data = {
        id = gachaId
    }
    return req.post(url.fancyCard.view, data, oncomplete, onfailed)
end

function req.fancyCardGachaPool(groupId, oncomplete, onfailed)
    local data = {
        groupId = groupId
    }
    return req.post(url.fancyCard.gachaPool, data, oncomplete, onfailed)
end

function req.albumEdit(cid, tag, switch, oncomplete, onfailed)
    local data = {
        cid  = cid,
        tag  = tag,
        switch  = switch,
    }
    return req.post(url.album.edit, data, oncomplete, onfailed)
end

function req.cardTrainingInfoList(pcids, oncomplete, onfailed)
    local data = {
        pcids  = pcids,
    }
    return req.post(url.card.training.infoList, data, oncomplete, onfailed)
end

function req.cardUnlockTrainingBase(pcid, trainId, subId, pcids, oncomplete, onfailed)
    local data = {
        pcid  = pcid,
        trainId  = trainId,
        subId  = subId,
        pcids  = pcids,
    }
    return req.post(url.card.unlockTrainingBase, data, oncomplete, onfailed)
end

function req.cardSupporterProgress(pcid, stType, slrType, oncomplete, onfailed)
    local data = {
        pcid  = pcid,
        stType = stType,
        slrType = slrType,
    }
    return req.post(url.card.supporterProgress, data, oncomplete, onfailed)
end
