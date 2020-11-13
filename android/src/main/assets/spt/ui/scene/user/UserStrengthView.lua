local UnityEngine = clr.UnityEngine
local UI = UnityEngine.UI
local Time = UnityEngine.Time
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local UserStrengthView = class(unity.base)

function UserStrengthView:ctor()
    self.closeScript = self.___ex.closeScript
    self.countText = self.___ex.countText
    self.costDiamondText = self.___ex.costDiamondText
    self.buyButtonScript = self.___ex.buyButtonScript
    self.buyButton = self.___ex.buyButton
    self.displayArea = self.___ex.displayArea
    self.canvasGroup = self.___ex.canvasGroup
    self.vipButtonArea = self.___ex.vipButtonArea
    self.buttonArea = self.___ex.buttonArea
    self.goVIPBtn = self.___ex.goVIPBtn
    self.cancleBtn = self.___ex.cancleBtn
    self.jumpBtn = self.___ex.jumpBtn
    self.activity = self.___ex.activity
    self.allSpRecoverTime = self.___ex.allSpRecoverTime
    self.couldBuyCount = 0
    self.costDiamond = 0
end
------------
-- 球员购买体力固定为120
------------
local DefaultBuyStrength = 120
function UserStrengthView:InitView(buyCount, totalCount, costDiamond, playerInfoModel)
    self.costDiamond = costDiamond
    self.couldBuyCount = tonumber(totalCount) - tonumber(buyCount)
    self.costDiamondText.text = " x " .. tostring(costDiamond)
    local haveTimes = self.couldBuyCount > 0
    if haveTimes then
        self.countText.text = lang.trans("today_buy", self.couldBuyCount, totalCount)
    else
        if PlayerInfoModel.new():GetVipLevel() == 14 then
            self.countText.text = lang.trans("not_have_buy_strongth_times")
            self.buyButton.interactable = false
            self.costDiamondText.text = "x" .. tostring(0)
        else
            self.countText.text = lang.transstr("not_have_buy_strongth_times") .. "\n" .. lang.transstr("vip_tip")
        end
    end
    self.displayArea:SetActive(true)
    self:UpdateDisplayArea(playerInfoModel:GetVipLevel() == 14 or haveTimes)
    self.allSpRecoverTime.gameObject:SetActive(false)
end

function UserStrengthView:start()
    DialogAnimation.Appear(self.transform, self.canvasGroup)
    self.closeScript:regOnButtonClick(function()
        self:Close()
    end)
    self.buyButtonScript:regOnButtonClick(function()
        if self.couldBuyCount > 0 then
            self:BuyStrength(self.costDiamond)
        end
    end)
    self.goVIPBtn:regOnButtonClick(function ()
        res.PushDialog("ui.controllers.charge.ChargeAndVIPCtrl","vip", PlayerInfoModel.new():GetVipLevel() + 1)
        self:Close()
    end)
    self.cancleBtn:regOnButtonClick(function ()
        self:Close()
    end)
    self.jumpBtn:regOnButtonClick(function ()
        res.PushScene("ui.controllers.activity.ActivityCtrl", "RewardDouble")
    end)
end

function UserStrengthView:UpdateStrengthView(sp, nextTime, fullTime)
    local spRecorverNextTime = nextTime
    local spRecorverFullTime = fullTime
    if spRecorverFullTime > 0 then
        self:coroutine(function()
            while spRecorverNextTime > 0 do
                self:UpdateStrength(sp, spRecorverNextTime, spRecorverFullTime)
                spRecorverNextTime = spRecorverNextTime - Time.unscaledDeltaTime
                spRecorverFullTime = spRecorverFullTime - Time.unscaledDeltaTime
                coroutine.yield()
            end
        end)
    else
        self:UpdateStrength(sp, 0, 0)
    end
end

function UserStrengthView:UpdateStrength(sp, spRecorverNextTime, spRecorverFullTime)
    -- local nextTime = spRecorverNextTime and string.formatTimeClock(spRecorverNextTime, 3600)
    local fullTime = spRecorverFullTime and string.formatTimeClock(spRecorverFullTime, 3600)
    self.allSpRecoverTime.text = lang.trans("buyStrengthAllRecoverTime", fullTime)
    self.allSpRecoverTime.gameObject:SetActive(spRecorverFullTime > 0)
end

function UserStrengthView:Close()
    DialogAnimation.Disappear(self.transform, self.canvasGroup, function()
        if type(self.closeDialog) == 'function' then
            self.closeDialog()
        end
    end)
end

function UserStrengthView:BuyStrength(costDiamond)
end

function UserStrengthView:UpdateDisplayArea(haveTimes)
    GameObjectHelper.FastSetActive(self.buttonArea, haveTimes)
    GameObjectHelper.FastSetActive(self.vipButtonArea, not haveTimes)
end

return UserStrengthView
