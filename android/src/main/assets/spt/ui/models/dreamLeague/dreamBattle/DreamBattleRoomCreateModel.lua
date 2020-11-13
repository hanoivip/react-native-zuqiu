local Model = require("ui.models.Model")
local DreamLeagueRoom = require("data.DreamLeagueRoom")
local DreamBattleRoomCreateModel = class(Model, "DreamBattleRoomCreateModel")

function DreamBattleRoomCreateModel:InitWithProtocol(data)
    self.data = data
    self.cacheData = {}
end

-- 因为需要知道选择的dropdown的matchId，因此使用["a vs b"] = matchId结构
function DreamBattleRoomCreateModel:GetTodayMatchTxtList()
    if not self.cacheData.matchList then
        self.cacheData.matchList = {}
        local matchData = self.data.todayMatchList
        for k, v in pairs(matchData) do
            self.cacheData.matchList[v.homeTeam .. "  VS  " .. v.awayTeam] = v.matchId
        end
    end

    return self.cacheData.matchList
end

-- 因为需要知道选择的dropdown的roomId，因此使用[roomName] = roomId结构
function DreamBattleRoomCreateModel:GetRoomList()
    if not self.cacheData.roomList then
        self.cacheData.roomList = {}
        for k, v in pairs(DreamLeagueRoom) do
            self.cacheData.roomList[v.name] = v.idRoom
        end
    end

    return self.cacheData.roomList
end

-- 返回创建房间的两个比赛的队
function DreamBattleRoomCreateModel:GetNationListByMatchId(matchId)
    for k, v in pairs(self.data.todayMatchList) do
        if tonumber(v.matchId) == tonumber(matchId) then
            local nationList = {}
            nationList[v.homeTeamEn] = true
            nationList[v.awayTeamEn] = true

            return nationList
        end
    end
end

function DreamBattleRoomCreateModel:GetUsedDcids()
    return self.data.usedDcids or {}
end

return DreamBattleRoomCreateModel
