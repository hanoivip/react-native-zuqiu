local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local LotteryRewardView = class(unity.base)

function LotteryRewardView:ctor()
--------Start_Auto_Generate--------
    self.titleTxt = self.___ex.titleTxt
    self.contentTxt = self.___ex.contentTxt
    self.closeBtnSpt = self.___ex.closeBtnSpt
--------End_Auto_Generate----------
end

function LotteryRewardView:start()
	DialogAnimation.Appear(self.transform)
    self.closeBtnSpt:regOnButtonClick(function()
        self:Close()
    end)
end

function LotteryRewardView:Close()
    DialogAnimation.Disappear(self.transform, nil, function() self.closeDialog() end)
end

function LotteryRewardView:InitView(eventModel)
    local content = eventModel:GetLotteryRewardDesc()
    self.contentTxt.text = content
end

return LotteryRewardView
