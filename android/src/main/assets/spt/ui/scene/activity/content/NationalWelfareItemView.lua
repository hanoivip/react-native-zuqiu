local GameObjectHelper = require("ui.common.GameObjectHelper")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")

local NationalWelfareItemView = class(unity.base)

function NationalWelfareItemView:ctor()
    self.parentRect = self.___ex.parentRect
    self.rewardBtn = self.___ex.rewardBtn
    self.rewardBtnDiable = self.___ex.rewardBtnDiable
    self.finishIcon = self.___ex.finishIcon
    self.txtRewardCondition = self.___ex.txtRewardCondition
    self.nationalWelfareItemScrollAtOnce = self.___ex.nationalWelfareItemScrollAtOnce
end

function NationalWelfareItemView:start()
     self.rewardBtn:regOnButtonClick(function()
        if self.onRewardBtnClick then
            self:onRewardBtnClick()
        end
    end)
end

function NationalWelfareItemView:InitView(nationalWelfareModel, rewardType, index, parentScrollRect)
    self.nationalWelfareModel = nationalWelfareModel
    res.ClearChildren(self.nationalWelfareItemScrollAtOnce.gameObject.transform)
    local rewardParams = {
        parentObj = self.parentRect,
        rewardData = self.nationalWelfareModel:GetRewardData(rewardType)[index].contents,
        isShowName = false,
        isReceive = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = true,
    }
    self.nationalWelfareItemScrollAtOnce.scrollRectInParent = parentScrollRect
    self.txtRewardCondition.text = lang.trans("activity_nationalWelfare_rewardConditionValue", nationalWelfareModel:GetRewardConditionByIndex(index))
    RewardDataCtrl.new(rewardParams)
end

-- state = 0 时表示可以领取奖励
function NationalWelfareItemView:InitRewardButtonState(state)
    if state == -1 then
        GameObjectHelper.FastSetActive(self.rewardBtn.gameObject, false)
        GameObjectHelper.FastSetActive(self.rewardBtnDiable, true)
        GameObjectHelper.FastSetActive(self.finishIcon, false)
    elseif state == 1 then
        GameObjectHelper.FastSetActive(self.rewardBtn.gameObject, false)
        GameObjectHelper.FastSetActive(self.rewardBtnDiable, false)
        GameObjectHelper.FastSetActive(self.finishIcon, true)
    elseif state == 0 then
        GameObjectHelper.FastSetActive(self.rewardBtn.gameObject, true)
        GameObjectHelper.FastSetActive(self.rewardBtnDiable, false)
        GameObjectHelper.FastSetActive(self.finishIcon, false)
    end
end

return NationalWelfareItemView