local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")
local PlayerDetailCtrl = require("ui.controllers.playerDetail.PeakPlayerDetailCtrl")
local GameObjectHelper = require("ui.common.GameObjectHelper")

local PeakSeasonRankCtrl = class()

function PeakSeasonRankCtrl:ctor(view)
    self.view = view
end

function PeakSeasonRankCtrl:InitView(peakRankModel)
    self.peakRankModel = peakRankModel
    self:CreateItemList()
    self.view:InitView(self.peakRankModel)
end

function PeakSeasonRankCtrl:CreateItemList()
    self.view.scrollView.onScrollCreateItem = function(index)
        local obj, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Peak/PeakSeasonRankItemBar.prefab")
        return obj, spt
    end
    self.view.scrollView.onScrollResetItem = function(spt, index)
        local rankData = self.view.scrollView.itemDatas[index]
        spt.onViewDetail = function() self:OnViewDetail(rankData.sid, rankData.pid) end
        spt.onInitTeamLogo = function() self:OnInitTeamLogo(spt:GetTeamLogo(), rankData.logo) end
        spt:InitView(rankData, index)
        
        local curRankSeason = self.peakRankModel:GetCurRankSeason()
        if curRankSeason.type ~= "current" and curRankSeason.type ~= "season" then
            spt:SetBtnViewActive(false)
        else
            spt:SetBtnViewActive(true) 
        end
        
        self.view.scrollView:updateItemIndex(spt, index)
    end

    self:RefreshScrollView()
end

function PeakSeasonRankCtrl:RefreshScrollView()
    local rankDataList = self.peakRankModel:GetCurSelectRankData()
    self.view.scrollView:clearData()
    if rankDataList then
        for i = 1, #rankDataList do
            table.insert(self.view.scrollView.itemDatas, rankDataList[i])
        end
    end
    self.view.scrollView:refresh()
end

-- 查看玩家详情
function PeakSeasonRankCtrl:OnViewDetail(sid, pid)
    local reqFunc = function()
        return req.peakViewOpponent(sid, pid)
    end
    PlayerDetailCtrl.ShowPlayerDetailView(reqFunc, pid, sid)
end

function PeakSeasonRankCtrl:OnInitTeamLogo(teamLogo, logoData)
    TeamLogoCtrl.BuildTeamLogo(teamLogo, logoData)
end

return PeakSeasonRankCtrl