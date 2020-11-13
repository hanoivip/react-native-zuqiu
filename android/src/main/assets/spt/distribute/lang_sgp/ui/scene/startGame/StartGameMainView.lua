local UnityEngine = clr.UnityEngine
local EventSystems = UnityEngine.EventSystems

local CommonConstants = require("ui.common.CommonConstants")
local StartGameConstants = require("ui.scene.startGame.StartGameConstants")
local GuideManager = require("ui.controllers.playerGuide.GuideManager")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local ReqEventModel = require("ui.models.event.ReqEventModel")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local PlayerNewFunctionModel = require("ui.models.PlayerNewFunctionModel")
local FancyCardsMapModel = require("ui.models.fancy.FancyCardsMapModel")

local StartGameMainView = class(unity.base)

function StartGameMainView:ctor()
    -- 主线
    self.questBoxView = self.___ex.questBoxView
    -- 联赛
    self.leagueBoxView = self.___ex.leagueBoxView
    -- 训练基地
    self.trainBoxView = self.___ex.trainBoxView
    -- 天梯
    self.ladderBoxView = self.___ex.ladderBoxView
    -- 特殊赛事
    self.specialQuestBoxView = self.___ex.specialQuestBoxView
    -- 巅峰对决
    self.peakBoxView = self.___ex.peakBoxView
    -- 劫镖
    self.transfortBoxView = self.___ex.transfortBoxView
    -- 冠军联赛
    self.arenaBoxView = self.___ex.arenaBoxView
    -- 动画管理器
    self.animator = self.___ex.animator
    -- 屏幕锁
    self.screenLock = self.___ex.screenLock
    -- 主线红点
    self.questBoxRedPoint = self.___ex.questBoxRedPoint
    -- 联赛红点
    self.leagueBoxRedPoint = self.___ex.leagueBoxRedPoint
    -- 天梯红点
    self.ladderBoxRedPoint = self.___ex.ladderBoxRedPoint
    -- 竞技场红点
    self.arenaRedPoint = self.___ex.arenaRedPoint
    -- 巅峰对决红点
    self.peakRedPoint = self.___ex.peakRedPoint
    -- 劫镖红点
    self.transportRedPoint = self.___ex.transportRedPoint
    -- 引导箭头
    self.guideArrow = self.___ex.guideArrow
    -- 训练基地开启红点
    self.trainRedPoint = self.___ex.trainRedPoint
    self.specialQuestRedPoint = self.___ex.specialQuestRedPoint

    -- 梦幻联赛
    self.dreamBoxView = self.___ex.dreamBoxView
    -- 争霸赛
    self.competeBoxView = self.___ex.competeBoxView
    -- 争霸赛邮件or新竞猜场次or竞猜奖励
    self.competeRedPoint = self.___ex.competeRedPoint

    -- 英雄殿堂
    self.heroHallBoxView = self.___ex.heroHallBoxView
    self.heroHallRedPoint = self.___ex.heroHallRedPoint

    -- 竞拍大厅
    self.auctionBoxView = self.___ex.auctionBoxView
    self.auctionRedPoint = self.___ex.auctionRedPoint

    -- 绿茵征途
    self.greenswardBoxView = self.___ex.greenswardBoxView
    self.greenswardRedPoint = self.___ex.greenswardRedPoint

    -- 梦幻11人
    self.fancyBoxView = self.___ex.fancyBoxView
    self.fancyRedPoint = self.___ex.fancyRedPoint
    self.fancyNewTip = self.___ex.fancyNewTip
end

