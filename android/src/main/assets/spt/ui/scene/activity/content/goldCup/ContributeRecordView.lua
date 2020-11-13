local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local ContributeRecordView = class(unity.base)

local CURRENCY = {
    d = "d",
    bkd = "bkd",
}
function ContributeRecordView:ctor()
    self.diaTxt = self.___ex.diaTxt
    self.bkdTxt = self.___ex.bkdTxt
    self.closeBtn = self.___ex.closeBtn

    DialogAnimation.Appear(self.transform, nil)
    self.closeBtn:regOnButtonClick(function()
        self:Close()
    end)
end

function ContributeRecordView:InitView(goldCupModel)
    self.goldCupModel = goldCupModel

    self.diaTxt.text = self.goldCupModel:GetContributeStr(CURRENCY.d)
    self.bkdTxt.text = self.goldCupModel:GetContributeStr(CURRENCY.bkd)
end

function ContributeRecordView:Close()
    if type(self.closeDialog) == "function" then
        DialogAnimation.Disappear(self.transform, nil, function()
            self.closeDialog()
        end)
    end
end

return ContributeRecordView