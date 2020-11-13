local EventSystem = require("EventSystem")
local DreamHallModel = require("ui.models.dreamLeague.dreamHall.DreamHallModel")
local DreamPlayerChooseModel = require("ui.models.dreamLeague.dreamHall.DreamPlayerChooseModel")
local DreamTeamHistoryModel = require("ui.models.dreamLeague.dreamTeamHistory.DreamTeamHistoryModel")
local DreamHallHistoryModel = require("ui.models.dreamLeague.dreamHall.DreamHallHistoryModel")
local DialogManager = require("ui.control.manager.DialogManager")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local DreamHallCtrl = class(BaseCtrl)

DreamHallCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/DreamLeague/DreamHall/DreamHall.prefab"

function DreamHallCtrl:Refresh()
    DreamHallCtrl.super.Refresh(self)
    self.view.onForamtionClick = function() self:ClickForamtion() end
    self.view.onMyLeagueClick = function() self:ClickMyLeague() end
    self.view.onYesterdayDetailClick = function(data) self:ClickYesterdayDetail(data) end
    clr.coroutine(function()
        local response = req.dreamLeagueMatchInfo()
        if api.success(response) then
            local data = response.val
            self.dreamHallModel = DreamHallModel.new()
            self.dreamHallModel:InitWithProtocol(data)
            self.view:InitView(self.dreamHallModel)
        end
    end)
end

function DreamHallCtrl:ClickForamtion()
    if not self.dreamHallModel:IsCanSetFormation() then
        DialogManager.ShowToastByLang("dream_league_ending")
        return
    end
    local allLightDcids, allNations = self.dreamHallModel:GetAllLightDcids()
    local teamData = self.dreamHallModel:GetTeamData()
    local dreamPlayerChooseModel = DreamPlayerChooseModel.new(teamData, allLightDcids, allNations)
    res.PushDialog("ui.controllers.dreamLeague.dreamHall.DreamPlayerChooseCtrl", dreamPlayerChooseModel)
end

function DreamHallCtrl:ClickYesterdayDetail(data)
    clr.coroutine(function()
        local matchId = data.matchId
        local response = req.dreamLeagueMatchTeam(matchId)
        if api.success(response) then
            local data = response.val
            local dreamHallHistoryModel = DreamHallHistoryModel.new()
            local matchScore = self.dreamHallModel:GetYesterdayMatchScore(matchId)
            dreamHallHistoryModel:InitWithProtocol(data, matchScore)
            res.PushDialog("ui.controllers.dreamLeague.dreamHall.DreamHallHistoryCtrl", dreamHallHistoryModel)
        end
    end)
end

function DreamHallCtrl:ClickMyLeague()
    clr.coroutine(function()
        local response = req.dreamLeagueMatchHistory()
        if api.success(response) then
            local data = response.val
            local dreamTeamHistoryModel = DreamTeamHistoryModel.new()
            dreamTeamHistoryModel:InitWithProtocol(data)
            res.PushDialog("ui.controllers.dreamLeague.dreamTeamHistory.DreamTeamHistoryCtrl", dreamTeamHistoryModel)
        end
    end)
end

function DreamHallCtrl:OnEnterScene()
    EventSystem.AddEvent("DreamHallCtrl_Refresh", self, self.Refresh)
end

function DreamHallCtrl:OnExitScene()
    EventSystem.RemoveEvent("DreamHallCtrl_Refresh", self, self.Refresh)
end


function DreamHallCtrl:GetStatusData()
    return self.teamPageModel
end

return DreamHallCtrl
