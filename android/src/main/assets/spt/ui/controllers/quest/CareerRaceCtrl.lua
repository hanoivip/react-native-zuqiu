local Timer = require('ui.common.Timer')
local BaseCtrl = require("ui.controllers.BaseCtrl")
local CareerRaceCtrl = class(BaseCtrl, "CareerRaceCtrl")

CareerRaceCtrl.dialogStatus = {
    touchClose = false,
    withShadow = true,
    unblockRaycast = false,
}

CareerRaceCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Quest/CareerRace.prefab"

function CareerRaceCtrl:ctor()
end

function CareerRaceCtrl:Init(activityModel)
	self.activityModel = activityModel
    self.view:InitView(self.activityModel)
end

function CareerRaceCtrl:UpdateResidualTimeText(residualSeconds)
    local residualSeconds = tonumber(residualSeconds)
    if self.countDownTimer ~= nil then self.countDownTimer:Destroy() end
    self.countDownTimer = Timer.new(residualSeconds, function(time)
        local str = self.activityModel:ConvertSecondsToDayAndHour(time) 
        self.view.countDownText.text = str
        if time <= 0 then
            self.activityModel:SetIsActivityEnd(true)
            EventSystem.SendEvent("ChangeCareerRaceRewardItemButtonState")            
        end
    end)
end

function CareerRaceCtrl:OnEnterScene()
    local residualTime = self.activityModel:GetResidualTime()
    self:UpdateResidualTimeText(residualTime)
end

function CareerRaceCtrl:OnExitScene()
	if self.countDownTimer ~= nil then
		self.countDownTimer:Destroy()
	end
end

return CareerRaceCtrl