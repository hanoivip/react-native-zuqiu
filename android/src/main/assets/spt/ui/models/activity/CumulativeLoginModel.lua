local ActivityModel = require("ui.models.activity.ActivityModel")

local CumulativeLoginModel = class(ActivityModel)

function CumulativeLoginModel:InitWithProtocol()

end

-- 1,2,3分别代表第几天登录
function CumulativeLoginModel:GetLoginStatus()
    return self:GetActivitySingleData().list[1].value
end

function CumulativeLoginModel:GetRewardContents()
    return self:GetActivitySingleData().list[1].contents
end

function CumulativeLoginModel:GetRewardStatus()
    return self:GetActivitySingleData().list[1].status
end

function CumulativeLoginModel:GetActivitySubId()
    return self:GetActivitySingleData().list[1].subID
end

return CumulativeLoginModel