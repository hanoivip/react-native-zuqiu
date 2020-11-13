local BaseCtrl = require("ui.controllers.BaseCtrl")
local CompeteArenaRankModel = require("ui.models.compete.arenaRank.CompeteArenaRankModel")

local CompeteArenaRankCtrl = class(BaseCtrl, "CompeteArenaRankCtrl")

CompeteArenaRankCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Compete/ArenaRank/CompeteArenaRank.prefab"

function CompeteArenaRankCtrl:ctor()
    CompeteArenaRankCtrl.super.ctor(self)
end

function CompeteArenaRankCtrl:Init(competeArenaRankModel)
    if competeArenaRankModel then
        self.model = competeArenaRankModel
    else
        self.model = CompeteArenaRankModel.new()
    end

    self.view.onClickBack = function() self:OnClickBack() end
    self.view.onClickLabel = function(tag, spt) self:OnClickLabel(tag, spt) end
    self.view.onClickTab = function(tag, spt) self:OnClickTab(tag, spt) end
end

function CompeteArenaRankCtrl:Refresh(competeArenaRankModel)
    CompeteArenaRankCtrl.super.Refresh(self)

    if competeArenaRankModel then
        self.model = competeArenaRankModel
    else
        self.model = CompeteArenaRankModel.new()
    end

    self.view:InitView(self.model)
    self.view:InitRankList()
end

function CompeteArenaRankCtrl:RequestOtherMatchTypeData(season, matchType)
    if not self:CheckAlreadyAccess(season, matchType) then
        clr.coroutine(function()
            local respone = req.worldTournamentRank(season, matchType)
            if api.success(respone) then
                local data = respone.val
                self.model:AddDataWithProtocol(season, matchType, data)
                self.view:RefreshRankList()
            end
        end)
    else
        self.view:RefreshRankList()
    end
end

function CompeteArenaRankCtrl:RequestOtherSeasonData(season, matchType)
    if not self:CheckAlreadyAccess(season, matchType) then
        clr.coroutine(function()
            local respone = req.worldTournamentRank(season, matchType)
            if api.success(respone) then
                local data = respone.val

                self.model:AddDataWithProtocol(season, matchType, data)
                self.model:InitRankLabels(season, data.localMatchCount)

                self.view:RefreshRankLabels()

                self.view:RefreshRankList()
                self.view:InitMyRankArea(self.model:GetCurrSeasonTag())
            end
        end)
    else
        self.model:InitRankLabels(season, self.model:GetLocalMatchCount(season))
        self.view:RefreshRankLabels()
        self.view:RefreshRankList()
        self.view:InitMyRankArea(self.model:GetCurrSeasonTag())
    end
end

function CompeteArenaRankCtrl:CheckAlreadyAccess(season, matchType)
    return self.model:IsDataExist(season, matchType)
end

function CompeteArenaRankCtrl:GetStatusData()
    return self.model
end

function CompeteArenaRankCtrl:OnClickBack()
    res.PopScene()
end

function CompeteArenaRankCtrl:OnClickLabel(tag, spt)
    if tag and spt then

        if spt.isSelect then return end

        self.view:ChangeMatchTypeLabelSelectTag(tag)

        self.model:SetCurrLabelTag(tag)

        self:RequestOtherMatchTypeData(self.model:GetCurrSeasonTag(), spt:GetMatchType())
    end
end

function CompeteArenaRankCtrl:OnClickTab(tag, spt)
    if spt.isSelect then return end

    self.view:ChangeSeasonTabSelectTag(tag)

    self.model:SetCurrSeasonTag(tag)
    local matchType = self.model:GetDefaultMatchType()
    self.model:SetCurrLabelTag(matchType)
    self:RequestOtherSeasonData(tag, matchType)
end

return CompeteArenaRankCtrl