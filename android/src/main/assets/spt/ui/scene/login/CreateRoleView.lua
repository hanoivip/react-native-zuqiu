local CreateRoleView = class(unity.base)

function CreateRoleView:ctor()
    self.roleName = self.___ex.roleName
    self.createButton = self.___ex.createButton
end

function CreateRoleView:SetRoleName(name)
    if type(name) == "string" then
        self.roleName.text = name
    end
end

function CreateRoleView:GetRoleName()
    return self.roleName.text
end

function CreateRoleView:RegOnCreateClick(func)
    if type(func) == "function" then
        self.createButton:regOnButtonClick(func)
    end
end

function CreateRoleView:Close()
    if type(self.closeDialog) == "function" then
        self.closeDialog()
    end
end

return CreateRoleView
