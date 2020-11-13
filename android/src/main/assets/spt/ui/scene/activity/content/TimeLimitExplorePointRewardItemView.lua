local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local TimeLimitExplorePointRewardItemView = class(unity.base)

function TimeLimitExplorePointRewardItemView:ctor()
    self.tips = self.___ex.tips
    self.parentRect = self.___ex.parentRect
    self.btnReward = self.___ex.btnReward
    self.itemScrollAtOnce = self.___ex.itemScrollAtOnce
    self.lockObj = self.___ex.lockObj
    self.getObj = self.___ex.getObj
end

function TimeLimitExplorePointRewardItemView:start()
    EventSystem.AddEvent("TimeLimitExplore.UpdatePointRewardInfo", self, self.UpdatePointRewardInfo)
end

function TimeLimitExplorePointRewardItemView:InitView(itemModel, parentScrollRect)
    self.itemModel = itemModel
    res.ClearChildren(self.itemScrollAtOnce.gameObject.transform)
    local rewardParams = {
        parentObj = self.parentRect,
        rewardData = self.itemModel.contents,
        isShowName = false,
        isReceive = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = true,
        isShowCardPieceBeforeItem = true,
    }
    self.itemScrollAtOnce.scrollRectInParent = parentScrollRect
    RewardDataCtrl.new(rewardParams)

    self.tips.text = lang.trans("visit_getPointDesc", self.itemModel.condition)
    self.btnReward:regOnButtonClick(function()
        self.onItemButtonClick(true, self.itemModel.subID)
    end)
    
    self:UpdatePointRewardInfo()
end

function TimeLimitExplorePointRewardItemView:UpdatePointRewardInfo()
    self.lockObj:SetActive(self.itemModel.status == -1)
    self.btnReward.gameObject:SetActive(self.itemModel.status == 0)
    self.getObj:SetActive(self.itemModel.status == 1)
end

function TimeLimitExplorePointRewardItemView:onDestroy()
    EventSystem.RemoveEvent("TimeLimitExplore.UpdatePointRewardInfo", self, self.UpdatePointRewardInfo)
end

return TimeLimitExplorePointRewardItemView
