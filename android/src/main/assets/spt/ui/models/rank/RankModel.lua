local RankTabType = require("ui.scene.rank.RankTabType")
local RankServer = require("ui.scene.rank.RankServer")
local Model = require("ui.models.Model")
local RankModel = class(Model, "RankModel")

function RankModel:ctor()
    self.selectMenu = RankTabType.TeamPower.pos
    self.selectServer = RankServer.Internal
end

function RankModel:InitWithProtocol(data)
    self.data = data
end

function RankModel:SetSelectMenu(selectMenu)
    self.selectMenu = selectMenu
end

function RankModel:GetSelectMenu()
    return self.selectMenu
end

function RankModel:SetServerState(selectServer)
    self.selectServer = selectServer
end

function RankModel:GetServerState()
    return self.selectServer
end

function RankModel:GetSelectKey()
    return self.selectKey
end

function RankModel:GetCurrentMenuData()
    local currentKey
    for k, v in pairs(RankTabType) do
        if self.selectMenu == v.pos then 
            currentKey = v.key
            break
        end
    end
    self.selectKey = currentKey
    local serverKey = self.selectServer == RankServer.Internal and "selfServer" or "allServer"
    return self.data[serverKey] and self.data[serverKey][currentKey] or {}
end

function RankModel:GetMenuTab()
    local menuMap = {}
    for k, v in pairs(RankTabType) do
        table.insert(menuMap, v)
    end
    table.sort(menuMap, function(a, b) return a.pos < b.pos end)
    return menuMap
end

return RankModel