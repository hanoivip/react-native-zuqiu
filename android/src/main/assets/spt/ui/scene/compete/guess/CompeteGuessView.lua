local UnityEngine = clr.UnityEngine
local Time = UnityEngine.Time
local GameObjectHelper = require("ui.common.GameObjectHelper")
local CompeteGuessSchedule = require("ui.models.compete.guess.CompeteGuessSchedule")

local CompeteGuessView = class(unity.base, "CompeteGuessView")

CompeteGuessView.menuTags = {
    match = "match",
    my = "my"
}

function  CompeteGuessView:ctor()
    -- 返回按钮
    self.btnBack = self.___ex.btnBack
    -- 标题
    self.txtTitle = self.___ex.txtTitle
    -- 页签group
    self.tab = self.___ex.tab
    -- 比赛列表面板
    self.objMatchBoard = self.___ex.objMatchBoard
    -- 比赛列表滑动组件
    self.matchScroll = self.___ex.matchScroll
    -- 我的记录面板
    self.objMyBoard = self.___ex.objMyBoard
    -- 我的记录滑动组件
    self.myScroll = self.___ex.myScroll
    -- 玩法说明
    self.btnIntro = self.___ex.btnIntro
    -- 没有比赛
    self.txtMatchNone = self.___ex.txtMatchNone
    -- 没有记录
    self.txtMyNone = self.___ex.txtMyNone
    -- 货币信息
    self.infoBarDynParent = self.___ex.infoBarDynParent
    -- 红点儿
    self.objReminderMatch = self.___ex.objReminderMatch
    self.objReminderMy = self.___ex.objReminderMy


    -- 滑动界面位置信息
    self.matchScrollPos = nil
    self.itemDatas = nil
end

function CompeteGuessView:start()
    self:RegBtnEvent()
    self:ShowDisplayArea(false)
end

function CompeteGuessView:update()
    if self.model then
        local currTime = self.model:GetCountdown()
        if self.model:GetSchedule() == CompeteGuessSchedule.guessing and currTime >=0 then
            local time = currTime - Time.deltaTime
            self.model:SetCountdown(time)
            if time <= 0 then
                if self.onCountZeroUpdate then
                    self.onCountZeroUpdate()
                end
            end
        end
    end
end

function CompeteGuessView:RegBtnEvent()
    self.tab:BindMenuItem(self.menuTags.match, function()
        self:ClearMyScrollPosInfo()
        if self.onClickTabMatch then
            self.onClickTabMatch(self.menuTags.match)
        end
    end)
    self.tab:BindMenuItem(self.menuTags.my, function()
        self:ClearMatchScrollPosInfo()
        if self.onClickTabMy then
            self.onClickTabMy(self.menuTags.my)
        end
    end)

    self.btnIntro:regOnButtonClick(function()
        if self.onClickBtnIntro then
            self.onClickBtnIntro()
        end
    end)
end

function CompeteGuessView:InitView(competeGuessModel)
end

function CompeteGuessView:ShowDisplayArea(isShow)
    GameObjectHelper.FastSetActive(self.objMatchBoard.gameObject, isShow)
    GameObjectHelper.FastSetActive(self.objMyBoard.gameObject, isShow)
end

function CompeteGuessView:InitMatchView(competeGuessModel)
    self.model = competeGuessModel
    GameObjectHelper.FastSetActive(self.objMatchBoard.gameObject, true)
    GameObjectHelper.FastSetActive(self.objMyBoard.gameObject, false)
    if not self.model:HasMatchData() then
        GameObjectHelper.FastSetActive(self.txtMatchNone.gameObject, true)
        GameObjectHelper.FastSetActive(self.matchScroll.gameObject, false)
        return
    end
    GameObjectHelper.FastSetActive(self.txtMatchNone.gameObject, false)
    GameObjectHelper.FastSetActive(self.matchScroll.gameObject, true)
    self.matchScroll:RegOnItemButtonClick("btnReplay", function(itemData) self:OnClickMatchItemReplay(itemData) end)
    self.matchScroll:RegOnItemButtonClick("btnReverseReward", function() self:OnClickMatchItemReverseReward() end)
    self.matchScroll:RegOnItemButtonClick("left_BtnSupport", function(itemData) self:OnClickMatchItemBtnSupport(itemData, true) end)
    self.matchScroll:RegOnItemButtonClick("right_BtnSupport", function(itemData) self:OnClickMatchItemBtnSupport(itemData, false) end)
    self.matchScroll:InitView(self.model:GetMatchList(), self.model)
    if self.matchScrollPos then
        self.matchScroll:SetScrollNormalizedPosition(self.matchScrollPos)
    end
end

