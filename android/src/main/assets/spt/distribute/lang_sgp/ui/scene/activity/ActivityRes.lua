local ActivitySort = require("data.ActivitySort")
local ActivityRes = class()

-- CtrlPath 为指定活动Ctrl 一般继承自ActivityContentBaseCtrl, 不填则默认为ActivityContentBaseCtrl
-- ModelPath 为指定活动Model 一般继承自ActivityModel, 不填则默认为ActivityModel
local ActivityResPath = 
{
    Sign = 
    {
        [1] = { 
            Name = "sign_2", 
            PrefabPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/Calendar/CalendarBoard.prefab",
            CtrlPath = "ui.controllers.activity.content.SignCtrl", 
            ModelPath = "ui.models.activity.SignModel"
        }
    },
    FirstPay = 
    {
        [1] = { 
            Name = "first_pay", 
            PrefabPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/Calendar/FirstPayBoard.prefab",
            CtrlPath = "ui.controllers.activity.content.FirstPayCtrl",
            ModelPath = "ui.models.activity.FirstPayModel"
        }
    },

    CumulativeConsumeSelf = 
    {
        [1] = {
            Name = "cumulative_consume",
            PrefabPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/Calendar/CumulativeConsumeBoard.prefab",
            CtrlPath = "ui.controllers.activity.content.CumulativeConsumeCtrl",
            ModelPath = "ui.models.activity.CumulativeConsumeModel"
        }
    },

    CumulativePay = 
    {
        [1] = {
            Name = "cumulative_pay",
            PrefabPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/Calendar/CumulativePayBoard.prefab",
            CtrlPath = "ui.controllers.activity.content.CumulativePayCtrl",
            ModelPath = "ui.models.activity.CumulativePayModel"
        }
    },

    SerialPay = 
    {
        [1] = {
            Name = "serial_pay",
            PrefabPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/Calendar/SerialPayBoard.prefab",
            CtrlPath = "ui.controllers.activity.content.SerialPayCtrl",
            ModelPath = "ui.models.activity.SerialPayModel"
        }
    },

    CumulativeLoginSelf = 
    {
        [1] = { 
            Name = "server_welfare", 
            PrefabPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/Calendar/CumulativeLoginBoard.prefab",
            CtrlPath = "ui.controllers.activity.content.CumulativeLoginCtrl",
            ModelPath = "ui.models.activity.CumulativeLoginModel"
        }
    },
    PowerTarget = 
    {
        [1] = {
            Name = "power_target",
            PrefabPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/Calendar/PowerTargetBoard.prefab",
            CtrlPath = "ui.controllers.activity.content.PowerTargetCtrl",
            ModelPath = "ui.models.activity.PowerTargetModel"
        }
    },
    GrowthPlanLevel =
    {
        [1] = {
            Name = "growth_plan",
            PrefabPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/Calendar/GrowthPlanBoard.prefab",
            CtrlPath = "ui.controllers.activity.content.GrowthPlanCtrl",
            ModelPath = "ui.models.activity.GrowthPlanModel"
        }
    },
    GrowthPlan =
    {
        [1] = {
            Name = "growth_plan_1",
            PrefabPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/GrowthPlan/GrowthPlan.prefab",
            CtrlPath = "ui.controllers.activity.content.growthPlan.GrowthPlanCtrl",
            ModelPath = "ui.models.activity.growthPlan.GrowthPlanModel"
        }
    },
    ServerPay = 
    {
        [1] = {
            Name = "server_pay",
            PrefabPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/Calendar/NationalWelfareBoard.prefab",
            CtrlPath = "ui.controllers.activity.content.NationalWelfareCtrl",
            ModelPath = "ui.models.activity.NationalWelfareModel"
        }
    },
    CBTDiamond = 
    {
        [1] = {
            Name = "cbt_diamond",
            PrefabPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/Calendar/CBTDiamondBoard.prefab",
            CtrlPath = "ui.controllers.activity.content.CBTDiamondCtrl",
            ModelPath = "ui.models.activity.CBTDiamondModel"
        }
    },
    RewardDouble = 
    {
        [1] = {
            Name = "reward_double",
            PrefabPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/Calendar/RewardDoubleBoard.prefab",
            CtrlPath = "ui.controllers.activity.content.RewardDoubleCtrl",
            ModelPath = "ui.models.activity.RewardDoubleModel"
        }
    },

    --每日登陆
    DailyLogin = 
    {
        [1] = { 
            Name = "obt_DailyLogin", 
            PrefabPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/Calendar/OBTDailyLoginBoard.prefab",
            CtrlPath = "ui.controllers.activity.content.OBTDailyLoginCtrl",
            ModelPath = "ui.models.activity.OBTDailyLoginModel"
        }
    },

    -- 累计消耗
    CumulativeConsume = 
    {
        [1] = {
            Name = "obt_CumulativeConsume",
            PrefabPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/Calendar/OBTCumulativeConsumeBoard.prefab",
            CtrlPath = "ui.controllers.activity.content.OBTCumulativeConsumeCtrl",
            ModelPath = "ui.models.activity.OBTCumulativeConsumeModel"
        }
    },

    -- 连续消耗
    SerialConsume = 
    {
        [1] = {
            Name = "obt_SerialConsume",
            PrefabPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/Calendar/OBTSerialConsumeBoard.prefab",
            CtrlPath = "ui.controllers.activity.content.OBTSerialConsumeCtrl",
            ModelPath = "ui.models.activity.OBTSerialConsumeModel"
        }
    },

    -- 累计登录
    CumulativeLogin = 
    {
        [1] = {
            Name = "obt_CumulativeLogin",
            PrefabPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/Calendar/OBTCumulativeLoginBoard.prefab",
            CtrlPath = "ui.controllers.activity.content.OBTCumulativeLoginCtrl",
            ModelPath = "ui.models.activity.OBTCumulativeLoginModel"
        }
    },

    -- 联赛翻倍
    CareerDouble = 
    {
        [1] = {
            Name = "careerDouble",
            PrefabPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/Calendar/CareerDoubleBoard.prefab",
            CtrlPath = "ui.controllers.activity.content.CareerDoubleCtrl",
            ModelPath = "ui.models.activity.CareerDoubleModel"
        }
    },

    -- 新加限时挑战
    TimeLimitChallenge = 
    {
        [1] = {
            Name = "confederations_cup_name",
            PrefabPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/Calendar/ConfederationsCup.prefab",
            CtrlPath = "ui.controllers.activity.content.PowerTargetCtrl",
            ModelPath = "ui.models.activity.PowerTargetModel"
        }
    },
    
    -- 限时脑力训练
    TimeLimitQuiz = 
    {
        [1] = {
            Name = "brainTraining",
            PrefabPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/Calendar/TimeLimitBrainTraingBoard.prefab",
            CtrlPath = "ui.controllers.activity.content.TimeLimitBrainTraingCtrl",
            ModelPath = "ui.models.activity.TimeLimitBrainTraingModel"
        }
    },

    TimeLimitMystery = 
    {
        [1] = {
            Name = "timelimit_mystery",
            PrefabPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/Calendar/TimeLimitMystery.prefab",
            CtrlPath = "ui.controllers.activity.content.TimeLimitBrainTraingCtrl",
            ModelPath = "ui.models.activity.TimeLimitBrainTraingModel"
        }
    },

    -- 技能升级
    SkillReward = 
    {
        [1] = 
        {
            Name = "skill_levelup_activity_title",
            PrefabPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/Skill/SkillLevelupBoard.prefab",
            CtrlPath = "ui.controllers.activity.content.SkillLevelupCtrl",
            ModelPath = "ui.models.activity.SkillLevelupModel"
        }
    },

    LuckWheel = 
    {
        [1] = {
            Name = "luckyWheel",
            PrefabPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/LuckyWheel/LuckyWheel.prefab",
            CtrlPath = "ui.controllers.activity.content.LuckyWheelCtrl",
            ModelPath = "ui.models.activity.LuckyWheelModel"
        }
    },

    TimeLimitSnatch = 
    {
        [1] = {
            Name = "indiana_limited",
            PrefabPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/LuckyWheelEx/LuckyWheelEx.prefab",
            CtrlPath = "ui.controllers.activity.content.LuckyWheelCtrlEx",
            ModelPath = "ui.models.activity.LuckyWheelModelEx"
        }
    },

    -- 普通球员来信
    TimeLimitLetter = 
    {
        [1] = {
            Name = "timelimit_letter",
            PrefabPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/Calendar/TimeLimitLetter.prefab",
            CtrlPath = "ui.controllers.activity.content.TimeLimitLetterCtrl",
            ModelPath = "ui.models.activity.TimeLimitedLetterModel"
        }
    },

    -- 传奇球员来信
    TimeLimitLeagueLetter = 
    {
        [1] = {
            Name = "",
            PrefabPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/Calendar/TimeLimitLeagueLetter.prefab",
            CtrlPath = "ui.controllers.activity.content.TimeLimitLeagueLetterCtrl",
            ModelPath = "ui.models.activity.TimeLimitedLeagueLetterModel"
        }
    },

    Default = 
    {
        [1] = 
        {
            Name = "default_activity",
            PrefabPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/Calendar/DefaultActivity.prefab",
            CtrlPath = "ui.controllers.activity.content.ActivityContentBaseCtrl",
            ModelPath = "ui.models.activity.ActivityModel"
        }
    },

    -- 竞猜
    QuizLottery = 
    {
        [1] = 
        {
            Name = "quiz_lottery_activity",
            PrefabPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/Lottery/LotteryBoard.prefab",
            CtrlPath = "ui.controllers.activity.content.LotteryCtrl",
            ModelPath = "ui.models.activity.LotteryModel"
        }
    },

    -- 出售礼盒
    TimeLimitGiftBag = 
    {
        [1] = {
            Name = "time_limit_giftbag",
            PrefabPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/Calendar/GiftBoxBoard.prefab",
            CtrlPath = "ui.controllers.activity.content.TimeLimitGiftBoxCtrl",
            ModelPath = "ui.models.activity.TimeLimitGiftBoxModel"
        }
    },

    -- 多档位每日充值
    MultiSerialPay = {
        [1] = {
            Name = "serial_pay",
            PrefabPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/MultiSerialPay/MultiSerialPayBoard.prefab",
            CtrlPath = "ui.controllers.activity.multiSerialPay.MultiSerialPayCtrl",
            ModelPath = "ui.models.activity.MultiSerialPayModel"
        }
    },

    -- 限时探索
    TimeLimitVisit = 
    {
        [1] = {
            Name = "time_limit_visit",
            PrefabPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/Explore/TimeLimitExploreBoard.prefab",
            CtrlPath = "ui.controllers.activity.content.TimeLimitExploreCtrl",
            ModelPath = "ui.models.activity.TimeLimitExploreModel"
        }
    },

    -- 拜仁抽奖活动
    LuckyDraw = 
    {
        [1] = {
            Name = "bayern_luckydraw",
            PrefabPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/BayernReward/BayernLuckyDrawActivity.prefab",
            CtrlPath = "ui.controllers.activity.content.BayernLuckyDrawCtrl",
            ModelPath = "ui.models.activity.BayernLuckyDrawModel"
        }
    },

    -- 首充重置
    NewFirstPayReset = 
    {
        [1] = {
            Name =  "firstPay_Reset",
            PrefabPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/FirstPayReset/FirstPayResetBoard.prefab",
            CtrlPath = "ui.controllers.activity.content.ActivityContentBaseCtrl",
            ModelPath = "ui.models.activity.ActivityModel"
        }
    },

    -- 迟来的礼物
    TimeLimitLateGift = 
    {
        [1] = {
            Name = "belatedGift_title",
            PrefabPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/Calendar/BelatedGift.prefab",
            CtrlPath = "ui.controllers.activity.content.BelatedGiftCtrl",
            ModelPath = "ui.models.activity.BelatedGiftModel"
        }
    },

    -- 大作战
    WorldBossActivity = 
    {
        [1] = {
            Name = "",
            PrefabPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/WorldBossActivity/WorldBossActivity.prefab",
            CtrlPath = "ui.controllers.activity.content.worldBossActivity.WorldBossActivityCtrl",
            ModelPath = "ui.models.activity.worldBossActivity.WorldBossActivityModel"
        }
    },
     -- 新春兑换
    ExchangeActivity = 
    {
        [1] = {
            Name = "",
            PrefabPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/WorldBossActivity/NewYearExchangeBroad.prefab",
            CtrlPath = "ui.controllers.activity.content.worldBossActivity.NewYearExchangeCtrl",
            ModelPath = "ui.models.activity.worldBossActivity.NewYearExchangeModel"
        }
    },
    -- 球迷商店
    TimeLimitFanShop = 
    {
        [1] = {
            Name = "fanShop_title",
            PrefabPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/FanShop/FanShopBoard.prefab",
            CtrlPath = "ui.controllers.activity.content.fanShop.FanShopCtrl",
            ModelPath = "ui.models.activity.fanShop.FanShopModel"
        }
    },
    -- 贴纸拆分
    --TimeLimitPasterSplit = 
    TimeLimitPasterRecover =
    {
        [1] = {
            Name = "time_limit_pasterSplit",
            PrefabPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/Calendar/PasterSplit.prefab",
            CtrlPath = "ui.controllers.activity.content.pasterSplit.PasterSplitCtrl",
            ModelPath = "ui.models.activity.PasterSplitModel",
        }
    },
    -- 招募反馈
    --TimeLimitRecruitReward =
    TimeLimitGacha =
    {
        [1] ={
            Name = "time_limit_recruitReward",
            PrefabPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/Calendar/RecruitReward.prefab",
            CtrlPath = "ui.controllers.activity.content.recruitReward.RecruitRewardCtrl",
            ModelPath = "ui.models.activity.RecruitRewardModel",
        }
    },
    --新用户成长计划
    GrowthPlanLogin =
    {
        [1] = {
            Name = "time_limit_growthPlan",
            PrefabPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/Calendar/GrowthPlanLogin.prefab",
            CtrlPath = "ui.controllers.activity.content.growthPlanLogin.GrowthPlanLoginCtrl",
            ModelPath = "ui.models.activity.GrowthPlanLoginModel",
        }
    },
    -- 砸罐子(开宝箱)活动
    TimeLimitPlayerTreasure =
    {
        [1] ={
            Name = "time_limit_playerTreasure",
            PrefabPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/Calendar/PlayerTreasure.prefab",
            CtrlPath = "ui.controllers.activity.content.playerTreasure.PlayerTreasureCtrl",
            ModelPath = "ui.models.activity.playerTreasure.PlayerTreasureModel",
        }
    },
    -- 战力竞赛
    PowerRank =
    {
        [1] = {
            Name = "activity_power_rank",
            PrefabPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/PowerRank/PowerRankBoard.prefab",
            CtrlPath = "ui.controllers.activity.content.powerRank.PowerRankCtrl",
            ModelPath = "ui.models.activity.PowerRankModel",
        }
    },
    -- 公会嘉年华
    TimeLimitGuildCarnival =
    {
        [1] = {
            Name = "time_limit_guild_carnival",
            PrefabPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/Calendar/TimeLimitGuildCarnival/TimeLimitGuildCarnival.prefab",
            CtrlPath = "ui.controllers.activity.content.timeLimitGuildCarnival.TimeLimitGuildCarnivalCtrl",
            ModelPath = "ui.models.activity.timeLimitGuildCarnival.TimeLimitGuildCarnivalModel"
        }
    },
    --吉祥物赠礼
    TimeLimitMascotPresent =
    {
        [1] = {
            Name = "time_limit_mascot",
            PrefabPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/Calendar/MascotPresent.prefab",
            CtrlPath = "ui.controllers.activity.content.MascotPresent.MascotPresentCtrl",
            ModelPath = "ui.models.activity.mascotPresent.MascotPresentModel",
        }
    },
    -- 招商引资(老虎机 转盘)
    TeamInvest =
    {
        [1] = {
            Name = "time_limit_team_invest",
            PrefabPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/TeamInvest/TeamInvestBoard.prefab",
            CtrlPath = "ui.controllers.activity.content.teamInvest.TeamInvestCtrl",
            ModelPath = "ui.models.activity.teamInvest.TeamInvestModel"
        }
    },
    -- 招商引资新手(老虎机 转盘)
    FreshTeamInvest =
    {
        [1] = {
            Name = "fresh_team_invest",
            PrefabPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/TeamInvest/TeamInvestBoard.prefab",
            CtrlPath = "ui.controllers.activity.content.teamInvest.FreshTeamInvestCtrl",
            ModelPath = "ui.models.activity.teamInvest.FreshTeamInvestModel"
        }
    },
    -- 点亮金杯活动
    TimeLimitGoldCup =
    {
        [1] = {
            Name = "lightUp_goldCup",
            PrefabPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/GoldCup/GoldCup.prefab",
            CtrlPath = "ui.controllers.activity.content.goldCup.GoldCupCtrl",
            ModelPath = "ui.models.activity.goldCup.GoldCupModel"
        }
    },
    -- 连锁礼盒活动
    GiftBox =
    {
        [1] = {
            Name = "chain_box",
            PrefabPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/TimeLimitChainBox/TimeLimitChainBoxBoard.prefab",
            CtrlPath = "ui.controllers.activity.content.timeLimitChainBox.TimeLimitChainBoxCtrl",
            ModelPath = "ui.models.activity.timeLimitChainBox.TimeLimitChainBoxModel"
        }
    },
    -- 连锁契约
    ChainGrowthPlan =
    {
        [1] = {
            Name = "chain_growthplan",
            PrefabPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/ChainGrowthPlan/ChainGrowthPlan.prefab",
            CtrlPath = "ui.controllers.activity.content.chainGrowthPlan.ChainGrowthPlanCtrl",
            ModelPath = "ui.models.activity.chainGrowthPlan.ChainGrowthPlanModel"
        }
    },
    -- 绿茵终结者
    TimeLimitPowerShoot =
    {
        [1] = {
            Name = "power_shoot",
            PrefabPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/TimeLimitPowerShoot/TimeLimitPowerShoot.prefab",
            CtrlPath = "ui.controllers.activity.content.timeLimitPowerShoot.TimeLimitPowerShootCtrl",
            ModelPath = "ui.models.activity.timeLimitPowerShoot.TimeLimitPowerShootModel"
        }
    },
    -- 金球助力
    TimeLimitGoldBall =
    {
        [1] = {
            Name = "time_limit_gold_ball",
            PrefabPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/Calendar/TimeLimitGoldBall/TimeLimitGoldBall.prefab",
            CtrlPath = "ui.controllers.activity.content.timeLimitGoldBall.TimeLimitGoldBallCtrl",
            ModelPath = "ui.models.activity.timeLimitGoldBall.TimeLimitGoldBallModel"
        }
    },
    -- 阶梯商店
    TimeLimitStageShop =
    {
        [1] = {
            Name = "stage_shop",
            PrefabPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/TimeLimitStageShop/TimeLimitStageShop.prefab",
            CtrlPath = "ui.controllers.activity.content.timeLimitStageShop.TimeLimitStageShopCtrl",
            ModelPath = "ui.models.activity.timeLimitStageShop.TimeLimitStageShopModel"
        }
    },
    -- 自选娃娃机
    TimeLimitPlayerDoll =
    {
        [1] = {
            Name = "timeLimit_player_doll",
            PrefabPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/PlayerDoll/PlayerDollBoard.prefab",
            CtrlPath = "ui.controllers.activity.content.playerDoll.PlayerDollCtrl",
            ModelPath = "ui.models.activity.playerDoll.PlayerDollModel"
        }
    },
    -- 幸运弹球台
    TimeLimitMarbles =
    {
        [1] = {
            Name = "marbles_title",
            PrefabPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/Marbles/MarblesBoard.prefab",
            CtrlPath = "ui.controllers.activity.content.marbles.MarblesCtrl",
            ModelPath = "ui.models.activity.marbles.MarblesModel"
        }
    },
    -- 周一免单购物车
    TimeLimitFreeShoppingCart =
    {
        [1] = {
            Name = "free_shopping_title",
            PrefabPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/FreeShoppingCart/FreeShoppingCartBoard.prefab",
            CtrlPath = "ui.controllers.activity.content.freeShoppingCart.FreeShoppingCartCtrl",
            ModelPath = "ui.models.activity.freeShoppingCart.FreeShoppingCartModel"
        }
    },
}

