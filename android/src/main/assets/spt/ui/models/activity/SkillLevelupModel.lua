local ActivityModel = require("ui.models.activity.ActivityModel")
local SkillLevelupModel = class(ActivityModel)

function SkillLevelupModel:InitWithProtocol()
end

function SkillLevelupModel:GetRewardData()
    return self:GetActivitySingleData().list or {}
end

function SkillLevelupModel:GetActivityDesc()
    return self:GetActivitySingleData().desc
end

function SkillLevelupModel:UpdateModel(activityData)
    local rewardData = self:GetRewardData()
    local activityListId = activityData.subID
    for i, v in ipairs(rewardData) do
        if activityListId == v.subID  then 
            v.status = activityData.status
            EventSystem.SendEvent("SkillLevelupChange", activityListId)
            break
        end
    end
end

function SkillLevelupModel:GetItemListData(activityListId)
    local data = nil
    local rewardData = self:GetRewardData()
    for i, v in ipairs(rewardData) do
        if activityListId == v.subID  then 
            data = v
            break
        end
    end
    return data
end

function SkillLevelupModel:GetStartTime()
    return self:GetActivitySingleData().beginTime
end

function SkillLevelupModel:GetEndTime()
    return self:GetActivitySingleData().endTime
end

return SkillLevelupModel