local LuaButton = require("ui.control.button.LuaButton")

local ServerItemView = class(LuaButton)

local ServerStatusDict = {
    [1] = "fluent",
    [2] = "normal",
    [3] = "hot",
    [4] = "recommend",
}

function ServerItemView:ctor()
    ServerItemView.super.ctor(self)
    self.serverNum = self.___ex.serverNum
    self.serverName = self.___ex.serverName
    self.status = self.___ex.status
    self.hasRole = self.___ex.hasRole
end

function ServerItemView:Init(serverNumDisplayName, serverName, statusNum, hasRole, index)
    self.index = index
    self.serverNum.text = tostring(serverNumDisplayName)
    self.serverName.text = tostring(serverName)
    self.hasRole:SetActive(hasRole)

    local status = ServerStatusDict[statusNum]
    for k, v in pairs(self.status) do
        if k == status then
            v:SetActive(true)
        else
            v:SetActive(false)
        end
    end
end

return ServerItemView
