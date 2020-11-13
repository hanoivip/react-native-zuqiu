--local GreenswardBuildModel = require("ui.models.greensward.build.GreenswardBuildModel")
local GeneralEventModel = require("ui.models.greensward.event.GeneralEventModel")
local TurntableEventModel = class(GeneralEventModel, "TurntableEventModel")

TurntableEventModel.MoraleStatus = {  -- morale
    ["Minus"] = 0, -- 显示为减morale
    ["Add"] = 1, -- 显示为加morale
}

function TurntableEventModel:ctor()
    TurntableEventModel.super.ctor(self)
    self.hasRolling = false
end

function TurntableEventModel:InitWithProtocolTurntable(data)
    self.turntableData = data
end

function TurntableEventModel:RefreshWheelData(data)
    self.turntableData.totalTimes = data.totalTimes
    self.turntableData.openTimes = data.openTimes
end

function TurntableEventModel:GetIsMinus(pos)
    local reward = self.turntableData.reward
    return reward[pos].statu == TurntableEventModel.Minus
end

function TurntableEventModel:GetRollList()
    local reward = self.turntableData.reward
    local ids = self:GetAcceptRewardIds()
    local rollList = {}
    for i, v in pairs(reward) do
        local index = tonumber(i)
        v.isAccept = tobool(ids[index])
        v.rollId = index
        table.insert(rollList, v)
    end
    table.sort(rollList, function(a, b) return a.rollId < b.rollId end)
    return rollList
end

function TurntableEventModel:GetAcceptRewardIds()
    local ids = self.data.wheel or {}
    local idKV = {}
    for i, v in ipairs(ids) do
        local index = tonumber(v) + 1
        idKV[index] = index
    end
    return idKV
end

function TurntableEventModel:GetRollState()
    return self.hasRolling
end

function TurntableEventModel:SetRollState(hasRolling)
    self.hasRolling = hasRolling
end

function TurntableEventModel:GetRemainCount()
    local totalTimes = self.turntableData.totalTimes
    local openTimes = self.turntableData.openTimes
    return  totalTimes - openTimes
end

function TurntableEventModel:GetTotalCount()
    return self.turntableData.totalTimes
end

-- 次数是从0开始  读表的话从1开始  所以+1
function TurntableEventModel:GetOpenTimesIndex()
    local times = self.turntableData.openTimes or 0
    return times + 1 or 1
end

function TurntableEventModel:HasTweenExtension()
    return true
end

return TurntableEventModel
