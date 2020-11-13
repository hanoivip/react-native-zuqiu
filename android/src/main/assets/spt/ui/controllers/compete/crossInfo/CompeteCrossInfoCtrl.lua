local BaseCtrl = require("ui.controllers.BaseCtrl")
local CompeteCrossInfoModel = require("ui.models.compete.crossInfo.CompeteCrossInfoModel")
local CompeteCrossInfoCtrl = class(BaseCtrl, "CompeteCrossInfoCtrl")

CompeteCrossInfoCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Compete/CrossInfo/CompeteCrossInfo.prefab"

function CompeteCrossInfoCtrl:ctor()
    CompeteCrossInfoCtrl.super.ctor(self)
end

function CompeteCrossInfoCtrl:Init(competeCrossInfoModel)
    if competeCrossInfoModel then
        self.model = competeCrossInfoModel
    else
        self.model = CompeteCrossInfoModel.new()
    end

    self.view.onClickBack = function() self:OnClickBack() end
    self.view.onClickLabel = function(tag, spt) self:OnClickLabel(tag, spt) end
    self.view.onClickTab = function(tag, spt) self:OnClickTab(tag, spt) end
end

function CompeteCrossInfoCtrl:Refresh(competeCrossInfoModel)
    CompeteCrossInfoCtrl.super.Refresh(self)

    if competeCrossInfoModel then
        self.model = competeCrossInfoModel
    else
        self.model = CompeteCrossInfoModel.new()
    end

    self.view:InitView(self.model)
    self.model:SetCurrSeasonTag(self.view:GetSeasonTabSelectedTag())
    self.model:SetCurrLabelTag(self.view:GetMatchTypeLabelSelectedTag())
    self.view:InitRankList(1)
end

function CompeteCrossInfoCtrl:RequestOtherMatchTypeData(season, matchType)
    if not self:CheckAlreadyAccess(season, matchType) then
        clr.coroutine(function()
            local respone = req.worldTournamentCrossInfo(season, matchType)
            if api.success(respone) then
                local data = respone.val
                self.model:AddDataWithProtocol(season, matchType, data)
                self.view:RefreshRankList(matchType)
            end
        end)
    else
        self.view:RefreshRankList(matchType)
    end
end

function CompeteCrossInfoCtrl:RequestOtherSeasonData(season, matchType)
    if not self:CheckAlreadyAccess(season, matchType) then
        clr.coroutine(function()
            local respone = req.worldTournamentCrossInfo(season, matchType)
            if api.success(respone) then
                local data = respone.val
                self.model:AddDataWithProtocol(season, matchType, data)
                self.model:InitRankLabels(season)

                self.view:RefreshRankLabels()

                self.view:RefreshRankList(matchType)
            end
        end)
    else
        self.model:InitRankLabels(season)

        self.view:RefreshRankLabels()

        self.view:RefreshRankList(matchType)
    end
end

function CompeteCrossInfoCtrl:CheckAlreadyAccess(season, matchType)
    return self.model:IsDataExist(season, matchType)
end

function CompeteCrossInfoCtrl:GetStatusData()
    return self.model
end

function CompeteCrossInfoCtrl:OnClickBack()
    res.PopScene()
end

function CompeteCrossInfoCtrl:OnClickLabel(tag, spt)
    if spt.isSelect then return end

    self.view:ChangeMatchTypeLabelSelectTag(tag)

    self.model:SetCurrLabelTag(tag)

    self:RequestOtherMatchTypeData(self.model:GetCurrSeasonTag(), spt:GetMatchType())
end

function CompeteCrossInfoCtrl:OnClickTab(tag, spt)
    if spt.isSelect then return end

    self.view:ChangeSeasonTabSelectTag(tag)

    self.model:SetCurrSeasonTag(tag)
    local matchType = self.model:GetDefaultMatchType()
    self.model:SetCurrLabelTag(matchType)

    self:RequestOtherSeasonData(tag, matchType)
end

return CompeteCrossInfoCtrl