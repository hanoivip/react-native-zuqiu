local GroupType = require("ui.scene.arena.schedule.GroupType")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local Model = require("ui.models.Model")
local ArenaNextMatchModel = class(Model, "ArenaNextMatchModel")

function ArenaNextMatchModel:ctor()
    ArenaNextMatchModel.super.ctor(self)
end

function ArenaNextMatchModel:Init(data)
    self.data = data or {}
end

function ArenaNextMatchModel:InitWithProtocol(data)
    assert(type(data) == "table")
    self:Init(data)
end

function ArenaNextMatchModel:GetHomeId()
    local home = (self.data.race.h == 1) and self.data.race.t1 or self.data.race.t2
    return home.id, home.sid
end

function ArenaNextMatchModel:GetVisitId()
    local visit = (self.data.race.h == 1) and self.data.race.t2 or self.data.race.t1
    return visit.id, visit.sid
end

function ArenaNextMatchModel:GetTeamData(id)
    return self.data.brief[id]
end

function ArenaNextMatchModel:GetTeamStageData(id)
    return self.data.stage[id]
end

function ArenaNextMatchModel:GetTeamPower(id)
    return self.data.power[id].power
end

function ArenaNextMatchModel:GetTime()
    return self.data.time.time
end

function ArenaNextMatchModel:GetTeamGroup()
    return GroupType.Key[self.data.race.groupOrder] or ""
end

function ArenaNextMatchModel:GetGroupDesc()
    return self.data.race.gameStage
end

function ArenaNextMatchModel:GetGroupRound()
    return self.data.race.roundOrder
end

function ArenaNextMatchModel:GetStageRound()
    return self.data.race.stageOrder
end

-- 服务器正在比赛计算时不显示数据(前提是在state为2 比赛的情况下)
function ArenaNextMatchModel:HasMatchGoon()
    local hasMatchGoon = false
    if not self.data.race then 
        hasMatchGoon = true 
    elseif self.data.race and (not next(self.data.race)) then
        hasMatchGoon = true 
    end
    return hasMatchGoon
end

-- 获取对手id
function ArenaNextMatchModel:GetOtherId()
    local playerInfoModel = PlayerInfoModel.new()
    local playerId = playerInfoModel:GetID()
    local homeId = self:GetHomeId() 
    local visitId = self:GetVisitId() 
    return playerId == homeId and visitId or homeId
end

return ArenaNextMatchModel