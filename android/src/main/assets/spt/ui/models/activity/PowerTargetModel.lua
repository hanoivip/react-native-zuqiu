local ActivityModel = require("ui.models.activity.ActivityModel")


local PowerTargetModel = class(ActivityModel)

function PowerTargetModel:InitWithProtocol()

end

function PowerTargetModel:GetDataByCurDiff()
    return self:GetActivitySingleData().list[self.diff or 1]
end

function PowerTargetModel:GetRemainTime()
    return self:GetActivitySingleData().remainTime
end

function PowerTargetModel:GetBeginTime()
    return self:GetActivitySingleData().beginTime
end

function PowerTargetModel:GetEndTime()
    return self:GetActivitySingleData().endTime
end

function PowerTargetModel:GetChallengeType()
    return self:GetActivitySingleData().type
end

function PowerTargetModel:GetCurrDiff()
    return self.diff or 1
end

function PowerTargetModel:SetCurrDiff(diff)
    self.diff = diff
    EventSystem.SendEvent("PowerTarget_Diff_Change", diff)
end

function PowerTargetModel:GetRewardContent()
    return self:GetActivitySingleData().list[self.diff or 1].contents
end

function PowerTargetModel:GetDefaultIndex()
    for i, v in ipairs(self:GetActivitySingleData().list) do
        if tonumber(v.status) ~= 1 then
            return i
        end
    end
    return table.nums(self:GetActivitySingleData().list)
end

function PowerTargetModel:GetSubId()
    return self:GetActivitySingleData().list[self.diff or 1].subID
end

function PowerTargetModel:GetPower()
    return self:GetActivitySingleData().list[self.diff or 1].value
end

function PowerTargetModel:GetStatus()
    return self:GetActivitySingleData().list[self.diff or 1].status
end

function PowerTargetModel:SetStatus(status)
    self:GetActivitySingleData().list[self.diff].status = status
end

function PowerTargetModel:GetFirstLoseIndex()
    for i, v in ipairs(self:GetActivitySingleData().list) do
        if v.status == -1 then return i end
    end
    return 1
end

function PowerTargetModel:GetDiffCount()
    local list = self:GetActivitySingleData().list
    if type(list) == "table" then
        return #list
    else
        return 0
    end
end

return PowerTargetModel