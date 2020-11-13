local Model = require("ui.models.Model")
local MatchScheduleType = require("ui.scene.arena.schedule.MatchScheduleType")
local ArenaPersonScheduleModel = class(Model, "ArenaPersonScheduleModel")

function ArenaPersonScheduleModel:ctor()
    ArenaPersonScheduleModel.super.ctor(self)
end

function ArenaPersonScheduleModel:Init(data)
    self.data = data or {}
end

function ArenaPersonScheduleModel:InitWithProtocol(data)
    assert(type(data) == "table")
    self:Init(data)
end

function ArenaPersonScheduleModel:GetGroupData()
    return self.data.group or {}
end

function ArenaPersonScheduleModel:GetArenaOutData()
    return self.data.out or {}
end

local function BuildScheduleData(oldData, newData)
    if oldData then 
        for k, v in pairs(oldData) do
            for index, data in ipairs(v) do
                table.insert(newData, data)
            end
        end
    end
end

-- 服务器数据结构不太友好
function ArenaPersonScheduleModel:GetListData()
    local group = self:GetGroupData()
    local out = self:GetArenaOutData()
    local list = {}
    for k, v in pairs(group) do
        for m, n in pairs(v) do
            for index, data in pairs(n) do
                table.insert(list, data)
            end
        end
    end

    BuildScheduleData(out[MatchScheduleType.SixteenIntoEight], list)
    BuildScheduleData(out[MatchScheduleType.EightIntoFour], list)
    BuildScheduleData(out[MatchScheduleType.Semi], list)
    BuildScheduleData(out[MatchScheduleType.Final], list)

    return list
end

function ArenaPersonScheduleModel:HasSchedule()
    local data = self:GetListData()
    if next(data) then
        return true
    end
end

return ArenaPersonScheduleModel