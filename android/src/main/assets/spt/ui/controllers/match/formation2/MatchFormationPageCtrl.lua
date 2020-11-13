local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local MatchFormationPageCtrl = class()

local MatchInfoModel = require("ui.models.MatchInfoModel")
local MatchPlayerTeamsModel = require("ui.models.match.MatchPlayerTeamsModel")
local MatchFormationCacheDataModel = require("ui.models.match.formation2.MatchFormationCacheDataModel")
local CardPowerCtrl = require("ui.controllers.cardDetail.CardPowerCtrl")
local ReqEventModel = require("ui.models.event.ReqEventModel")

function MatchFormationPageCtrl:ctor()
    self.matchPlayerTeamsModel = nil
    self.matchFormationCacheDataModel = nil
    self.formationPageView = nil
    self:Init()
end

function MatchFormationPageCtrl:Init()
    clr.coroutine(function ()
        unity.waitForEndOfFrame()
        self.matchPlayerTeamsModel = MatchPlayerTeamsModel.new()
        local team = ReqEventModel.GetInfo("team")
        if tonumber(team) > 0 then
            clr.coroutine(function()
                local respone = req.teamIndex()
                if api.success(respone) then
                    local data = respone.val
                    if data.teams then
                        MatchInfoModel:SetMatchTeamData(data.teams)
                        self.matchPlayerTeamsModel:SetTeamType(MatchInfoModel.GetInstance():GetMatchType())
                        self.matchPlayerTeamsModel:InitWithProtocol(MatchInfoModel.GetInstance():GetMatchTeamData())
                        self.matchFormationCacheDataModel = MatchFormationCacheDataModel.new(self.matchPlayerTeamsModel)
                        self:ResetCardsLock(data)
                        local pageObj = res.LoadRes("Assets/CapstonesRes/Game/UI/Match/Formation2/MatchFormationPage.prefab")
                        local pageGO = Object.Instantiate(pageObj)
                        self.formationPageView = pageGO:GetComponent(clr.CapsUnityLuaBehav)
                        self:InitView()
                    end
                end
            end)
        else
            self.matchPlayerTeamsModel:SetTeamType(MatchInfoModel.GetInstance():GetMatchType())
            self.matchPlayerTeamsModel:InitWithProtocol(MatchInfoModel.GetInstance():GetMatchTeamData())
            self.matchFormationCacheDataModel = MatchFormationCacheDataModel.new(self.matchPlayerTeamsModel)
            self.matchFormationCacheDataModel.specialEventsMatchId = MatchInfoModel.GetInstance().specialEventsMatchId
            local pageObj = res.LoadRes("Assets/CapstonesRes/Game/UI/Match/Formation2/MatchFormationPage.prefab")
            local pageGO = Object.Instantiate(pageObj)
            self.formationPageView = pageGO:GetComponent(clr.CapsUnityLuaBehav)
            self:InitView()
        end
    end)
end

function MatchFormationPageCtrl:ResetCardsLock(data)
    local locks = data.lock
    local playerCardsMapModel = require("ui.models.PlayerCardsMapModel").new()
    for pcid, lock in pairs(locks) do
        playerCardsMapModel:ResetCardLock(pcid, lock)
    end
end

function MatchFormationPageCtrl:InitView(matchPlayerTeamsModel, matchFormationCacheDataModel)
    if matchPlayerTeamsModel then
        self.matchPlayerTeamsModel = matchPlayerTeamsModel
    end

    if matchFormationCacheDataModel then
        self.matchFormationCacheDataModel = matchFormationCacheDataModel
    end

    self.formationPageView:InitView(self.matchPlayerTeamsModel, self.matchFormationCacheDataModel)
    self.formationPageView.onShowPower = function (powerValue)
        self:OnShowPower(powerValue)
    end
end

function MatchFormationPageCtrl:OnShowPower(powerValue)
    if not self.powerCtrl then
        self.powerCtrl = CardPowerCtrl.new(self.formationPageView.powerNumArea, 4, 8)
    end
    self.powerCtrl:InitPower(powerValue)
end

return MatchFormationPageCtrl
