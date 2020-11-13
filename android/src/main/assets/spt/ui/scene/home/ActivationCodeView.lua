local ActivationCodeView = class(unity.base)

function ActivationCodeView:ctor()
    self.inputArea = self.___ex.inputArea
    self.confirmBtn = self.___ex.confirmBtn
    self.closeBtn = self.___ex.closeBtn
end

function ActivationCodeView:start()
    self.closeBtn:regOnButtonClick(function()
        if type(self.closeDialog) == "function" then
            self.closeDialog()
        end
    end)

    self.confirmBtn:regOnButtonClick(function()
        self:coroutine(function()
            local code = self.inputArea.text
            local data = {code = code}
            local response = req.activationCode(data)
            if api.success(response) then
                if type(self.closeDialog) == "function" then
                    self.closeDialog()
                end
            end
        end)
    end)
end

return ActivationCodeView