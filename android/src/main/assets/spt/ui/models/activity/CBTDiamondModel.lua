local ActivityModel = require("ui.models.activity.ActivityModel")
local CBTDiamondModel = class(ActivityModel)

function CBTDiamondModel:InitWithProtocol()
end

function CBTDiamondModel:GetRemainTime()
    return self:GetActivitySingleData().remainTime
end

function CBTDiamondModel:GetRMB()
    return self:GetActivitySingleData().value.fee
end

function CBTDiamondModel:GetDiamond()
    return self:GetActivitySingleData().value.d
end

function CBTDiamondModel:GetVIPEXP()
    return self:GetActivitySingleData().value.vip.d
end

function CBTDiamondModel:GetVIPLevel()
    return self:GetActivitySingleData().value.vip.lvl
end

function CBTDiamondModel:GetStartTime()
    return self:GetActivitySingleData().beginTime
end

function CBTDiamondModel:GetEndTime()
    return self:GetActivitySingleData().endTime
end


return CBTDiamondModel