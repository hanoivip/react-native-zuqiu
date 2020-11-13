local ArenaScheduleIndex = require("data.ArenaScheduleIndex")
local Model = require("ui.models.Model")
local ArenaScheduleTeamModel = class(Model, "ArenaScheduleTeamModel")

function ArenaScheduleTeamModel.GetInstance()
    return ArenaScheduleTeamModel.Instance
end

function ArenaScheduleTeamModel.ClearInstance()
    ArenaScheduleTeamModel.Instance = nil
end

function ArenaScheduleTeamModel:ctor()
    ArenaScheduleTeamModel.super.ctor(self)
    ArenaScheduleTeamModel.Instance = self
end

function ArenaScheduleTeamModel:Init(data)
    self.data = data or {}
end

function ArenaScheduleTeamModel:InitWithProtocol(data)
    assert(type(data) == "table")
    self:Init(data)
end

function ArenaScheduleTeamModel:GetPlayerTeamData()
    return self.data.brief
end

function ArenaScheduleTeamModel:GetPlayerMatchData()
    return self.data.match
end

function ArenaScheduleTeamModel:GetOrderTime(gameOrder)
    local matchData = self:GetPlayerMatchData()
    local list = matchData and matchData.list or {}
    return list[gameOrder] and list[gameOrder].time or ""
end

-- gameStage 为MatchScheduleType， stageOrder为第几轮
function ArenaScheduleTeamModel:GetMatchTime(gameStage, stageOrder)
    for i, v in ipairs(ArenaScheduleIndex) do
        if gameStage == v.gameStage and stageOrder == (v.stageOrder + 1) then 
            local gameOrder = v.gameOrder + 1
            return self:GetOrderTime(gameOrder)
        end
    end
    return ""
end

function ArenaScheduleTeamModel:GetPlayerLogo(id)
    local teamData = self:GetPlayerTeamData()
    return teamData[id].logo
end

function ArenaScheduleTeamModel:GetPlayerName(id)
    local teamData = self:GetPlayerTeamData()
    return teamData[id].name
end

return ArenaScheduleTeamModel