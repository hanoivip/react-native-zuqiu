local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local PlaneDialog = class(unity.base)

function PlaneDialog:ctor()
--------Start_Auto_Generate--------
    self.titleAreaGo = self.___ex.titleAreaGo
    self.titleTxt = self.___ex.titleTxt
    self.unlockTxt = self.___ex.unlockTxt
    self.descTxt = self.___ex.descTxt
    self.flyBtn = self.___ex.flyBtn
    self.flyDescTxt = self.___ex.flyDescTxt
    self.leaveBtn = self.___ex.leaveBtn
    self.leaveDescTxt = self.___ex.leaveDescTxt
    self.closeBtnSpt = self.___ex.closeBtnSpt
--------End_Auto_Generate----------
end

function PlaneDialog:start()
	DialogAnimation.Appear(self.transform)
    self.flyBtn:regOnButtonClick(function()
        self:FlyTrigger()
    end)
    self.leaveBtn:regOnButtonClick(function()
        self:Close()
    end)
end

function PlaneDialog:FlyTrigger()
    if self.flyClick then 
		self.flyClick()
	end
end

function PlaneDialog:Close()
    DialogAnimation.Disappear(self.transform, nil, self.closeDialog)
end

function PlaneDialog:InitView(eventModel)
	local nextFloor = eventModel:GetNextFloor()
	self.titleTxt.text = lang.trans("adventure_plane_fly", nextFloor)
	self.descTxt.text = lang.trans("adventure_plane_desc", nextFloor)
	self.flyDescTxt.text = lang.trans("adventure_plane_buttonDesc1", nextFloor)
	self.leaveDescTxt.text = lang.trans("adventure_plane_buttonDesc2")
end

return PlaneDialog
