local GroupType = require("ui.scene.arena.schedule.GroupType")
local Model = require("ui.models.Model")
local ArenaTeamMatchModel = class(Model, "ArenaTeamMatchModel")

function ArenaTeamMatchModel.GetInstance()
    return ArenaTeamMatchModel.Instance
end

function ArenaTeamMatchModel.ClearInstance()
    ArenaTeamMatchModel.Instance = nil
end

function ArenaTeamMatchModel:ctor()
    ArenaTeamMatchModel.super.ctor(self)
    ArenaTeamMatchModel.Instance = self
end

function ArenaTeamMatchModel:Init(data)
    self.data = data or {}
end

function ArenaTeamMatchModel:InitWithProtocol(data)
    assert(type(data) == "table")
    self:Init(data)
end

function ArenaTeamMatchModel:GetGroupData(groupIndex)
    return self.data.schedule[groupIndex]
end

-- 没有开始比赛时积分服务器没有存储数据，手动构建数据
function ArenaTeamMatchModel:GetScoreData(groupIndex)
    local scores = self.data.scores and self.data.scores[groupIndex] or {}
    if not next(scores) then 
        scores = {}
        local groupData = self:GetGroupData(groupIndex)
        local teams = groupData[1]
        for i, v in ipairs(teams) do
            local id1 = v.t1.id
            local id2 = v.t2.id
            local sid1 = v.t1.sid
            local sid2 = v.t2.sid
            local tempScore1 = {}
            tempScore1.id = id1
            tempScore1.sid = sid1
            table.insert(scores, tempScore1)
            local tempScore2 = {}
            tempScore2.id = id2
            tempScore2.sid = sid2
            table.insert(scores, tempScore2)
        end
    end
    return scores
end

-- 获取球员在赛程中所处的分组索引
function ArenaTeamMatchModel:GetPlayerTeamInScore(playerId)
    for index, group in ipairs(GroupType.Group) do
        local scoreData = self:GetScoreData(index)
        for i, v in ipairs(scoreData) do
            if v.id == playerId then 
                return index
            end
        end
    end
    return 1
end

return ArenaTeamMatchModel