local Model = require("ui.models.Model")
local DreamBattleRoomInfoModel = class(Model, "DreamBattleRoomInfoModel")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")

function DreamBattleRoomInfoModel:InitWithProtocol(data, roomData)
    self.data = data
    self.roomData = roomData
end

function DreamBattleRoomInfoModel:GetNationList()
    if self.nationList and next(self.nationList) then
        return self.nationList
    end

    self.nationList = {}
    self.nationList[self.roomData.homeTeamEn] = true
    self.nationList[self.roomData.awayTeamEn] = true

    return self.nationList
end

function DreamBattleRoomInfoModel:GetHasEnterCount()
    return #self.data.roomInfo.player
end

-- 这个是DreamLeagueRoom表的编号
function DreamBattleRoomInfoModel:GetRoomId()
    return self.roomData.roomId
end

-- 获取服务器定义的房间id
function DreamBattleRoomInfoModel:GetServerSetUpId()
    return self.roomData.id
end

function DreamBattleRoomInfoModel:GetUsedDcids()
    return self.data.usedDcids or {}
end

function DreamBattleRoomInfoModel:GetTotalFee()
    return self.data.roomInfo.totalFee
end

function DreamBattleRoomInfoModel:GetHasEnterdPlayerList()
    return self.data.roomInfo.player
end

function DreamBattleRoomInfoModel:GetIsSelfInRoom()
    local playerList = self:GetHasEnterdPlayerList()
    local selfPid = PlayerInfoModel.new():GetID()
    for k,v in pairs(playerList) do
        if selfPid == v.pid then
            return true
        end
    end
end

return DreamBattleRoomInfoModel