function StartGameMainView:InitView(unlockModel)
    self.questBoxView:InitView(unlockModel, StartGameConstants.ViewConstants.QUEST)
    self.leagueBoxView:InitView(unlockModel, StartGameConstants.ViewConstants.LEAGUE)
    self.trainBoxView:InitView(unlockModel, StartGameConstants.ViewConstants.TRAIN)
    self.ladderBoxView:InitView(unlockModel, StartGameConstants.ViewConstants.LADDER)
    self.specialQuestBoxView:InitView(unlockModel, StartGameConstants.ViewConstants.SPECIAL_QUEST)
    self.peakBoxView:InitView(unlockModel, StartGameConstants.ViewConstants.PEAK)
    self.arenaBoxView:InitView(unlockModel, StartGameConstants.ViewConstants.ARENA)
    self.transfortBoxView:InitView(unlockModel, StartGameConstants.ViewConstants.TRANSFORT)
    self.dreamBoxView:InitView(unlockModel, StartGameConstants.ViewConstants.DREAM)
    self.competeBoxView:InitView(unlockModel, StartGameConstants.ViewConstants.COMPETE)
    self.heroHallBoxView:InitView(unlockModel, StartGameConstants.ViewConstants.HERO_HALL)
    self.auctionBoxView:InitView(unlockModel, StartGameConstants.ViewConstants.AUCTION)
    self.greenswardBoxView:InitView(unlockModel, StartGameConstants.ViewConstants.GREENSWARD)
    self.fancyBoxView:InitView(unlockModel, StartGameConstants.ViewConstants.Fancy)

    -- ios提审屏蔽
    if luaevt.trig("___EVENT__NOT_OPEN_FORBIDDEN") then
        GameObjectHelper.FastSetActive(self.specialQuestBoxView.gameObject, false)
        GameObjectHelper.FastSetActive(self.peakBoxView.gameObject, false)
        GameObjectHelper.FastSetActive(self.arenaBoxView.gameObject, false)
        GameObjectHelper.FastSetActive(self.transfortBoxView.gameObject, false)
        GameObjectHelper.FastSetActive(self.competeBoxView.gameObject, false)
        GameObjectHelper.FastSetActive(self.heroHallBoxView.gameObject, false)
        GameObjectHelper.FastSetActive(self.auctionBoxView.gameObject, false)
        GameObjectHelper.FastSetActive(self.greenswardBoxView.gameObject, false)
    end
end

function StartGameMainView:PlayMoveInAnim()
    if GuideManager.GuideIsOnGoing("main") then
    -- 海外版屏蔽梦幻卡
    --if GuideManager.GuideIsOnGoing("main") or GuideManager.GuideIsOnGoing("fancy") then
        self.currentEventSystem = EventSystems.EventSystem.current
        self.currentEventSystem.enabled = false
        GuideManager.HideLastGuide()
    end
    self.animator:Play("MoveIn", 0)
    GameObjectHelper.FastSetActive(self.screenLock, true)
end

function StartGameMainView:PlayStayAnim()
    self.animator:Play("Stay")
end

function StartGameMainView:OnAnimEnd(animMoveType)
    if animMoveType == CommonConstants.UIAnimMoveType.MOVE_IN then
        self:PlayStayAnim()
        GameObjectHelper.FastSetActive(self.screenLock, false)
        local playerInfoModel = PlayerInfoModel.new()
        -- 是否为新功能开启第一次进入
        self:CheckNewFunctionOpend(PlayerNewFunctionModel.new())
        self:IsShowQuestBoxRedPoint()
        self:IsShowLeagueBoxRedPoint()
        self:IsShowLadderBoxRedPoint()
        self:IsShowArenaRedPoint()
        self:IsShowSpecialQuestRedPoint()
        self:IsShowPeakRedPoint()
        self:IsShowTransportRedPoint()
        self:IsShowCompetePoint()
        self:IsShowGreenswardPoint()
        --海外版屏蔽梦幻卡
        --self:IsShowFancyPoint()
        -- 是否显示引导箭头
        if not GuideManager.GuideIsOnGoing("main") and tonumber(playerInfoModel:GetLevel()) < 10 then
            GameObjectHelper.FastSetActive(self.guideArrow, true)
        else
            GameObjectHelper.FastSetActive(self.guideArrow, false)
        end
        -- 点击征途按钮进入开始游戏页面
        if GuideManager.GuideIsOnGoing("main") then
        --海外版屏蔽梦幻卡
        --if GuideManager.GuideIsOnGoing("main") or GuideManager.GuideIsOnGoing("fancy") then
            self.currentEventSystem.enabled = true
        end
        GuideManager.Show(self)
    end
