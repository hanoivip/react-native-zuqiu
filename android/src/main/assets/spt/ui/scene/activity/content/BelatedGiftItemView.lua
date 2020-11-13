local UnityEngine = clr.UnityEngine
local Button = UnityEngine.UI.Button
local Text = UnityEngine.UI.Text
local GameObjectHelper = require("ui.common.GameObjectHelper")
local ColorConversionHelper = require("ui.common.ColorConversionHelper")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")

local BelatedGiftItemView = class(unity.base)

function BelatedGiftItemView:ctor()
    self.rewardBtn = self.___ex.rewardBtn
    self.rewardBtnCompnent = self.___ex.rewardBtnCompnent
    self.gradientText = self.___ex.gradientText
    self.rewardTxt = self.___ex.rewardTxt
    self.finishIcon = self.___ex.finishIcon
    self.overTimeIcon = self.___ex.overTimeIcon
    self.lastValue = self.___ex.lastValue
    self.currValue = self.___ex.currValue
    self.moneyArea = self.___ex.moneyArea
    self.rewardBtnEffect = self.___ex.rewardBtnEffect
    self.lastTime = self.___ex.lastTime
    self.titleWord = self.___ex.titleWord
end

function BelatedGiftItemView:start()
    self.rewardBtn:regOnButtonClick(function()
        self:OnRewardBtnClick()
    end)
end

--status = -1 不能领取, = 0 可以领取,  =1  已领取
function BelatedGiftItemView:InitRewardButtonState()
    local state = self.itemData.state or 1
    if state == -1 then
        local str = lang.trans("receive")
        self.rewardTxt.text = self.itemData.isOverTime and lang.transstr("belatedGift_item_nil_time") or lang.trans("receive")
        self:SetButtonState(false)
        GameObjectHelper.FastSetActive(self.rewardBtn.gameObject, true)
        GameObjectHelper.FastSetActive(self.finishIcon, false)
        GameObjectHelper.FastSetActive(self.lastValue.gameObject, false)
        GameObjectHelper.FastSetActive(self.currValue.gameObject, true)
        self:IsOverTimeIcon(self.itemData.isOverTime)
    elseif state == 1 then
        GameObjectHelper.FastSetActive(self.rewardBtn.gameObject, false)
        GameObjectHelper.FastSetActive(self.finishIcon, true)
        GameObjectHelper.FastSetActive(self.lastValue.gameObject, true)
        GameObjectHelper.FastSetActive(self.currValue.gameObject, false)
        self.lastTime.text = ""
    elseif state == 0 then
        self.rewardTxt.text = lang.trans("receive")
        self.rewardBtn:onPointEventHandle(true)
        GameObjectHelper.FastSetActive(self.rewardBtn.gameObject, true)
        GameObjectHelper.FastSetActive(self.finishIcon, false)
        GameObjectHelper.FastSetActive(self.lastValue.gameObject, false)
        GameObjectHelper.FastSetActive(self.currValue.gameObject, true)
        self:IsOverTimeIcon(self.itemData.isOverTime)
    end
end

function BelatedGiftItemView:IsOverTimeIcon(flag)
    if flag then
        GameObjectHelper.FastSetActive(self.overTimeIcon, true)
        GameObjectHelper.FastSetActive(self.rewardBtn.gameObject, false)
        GameObjectHelper.FastSetActive(self.finishIcon, false)
        GameObjectHelper.FastSetActive(self.currValue.gameObject, false)
        GameObjectHelper.FastSetActive(self.lastValue.gameObject, true)
        self.lastTime.text = ""
    else
        GameObjectHelper.FastSetActive(self.overTimeIcon, false)
        self.lastTime.text = self.itemData.endTimes
    end
end

function BelatedGiftItemView:SetButtonState(isOpen)
    self.rewardBtn:onPointEventHandle(isOpen)
    self.rewardBtnCompnent.interactable = isOpen
    self.rewardBtnEffect:SetActive(isOpen)
    local r, g, b 
    self.gradientText.enabled = isOpen
    if isOpen then 
        r, g, b = 145, 125, 86
    else
        r, g, b = 125, 125, 125
    end
    local color = ColorConversionHelper.ConversionColor(r, g, b)
    self.rewardTxt.color = color
end

function BelatedGiftItemView:OnRewardBtnClick()
    if self.onRewardBtnClick then
        self.onRewardBtnClick(self.itemData.subID, function ()
            self.itemData.state = 1
            self:InitRewardButtonState()
        end)
    end
end

function BelatedGiftItemView:InitView(itemData)
    self.itemData = itemData
    self:InitRewardButtonState()
    res.ClearChildren(self.moneyArea.transform)
    local rewardParams = {
        parentObj = self.moneyArea,
        rewardData = itemData.contents,
        isShowName = false,
        isReceive = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = true,
        hideCount = true,
    }
    self.lastValue.text = "x" .. self.itemData.rewardValue
    self.currValue.text = "x" .. self.itemData.rewardValue
    self.titleWord.text = self.itemData.titleWord
    RewardDataCtrl.new(rewardParams)
end

return BelatedGiftItemView
