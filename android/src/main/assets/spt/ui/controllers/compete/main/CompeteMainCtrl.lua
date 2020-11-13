local CompeteMainModel = require("ui.models.compete.main.CompeteMainModel")
local PlayerDetailCtrl = require("ui.controllers.playerDetail.PlayerDetailCtrl")
local CompeteInfoBarCtrl = require("ui.controllers.common.CompeteInfoBarCtrl")
local MatchLoader = require("coregame.MatchLoader")
local CompeteFormationTeamModel = require("ui.models.compete.main.CompeteFormationTeamModel")
local CompeteRewardModel = require("ui.models.compete.reward.CompeteRewardModel")
local CompeteArenaRankModel = require("ui.models.compete.arenaRank.CompeteArenaRankModel")
local CompeteCrossInfoModel = require("ui.models.compete.crossInfo.CompeteCrossInfoModel")
local DialogManager = require("ui.control.manager.DialogManager")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local MatchInfoModel = require("ui.models.MatchInfoModel")
local FormationConstants = require("ui.scene.formation.FormationConstants")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local CompeteMainCtrl = class(BaseCtrl, "CompeteMainCtrl")
local ReqEventModel = require("ui.models.event.ReqEventModel")

CompeteMainCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Compete/Main/Prefab/CompeteMain.prefab"

function CompeteMainCtrl:AheadRequest()
    if self.view then 
        self.view:ShowDisplayArea(false)
    end
    local response = req.worldTournamentMatchList()
    if api.success(response) then
        local data = response.val
        self.competeMainModel = CompeteMainModel.new()
        self.competeMainModel:InitWithProtocol(data)
        self.view:ShowDisplayArea(true)
    end 
end

function CompeteMainCtrl:Init()
    self.view:RegOnDynamicLoad(function (child)
        self.infoBarCtrl = CompeteInfoBarCtrl.new(child, self)
    end)

    self.view.clickFormation = function() self:OnClickFormation() end
    self.view.clickStore = function() self:OnClickStore() end
    self.view.clickReward = function() self:OnClickReward() end
    self.view.clickArenaMatch = function() self:OnClickArenaMatch() end
    self.view.clickCrossCup1 = function() self:OnClickCrossCup1() end
    self.view.clickCrossCup2 = function() self:OnClickCrossCup2() end
    self.view.clickCrossInfo = function() self:OnClickCrossInfo() end
    self.view.clickIntroduce = function() self:OnClickIntroduce() end
    self.view.clickGuess = function() self:OnClickGuess() end
    self.view.clickChampionWall = function() self:OnClickChampionWall() end
    self.view.clickStartMatch = function(competeModel) self:OnClickStartMatch(competeModel) end
    self.view.clickCheckFormation = function(competeModel) self:OnClickCheckFormation(competeModel) end
    self.view.displayMailRedPoint = function() self:DisplayMailRedPoint() end
    self.view.displayGuessRedPoint = function() self:DisplayGuessRedPoint() end
    self.view.displayGuessRewardRedPoint = function() self:DisplayGuessRewardRedPoint() end
    self.view.onSeasonRankListClose = function() self:OnSeasonRankListClose() end
    self.defaultCrossInfoMatchType = "1"
    self.defaultArenaRankMatchType = "7"
end

function CompeteMainCtrl:Refresh()
    CompeteMainCtrl.super.Refresh(self)
    if self.competeMainModel then 
        self.view:InitView(self.competeMainModel)
        self:ShowSortBorder()
    end
end

function CompeteMainCtrl:OnEnterScene()
    self.view:OnEnterScene()
end

function CompeteMainCtrl:OnExitScene()
    self.view:OnExitScene()
end

function CompeteMainCtrl:OnClickFormation()
    self.view:coroutine(function()
        local respone = req.worldTournamentGetTeam()
        if api.success(respone) then
            local data = respone.val
            local competeFormationTeamModel = CompeteFormationTeamModel.new("worldTournament")
            competeFormationTeamModel:InitWithProtocol(data)
            competeFormationTeamModel:SetCompeteSpecialTeamData(data.special)
            competeFormationTeamModel:SetTeamType(FormationConstants.TeamType.COMPETE)
            res.PushScene("ui.controllers.compete.main.CompeteFormationTeamCtrl", competeFormationTeamModel)
        end
    end)
end

function CompeteMainCtrl:OnClickStore()
    res.PushScene("ui.controllers.compete.store.CompeteStoreCtrl")
end

function CompeteMainCtrl:OnClickReward()
    self.view:coroutine(function()
        local response = req.worldTournamentRewardData() 
        if api.success(response) then
            local data = response.val              
            local competeRewardModel = CompeteRewardModel.new(data)
            competeRewardModel:InitWithProtocol()
            local mailList = competeRewardModel:GetMailList()
            if not mailList or not next(mailList) then
                DialogManager.ShowToast(lang.trans("compete_reward_noMails"))
            else
                res.PushScene("ui.controllers.compete.reward.CompeteRewardCtrl", competeRewardModel)
            end
        end
    end)
