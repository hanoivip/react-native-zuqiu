local PeakHonor = require("data.PeakHonor")
local Model = require("ui.models.Model")

local PeakEveryTaskModel = class(Model)

function PeakEveryTaskModel:ctor()
    PeakEveryTaskModel.super.ctor(self)
end

local function sortDataList(a, b)
    --status = -1 不能领取, = 0 可以领取,  =1  已领取
    --status = 0.8 不能领取, = 0.2 可以领取,  =1.2  已领取
    local aCompareNum = math.abs(tonumber(a.status) + 0.2)
    local bCompareNum = math.abs(tonumber(b.status) + 0.2)
    if aCompareNum < bCompareNum then
        return true
    end
    if aCompareNum > bCompareNum then
        return false
    end
    return PeakHonor[tostring(a.ID)].order < PeakHonor[tostring(b.ID)].order
end

function PeakEveryTaskModel:InitWithProtocol(data)
    assert(data)
    self.data = data
end

function PeakEveryTaskModel:GetTitleById(id)
    return PeakHonor[tostring(id)].title
end

function PeakEveryTaskModel:GetDescById(id)
    return PeakHonor[tostring(id)].desc
end

function PeakEveryTaskModel:GetTypeById(id)
    return PeakHonor[tostring(id)].type
end

function PeakEveryTaskModel:GetFinishTimeByIndex(id)
    return PeakHonor[tostring(id)].condition
end

-- function PeakEveryTaskModel:GetContentsById(id)
--     return PeakHonor[tostring(id)].contents
-- end

function PeakEveryTaskModel:GetAllTaskData()
    table.sort(self.data.list, sortDataList)
    return self.data.list
end

function PeakEveryTaskModel:GetChallengeTaskData()
    local taskData = {}
    for i, v in ipairs(self.data.list) do
        if tonumber(v.type) == 1 then
            table.insert(taskData, v)
        end
    end
    table.sort(taskData, sortDataList)
    return taskData
end

function PeakEveryTaskModel:GetWinTaskData()
    local winData = {}
    for i, v in ipairs(self.data.list) do
        if tonumber(v.type) == 2 then
            table.insert(winData, v)
        end
    end
    table.sort(winData, sortDataList)
    return winData
end

function PeakEveryTaskModel:GetWinTaskTime()
    return self.data.winChallengeCountToday
end

function PeakEveryTaskModel:GetChallengeTaskTime()
    return self.data.challengeCountToday
end

function PeakEveryTaskModel:GetTag()
    return self.tag or "all"
end

function PeakEveryTaskModel:SetTag(tag)
    self.tag = tag
end

return PeakEveryTaskModel