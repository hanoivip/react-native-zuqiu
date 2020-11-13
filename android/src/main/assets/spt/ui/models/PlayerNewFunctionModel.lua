local Model = require("ui.models.Model")
local LoginModel = require("ui.models.login.LoginModel")

local PlayerNewFunctionModel = class(Model)

function PlayerNewFunctionModel:ctor()
    PlayerNewFunctionModel.super.ctor(self)
end

function PlayerNewFunctionModel:Init(data)
    if not data then
        data = cache.getPlayerNewFunctionData()
    end
    self.data = data
end

function PlayerNewFunctionModel:InitWithProtocol(data)
    cache.setPlayerNewFunctionData(data)
    self:Init(data)
end

function PlayerNewFunctionModel:SetWithProtocol(data, functionName)
    assert(type(data) == "table")
    cache.setPlayerNewFunctionData(data)
    self:Init(data)
    self:UpdateNewFunctionState(functionName)
end

function PlayerNewFunctionModel:IsOpend()
    return self.data.opened
end

function PlayerNewFunctionModel:CheckFirstEnterScene(functionName)
    if  self.data.content[functionName] and self.data.content[functionName] == 1 then
        return true
    end
    return false
end

function PlayerNewFunctionModel:UpdateNewFunctionState(functionName)
    local isShow = self:CheckFirstEnterScene(functionName)
    EventSystem.SendEvent("UpdateNewFunctionState", functionName, isShow)
end

return PlayerNewFunctionModel
