local ArenaModel = require("ui.models.arena.ArenaModel")
local ArenaNextMatchModel = require("ui.models.arena.schedule.ArenaNextMatchModel")
local ArenaScheduleTeamModel = require("ui.models.arena.schedule.ArenaScheduleTeamModel")
local ArenaPersonScheduleModel = require("ui.models.arena.schedule.ArenaPersonScheduleModel")
local ArenaInfoBarCtrl = require("ui.controllers.common.ArenaInfoBarCtrl")
local CourtBuildModel = require("ui.models.court.CourtBuildModel")
local CourtBuildTechnologyModel = require("ui.models.court.CourtBuildTechnologyModel")
local ArenaPlayerTeamsModel = require("ui.models.arena.formation.ArenaPlayerTeamsModel")
local ScheduleListPageType = require("ui.scene.arena.schedule.ScheduleListPageType")
local MatchScheduleType = require("ui.scene.arena.schedule.MatchScheduleType")
local PlayerDetailCtrl = require("ui.controllers.playerDetail.PlayerDetailCtrl")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local TechnologySettingConfig = require("ui.scene.court.technologyHall.TechnologySettingConfig")
local DialogManager = require("ui.control.manager.DialogManager")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local ArenaScheduleCtrl = class(BaseCtrl, "CourtMainCtrl")

ArenaScheduleCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Arena/Prefab/ArenaSchedule.prefab"

function ArenaScheduleCtrl:Init(arenaType)
    self.view:RegOnDynamicLoad(function (child)
        self.infoBarCtrl = ArenaInfoBarCtrl.new(child, self)
        self.infoBarCtrl:RegOnBtnBack(function()
            self.view:OnClickBackAnimation()
        end)
    end)
    self.view.clickReward = function() self:OnClickReward() end
    self.view.clickSchedule = function() self:OnClickSchedule() end
    self.view.clickMyFormation = function() self:OnClickMyFormation() end
    self.view.clickOtherFormation = function() self:OnClickOtherFormation() end
    self.view.clickCourt = function() self:OnClickCourt() end
    self.view.clickScheduleReward = function(isRecieved) self:OnClickScheduleReward(isRecieved) end
    self.view.clickRule = function() self:OnClickRule() end
    self.view.clickCourtTechnology = function() self:OnClickCourtTechnology() end
    self.view.clickBack = function() self:OnClickBack() end
end

function ArenaScheduleCtrl:OnClickRule()
    res.PushScene("ui.controllers.arena.ArenaRuleCtrl")
end

function ArenaScheduleCtrl:OnClickMyFormation()
    clr.coroutine(function()
        local respone = req.arenaGetTeam(self.arenaType)
        if api.success(respone) then
            local data = respone.val
            local arenaModel = ArenaModel.new()
            local matchArenaType = arenaModel:GetMatchArena(self.arenaType)
            local arenaPlayerTeamsModel = ArenaPlayerTeamsModel.new(self.arenaType, matchArenaType, arenaModel)
            arenaPlayerTeamsModel:InitWithProtocol(data)
            res.PushScene("ui.controllers.arena.formation.ArenaFormationPageCtrl", arenaPlayerTeamsModel)
        end
    end)

end

function ArenaScheduleCtrl:OnEnterScene()
    self.view:EnterScene()
end

function ArenaScheduleCtrl:OnExitScene()
    self.view:ExitScene()
end