end

function StartGameMainView:Close()
    self:PlayLeaveAnimation()
    -- 这步先删除了
    -- GuideManager.Show(res.curSceneInfo.ctrl)
end

function StartGameMainView:CloseImmediate()
    if type(self.closeDialog) == "function" then
        self.closeDialog()
    end
end

function StartGameMainView:IsShowQuestBoxRedPoint()
    local letter = ReqEventModel.GetInfo("letter")
    local boolFlag1 = tonumber(letter) > 0 --来信

    local boolFlag2 = false
    local activity = ReqEventModel.GetInfo("activity")
    if type(activity.CareerRaceSelf) == "table" then
        local flagValue = 1
        local CareerRaceSelf = activity.CareerRaceSelf
        for k, v in pairs(CareerRaceSelf) do
            flagValue = v
        end
        boolFlag2 = tonumber(flagValue) == 0
    end

    GameObjectHelper.FastSetActive(self.questBoxRedPoint, boolFalg1 or boolFlag2)
end

function StartGameMainView:IsShowLeagueBoxRedPoint()
    local leagueLimit = ReqEventModel.GetInfo("leagueLimit")
    GameObjectHelper.FastSetActive(self.leagueBoxRedPoint, tonumber(leagueLimit) > 0)
end

function StartGameMainView:IsShowLadderBoxRedPoint()
    local ladderRecord = ReqEventModel.GetInfo("ladderRecord")
    GameObjectHelper.FastSetActive(self.ladderBoxRedPoint, tonumber(ladderRecord) > 0)
end

function StartGameMainView:IsShowArenaRedPoint()
    local arenaZone = ReqEventModel.GetInfo("arenaZone")
    local arenaHonor = ReqEventModel.GetInfo("arenaHonor")
    local arenaZoneAdvance = ReqEventModel.GetInfo("arenaZoneAdvance")
    local isShowRedPoint = false
    if tonumber(arenaZone) > 0 or tonumber(arenaHonor) > 0 or tonumber(arenaZoneAdvance) > 0 then
        isShowRedPoint = true
    end
    GameObjectHelper.FastSetActive(self.arenaRedPoint, isShowRedPoint)
end

function StartGameMainView:IsShowSpecialQuestRedPoint()
    local specific = ReqEventModel.GetInfo("specific")
    GameObjectHelper.FastSetActive(self.specialQuestRedPoint, tonumber(specific) > 0)
end

function StartGameMainView:IsShowPeakRedPoint()
    local peak = ReqEventModel.GetInfo("peak")
    GameObjectHelper.FastSetActive(self.peakRedPoint, tonumber(peak) > 0)
end

function StartGameMainView:IsShowTransportRedPoint()
    local transport = ReqEventModel.GetInfo("transport")
    local transportApply = ReqEventModel.GetInfo("transportApply")
    local transportLog = ReqEventModel.GetInfo("transportLog")
    GameObjectHelper.FastSetActive(self.transportRedPoint, tonumber(transport) > 0 or tonumber(transportApply) > 0 or tonumber(transportLog) > 0)
end

function StartGameMainView:IsShowCompetePoint()
    local email = ReqEventModel.GetInfo("worldTournamentEmail") or 0
    local guess = ReqEventModel.GetInfo("worldTournamentGuess") or 0 -- 有新竞猜
    local guess_reward = ReqEventModel.GetInfo("worldTournamentGuessBonus") or 0 -- 有竞猜奖励
    local isShow = tonumber(email) > 0 or tonumber(guess) > 0 or tonumber(guess_reward) > 0
    GameObjectHelper.FastSetActive(self.competeRedPoint, isShow)
end

