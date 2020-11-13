local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local CumulativeDisplayItemView = class(unity.base)

function CumulativeDisplayItemView:ctor()
--------Start_Auto_Generate--------
    self.itemTrans = self.___ex.itemTrans
    self.conditionTxt = self.___ex.conditionTxt
--------End_Auto_Generate----------
end

function CumulativeDisplayItemView:InitView(rewardData)
    self.condition = rewardData.condition
    self.reward = rewardData.display
    res.ClearChildren(self.itemTrans)
    local rewardParams = {
        parentObj = self.itemTrans,
        rewardData = self.reward,
        isShowName = true,
        isReceive = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = true,
    }
    RewardDataCtrl.new(rewardParams)
    self.conditionTxt.text = tostring(self.condition) .. lang.transstr("diamond")
end

return CumulativeDisplayItemView