local RecieveState = 4
function ArenaScheduleCtrl:OnClickScheduleReward(isRecieved)
    if isRecieved then 
        clr.coroutine(function()
            local respone = req.arenaQuit(self.arenaType)
            if api.success(respone) then
                self:OnClickBack()
            end
        end)
    else
        clr.coroutine(function()
            local respone = req.arenaReceiveReward(self.arenaType)
            if api.success(respone) then
                local data = respone.val
                local arenaModel = ArenaModel.new()
                arenaModel:SetMatchState(self.arenaType, RecieveState)
                if data.silverM then 
                    local silverM = arenaModel:GetSilverMoney()
                    silverM = silverM + data.silverM
                    arenaModel:SetSilverMoney(silverM)
                elseif data.goldenM then 
                    local goldenM = arenaModel:GetGoldMoney()
                    goldenM = goldenM + data.goldenM
                    arenaModel:SetGoldMoney(goldenM)
                elseif data.blackM then 
                    local blackM = arenaModel:GetBlackGoldMoney()
                    blackM = blackM + data.blackM
                    arenaModel:SetBlackGoldMoney(blackM)
                elseif data.platinumM then 
                    local platinumM = arenaModel:GetPlatinaMoney()
                    platinumM = platinumM + data.platinumM
                    arenaModel:SetPlatinaMoney(platinumM)
                elseif data.peakChampionM then
                    local peakChampionM = arenaModel:GetPeakChampionMoney()
                    peakChampionM = peakChampionM + data.peakChampionM
                    arenaModel:SetPeakChampionMoney(peakChampionM)
                end
            end
        end)
    end
end

function ArenaScheduleCtrl:OnClickOtherFormation()
    local otherId = self.arenaNextMatchModel:GetOtherId()
    local teamData = self.arenaNextMatchModel:GetTeamData(otherId)
    local sid = teamData.sid
    local arenaModel = ArenaModel.new()
    PlayerDetailCtrl.ShowPlayerDetailView(function() return req.arenaOtherTeam(otherId, sid, self.arenaType) end, otherId, sid, arenaModel:GetPayerSid() ~= sid, nil, nil, nil, self.arenaType)
end

function ArenaScheduleCtrl:OnClickCourtTechnology()
    local homeId, homeSid = self.arenaNextMatchModel:GetHomeId() 
    local playerInfoModel = PlayerInfoModel.new()
    local playerId = playerInfoModel:GetID()

    local isMyHomeCourt = tobool(playerId == homeId)
    local desc = self.arenaNextMatchModel:GetGroupDesc()
    if desc == MatchScheduleType.Final then
        local courtBuildTechnologyModel = CourtBuildTechnologyModel.new()
        courtBuildTechnologyModel:UseDefaultData(TechnologySettingConfig.SettingType.Arena)
        res.PushDialog("ui.controllers.court.technologyHall.HomeCourtTechnologyCtrl", TechnologySettingConfig.SettingType.Arena, courtBuildTechnologyModel, isMyHomeCourt, true)
    else
        if isMyHomeCourt then 
            local courtBuildModel = CourtBuildModel.new()
            if courtBuildModel.data and type(courtBuildModel.data) == "table" then
                res.PushDialog("ui.controllers.court.technologyHall.HomeCourtTechnologyCtrl", TechnologySettingConfig.SettingType.Arena, courtBuildModel, isMyHomeCourt)
            else
                clr.coroutine(function()
                    local response = req.buildInfo()
                    if api.success(response) then
                        local data = response.val
                        courtBuildModel:InitWithProtocol(data)
                        res.PushDialog("ui.controllers.court.technologyHall.HomeCourtTechnologyCtrl", TechnologySettingConfig.SettingType.Arena, courtBuildModel, isMyHomeCourt)
                    end
                end)
            end
        else
            clr.coroutine(function()
                local response = req.arenaViewMatchTech(homeId, homeSid)
                if api.success(response) then
                    local data = response.val
                    local courtBuildTechnologyModel = CourtBuildTechnologyModel.new()
                    courtBuildTechnologyModel:InitWithProtocol(data)
                    res.PushDialog("ui.controllers.court.technologyHall.HomeCourtTechnologyCtrl", TechnologySettingConfig.SettingType.Arena, courtBuildTechnologyModel, isMyHomeCourt)
                end
            end)
        end
    end
end

function ArenaScheduleCtrl:OnClickCourt()
    local courtBuildModel = CourtBuildModel.new()
    if courtBuildModel.data and type(courtBuildModel.data) == "table" then
        res.PushDialog("ui.controllers.court.technologyHall.CourtDisplayCtrl", courtBuildModel, TechnologySettingConfig.Arena)
    else
        clr.coroutine(function()
            local response = req.buildInfo()
            if api.success(response) then
                local data = response.val
                courtBuildModel:InitWithProtocol(data)
                res.PushDialog("ui.controllers.court.technologyHall.CourtDisplayCtrl", courtBuildModel, TechnologySettingConfig.Arena)
            end
        end)
    end