function StartGameMainView:IsShowGreenswardPoint()
    local advReward = ReqEventModel.GetInfo("advReward") or 0 -- 有可领取的奖励
    local advDaily = ReqEventModel.GetInfo("advDaily") or 0 -- 有可领取的士气
    local advFriend = ReqEventModel.GetInfo("advFriend") or 0 -- 有可领取的赠送士气
    local isShow = tonumber(advReward) > 0 or tonumber(advDaily) > 0 or tonumber(advFriend) > 0
    GameObjectHelper.FastSetActive(self.greenswardRedPoint, isShow)
end

function StartGameMainView:IsShowFancyPoint()
    local isShow = table.nums(ReqEventModel.GetInfo("fancyGacha") or {}) > 0 -- 有可领取的奖励
    GameObjectHelper.FastSetActive(self.fancyRedPoint, isShow)
    GameObjectHelper.FastSetActive(self.fancyNewTip, not isShow and FancyCardsMapModel.new():IsHaveNewCard())
end

function StartGameMainView:EnterScene()
    EventSystem.AddEvent("ReqEventModel_letter", self, self.IsShowQuestBoxRedPoint)
    EventSystem.AddEvent("ReqEventModel_leagueLimit", self, self.IsShowLeagueBoxRedPoint)
    EventSystem.AddEvent("ReqEventModel_ladderRecord", self, self.IsShowLadderBoxRedPoint)
    EventSystem.AddEvent("ReqEventModel_arenaHonor", self, self.IsShowArenaRedPoint)
    EventSystem.AddEvent("ReqEventModel_arenaZone", self, self.IsShowArenaRedPoint)
    EventSystem.AddEvent("ReqEventModel_arenaZoneAdvance", self, self.IsShowArenaRedPoint)
    EventSystem.AddEvent("ReqEventModel_specific", self, self.IsShowSpecialQuestRedPoint)
    EventSystem.AddEvent("UpdateNewFunctionState", self, self.UpdateNewFunctionState)
    EventSystem.AddEvent("ReqEventModel_peak", self, self.IsShowPeakRedPoint)
    EventSystem.AddEvent("ReqEventModel_transport", self, self.IsShowTransportRedPoint)
    EventSystem.AddEvent("ReqEventModel_transportApply", self, self.IsShowTransportRedPoint)
    EventSystem.AddEvent("ReqEventModel_transportLog", self, self.IsShowTransportRedPoint)
end

function StartGameMainView:ExitScene()
    EventSystem.RemoveEvent("ReqEventModel_letter", self, self.IsShowQuestBoxRedPoint)
    EventSystem.RemoveEvent("ReqEventModel_leagueLimit", self, self.IsShowLeagueBoxRedPoint)
    EventSystem.RemoveEvent("ReqEventModel_ladderRecord", self, self.IsShowLadderBoxRedPoint)
    EventSystem.RemoveEvent("ReqEventModel_arenaHonor", self, self.IsShowArenaRedPoint)
    EventSystem.RemoveEvent("ReqEventModel_arenaZone", self, self.IsShowArenaRedPoint)
    EventSystem.RemoveEvent("ReqEventModel_arenaZoneAdvance", self, self.IsShowArenaRedPoint)
    EventSystem.RemoveEvent("ReqEventModel_specific", self, self.IsShowSpecialQuestRedPoint)
    EventSystem.RemoveEvent("UpdateNewFunctionState", self, self.UpdateNewFunctionState)
    EventSystem.RemoveEvent("ReqEventModel_peak", self, self.IsShowPeakRedPoint)
    EventSystem.RemoveEvent("ReqEventModel_transport", self, self.IsShowTransportRedPoint)
    EventSystem.RemoveEvent("ReqEventModel_transportApply", self, self.IsShowTransportRedPoint)
    EventSystem.RemoveEvent("ReqEventModel_transportLog", self, self.IsShowTransportRedPoint)
end

