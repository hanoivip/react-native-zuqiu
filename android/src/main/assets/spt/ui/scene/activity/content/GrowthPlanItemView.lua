local UnityEngine = clr.UnityEngine
local Button = UnityEngine.UI.Button
local Text = UnityEngine.UI.Text
local GameObjectHelper = require("ui.common.GameObjectHelper")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")

local GrowthPlanItemView = class(unity.base)

function GrowthPlanItemView:ctor()
    self.parentRect = self.___ex.parentRect
    self.rewardBtn = self.___ex.rewardBtn
    self.rewardBtnDiable = self.___ex.rewardBtnDiable
    self.finishIcon = self.___ex.finishIcon
    self.conditionDescText = self.___ex.conditionDescText
    self.cumulativeConsumeItemScrollAtOnce = self.___ex.cumulativeConsumeItemScrollAtOnce
end

function GrowthPlanItemView:start()
     self.rewardBtn:regOnButtonClick(function()
        self:OnRewardBtnClick()
    end)
end

-- state = 0 时表示可以领取奖励
function GrowthPlanItemView:InitRewardButtonState(state)
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

function GrowthPlanItemView:OnRewardBtnClick()
    if self.onRewardBtnClick then
        self:onRewardBtnClick()
    end
end

function GrowthPlanItemView:InitView(growthPlanModel, index, parentScrollRect)
    self.growthPlanModel = growthPlanModel
    res.ClearChildren(self.cumulativeConsumeItemScrollAtOnce.gameObject.transform)
    local rewardParams = {
        parentObj = self.parentRect,
        rewardData = growthPlanModel:GetRewardData()[index].contents,
        isShowName = false,
        isReceive = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = true,
    }
    self.cumulativeConsumeItemScrollAtOnce.scrollRectInParent = parentScrollRect
    self.conditionDescText.text = string.format(growthPlanModel:GetConditionDescByIndex(index), growthPlanModel:GetRewardProgressByIndex(index))
    RewardDataCtrl.new(rewardParams)
end

return GrowthPlanItemView