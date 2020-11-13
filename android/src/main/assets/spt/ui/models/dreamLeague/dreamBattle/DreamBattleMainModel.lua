local Model = require("ui.models.Model")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")

local DreamBattleMainModel = class(Model, "DreamBattleMainModel")

function DreamBattleMainModel:InitWithProtocol(data)
    self.data = data
    self:SortRoomData()

    self.levelLimit = 30
end

local function sortRoomData(a, b)
    if table.nums(a.player) == table.nums(b.player) then
        return a.c_t > b.c_t
    end
    return table.nums(a.player) > table.nums(b.player)
end

function DreamBattleMainModel:SortRoomData()
    table.sort(self.data.roomList, sortRoomData)
end

function DreamBattleMainModel:GetRoomData()
    return self.data.roomList
end

function DreamBattleMainModel:SetRoomData(roomData)
    self.data.roomList = roomData
    EventSystem.SendEvent("Dream_Battle_Refresh", true)
end

function DreamBattleMainModel:IsCanCreateRoom()
    return self.data.canCreate
end

function DreamBattleMainModel:IsPlayerLevelSatisfy()
    local playerInfoModel = PlayerInfoModel.new()
    local level = playerInfoModel:GetLevel()
    return level > self.levelLimit
end

function DreamBattleMainModel:GetPlayerLevelLimit()
    return self.levelLimit
end

return DreamBattleMainModel
