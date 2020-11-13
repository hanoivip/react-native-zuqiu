local AccountView = class(unity.base)

function AccountView:ctor()
    self.account = self.___ex.account
    self.password = self.___ex.password
    self.loginButton = self.___ex.loginButton
end

function AccountView:SetAccountName(name)
    if type(name) == "string" then
        self.account.text = name
    end
end

function AccountView:GetAccountName()
    return self.account.text
end

function AccountView:SetPassword(password)
    if type(password) == "string" then
        self.password.text = password
    end
end

function AccountView:GetPassword()
    return self.password.text
end

function AccountView:RegOnLoginClick(func)
    if type(func) == "function" then
        self.loginButton:regOnButtonClick(func)
    end
end

function AccountView:Close()
    if type(self.closeDialog) == "function" then
        self.closeDialog()
    end
end

return AccountView
