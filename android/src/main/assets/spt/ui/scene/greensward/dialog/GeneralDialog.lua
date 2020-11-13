local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local ColorConversionHelper = require("ui.common.ColorConversionHelper")
local GeneralDialog = class(unity.base)

function GeneralDialog:ctor()
--------Start_Auto_Generate--------
    self.bgImg = self.___ex.bgImg
    self.bgImg = self.___ex.bgImg
    self.titleTxt = self.___ex.titleTxt
    self.descTxt = self.___ex.descTxt
    self.starEffectGo = self.___ex.starEffectGo
    self.starEffectTipsTxt = self.___ex.starEffectTipsTxt
    self.moraleBtn = self.___ex.moraleBtn
    self.iconImg = self.___ex.iconImg
    self.moraleNumTxt = self.___ex.moraleNumTxt
    self.moraleDescTxt = self.___ex.moraleDescTxt
    self.poweBtn = self.___ex.poweBtn
    self.iconImg = self.___ex.iconImg
    self.powerNumTxt = self.___ex.powerNumTxt
    self.powerDescTxt = self.___ex.powerDescTxt
    self.itemBtn = self.___ex.itemBtn
    self.itemDescTxt = self.___ex.itemDescTxt
    self.leaveBtn = self.___ex.leaveBtn
    self.leaveDescTxt = self.___ex.leaveDescTxt
--------End_Auto_Generate----------
    self.nameColorComponent = self.___ex.nameColorComponent
    self.itemButton = self.___ex.itemButton
end

function GeneralDialog:start()
	DialogAnimation.Appear(self.transform)
    self.moraleBtn:regOnButtonClick(function()
        self:MoraleTrigger()
    end)
    self.poweBtn:regOnButtonClick(function()
        self:PowerTrigger()
    end)
    self.itemBtn:regOnButtonClick(function()
        self:ItemTrigger()
    end)
    self.leaveBtn:regOnButtonClick(function()
        self:Close()
    end)
end

function GeneralDialog:MoraleTrigger()
    if self.moraleClick then 
		self.moraleClick()
	end
end

function GeneralDialog:PowerTrigger()
    if self.powerClick then 
		self.powerClick()
	end
end

function GeneralDialog:ItemTrigger()
    if self.itemClick then
        self.itemClick(self.hasItem)
    end
end

function GeneralDialog:Close()
    DialogAnimation.Disappear(self.transform, nil, self.closeDialog)
end

function GeneralDialog:InitView(eventModel)
    local bgPath = "Assets/CapstonesRes/Game/UI/Scene/Greensward/DialogImage/Dialog/"
    local name = eventModel:GetBottomBoardName()
    self.bgImg.overrideSprite = res.LoadRes(bgPath .. name .. ".png")
    self.titleTxt.text = eventModel:GetEventName()
    self.descTxt.text = eventModel:GetContentText()
    self.moraleDescTxt.text = eventModel:GetMoraleButtonDesc()
    local consumeMorale, starSymbol = eventModel:GetConsumeMorale()
    self.moraleNumTxt.text = "x" .. tostring(consumeMorale or 0).. ","
    local r, g, b = eventModel:GetConvertColor(starSymbol)
    self.moraleNumTxt.color = ColorConversionHelper.ConversionColor(r, g, b)
    self.powerDescTxt.text = eventModel:GetPowerButtonDesc()
    self.powerNumTxt.text = "x" .. tostring(eventModel:GetConsumeFight() or 0) .. ","

    local leaveButtonDesc = eventModel:GetLeaveButtonDesc()
    self.leaveDescTxt.text = leaveButtonDesc

    local hasMorale = eventModel:ConsumeByMorale()
    local hasPower = eventModel:ConsumeByPower()
    local consumeByItem = eventModel:ConsumeByItem()
    local hasStarEffect, starEffectDesc = eventModel:GetStarEffectCondition()

    local hasLeaveButton = tobool(leaveButtonDesc and leaveButtonDesc ~= "")
    GameObjectHelper.FastSetActive(self.leaveBtn.gameObject, hasLeaveButton)
    GameObjectHelper.FastSetActive(self.moraleBtn.gameObject, hasMorale)
    GameObjectHelper.FastSetActive(self.itemBtn.gameObject, consumeByItem)
    GameObjectHelper.FastSetActive(self.poweBtn.gameObject, hasPower)
    GameObjectHelper.FastSetActive(self.starEffectGo.gameObject, hasStarEffect)

    self.hasItem = false
    if consumeByItem then
        self.itemDescTxt.text = eventModel:GetItemButtonDesc()
        self.hasItem = eventModel:CanConsumeItemFill()
    end
    local itemColor = self.hasItem and ColorConversionHelper.ConversionColor(255, 255, 255, 255) or ColorConversionHelper.ConversionColor(213, 215, 222, 255)
    self.itemButton.interactable = self.hasItem
    self.itemDescTxt.color = itemColor

    if hasStarEffect then
        self.starEffectTipsTxt.text = starEffectDesc
    end

    local nameGradientColor = eventModel:GetDialogTitleColor()
    if nameGradientColor then
        self.nameColorComponent:ResetPointColors(table.nums(nameGradientColor))
        for i, v in ipairs(nameGradientColor) do
            self.nameColorComponent:AddPointColors(v.percent, v.color)
        end
    end
end

function GeneralDialog:ExitScene()
end

return GeneralDialog
