local UnityEngine = clr.UnityEngine
local Button = UnityEngine.UI.Button
local Text = UnityEngine.UI.Text
local GameObjectHelper = require("ui.common.GameObjectHelper")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")

local ChainGrowthPlanScrollItemView = class(unity.base)

function ChainGrowthPlanScrollItemView:ctor()
    self.parentRect = self.___ex.parentRect
    self.rewardBtn = self.___ex.rewardBtn
    self.rewardBtnDiable = self.___ex.rewardBtnDiable
    self.finishIcon = self.___ex.finishIcon
    self.conditionDescText = self.___ex.conditionDescText
    self.btnDisableTxt = self.___ex.btnDisableTxt
    self.cumulativeConsumeItemScrollAtOnce = self.___ex.cumulativeConsumeItemScrollAtOnce

    self.collectStatus = {
        collected = 1,
        notQualified = -1,
        collectable = 0,
    }
end

function ChainGrowthPlanScrollItemView:start()
    self.rewardBtn:regOnButtonClick(function()
        self:OnRewardBtnClick()
    end)
end

function ChainGrowthPlanScrollItemView:InitRewardButtonState(state)
    GameObjectHelper.FastSetActive(self.finishIcon, state == self.collectStatus.collected)

    local isActActive = self.activityModel:GetActState()
    if isActActive then
        GameObjectHelper.FastSetActive(self.rewardBtn.gameObject, state == self.collectStatus.collectable)
        GameObjectHelper.FastSetActive(self.rewardBtnDiable, state == self.collectStatus.notQualified)
        self.btnDisableTxt.text = lang.transstr("friends_receiveStrength_receive")
    else
        GameObjectHelper.FastSetActive(self.rewardBtn.gameObject, false)
        GameObjectHelper.FastSetActive(self.rewardBtnDiable, state ~= self.collectStatus.collected)
        self.btnDisableTxt.text = lang.transstr("belatedGift_item_nil_time")
    end
end

function ChainGrowthPlanScrollItemView:OnRewardBtnClick()
    if type(self.onRewardBtnClick) == "function" then
        self.onRewardBtnClick()
    end
end

function ChainGrowthPlanScrollItemView:InitView(growthPlanModel, index, parentScrollRect)
    self.activityModel = growthPlanModel
    self:InitRewardButtonState(self.activityModel:GetRewardStatusByIndex(index))
    
    res.ClearChildren(self.cumulativeConsumeItemScrollAtOnce.gameObject.transform)
    local rewardParams = {
        parentObj = self.parentRect,
        rewardData = self.activityModel:GetRewardDataList()[index].contents,
        isShowName = false,
        isReceive = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = true,
    }
    self.cumulativeConsumeItemScrollAtOnce.scrollRectInParent = parentScrollRect
    self.conditionDescText.text = self.activityModel:GetConditionDescByIndex(index)
    RewardDataCtrl.new(rewardParams)
end

function ChainGrowthPlanScrollItemView:onDestroy()
end

return ChainGrowthPlanScrollItemView