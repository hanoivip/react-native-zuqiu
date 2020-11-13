local CompeteGuessModel = require("ui.models.compete.guess.CompeteGuessModel")
local CompeteInfoBarCtrl = require("ui.controllers.common.CompeteInfoBarCtrl")
local SimpleIntroduceModel = require("ui.models.common.SimpleIntroduceModel")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local ReqEventModel = require("ui.models.event.ReqEventModel")
local BaseCtrl = require("ui.controllers.BaseCtrl")

local CompeteGuessCtrl = class(BaseCtrl, "CompeteGuessCtrl")

CompeteGuessCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Compete/Guess/CompeteGuess.prefab"

function CompeteGuessCtrl:AheadRequest()
    local response = req.competeGuessData()
    if api.success(response) then
        local data = response.val
        if not self.model then
            self.model = CompeteGuessModel.new()
        end
        if type(data) == "table" and next(data) then
            self.model:InitWithProtocol(data)
        end
    end
end

function CompeteGuessCtrl:Init()
    CompeteGuessCtrl.super.Init(self)
    self.view:RegOnDynamicLoad(function(child)
        self.infoBarCtrl = CompeteInfoBarCtrl.new(child, self)
        self.infoBarCtrl:RegOnBtnBack(function()
            self:OnClickBtnBack()
        end)
    end)

    self.view.onClickTabMatch = function(tag) self:OnClickTab(tag, false) end
    self.view.onClickTabMy = function(tag) self:OnClickTab(tag, false) end
    self.view.onClickBtnIntro = function() self:OnClickBtnIntro() end
    -- 竞猜列表
    self.view.onClickMatchItemReplay = function(itemData) self:OnClickBtnReplay(itemData) end
    self.view.onClickReverseReward = function() self:OnClickReverseReward() end
    self.view.onClickBtnSupport = function(playerData, matchType, combatIndex) self:OnClickBtnSupport(playerData, matchType, combatIndex) end
    self.view.onClickBtnSupported = function(guessStage) self:OnClickBtnSupported(guessStage) end
    -- 我的竞猜
    self.view.onRewardReceive = function(season, round, matchType, combatIndex, idx) self:OnRewardReceive(season, round, matchType, combatIndex, idx) end
    self.view.onClickMyItemReplay = function(matchData) self:OnClickBtnReplay(matchData) end
    -- 计时为0更新
    self.view.onCountZeroUpdate = function() self:OnCountZeroUpdate() end
    -- 奖励红点
    self.view.displayGuessRewardRedPoint = function() self:DisplayGuessRewardRedPoint() end
end

function CompeteGuessCtrl:Refresh()
    CompeteGuessCtrl.super.Refresh(self)
    local currTag = self.model:GetCurrTabTag() or self.view.menuTags.match
    self.view.tab:selectMenuItem(currTag)
    self:OnClickTab(currTag, true)
end

function CompeteGuessCtrl:OnEnterScene()
    self.view:OnEnterScene()
end

function CompeteGuessCtrl:OnExitScene()
    self.view:OnExitScene()
end

function CompeteGuessCtrl:OnClickTab(tag, isRefresh)
    if self.model:GetCurrTabTag() == tag and not isRefresh then return end

    self.model:SetCurrTabTag(tag)
    if tag == self.view.menuTags.match then
        self:OnClickTabMatch(tag)
    elseif tag == self.view.menuTags.my then
        self:OnClickTabMy(tag)
    else
        dump("wrong tag!")
    end
end

function CompeteGuessCtrl:OnClickTabMatch(tag)
    self.view:InitMatchView(self.model)
    self:CheckRedPoint()
end

function CompeteGuessCtrl:OnClickTabMy(tag)
    self.view:InitMyView(self.model)
    self:CheckRedPoint()
end

-- 红点判断
function CompeteGuessCtrl:CheckRedPoint()
    self:CheckMyRedPoint()
end

function CompeteGuessCtrl:CheckMatchRedPoint()
    local hasNewMatch = ReqEventModel.GetInfo("worldTournamentGuess") or 0
    self.view:ShowMatchRedPoint(tonumber(hasNewMatch) > 0)
end

function CompeteGuessCtrl:CheckMyRedPoint()
    local hasReward = ReqEventModel.GetInfo("worldTournamentGuessBonus") or 0
    self.view:ShowMyRedPoint(tonumber(hasReward) > 0)
end

-- 点击玩法说明
function CompeteGuessCtrl:OnClickBtnIntro()
    local simpleIntroduceModel = SimpleIntroduceModel.new()
    simpleIntroduceModel:InitModel(2, "CompeteGuess")
    res.PushDialog("ui.controllers.common.SimpleIntroduceCtrl", simpleIntroduceModel)
end

function CompeteGuessCtrl:OnClickBtnBack()
    self.model:SetCurrTabTag(self.view.menuTags.match)
    self.view.tab:selectMenuItem(self.view.menuTags.match)
    self.view:ClearScrollPosInfo()
    res.PopScene()
end

-- 点击回放按钮
function CompeteGuessCtrl:OnClickBtnReplay(matchData)
    res.PushDialog("ui.controllers.compete.guess.CompeteGuessReplayCtrl", matchData)
end

-- 点击翻盘奖励按钮
function CompeteGuessCtrl:OnClickReverseReward()
    res.PushDialog("ui.controllers.compete.guess.CompeteGuessReverseRewardCtrl", self.model:GetReverseReward(), self.model:GetJudgeStage())
end

-- 点击支持按钮
function CompeteGuessCtrl:OnClickBtnSupport(playerData, matchType, combatIndex)
    self.view:SaveMatchScrollPos()
    res.PushScene("ui.controllers.compete.guess.CompeteSupportPageCtrl", playerData, matchType, combatIndex, self.model:GetStageReward())
end

-- 点击已经竞猜过得按钮，显示竞猜奖励
function CompeteGuessCtrl:OnClickBtnSupported(guessStage)
    local rewards = self.model:GetStageReward()
    local reward = rewards[tostring(guessStage)]
    res.PushDialog("ui.controllers.compete.guess.CompeteGuessStageRewardCtrl", reward, false)
end

-- 领取奖励
function CompeteGuessCtrl:OnRewardReceive(season, round, matchType, combatIndex, idx)
    self.view:coroutine(function()
        local response = req.competeGuessReceive(season, round, matchType, combatIndex)
        if api.success(response) then
            local data = response.val
            CongratulationsPageCtrl.new(data.contents)
            self.model:UpdateAfterReceive(data, season, round, matchType, combatIndex)
            self.view:UpdateAfterReceive(idx)
        end
    end)
end

-- 计时为0更新
function CompeteGuessCtrl:OnCountZeroUpdate()
    if self.isUpdateing then return end

    self.isUpdateing = true
    self.view:coroutine(function()
        local response = req.competeGuessData()
        if api.success(response) then
            local data = response.val
            if not self.model then
                self.model = CompeteGuessModel.new()
            end
            if type(data) == "table" and next(data) then
                self.model:InitWithProtocol(data)
            end
            self:Refresh()
            self.isUpdateing = false
        end
    end)
end

-- 奖励红点
function CompeteGuessCtrl:DisplayGuessRewardRedPoint()
    self:CheckMyRedPoint()
end

return CompeteGuessCtrl
