local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")

local ShowGirlView = class(unity.base)

function ShowGirlView:ctor()
    self.closeBtn = self.___ex.closeBtn
    self.notCharged = self.___ex.notCharged
    self.charged = self.___ex.charged
    self.priceText = self.___ex.priceText
    self.qqText = self.___ex.qqText
    self.chargeBtn = self.___ex.chargeBtn
    self.contactBtn = self.___ex.contactBtn

    DialogAnimation.Appear(self.transform, nil)
end

function ShowGirlView:InitView(model)
    self.model = model

    local charged = model:Charged()
    self.charged:SetActive(charged)
    self.notCharged:SetActive(not charged)

    self.qqText.text = tostring(model.data.GsSetting.QQ)
    self.priceText.text = tostring(model.data.GsSetting.singlePayAmount)

    self.closeBtn:regOnButtonClick(
        function()
            self:Close()
        end
    )

    self.chargeBtn:regOnButtonClick(
        function()
            if self.chargeBtnClick then
                self.chargeBtnClick()
            end
        end
    )

    self.contactBtn:regOnButtonClick(
        function()
            if self.contactBtnClick then
                self.contactBtnClick()
            end
        end
    )
end

function ShowGirlView:OnEnterScene()
end

function ShowGirlView:OnExitScene()
end

function ShowGirlView:Close()
    if type(self.closeDialog) == "function" then
        DialogAnimation.Disappear(
            self.transform,
            nil,
            function()
                self.closeDialog()
            end
        )
    end
end

return ShowGirlView