function CompeteGuessView:InitMyView(competeGuessModel)
    self.model = competeGuessModel
    GameObjectHelper.FastSetActive(self.objMatchBoard.gameObject, false)
    GameObjectHelper.FastSetActive(self.objMyBoard.gameObject, true)
    local myDatas = self.model:GetMyList()
    if not self.model:HasMyData() or table.nums(myDatas) <= 0 then
        GameObjectHelper.FastSetActive(self.txtMyNone.gameObject, true)
        GameObjectHelper.FastSetActive(self.myScroll.gameObject, false)
        return
    end
    GameObjectHelper.FastSetActive(self.txtMyNone.gameObject, false)
    GameObjectHelper.FastSetActive(self.myScroll.gameObject, true)
    self.myScroll:SetJudgeStage(self.model:GetJudgeStage())
    self.myScroll.onRewardReceive = function(season, round, matchType, combatIndex, idx) self:OnRewardReceive(season, round, matchType, combatIndex, idx) end
    self.myScroll.onClickMyItemReplay = function(matchData) self:OnClickMyItemReplay(matchData) end
    self.myScroll:InitView(myDatas, competeGuessModel)
end

function CompeteGuessView:RegOnDynamicLoad(func)
    self.infoBarDynParent:RegOnDynamicLoad(func)
end

function CompeteGuessView:OnEnterScene()
    EventSystem.AddEvent("ReqEventModel_worldTournamentGuessBonus", self, self.DisplayGuessRewardRedPoint)
end

function CompeteGuessView:OnExitScene()
    EventSystem.RemoveEvent("ReqEventModel_worldTournamentGuessBonus", self, self.DisplayGuessRewardRedPoint)
end

-- 奖励红点
function CompeteGuessView:DisplayGuessRewardRedPoint()
    if self.displayGuessRewardRedPoint then
        self.displayGuessRewardRedPoint()
    end
end

function CompeteGuessView:ShowMatchRedPoint(isShow)
    GameObjectHelper.FastSetActive(self.objReminderMatch.gameObject, isShow)
end

function CompeteGuessView:ShowMyRedPoint(isShow)
    GameObjectHelper.FastSetActive(self.objReminderMy.gameObject, isShow)
end

function CompeteGuessView:SaveMatchScrollPos()
    self.matchScrollPos = self.matchScroll:GetScrollNormalizedPosition()
end

function CompeteGuessView:ClearScrollPosInfo()
    self:ClearMatchScrollPosInfo()
    self:ClearMyScrollPosInfo()
end

function CompeteGuessView:ClearMatchScrollPosInfo()
    self.matchScrollPos = nil
end

function CompeteGuessView:ClearMyScrollPosInfo()
    self.myScrollIndex = nil
end

function CompeteGuessView:OnClickMatchItemReplay(itemData)
    if self.onClickMatchItemReplay then
        self.onClickMatchItemReplay(itemData)
    end
end

function CompeteGuessView:OnClickMatchItemReverseReward()
    if self.onClickReverseReward then
        self.onClickReverseReward()
    end
end

function CompeteGuessView:OnClickMatchItemBtnSupport(itemData, isPlayer1)
    if itemData then
        if itemData.myGuess then
            if self.onClickBtnSupported then
                self.onClickBtnSupported(itemData.myGuess.guessStage)
            end
        else
            if self.onClickBtnSupport then
                if isPlayer1 then
                    self.onClickBtnSupport(itemData.player1, itemData.matchType, itemData.combatIndex)
                else
                    self.onClickBtnSupport(itemData.player2, itemData.matchType, itemData.combatIndex)
                end
            end
        end
    end
end

function CompeteGuessView:OnRewardReceive(season, round, matchType, combatIndex, idx)
    if self.onRewardReceive then
        self.onRewardReceive(season, round, matchType, combatIndex, idx)
    end
end

function CompeteGuessView:OnClickMyItemReplay(matchData)
    if self.onClickMyItemReplay then
        self.onClickMyItemReplay(matchData)
    end
end

function CompeteGuessView:UpdateAfterReceive(idx)
    local myDatas = self.model:GetMyList()
    if not self.model:HasMyData() or table.nums(myDatas) <= 0 then
        GameObjectHelper.FastSetActive(self.txtMyNone.gameObject, true)
        GameObjectHelper.FastSetActive(self.myScroll.gameObject, false)
        return
    end
    GameObjectHelper.FastSetActive(self.txtMyNone.gameObject, false)
    GameObjectHelper.FastSetActive(self.myScroll.gameObject, true)
    self.myScroll:InitView(myDatas, self.model)
    self.myScroll:scrollToCellImmediate(idx)
end

return CompeteGuessView
