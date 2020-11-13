local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local VIP = require("data.VIP")
local GreenswardMoraleView = class(unity.base)

function GreenswardMoraleView:ctor()
    self.closeScript = self.___ex.closeScript
    self.countText = self.___ex.countText
    self.costDiamondText = self.___ex.costDiamondText
    self.buyButtonScript = self.___ex.buyButtonScript
    self.buyButton = self.___ex.buyButton
    self.displayArea = self.___ex.displayArea
    self.canvasGroup = self.___ex.canvasGroup
    self.buttonArea = self.___ex.buttonArea
    self.vipButtonArea = self.___ex.vipButtonArea
    self.goVIPBtn = self.___ex.goVIPBtn
    self.cancelBtn = self.___ex.cancelBtn
    self.desc = self.___ex.desc
    self.couldBuyCount = 0
end

function GreenswardMoraleView:InitView(buildModel)
    local adventureBaseData = buildModel:GetAdventureBaseData()
    local playerInfo = buildModel:GetPlayerInfo()
    local moraleBuyNum = buildModel:GetMoraleBuyNum()
    local vipLvl = playerInfo:GetVipLevel()
    self.vipLvl = tonumber(vipLvl)
    local vipData = VIP[tonumber(vipLvl) + 1]
    local totalCount = vipData and vipData.advMorale or 1
    local maxCount = VIP[#VIP] and VIP[#VIP].advMorale or 1

    local couldBuyCount = tonumber(totalCount) - tonumber(moraleBuyNum)
    local costDiamond = adventureBaseData.purchaseMoralePrice[moraleBuyNum + 1]
    self.costDiamondText.text = " x " .. tostring(costDiamond)
    local purchaseMorale = adventureBaseData.purchaseMorale or 0
    local haveTimes = couldBuyCount > 0
    self.desc.text = lang.trans("buyMoraleDesc", purchaseMorale)
    local havaVipCount = (maxCount - totalCount) > 0
    if haveTimes then
        self.countText.text = lang.trans("today_buy", couldBuyCount, totalCount)
    elseif havaVipCount then
        self.countText.text = lang.transstr("not_have_buy_morale_times") .. "\n" .. lang.transstr("vip_tip")
    else
        self.countText.text = lang.trans("not_have_buy_morale_times")
    end
    GameObjectHelper.FastSetActive(self.buttonArea, haveTimes)
    GameObjectHelper.FastSetActive(self.vipButtonArea, not haveTimes and havaVipCount)
    self.couldBuyCount = couldBuyCount
    GameObjectHelper.FastSetActive(self.displayArea, true)
end

function GreenswardMoraleView:start()
    DialogAnimation.Appear(self.transform, self.canvasGroup)
    self.closeScript:regOnButtonClick(function()
        self:Close()
    end)
    self.buyButtonScript:regOnButtonClick(function()
        if self.couldBuyCount > 0 then
            if self.onMoraleBuyClick then
                self.onMoraleBuyClick()
            end
        end
    end)
    self.cancelBtn:regOnButtonClick(function()
        if self.onCancelClick then
            self.onCancelClick()
        end
    end)
    self.goVIPBtn:regOnButtonClick(function()
        if self.onVipClick then
            self.onVipClick(self.vipLvl)
        end
    end)
end

function GreenswardMoraleView:Close()
    DialogAnimation.Disappear(self.transform, self.canvasGroup, function()
        if type(self.closeDialog) == 'function' then
            self.closeDialog()
        end
    end)
end

return GreenswardMoraleView