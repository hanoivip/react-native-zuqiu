local UnityEngine = clr.UnityEngine
local Button = UnityEngine.UI.Button
local Text = UnityEngine.UI.Text
local GameObjectHelper = require("ui.common.GameObjectHelper")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")

local CumulativePayItemView = class(unity.base)

function CumulativePayItemView:ctor()
    self.parentRect = self.___ex.parentRect
    self.rewardBtn = self.___ex.rewardBtn
    self.rewardBtnDiable = self.___ex.rewardBtnDiable
    self.finishIcon = self.___ex.finishIcon
    self.payTipText = self.___ex.payTipText
    self.diamondNumberText1 = self.___ex.diamondNumberText1
    self.diamondNumberText2 = self.___ex.diamondNumberText2
    self.defaultBgObj = self.___ex.defaultBgObj
    self.specialBgObj = self.___ex.specialBgObj
    self.specialTipObj = self.___ex.specialTipObj
    self.cornerTipTxt = self.___ex.cornerTipTxt
    self.cumulativeConsumeItemScrollAtOnce = self.___ex.cumulativeConsumeItemScrollAtOnce
end

function CumulativePayItemView:start()
     self.rewardBtn:regOnButtonClick(function()
        self:OnRewardBtnClick()
    end)
end

-- state = 0 时表示可以领取奖励
function CumulativePayItemView:InitRewardButtonState(state)
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

function CumulativePayItemView:RefreshTextContentAndButtonState(consumeDiamondNumber)
    self.diamondNumberText.text = tostring(self.cumulativePayModel:GetConsumeDiamondNumberByIndex(self.index)) .. "/"
        .. tostring(self.cumulativePayModel:GetRewardConditionByIndex(self.index))

    self:InitRewardButtonState(self.cumulativePayModel:GetRewardStatusByIndex(self.index))
end

function CumulativePayItemView:OnRewardBtnClick()
    if self.onRewardBtnClick then
        self:onRewardBtnClick()
    end
end

function CumulativePayItemView:InitView(cumulativePayModel, index, parentScrollRect)
    self.cumulativePayModel = cumulativePayModel
    self.index = index
    self:SelectItemShowType()
    res.ClearChildren(self.cumulativeConsumeItemScrollAtOnce.gameObject.transform)
    local rewardParams = {
        parentObj = self.parentRect,
        rewardData = cumulativePayModel:GetRewardData()[index].contents,
        isShowName = false,
        isReceive = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = true,
    }
    self.cumulativeConsumeItemScrollAtOnce.scrollRectInParent = parentScrollRect
    self.diamondNumberText.text = tostring(cumulativePayModel:GetConsumeDiamondNumberByIndex(index)) .. "/"
        .. tostring(cumulativePayModel:GetRewardConditionByIndex(index))

    RewardDataCtrl.new(rewardParams)
end

function CumulativePayItemView:SelectItemShowType()
    local isShowDefaultItemBg = self.cumulativePayModel:IsShowDefaultItemBg(self.index)
    GameObjectHelper.FastSetActive(self.defaultBgObj, isShowDefaultItemBg)
    GameObjectHelper.FastSetActive(self.payTipText.gameObject, isShowDefaultItemBg)
    GameObjectHelper.FastSetActive(self.specialBgObj, not isShowDefaultItemBg)
    GameObjectHelper.FastSetActive(self.specialTipObj, not isShowDefaultItemBg)
    self.diamondNumberText = isShowDefaultItemBg and self.diamondNumberText1 or self.diamondNumberText2
    if not isShowDefaultItemBg then
        self.cornerTipTxt.text = self.cumulativePayModel:GetCornerTipByIndex(self.index)
    end
end

return CumulativePayItemView