local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local TimeLimitStageShopRewardItemView = class(unity.base)

function TimeLimitStageShopRewardItemView:ctor()
--------Start_Auto_Generate--------
    self.selectGo = self.___ex.selectGo
    self.corner1Go = self.___ex.corner1Go
    self.corner2Go = self.___ex.corner2Go
    self.soldGo = self.___ex.soldGo
    self.remainTxt = self.___ex.remainTxt
    self.rewardTrans = self.___ex.rewardTrans
--------End_Auto_Generate----------
end

function TimeLimitStageShopRewardItemView:InitView(rewardData)
    local buyCount = rewardData.buyCount
    local rewardCount = rewardData.rewardCount
    local rewardType = rewardData.rewardType
    local remainCount = rewardCount - buyCount

    GameObjectHelper.FastSetActive(self.corner1Go, rewardType == 1)
    GameObjectHelper.FastSetActive(self.corner2Go, rewardType == 2)
    GameObjectHelper.FastSetActive(self.soldGo, remainCount <= 0)
    self.remainTxt.text = lang.trans("stage_shop_remain", remainCount)
    local rewardParams = {
        parentObj = self.rewardTrans,
        rewardData = rewardData.contents,
        isShowName = false,
        isReceive = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = true,
        isShowSymbol = false,
    }
    res.ClearChildren(self.rewardTrans)
    RewardDataCtrl.new(rewardParams)
end

return TimeLimitStageShopRewardItemView
