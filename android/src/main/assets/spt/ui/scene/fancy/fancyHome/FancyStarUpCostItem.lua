local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local FancyStarUpCostItem = class(unity.base)

function FancyStarUpCostItem:ctor()
--------Start_Auto_Generate--------
    self.itemTrans = self.___ex.itemTrans
    self.countTxt = self.___ex.countTxt
    self.nameTxt = self.___ex.nameTxt
--------End_Auto_Generate----------
end

function FancyStarUpCostItem:InitView(data)
    self.nameTxt.text = data.name
    self.countTxt.text = data.count
    res.ClearChildren(self.itemTrans)
    local rewardParams = {
        parentObj = self.itemTrans,
        rewardData = data.content,
        isShowName = false,
        isReceive = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = not tobool(data.content.fancyCard),
        hideCount = true,
    }
    RewardDataCtrl.new(rewardParams)
end

return FancyStarUpCostItem
