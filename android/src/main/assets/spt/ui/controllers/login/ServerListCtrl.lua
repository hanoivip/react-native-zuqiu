local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object

local LoginModel = require("ui.models.login.LoginModel")
local BaseCtrl = require("ui.controllers.BaseCtrl")

local ServerListCtrl = class(BaseCtrl)

ServerListCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Login/ServerList.prefab"

ServerListCtrl.dialogStatus = {
    touchClose = true,
    withShadow = false,
    unblockRaycast = false,
}

function ServerListCtrl:Refresh()
    ServerListCtrl.super.Refresh(self)
    local servers = LoginModel.GetServers()

    local accountItems = {}
    local prefab = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Login/AccountItem.prefab")
    for i, v in ipairs(LoginModel.GetPlayers()) do
        local obj = Object.Instantiate(prefab)
        local spt = res.GetLuaScript(obj)
        spt:regOnButtonClick(function()
            LoginModel.SetCurrentServer(servers[spt.index])
            self.view:Close()
        end)
        spt:Init(v.displayId, v.name, v.state, v.player.name, v.player.lvl, v.player.logo, v.index)
        table.insert(accountItems, spt)
    end

    local recommendItems = {}
    local otherItems = {}
    prefab = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Login/ServerItem.prefab")
    for i, v in ipairs(servers) do
        local obj = Object.Instantiate(prefab)
        local spt = res.GetLuaScript(obj)
        spt:regOnButtonClick(function()
            LoginModel.SetCurrentServer(servers[spt.index])
            self.view:Close()
        end)
        spt:Init(v.displayId, v.name, v.state, type(v.player) == "table", v.index)
        if v.state == 4 then
            table.insert(recommendItems, spt)
        else
            table.insert(otherItems, spt)
        end
    end
    
    self.view:Init(recommendItems, otherItems, accountItems)
end

return ServerListCtrl
