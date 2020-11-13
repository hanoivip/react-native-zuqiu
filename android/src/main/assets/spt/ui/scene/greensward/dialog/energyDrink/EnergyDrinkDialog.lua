local UnityEngine = clr.UnityEngine
local Color = UnityEngine.Color
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local ColorConversionHelper = require("ui.common.ColorConversionHelper")
local EnergyDrinkDialog = class(unity.base)

function EnergyDrinkDialog:ctor()
--------Start_Auto_Generate--------
    self.titleTxt = self.___ex.titleTxt
    self.tipsTxt = self.___ex.tipsTxt
    self.effect1Go = self.___ex.effect1Go
    self.effect1Txt = self.___ex.effect1Txt
    self.effect2Go = self.___ex.effect2Go
    self.effect2Txt = self.___ex.effect2Txt
    self.startBtn = self.___ex.startBtn
    self.consumeCountTxt = self.___ex.consumeCountTxt
    self.moraleGo = self.___ex.moraleGo
    self.fightGo = self.___ex.fightGo
    self.closeBtnSpt = self.___ex.closeBtnSpt
--------End_Auto_Generate----------
end

local UpColor = Color(0.78, 0.93, 0.33)
local DownColor = Color(0.96, 0.38, 0.38)

function EnergyDrinkDialog:start()
	DialogAnimation.Appear(self.transform)
    self.closeBtnSpt:regOnButtonClick(function()
        self:Close()
    end)
    self.startBtn:regOnButtonClick(function()
        self:OnStartClick()
    end)
end

function EnergyDrinkDialog:Close()
    DialogAnimation.Disappear(self.transform, nil, self.closeDialog)
end

function EnergyDrinkDialog:OnStartClick()
    if self.onStartClick then
        self.onStartClick()
    end
end

function EnergyDrinkDialog:InitView(eventModel)
    self.eventModel = eventModel
    self.titleTxt.text = eventModel:GetEventName()
    local effectDisplay = eventModel:GetEnergyDrinkEffectDisplay()
    for i, v in ipairs(effectDisplay) do
        local txtName = "effect" .. i .. "Txt"
        local symbol = ""
        if tonumber(v) > 0 then
            symbol = "+"
            self[txtName].color = UpColor
        else
            self[txtName].color = DownColor
        end
        self[txtName].text = lang.transstr("allAttribute") .. " " .. symbol .. v .. "%"
    end
    self:SetConsumeBtn()
end

function EnergyDrinkDialog:SetConsumeBtn()
    local moraleState = self.eventModel:ConsumeByMorale()
    local powerState = self.eventModel:ConsumeByPower()
    local count = 0
    local color = self.consumeCountTxt.color
    if moraleState then
        local starSymbol = 0
        count, starSymbol = self.eventModel:GetConsumeMorale()
        local r, g, b = self.eventModel:GetConvertColor(starSymbol)
        color = ColorConversionHelper.ConversionColor(r, g, b)
    elseif powerState then
        count = self.eventModel:GetConsumeFight()
    end
    GameObjectHelper.FastSetActive(self.fightGo, powerState)
    GameObjectHelper.FastSetActive(self.moraleGo, moraleState)
    self.consumeCountTxt.text = "x" .. count
    self.consumeCountTxt.color = color
end

return EnergyDrinkDialog
