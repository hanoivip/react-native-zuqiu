local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")
local MatchLoader = require("coregame.MatchLoader")
local PlayerDetailCtrl = require("ui.controllers.playerDetail.PeakPlayerDetailCtrl")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local PeakRankModel = require("ui.models.peak.PeakRankModel")

local PeakRankBoardCtrl = class(BaseCtrl)

PeakRankBoardCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Peak/PeakRankBoard.prefab"

PeakRankBoardCtrl.dialogStatus = {
    touchClose = true,
    withShadow = true,
    unblockRaycast = false,
}

function PeakRankBoardCtrl:AheadRequest()
    local response = req.peakRank()
    if api.success(response) then
        local data = response.val
        if data then
            self.peakRankModel = PeakRankModel.new()
            self.peakRankModel:InitWithProtocol(data)
        end
    end    
end

function PeakRankBoardCtrl:Init()
    self:CreateItemList()
    self.view.onBack = function() self:OnBack() end
    self.view:InitView(self.peakRankModel)
end

function PeakRankBoardCtrl:CreateItemList()
    self.view.scrollView.onScrollCreateItem = function(index)
        local obj, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Peak/PeakRankItem.prefab")
        return obj, spt
    end
    self.view.scrollView.onScrollResetItem = function(spt, index)
        local rankData = self.view.scrollView.itemDatas[index]
        spt.onView = function() self:OnView(rankData.id) end
        spt.onInitTeamLogo = function() self:OnInitTeamLogo(spt:GetTeamLogo(), rankData.logo) end
        spt.onViewDetail = function() self:OnViewDetail(rankData.sid, rankData.pid) end
        spt:InitView(rankData, index)
        self.view.scrollView:updateItemIndex(spt, index)
    end

    self:RefreshScrollView()
end

function PeakRankBoardCtrl:RefreshScrollView()
    local rankDataList = self.peakRankModel:GetPeakRankDataList()
    self.view.scrollView:clearData()
    for i = 1, #rankDataList do
        table.insert(self.view.scrollView.itemDatas, rankDataList[i])
    end
    self.view.scrollView:refresh()
end

function PeakRankBoardCtrl:OnInitTeamLogo(teamLogo, logoData)
    TeamLogoCtrl.BuildTeamLogo(teamLogo, logoData)
end

function PeakRankBoardCtrl:OnBack()
    res.PopScene()
end

function PeakRankBoardCtrl:OnViewDetail(sid, pid)
    local reqFunc = function()
        return req.peakViewOpponent(sid, pid)
    end
    PlayerDetailCtrl.ShowPlayerDetailView(reqFunc, pid, sid)
end

return PeakRankBoardCtrl