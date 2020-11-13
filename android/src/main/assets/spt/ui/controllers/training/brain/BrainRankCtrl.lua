local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")
local BrainRankCtrl = class()

function BrainRankCtrl:ctor(view)
    self.view = view
end

function BrainRankCtrl:InitView(rankModel)
    self.rankModel = rankModel
    self:CreateItemList()
    self.view:InitView(self.rankModel)
end

function BrainRankCtrl:CreateItemList()
    self.view.scrollView.onScrollCreateItem = function(spt, index)
        local obj, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Training/Brain/BrainRankItemBar.prefab")
        return obj, spt
    end
    self.view.scrollView.onScrollResetItem = function(spt, index)
        local rankData = self.view.scrollView.itemDatas[index]
        spt.onInitTeamLogo = function() self:OnInitTeamLogo(spt:GetTeamLogo(), rankData.logo) end
        spt:InitView(rankData, index)
        self.view.scrollView:updateItemIndex(spt, index)
    end
    self:RefreshScrollView()
end

function BrainRankCtrl:RefreshScrollView()
    local rankDataList = self.rankModel:GetCurRankDataList()
    self.view.scrollView:clearData()
    for i = 1, #rankDataList do
        table.insert(self.view.scrollView.itemDatas, rankDataList[i])
    end
    self.view.scrollView:refresh()
end

function BrainRankCtrl:OnInitTeamLogo(teamLogo, logoData)
    TeamLogoCtrl.BuildTeamLogo(teamLogo, logoData)
end

return BrainRankCtrl