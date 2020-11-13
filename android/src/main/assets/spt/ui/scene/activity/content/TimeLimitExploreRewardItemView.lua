local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local TimeLimitExploreRewardItemView = class(unity.base)

function TimeLimitExploreRewardItemView:ctor()
    self.parentRect = self.___ex.parentRect
    self.itemScrollAtOnce = self.___ex.itemScrollAtOnce
    self.rankNumber = self.___ex.rankNumber
    self.bg1 = self.___ex.bg1
    self.bg2 = self.___ex.bg2
    self.arrow = self.___ex.arrow
end

function TimeLimitExploreRewardItemView:InitView(itemModel, parentScrollRect, index)
    self.itemModel = itemModel
    self.index = index
    res.ClearChildren(self.itemScrollAtOnce.gameObject.transform)
    local rewardParams = {
        parentObj = self.parentRect,
        rewardData = self.itemModel.contents,
        isShowName = false,
        isReceive = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = true,
    }
    self.itemScrollAtOnce.scrollRectInParent = parentScrollRect
    RewardDataCtrl.new(rewardParams)

    if itemModel.topLimit == itemModel.downLimit then
        self.rankNumber.text = lang.trans("guildwar_rank", tostring(itemModel.topLimit))
    else
        local num = tostring(itemModel.topLimit) .. "—" .. tostring(itemModel.downLimit)
        self.rankNumber.text = lang.trans("guildwar_rank", num)
    end
    self.arrow:SetActive(self.parentRect.gameObject.transform.childCount > 4)

    self.bg1:SetActive(self.index % 2 == 1)
    self.bg2:SetActive(self.index % 2 == 0)
end

return TimeLimitExploreRewardItemView
