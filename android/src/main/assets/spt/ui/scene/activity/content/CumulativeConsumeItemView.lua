local UnityEngine = clr.UnityEngine
local Button = UnityEngine.UI.Button
local Text = UnityEngine.UI.Text
local GameObjectHelper = require("ui.common.GameObjectHelper")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")

local CumulativeConsumeItemView = class(unity.base)

function CumulativeConsumeItemView:ctor()
    self.parentRect = self.___ex.parentRect
    self.rewardBtn = self.___ex.rewardBtn
    self.rewardBtnDiable = self.___ex.rewardBtnDiable
    self.finishIcon = self.___ex.finishIcon
    self.payTipText = self.___ex.payTipText
    self.diamondNumberText = self.___ex.diamondNumberText
    self.cumulativeConsumeItemScrollAtOnce = self.___ex.cumulativeConsumeItemScrollAtOnce
end

function CumulativeConsumeItemView:start()
     self.rewardBtn:regOnButtonClick(function()
        self:OnRewardBtnClick()
    end)
end

-- state = 0 时表示可以领取奖励
function CumulativeConsumeItemView:InitRewardButtonState(state)
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

function CumulativeConsumeItemView:RefreshTextContentAndButtonState()
    self.diamondNumberText.text = tostring(self.cumulativeConsumeModel:GetConsumeDiamondNumberByIndex(self.index)) .. "/"
        .. tostring(self.cumulativeConsumeModel:GetRewardConditionByIndex(self.index))
    self:InitRewardButtonState(self.cumulativeConsumeModel:GetRewardStatusByIndex(self.index))
end

function CumulativeConsumeItemView:OnRewardBtnClick()
    if self.onRewardBtnClick then
        self:onRewardBtnClick()
    end
end

function CumulativeConsumeItemView:InitView(cumulativeConsumeModel, index, parentScrollRect)
    self.cumulativeConsumeModel = cumulativeConsumeModel
    self.index = index
    res.ClearChildren(self.cumulativeConsumeItemScrollAtOnce.gameObject.transform)
    local rewardParams = {
        parentObj = self.parentRect,
        rewardData = cumulativeConsumeModel:GetRewardData()[index].contents,
        isShowName = false,
        isReceive = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = true,
    }
    self.cumulativeConsumeItemScrollAtOnce.scrollRectInParent = parentScrollRect
    self.diamondNumberText.text = tostring(cumulativeConsumeModel:GetConsumeDiamondNumberByIndex(index)) .. "/"
        .. tostring(cumulativeConsumeModel:GetRewardConditionByIndex(index))

    RewardDataCtrl.new(rewardParams)
end

return CumulativeConsumeItemView