local ActivityModel = require("ui.models.activity.ActivityModel")

local OBTDailyLoginModel = class(ActivityModel)

function OBTDailyLoginModel:InitWithProtocol()

end

function OBTDailyLoginModel:GetStartTime()
    return self:GetActivitySingleData().beginTime
end

function OBTDailyLoginModel:GetEndTime()
    return self:GetActivitySingleData().endTime
end

function OBTDailyLoginModel:GetDesc()
    return self:GetActivitySingleData().desc
end

function OBTDailyLoginModel:GetConditionDesc()
    return self:GetActivitySingleData().list[1].conditionDesc
end

-- 1,2,3分别代表第几天登录
function OBTDailyLoginModel:GetLoginStatus()
    return self:GetActivitySingleData().list[1].value
end

function OBTDailyLoginModel:GetRewardContents()
    return self:GetActivitySingleData().list[1].contents
end

function OBTDailyLoginModel:GetRewardStatus()
    return self:GetActivitySingleData().list[1].status
end

function OBTDailyLoginModel:GetActivitySubId()
    return self:GetActivitySingleData().list[1].subID
end

return OBTDailyLoginModel