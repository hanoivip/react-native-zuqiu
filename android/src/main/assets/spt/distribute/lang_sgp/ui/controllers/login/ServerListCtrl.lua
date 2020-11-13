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

local function ReportSelectServer(mServer)
    if not mServer then
        return
    end
    local mPlayer = mServer.player
    luaevt.trig('SDK_PushUserOp_LUA',"SelectServer", mPlayer and mPlayer.pid, mPlayer and mPlayer.name, tostring(mPlayer and mPlayer.lvl), mServer.id, mServer.name ,mServer.id, mServer.name , 0)
    if mPlayer then
        luaevt.trig('SDK_PushUserOp_LUA',"SelectRole", mPlayer and mPlayer.pid, mPlayer and mPlayer.name, tostring(mPlayer and mPlayer.lvl), mServer.id, mServer.name ,mServer.id, mServer.name , 0)
    end
end

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
            ReportSelectServer(servers[spt.index])
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
            ReportSelectServer(servers[spt.index])
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
