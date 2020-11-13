local LoginModel = require("ui.models.login.LoginModel")
local AccountCtrl = class()

function AccountCtrl:ctor()
    local dialog, dialogcomp = res.ShowDialog("Assets/CapstonesRes/Game/UI/Scene/Login/AccountView.prefab", "camera")
    self.view = dialogcomp.contentcomp

    self.view:RegOnLoginClick(function ()
        clr.coroutine(function()
            local email = tostring(self:GetAccountName())
            local pwd = tostring(self:GetPassword())
            local response = req.eBind(email, pwd)
            if api.success(response) then
                self:Close()
                if type(self.loginCallback) == "function" then
                    self.loginCallback()
                end
            end
        end)
    end)

    local account = LoginModel.GetAccount()
    if account then
        local email = account["cuid"]
        if email then
            self:SetAccountName(email)
        end
    end
end

function AccountCtrl:SetAccountName(name)
    self.view:SetAccountName(name)
end

function AccountCtrl:GetAccountName()
    return self.view:GetAccountName()
end

function AccountCtrl:SetPassword(password)
    self.view:SetPassword(password)
end

function AccountCtrl:GetPassword()
    return self.view:GetPassword()
end

function AccountCtrl:RegAfterLoginClick(func)
    if type(func) == "function" then
        self.loginCallback = func
    end
end

function AccountCtrl:Close()
    self.view:Close()
end

return AccountCtrl
