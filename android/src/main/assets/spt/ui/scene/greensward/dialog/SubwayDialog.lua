local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local ColorConversionHelper = require("ui.common.ColorConversionHelper")
local SubwayDialog = class(unity.base)

function SubwayDialog:ctor()
--------Start_Auto_Generate--------
    self.titleAreaGo = self.___ex.titleAreaGo
    self.titleTxt = self.___ex.titleTxt
    self.unlockTxt = self.___ex.unlockTxt
    self.descTxt = self.___ex.descTxt
    self.eventBtn = self.___ex.eventBtn
    self.moraleNumTxt = self.___ex.moraleNumTxt
    self.leaveBtn = self.___ex.leaveBtn
    self.closeBtnSpt = self.___ex.closeBtnSpt
--------End_Auto_Generate----------
end

function SubwayDialog:start()
	DialogAnimation.Appear(self.transform)
    self.closeBtnSpt:regOnButtonClick(function()
        self:Close()
    end)
    self.eventBtn:regOnButtonClick(function()
        self:EventTrigger()
    end)
    self.leaveBtn:regOnButtonClick(function()
        self:Close()
    end)
end

function SubwayDialog:EventTrigger()
    if self.eventClick then 
		self.eventClick()
	end
end

function SubwayDialog:Close()
    DialogAnimation.Disappear(self.transform, nil, self.closeDialog)
end

function SubwayDialog:InitView(eventModel)
	self.titleTxt.text = eventModel:GetEventName()
	local blockPoint = eventModel:GetBlockPoint()
	self.unlockTxt.text = lang.trans("unlock_terrain_condition", blockPoint)
	self.descTxt.text = eventModel:GetContentText()
	self.descTxt.text = self:GetContentText()
    local consumeMorale, starSymbol = eventModel:GetConsumeMorale()
    self.moraleNumTxt.text = "x" .. tostring(consumeMorale or 0)
    local r, g, b = eventModel:GetConvertColor(starSymbol)
    self.moraleNumTxt.color = ColorConversionHelper.ConversionColor(r, g, b)
end

return SubwayDialog
