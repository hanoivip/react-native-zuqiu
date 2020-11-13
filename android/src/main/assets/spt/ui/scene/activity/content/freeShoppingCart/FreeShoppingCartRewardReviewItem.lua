local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local FreeShoppingCartRewardReviewItem = class()

function FreeShoppingCartRewardReviewItem:ctor()
--------Start_Auto_Generate--------
    self.titleTxt = self.___ex.titleTxt
    self.itemTrans = self.___ex.itemTrans
--------End_Auto_Generate----------
end

function FreeShoppingCartRewardReviewItem:InitView(dayData)
    local index, firstDayData = next(dayData)
    local dateTime = firstDayData.chooseRewardBeginTime
    dateTime = string.convertSecondToMonthAndDay(dateTime)
    dateTime = dateTime.month .. "." .. dateTime.day
    self.titleTxt.text = lang.trans("free_shopping_choose_title", dateTime)
    res.ClearChildren(self.itemTrans)
    for i, v in ipairs(dayData) do
        local rewardParams = {
            parentObj = self.itemTrans,
            rewardData = v.contents,
            isShowName = false,
            isReceive = false,
            isShowBaseReward = true,
            isShowCardReward = true,
            isShowDetail = true,
        }
        RewardDataCtrl.new(rewardParams)
    end
end

return FreeShoppingCartRewardReviewItem
