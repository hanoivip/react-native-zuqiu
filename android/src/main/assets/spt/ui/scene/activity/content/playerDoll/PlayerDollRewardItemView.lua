local RewardDataCtrl = require('ui.controllers.common.RewardDataCtrl')
local RewardNameHelper = require("ui.scene.itemList.RewardNameHelper")

local PlayerDollRewardItemView = class(unity.base)

function PlayerDollRewardItemView:ctor()
--------Start_Auto_Generate--------
    self.contentTrans = self.___ex.contentTrans
    self.nameTxt = self.___ex.nameTxt
--------End_Auto_Generate----------
end

function PlayerDollRewardItemView:InitView(itemData)
    res.ClearChildren(self.contentTrans)
    local reward = itemData.reward.contents
    local rewardParams = {
        parentObj = self.contentTrans,
        rewardData = reward,
        isShowName = false,
        isReceive = false,
        isShowSymbol = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = true,
    }
    RewardDataCtrl.new(rewardParams)
    local nameStr = RewardNameHelper.GetSingleContentName(reward)
    self.nameTxt.text = string.sub(nameStr, 2, #nameStr)
end

return PlayerDollRewardItemView