end

function CompeteMainCtrl:OnClickArenaMatch()
    self.view:coroutine(function()
        local response = req.worldTournamentRank(nil, self.defaultArenaRankMatchType) 
        if api.success(response) then
            local data = response.val            
            if not data.seasonList or not next(data.seasonList) then
                DialogManager.ShowToast(lang.trans("compete_arenaRank_noInfo"))
            else
                local competeArenaRankModel = CompeteArenaRankModel.new()
                competeArenaRankModel:InitWithProtocol(nil, self.defaultArenaRankMatchType, data)
                res.PushScene("ui.controllers.compete.arenaRank.CompeteArenaRankCtrl", competeArenaRankModel)
            end 
        end
    end)
end

function CompeteMainCtrl:OnClickCrossCup1()
    local currentPageIndex = self.competeMainModel:GetCurrentPageIndex()
    res.PushScene("ui.controllers.compete.cross.CompeteCrossMatchCtrlEx", currentPageIndex)
end

function CompeteMainCtrl:OnClickCrossCup2()
    local currentPageIndex = self.competeMainModel:GetCurrentPageIndex()
    res.PushScene("ui.controllers.compete.cross.CompeteCrossMatchCtrl", currentPageIndex)
end

function CompeteMainCtrl:OnClickCrossInfo()
    self.view:coroutine(function()
        local response = req.worldTournamentCrossInfo(nil, self.defaultCrossInfoMatchType) 
        if api.success(response) then
            local data = response.val
            if not data.seasonList or not next(data.seasonList) then
                DialogManager.ShowToast(lang.trans("compete_crossInfo_noInfo"))
            else
                local competeCrossInfoModel = CompeteCrossInfoModel.new()
                competeCrossInfoModel:InitWithProtocol(nil, self.defaultCrossInfoMatchType, data)
                res.PushScene("ui.controllers.compete.crossInfo.CompeteCrossInfoCtrl", competeCrossInfoModel)
            end
        end
    end)
end

function CompeteMainCtrl:OnClickIntroduce()
    res.PushScene("ui.controllers.compete.introduce.IntroduceCtrl")
end

function CompeteMainCtrl:OnClickGuess()
    res.PushScene("ui.controllers.compete.guess.CompeteGuessCtrl")
end

function CompeteMainCtrl:OnClickChampionWall()
    res.PushScene("ui.controllers.compete.championWall.CompeteChampionWallCtrl")
end

function CompeteMainCtrl:DisplayMailRedPoint()
    local hasNewMail = ReqEventModel.GetInfo("worldTournamentEmail")
    GameObjectHelper.FastSetActive(self.view.hasMailRedPoint, tonumber(hasNewMail) > 0)
end

function CompeteMainCtrl:DisplayGuessRedPoint()
    local guess = ReqEventModel.GetInfo("worldTournamentGuess") or 0
    self.view:SetGuessRedPoint(tonumber(guess) > 0)
end

function CompeteMainCtrl:DisplayGuessRewardRedPoint()
    local guess_reward = ReqEventModel.GetInfo("worldTournamentGuessBonus") or 0
    self.view:SetGuessRedPoint(tonumber(guess_reward) > 0)
end

function CompeteMainCtrl:OnClickStartMatch(competeModel)
    local matchType = competeModel:GetMatchType()
    local pid = competeModel:GetPid()
    local sid = competeModel:GetSid()

    self.view:coroutine(function()
        local response = req.competeMatch(pid, matchType, sid)
        if api.success(response) then
            local data = response.val
			MatchInfoModel.GetInstance():ConvertMatchTeamData(data)
            MatchLoader.startMatch(data)
        end
    end)
end

function CompeteMainCtrl:OnClickCheckFormation(competeModel)
    local pid = competeModel:GetPid()
    local sid = competeModel:GetSid()
    PlayerDetailCtrl.ShowPlayerDetailView(function() return req.competeFormationDetail(pid, sid, "worldTournament") end, pid, sid)
end

function CompeteMainCtrl:ShowSortBorder()
    local isShowSortBorder = self.competeMainModel:CheckIsShowSortBorder()
    if isShowSortBorder then
        self.competeMainModel:SetToDayShowState()
        res.PushDialog("ui.controllers.compete.main.SeasonRankListCtrl", self.competeMainModel)
    else
        self:ShowGuessConfirm()
    end
end

-- 赛季排行界面关闭事件函数
function CompeteMainCtrl:OnSeasonRankListClose()
    self:ShowGuessConfirm()
end

-- 争霸赛竞猜确认机制
function CompeteMainCtrl:ShowGuessConfirm()
    local hide = luaevt.trig("__SGP__VERSION__") or luaevt.trig("__KR__VERSION__") or luaevt.trig("__UK__VERSION__")
    if not hide then
        if self.competeMainModel:CheckShowGuessConfirm() then
            res.PushDialog("ui.controllers.compete.guess.CompeteGuessConfirmCtrl", self.competeMainModel:GetGuessData(), self.competeMainModel)
        end
    end
end

return CompeteMainCtrl
