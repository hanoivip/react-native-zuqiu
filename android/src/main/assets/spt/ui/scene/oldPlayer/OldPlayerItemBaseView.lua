local GameObjectHelper = require("ui.common.GameObjectHelper")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local ColorConversionHelper = require("ui.common.ColorConversionHelper")
local OldPlayerItemBaseView = class(unity.base)

function OldPlayerItemBaseView:ctor()
    self.rewardArea = self.___ex.rewardArea
    self.recvBtn = self.___ex.recvBtn
    self.recvText = self.___ex.recvText
    self.recvBtnCompnent = self.___ex.recvBtnCompnent
    self.recvBtnEffect = self.___ex.recvBtnEffect
    self.gradientText = self.___ex.gradientText
    self.finishObj = self.___ex.finishObj
end

function OldPlayerItemBaseView:InitView(itemData)
    res.ClearChildren(self.rewardArea.transform)
    local rewardParams = {
        parentObj = self.rewardArea,
        rewardData = itemData.contents,
        isShowName = false,
        isReceive = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = true,
        hideCount = false,
    }
    RewardDataCtrl.new(rewardParams)
    self:InitRewardButtonState(itemData.status)
end

function OldPlayerItemBaseView:InitRewardButtonState(state)
    if state == -1 then
        self:SetButtonState(false)
        GameObjectHelper.FastSetActive(self.recvBtn.gameObject, true)
        GameObjectHelper.FastSetActive(self.finishObj, false)
    elseif state == 1 then
        GameObjectHelper.FastSetActive(self.recvBtn.gameObject, false)
        GameObjectHelper.FastSetActive(self.finishObj, true)
    elseif state == 0 then
        self:SetButtonState(true)
        GameObjectHelper.FastSetActive(self.recvBtn.gameObject, true)
        GameObjectHelper.FastSetActive(self.finishObj, false)
    end
end

function OldPlayerItemBaseView:SetButtonState(isOpen)
    self.recvBtn:onPointEventHandle(isOpen)
    self.recvBtnCompnent.interactable = isOpen
    self.recvBtnEffect:SetActive(isOpen)
    local r, g, b 
    self.gradientText.enabled = isOpen
    if isOpen then 
        r, g, b = 145, 125, 86
    else
        r, g, b = 125, 125, 125
    end
    local color = ColorConversionHelper.ConversionColor(r, g, b)
    self.recvText.color = color
end

return OldPlayerItemBaseView
