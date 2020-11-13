local LadderDailyRewardDetailCtrl = class()

function LadderDailyRewardDetailCtrl:ctor(view)
    self.view = view
end

function LadderDailyRewardDetailCtrl:InitView(ladderModel)
    self.ladderModel = ladderModel
    self:CreateItemList()
    self.view:InitView(self.ladderModel)
end

function LadderDailyRewardDetailCtrl:CreateItemList()
    self.view.scrollView.onScrollCreateItem = function(index)
        local obj, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Ladder/LadderDailyRewardDetailItemBar.prefab")
        return obj, spt
    end
    self.view.scrollView.onScrollResetItem = function(spt, index)
        local dailyRewardData = self.view.scrollView.itemDatas[index]
        spt:InitView(dailyRewardData)
        self.view.scrollView:updateItemIndex(spt, index)
    end

    self:RefreshScrollView()
end

function LadderDailyRewardDetailCtrl:RefreshScrollView()
    local dailyRewardDataList = self.ladderModel:GetDailyRewardData()
    self.view.scrollView:clearData()
    for i = 1, #dailyRewardDataList do
        table.insert(self.view.scrollView.itemDatas, dailyRewardDataList[i])
    end
    self.view.scrollView:refresh()
end

return LadderDailyRewardDetailCtrl