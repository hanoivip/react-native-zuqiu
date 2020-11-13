local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local EnergyDrinkRewardView = class(unity.base)

function EnergyDrinkRewardView:ctor()
--------Start_Auto_Generate--------
    self.titleTxt = self.___ex.titleTxt
    self.tipsTxt = self.___ex.tipsTxt
    self.effect1Go = self.___ex.effect1Go
    self.effect1Txt = self.___ex.effect1Txt
    self.effect2Go = self.___ex.effect2Go
    self.effect2Txt = self.___ex.effect2Txt
    self.startBtn = self.___ex.startBtn
    self.closeBtnSpt = self.___ex.closeBtnSpt
--------End_Auto_Generate----------
end

function EnergyDrinkRewardView:start()
	DialogAnimation.Appear(self.transform)
    self.closeBtnSpt:regOnButtonClick(function()
        self:Close()
    end)
    self.startBtn:regOnButtonClick(function()
        self:OnStartClick()
    end)
end

function EnergyDrinkRewardView:Close()
    DialogAnimation.Disappear(self.transform, nil, self.closeDialog)
end

function EnergyDrinkRewardView:OnStartClick()
    self:Close()
end

function EnergyDrinkRewardView:InitView(eventModel)
    self.eventModel = eventModel
    self.titleTxt.text = eventModel:GetEventName()
    local rewardBuff = eventModel:GetDrinkBuff()
    local isUp = rewardBuff.buff > 0
    local buffNum = math.abs(rewardBuff.buff)
    local round = rewardBuff.round

    if isUp then
        self.tipsTxt.text = lang.trans("adventure_energy_tip", round)
    else
        self.tipsTxt.text = lang.trans("adventure_energy_debuff", round)
    end

    GameObjectHelper.FastSetActive(self.effect1Go, not isUp)
    GameObjectHelper.FastSetActive(self.effect2Go, isUp)
    self.effect1Txt.text = lang.transstr("allAttribute") .. "-" .. buffNum .. "%"
    self.effect2Txt.text = lang.transstr("allAttribute") .. "+" .. buffNum .. "%"
end

return EnergyDrinkRewardView