function ActivityRes:ctor()
    self.labelIconCache = {}
    self.prefabCache = {}
    self.activityList = {}
    for activityType, v in pairs(ActivityResPath) do
        self.labelIconCache[activityType] = {}
        self.prefabCache[activityType] = {}
        table.insert(self.activityList, activityType)
    end
    table.sort(self.activityList, function(a, b) return ActivitySort[a] and ActivitySort[b] and ActivitySort[a].sortID < ActivitySort[b].sortID end)
end

function ActivityRes:GetLabelName(activityType, activityId)
    local name = nil
    if self:CheckActivityAvailable(activityType) then
        if ActivityResPath[activityType][activityId] == nil then
            name = ActivityResPath[activityType][1].Name
        else
            name = ActivityResPath[activityType][activityId].Name
        end
    else
        name = ActivityResPath["Default"][1].Name
    end
    return lang.transstr(name)
end

function ActivityRes:GetLabelIcon(activityType, activityId)
    if not ActivityResPath[activityType] then return end
    local activityId = tonumber(activityId)
    if not self.labelIconCache[activityType][activityId] then
        local iconRes = ActivityResPath[activityType][activityId].LabelIcon
        self.labelIconCache[activityType][activityId] = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Activties/Image/" .. iconRes .. ".png")
    end
    return self.labelIconCache[activityType][activityId]