end

function ArenaScheduleCtrl:OnClickReward()
    local arenaModel = ArenaModel.new()
    if arenaModel:IsMatchValid(self.arenaType) then 
        res.PushScene("ui.controllers.arena.ArenaRewardCtrl", self.arenaType)
    else
        DialogManager.ShowToast(lang.trans("data_not_valid"))
    end
end

function ArenaScheduleCtrl:OnClickBack()
    res.PushScene("ui.controllers.arena.ArenaMainCtrl")
end

function ArenaScheduleCtrl:OnClickSchedule()
    local arenaModel = ArenaModel.new()
    if arenaModel:IsMatchValid(self.arenaType) then 
        local scheduleListPage
        if arenaModel:IsMatchOverNotRecieve(self.arenaType) or arenaModel:IsMatchOverRecieved(self.arenaType) then -- 进来直接被淘汰直接进入奖励界面
            scheduleListPage = ScheduleListPageType.MatchPage
        elseif self.arenaNextMatchModel and self.arenaNextMatchModel:GetGroupDesc() == 'group' then
            scheduleListPage = ScheduleListPageType.MatchPage
        else
            scheduleListPage = ScheduleListPageType.SchedulePage
        end
        res.PushScene("ui.controllers.arena.schedule.ArenaScheduleListCtrl", scheduleListPage, self.arenaType)
    else
        DialogManager.ShowToast(lang.trans("data_not_valid"))
    end
end

-- isInit 在从主界面进去的时候 展示 个人赛果
function ArenaScheduleCtrl:Refresh(arenaType, isInit)
    ArenaScheduleCtrl.super.Refresh(self)
    self.arenaType = arenaType
    self.view:ShowDisplayArea(false)
    local arenaModel = ArenaModel.new()
    local arenaScheduleTeamModel = ArenaScheduleTeamModel.new()
    clr.coroutine(function()
        local response = req.getArenaPlayersBrief(arenaType)
        if api.success(response) then
            local data = response.val
            
            arenaScheduleTeamModel:InitWithProtocol(data)
            self:PostRaceData(arenaModel, isInit)
        end
    end)
end

function ArenaScheduleCtrl:GetStatusData()
    return self.arenaType
end

function ArenaScheduleCtrl:PostRaceData(arenaModel, isInit)
    if arenaModel:IsMatchOverNotRecieve(self.arenaType) or arenaModel:IsMatchOverRecieved(self.arenaType) then
        self.view:InitView(arenaModel, nil, self.arenaType)
    elseif arenaModel:IsMatchOngoing(self.arenaType) then 
        clr.coroutine(function()
            local response = req.arenaRaceInfo(self.arenaType)
            if api.success(response) then
                local data = response.val
                self.arenaNextMatchModel = ArenaNextMatchModel.new()
                self.arenaNextMatchModel:InitWithProtocol(data)
                self.view:InitView(arenaModel, self.arenaNextMatchModel, self.arenaType)

                self:ShowPersonSchedule(isInit)
            end
        end)
    end
end

-- 赛果展示
function ArenaScheduleCtrl:ShowPersonSchedule(isInit)
    if isInit then
        clr.coroutine(function()
            local response = req.playerArenaScheduleBoard(self.arenaType)
            if api.success(response) then
                local data = response.val
                local arenaPersonScheduleModel = ArenaPersonScheduleModel.new()
                arenaPersonScheduleModel:InitWithProtocol(data)
                local hasSchedule = arenaPersonScheduleModel:HasSchedule()
                if hasSchedule then 
                    local arenaScheduleTeamModel = ArenaScheduleTeamModel.GetInstance()
                    res.PushDialog("ui.controllers.arena.schedule.PersonScheduleCtrl", arenaPersonScheduleModel, arenaScheduleTeamModel)
                end
            end
        end)
    end
end

return ArenaScheduleCtrl
