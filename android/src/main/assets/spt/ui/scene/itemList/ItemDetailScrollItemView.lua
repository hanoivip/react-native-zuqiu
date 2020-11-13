local GameObjectHelper = require("ui.common.GameObjectHelper")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")

local ItemDetailScrollItemView = class(unity.base, "ItemDetailScrollItemView")

function ItemDetailScrollItemView:ctor()
    self.rctContent = self.___ex.rctContent
end

function ItemDetailScrollItemView:InitView(itemData)
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

return ItemDetailScrollItemView
