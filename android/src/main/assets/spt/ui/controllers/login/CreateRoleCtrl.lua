local LoginModel = require("ui.models.login.LoginModel")
local CreateRoleCtrl = class()

function CreateRoleCtrl:ctor()
    local dialog, dialogcomp = res.ShowDialog("Assets/CapstonesRes/Game/UI/Scene/Login/CreateRoleView.prefab", "camera")  
    self.view = dialogcomp.contentcomp

    self.view:RegOnCreateClick(function ()
        clr.coroutine(function()
            local account = LoginModel.GetAccount()
            local aid = account.aid
            local name = self:GetRoleName()
            local tid = "c101"
            local response = req.create(aid, name, tid)
            if api.success(response) then
                local playerInfo = response.val
                api.setToken(playerInfo["token"])
                res.ChangeScene("ui.controllers.home.HomeMainCtrl")
            end
        end)
    end)
end

function CreateRoleCtrl:SetRoleName(name)
    self.view:SetRoleName(name)
end

function CreateRoleCtrl:GetRoleName()
    return self.view:GetRoleName()
end

function CreateRoleCtrl:Close()
    self.view:Close()
end

return CreateRoleCtrl
