local RewardDataCtrl = require('ui.controllers.common.RewardDataCtrl')
local EventSystem = require("EventSystem")
local Timer = require('ui.common.Timer')
local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")

local FirstPayView = class(unity.base)

function FirstPayView:ctor()
    self.residualTime = self.___ex.residualTime
    self.payButton = self.___ex.payButton
    self.scrollObj = self.___ex.scrollObj
    self.payButtonText = self.___ex.payButtonText
    self.finishIcon = self.___ex.finishIcon
    self.closeBtn = self.___ex.closeBtn

    self.residualTimer = nil
end

function FirstPayView:start()
    self.payButton:regOnButtonClick(function()
        self:OnBtnClick()
    end)
    self.closeBtn:regOnButtonClick(function ()
        self:Close()
    end)
    EventSystem.AddEvent("BuyStoreItem", self, self.ResetPayButtonState)
end

function FirstPayView:OnBtnClick()
    if self.clickPay then
        self:clickPay()
    end
end

function FirstPayView:InitView(firstPayModel, bGuide)
    local rewardParams = {
        parentObj = self.scrollObj,
        rewardData = firstPayModel:GetRewardContents(),
        isShowName = false,
        isReceive = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = true,
    }
    RewardDataCtrl.new(rewardParams)

    if self.residualTimer ~= nil then
        self.residualTimer:Destroy()
    end

    GameObjectHelper.FastSetActive(self.closeBtn.gameObject, bGuide)

    self.residualTimer = Timer.new(firstPayModel:GetRemainTime(), function(time)
        self.residualTime.text = lang.transstr("residual_time") .. string.convertSecondToTime(time)
    end)

    self:InitPayButtonState(firstPayModel:GetRewardStatus())
    if bGuide then
        self:PlayInAnimator()
    end
end

function FirstPayView:ResetPayButtonState()
    self:InitPayButtonState(1)
end

function FirstPayView:InitPayButtonState(status)
    if type(self.initPayButtonState) == "function" then
        self.initPayButtonState(status)
    end
end

function FirstPayView:OnRefresh()
end

function FirstPayView:onDestroy()
    if self.residualTimer ~= nil then
        self.residualTimer:Destroy()
    end
    EventSystem.RemoveEvent("BuyStoreItem", self, self.ResetPayButtonState)
end

function FirstPayView:PlayInAnimator()
    DialogAnimation.Appear(self.transform, self.canvasGroup)
end

function FirstPayView:PlayOutAnimator()
    DialogAnimation.Disappear(self.transform, self.canvasGroup, function() self:CloseView() end)
end

function FirstPayView:CloseView()
    if type(self.closeDialog) == 'function' then
        self.closeDialog()
    end
end

function FirstPayView:Close()
    self:PlayOutAnimator()
end

return FirstPayView