function StartGameMainView:CheckNewFunctionOpend(playerNewFunctionModel)
    if playerNewFunctionModel:IsOpend() then
        if playerNewFunctionModel:CheckFirstEnterScene("league") then
            GameObjectHelper.FastSetActive(self.leagueBoxRedPoint, true)
        else
            GameObjectHelper.FastSetActive(self.leagueBoxRedPoint, false)
        end
        if playerNewFunctionModel:CheckFirstEnterScene("ladder") then
            GameObjectHelper.FastSetActive(self.ladderBoxRedPoint, true)
        else
            GameObjectHelper.FastSetActive(self.ladderBoxRedPoint, false)
        end
        if playerNewFunctionModel:CheckFirstEnterScene("arena") then
            GameObjectHelper.FastSetActive(self.arenaRedPoint, true)
        else
            GameObjectHelper.FastSetActive(self.arenaRedPoint, false)
        end
        if playerNewFunctionModel:CheckFirstEnterScene("littleGame") then
            GameObjectHelper.FastSetActive(self.trainRedPoint, true)
        else
            GameObjectHelper.FastSetActive(self.trainRedPoint, false)
        end
        if playerNewFunctionModel:CheckFirstEnterScene("peak") then
            GameObjectHelper.FastSetActive(self.peakRedPoint, true)
        else
            GameObjectHelper.FastSetActive(self.peakRedPoint, false)
        end
        if playerNewFunctionModel:CheckFirstEnterScene("specific") then
            GameObjectHelper.FastSetActive(self.specialQuestRedPoint, true)
        else
            GameObjectHelper.FastSetActive(self.specialQuestRedPoint, false)
        end
        if playerNewFunctionModel:CheckFirstEnterScene("transport") then
            GameObjectHelper.FastSetActive(self.transportRedPoint, true)
        else
            GameObjectHelper.FastSetActive(self.transportRedPoint, false)
        end
    else
        GameObjectHelper.FastSetActive(self.leagueBoxRedPoint, false)
        GameObjectHelper.FastSetActive(self.ladderBoxRedPoint, false)
        GameObjectHelper.FastSetActive(self.arenaRedPoint, false)
        GameObjectHelper.FastSetActive(self.trainRedPoint, false)
        GameObjectHelper.FastSetActive(self.peakRedPoint, false)
        GameObjectHelper.FastSetActive(self.specialQuestRedPoint, false)
        GameObjectHelper.FastSetActive(self.transportRedPoint, false)
    end
end

function StartGameMainView:UpdateNewFunctionState(name, isShow)
    if name == "littleGame" then
        GameObjectHelper.FastSetActive(self.trainRedPoint, isShow)
    elseif name == "arena" then
        GameObjectHelper.FastSetActive(self.arenaRedPoint, isShow)
    elseif name == "ladder" then
        GameObjectHelper.FastSetActive(self.ladderBoxRedPoint, isShow)
    elseif name == "league" then
        GameObjectHelper.FastSetActive(self.leagueBoxRedPoint, isShow)
    elseif name == "peak" then
        GameObjectHelper.FastSetActive(self.peakRedPoint, isShow)
    elseif name == "specific" then
        GameObjectHelper.FastSetActive(self.specialQuestRedPoint, isShow)
    elseif name == "transport" then
        GameObjectHelper.FastSetActive(self.transportRedPoint, isShow)
    end
end

function StartGameMainView:OnLeave()
    self:CloseImmediate()
end

function StartGameMainView:PlayLeaveAnimation()
    GameObjectHelper.FastSetActive(self.questBoxRedPoint, false)
    GameObjectHelper.FastSetActive(self.leagueBoxRedPoint, false)
    GameObjectHelper.FastSetActive(self.peakRedPoint, false)
    GameObjectHelper.FastSetActive(self.arenaRedPoint, false)
    GameObjectHelper.FastSetActive(self.specialQuestRedPoint, false)
    GameObjectHelper.FastSetActive(self.trainRedPoint, false)
    GameObjectHelper.FastSetActive(self.ladderBoxRedPoint, false)
    GameObjectHelper.FastSetActive(self.transportRedPoint, false)
    self.animator:Play("MoveOut", 0)
end

return StartGameMainView