local DialogAnimation = require("ui.control.dialog.DialogAnimation")

local TimeLimitGoldBallAdvanceConfirmView = class(unity.base, "TimeLimitGoldBallAdvanceConfirmView")

function TimeLimitGoldBallAdvanceConfirmView:ctor()
    -- 标题
    self.txtTitle = self.___ex.txtTitle
    -- 关闭按钮
    self.btnClose = self.___ex.btnClose
    -- canvasGroup
    self.canvasGroup = self.___ex.canvasGroup
    -- 面板的Rect Transform
    self.rctBoard = self.___ex.rctBoard
    -- 确认
    self.btnConfirm = self.___ex.btnConfirm
    self.txtConfirm = self.___ex.txtConfirm
end

function TimeLimitGoldBallAdvanceConfirmView:start()
    self:RegBtnEvent()
    DialogAnimation.Appear(self.transform, self.canvasGroup)
end

function TimeLimitGoldBallAdvanceConfirmView:InitView(timeLimitGoldBallModel)
    local priceStr = string.formatNumWithUnit(timeLimitGoldBallModel:GetAdvancePrice())
    local priceTypeStr = timeLimitGoldBallModel:GetAdvancePriceTypeStr()
    self.txtConfirm.text = lang.trans("time_limit_gold_buyadvance_confirm", priceStr, priceTypeStr)
end

function TimeLimitGoldBallAdvanceConfirmView:RefreshView()
end

function TimeLimitGoldBallAdvanceConfirmView:RegBtnEvent()
    self.btnClose:regOnButtonClick(function()
        self:Close()
    end)
    self.btnConfirm:regOnButtonClick(function()
        self:OnBtnConfirm()
    end)
end

function TimeLimitGoldBallAdvanceConfirmView:Close()
    local callback = function()
        if type(self.closeDialog) == "function" then
            self.closeDialog()
        end
    end
    DialogAnimation.Disappear(self.transform, nil, callback)
end

function TimeLimitGoldBallAdvanceConfirmView:OnBtnConfirm()
    EventSystem.SendEvent("TimeLimit_GoldBall_BuyAdvanceConfirm")
end

return TimeLimitGoldBallAdvanceConfirmView
