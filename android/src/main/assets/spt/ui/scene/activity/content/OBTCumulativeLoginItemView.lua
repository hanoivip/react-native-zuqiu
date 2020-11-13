local UnityEngine = clr.UnityEngine
local Button = UnityEngine.UI.Button
local Text = UnityEngine.UI.Text
local GameObjectHelper = require("ui.common.GameObjectHelper")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")

local OBTSerialConsumeItemView = class(unity.base)

function OBTSerialConsumeItemView:ctor()
    self.parentRect = self.___ex.parentRect
    self.rewardBtn = self.___ex.rewardBtn
    self.rewardBtnDiable = self.___ex.rewardBtnDiable
    self.finishIcon = self.___ex.finishIcon
    self.payTipText = self.___ex.payTipText
    self.diamondNumberText = self.___ex.diamondNumberText
    self.cumulativeConsumeItemScrollAtOnce = self.___ex.cumulativeConsumeItemScrollAtOnce
end

function OBTSerialConsumeItemView:start()
     self.rewardBtn:regOnButtonClick(function()
        self:OnRewardBtnClick()
    end)
end

-- state = 0 时表示可以领取奖励
function OBTSerialConsumeItemView:InitRewardButtonState(state)
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

function OBTSerialConsumeItemView:RefreshTextContentAndButtonState()
    self:InitRewardButtonState(self.obtSerialConsumeModel:GetRewardStatusByIndex(self.index))
end

function OBTSerialConsumeItemView:OnRewardBtnClick()
    if self.onRewardBtnClick then
        self:onRewardBtnClick()
    end
end

function OBTSerialConsumeItemView:InitView(obtSerialConsumeModel, index, parentScrollRect)
    self.obtSerialConsumeModel = obtSerialConsumeModel
    self.index = index
    res.ClearChildren(self.cumulativeConsumeItemScrollAtOnce.gameObject.transform)
    self.payTipText.text = obtSerialConsumeModel:GetPayDescByIndex(index)
    local rewardParams = {
        parentObj = self.parentRect,
        rewardData = obtSerialConsumeModel:GetRewardData()[index].contents,
        isShowName = false,
        isReceive = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = true,
    }
    self.cumulativeConsumeItemScrollAtOnce.scrollRectInParent = parentScrollRect

    RewardDataCtrl.new(rewardParams)
end

return OBTSerialConsumeItemView