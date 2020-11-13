local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local GameObjectHelper = require("ui.common.GameObjectHelper")

local GiftBoxDetailItemView = class(unity.base, "GiftBoxDetailItemView")

function GiftBoxDetailItemView:ctor()
    self.rctContent = self.___ex.rctContent
end

function GiftBoxDetailItemView:InitView(itemData)
    res.ClearChildren(self.rctContent)
    local rewardParams = {
        parentObj = self.rctContent,
        rewardData = itemData.contents,
        isShowName = false,
        isReceive = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = true,
     }
     RewardDataCtrl.new(rewardParams)
end

return GiftBoxDetailItemView
