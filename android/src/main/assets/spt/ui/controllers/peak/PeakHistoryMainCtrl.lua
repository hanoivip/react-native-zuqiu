local BaseCtrl = require("ui.controllers.BaseCtrl")
local PeakHistoryModel = require("ui.models.peak.PeakHistoryModel")
local PeakPlayerDetailCtrl = require("ui.controllers.playerDetail.PeakPlayerDetailCtrl")
local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")

local PeakHistoryMainCtrl = class(BaseCtrl)

PeakHistoryMainCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Peak/PeakHistoryBoard.prefab"

function PeakHistoryMainCtrl:Init(data)
    self.recordListData = data
    self.peakHistoryModel = PeakHistoryModel.new()
    self.peakHistoryModel:InitWithProtocol(data)
end

function PeakHistoryMainCtrl:GetStatusData()
    return self.recordListData
end

function PeakHistoryMainCtrl:Refresh()
    self:InitView()
end

function PeakHistoryMainCtrl:InitView()
    self.view.onBack = function() self:OnBack() end
    self.view:InitView()
    self:CreateItemList()
end

function PeakHistoryMainCtrl:CreateItemList()
    self.view.scrollView.onScrollCreateItem = function(index)
        local obj, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Peak/PeakHistoryItem.prefab")
        return obj, spt
    end
    self.view.scrollView.onScrollResetItem = function(spt, index)
        local peakHistoryData = self.view.scrollView.itemDatas[index]
        spt.onInitTeamLogo = function() self:OnInitTeamLogo(spt:GetTeamLogo(), peakHistoryData.opponent.logo) end
        spt.onViewFightDetail = function() self:OnViewFightDetail(index) end
        spt.onViewOpponentDetail = function() self:OnViewOpponentDetail(peakHistoryData.opponent.sid, peakHistoryData.opponent.pid) end
        spt:InitView(peakHistoryData)
        self.view.scrollView:updateItemIndex(spt, index)
    end
    self:RefreshScrollView()
end

function PeakHistoryMainCtrl:RefreshScrollView()
    local peakHistoryList = self.peakHistoryModel:GetPeakHistoryList()
    self.view.scrollView:clearData()
    for i = 1, #peakHistoryList do
        table.insert(self.view.scrollView.itemDatas, peakHistoryList[i])
    end
    self.view.scrollView:refresh()
end

function PeakHistoryMainCtrl:OnInitTeamLogo(teamLogo, logoData)
    TeamLogoCtrl.BuildTeamLogo(teamLogo, logoData)
end

-- 查看比赛结果详情
function PeakHistoryMainCtrl:OnViewFightDetail(peakHistoryModelIndex)
    res.PushDialog("ui.controllers.peak.PeakMatchDetailsCtrl", self.peakHistoryModel:GetSingleMatchData(peakHistoryModelIndex))

end

-- 查看对手信息
function PeakHistoryMainCtrl:OnViewOpponentDetail(sid , pid)
    PeakPlayerDetailCtrl.ShowPlayerDetailView(function() return req.peakViewOpponent(sid, pid) end, pid, sid, sid, require("ui.models.PlayerInfoModel").new():GetID() == pid)
end

return PeakHistoryMainCtrl