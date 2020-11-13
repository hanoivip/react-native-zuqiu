local ItemModel = require("ui.models.ItemModel")

local LadderRewardDetailCtrl = class()

function LadderRewardDetailCtrl:ctor(view)
    self.view = view
end

function LadderRewardDetailCtrl:InitView(ladderModel)
    self.ladderModel = ladderModel
    self:CreateItemList()
    self.view:InitView(self.ladderModel)
end

function LadderRewardDetailCtrl:CreateItemList()
    self.view.scrollView.onScrollCreateItem = function(index)
        local obj, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Ladder/LadderRewardDetailItemBar.prefab")
        return obj, spt
    end
    self.view.scrollView.onScrollResetItem = function(spt, index)
        local seasonRewardData = self.view.scrollView.itemDatas[index]
        spt:ClearRewardItems()
        spt:InitView(seasonRewardData)
        self.view.scrollView:updateItemIndex(spt, index)
    end

    self:RefreshScrollView()
end

function LadderRewardDetailCtrl:RefreshScrollView()
    local seasonRewardDataList = self.ladderModel:GetSeasonRewardData()
    self.view.scrollView:clearData()
    for i = 1, #seasonRewardDataList do
        table.insert(self.view.scrollView.itemDatas, seasonRewardDataList[i])
    end
    self.view.scrollView:refresh()
end

return LadderRewardDetailCtrl