end

function ActivityRes:GetActivityContent(activityType, activityId)
    if not ActivityResPath[activityType] then 
        local prefabRes = ActivityResPath["Default"][1].PrefabPath
        return res.LoadRes(prefabRes)
    end

    local activityId = tonumber(activityId)
    if not self.prefabCache[activityType][activityId] then
        local prefabRes = nil
        if ActivityResPath[activityType][activityId] == nil then
            prefabRes = ActivityResPath[activityType][1].PrefabPath
        else
            prefabRes = ActivityResPath[activityType][activityId].PrefabPath
        end
        self.prefabCache[activityType][activityId] = res.LoadRes(prefabRes)
    end
    
    if self.prefabCache[activityType][activityId] == nil then
        return self.prefabCache[activityType][1]
    else
        return self.prefabCache[activityType][activityId]
    end
end

function ActivityRes:GetActivityControllerPath(activityType, activityId)
    if self:CheckActivityAvailable(activityType) then
        if ActivityResPath[activityType][activityId] == nil then
            return ActivityResPath[activityType][1].CtrlPath
        else
            return ActivityResPath[activityType][activityId].CtrlPath
        end
    else
        return ActivityResPath["Default"][1].CtrlPath
    end
end

function ActivityRes:GetActivityModelPath(activityType, activityId)
    if self:CheckActivityAvailable(activityType) then
        if ActivityResPath[activityType][activityId] == nil then
            return ActivityResPath[activityType][1].ModelPath
        else
            return ActivityResPath[activityType][activityId].ModelPath
        end
    else
        return ActivityResPath["Default"][1].ModelPath
    end
end

function ActivityRes:CheckActivityAvailable(activityType)
    if ActivityResPath[activityType] then
        return true
    end
end

function ActivityRes:GetActivityList()
    return self.activityList
end

return ActivityRes
