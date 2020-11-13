local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")
local PlayerDetailCtrl = require("ui.controllers.playerDetail.PeakPlayerDetailCtrl")

local PeakRealTimeRankCtrl = class()

function PeakRealTimeRankCtrl:ctor(view)
    self.view = view
end

function PeakRealTimeRankCtrl:InitView(peakRankModel)
    self.peakRankModel = peakRankModel
    self:CreateItemList()
    self.view:InitView(self.peakRankModel)
end

function PeakRealTimeRankCtrl:CreateItemList()
    self.view.scrollView.onScrollCreateItem = function(index)
        local obj, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Peak/PeakRealTimeRankItemBar.prefab")
        return obj, spt
    end
    self.view.scrollView.onScrollResetItem = function(spt, index)
        local rankData = self.view.scrollView.itemDatas[index]
        spt.onViewDetail = function() self:OnViewDetail(rankData.sid, rankData.pid) end
        spt.onInitTeamLogo = function() self:OnInitTeamLogo(spt:GetTeamLogo(), rankData.logo) end
        spt:InitView(rankData, index)
        self.view.scrollView:updateItemIndex(spt, index)
    end

    self:RefreshScrollView()
end

function PeakRealTimeRankCtrl:RefreshScrollView()
    local rankDataList = self.peakRankModel:GetCurSelectRankData()
    self.view.scrollView:clearData()
    for i = 1, #rankDataList do
        table.insert(self.view.scrollView.itemDatas, rankDataList[i])
    end
    self.view.scrollView:refresh()
end

-- 查看玩家详情
function PeakRealTimeRankCtrl:OnViewDetail(sid, pid)
    local reqFunc = function()
        return req.peakViewOpponent(sid, pid)
    end
    PlayerDetailCtrl.ShowPlayerDetailView(reqFunc, pid, sid)
end

function PeakRealTimeRankCtrl:OnInitTeamLogo(teamLogo, logoData)
    TeamLogoCtrl.BuildTeamLogo(teamLogo, logoData)
end

return PeakRealTimeRankCtrl