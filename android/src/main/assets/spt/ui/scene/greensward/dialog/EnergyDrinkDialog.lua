local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local EnergyDrinkDialog = class(unity.base)

function EnergyDrinkDialog:ctor()
--------Start_Auto_Generate--------
    self.titleTxt = self.___ex.titleTxt
    self.unlockTxt = self.___ex.unlockTxt
    self.tipsTxt = self.___ex.tipsTxt
    self.effectTxt = self.___ex.effectTxt
    self.effect1Go = self.___ex.effect1Go
    self.effect2Go = self.___ex.effect2Go
    self.startBtn = self.___ex.startBtn
    self.closeBtnSpt = self.___ex.closeBtnSpt
--------End_Auto_Generate----------
end

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
    local blockPoint = eventModel:GetBlockPoint()
    self.unlockTxt.text = lang.trans("unlock_terrain_condition", blockPoint)
end

return EnergyDrinkDialog
