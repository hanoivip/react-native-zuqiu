local ActivityModel = require("ui.models.activity.ActivityModel")

local FirstPayModel = class(ActivityModel)

function FirstPayModel:InitWithProtocol()

end

function FirstPayModel:GetRemainTime()
    return self:GetActivitySingleData().remainTime
end

function FirstPayModel:GetRewardContents()
    return self:GetActivitySingleData().list[1].contents
end

function FirstPayModel:GetRewardStatus()
    return self:GetActivitySingleData().list[1].status
end

function FirstPayModel:GetActivityID()
    return self:GetActivitySingleData().id
end

function FirstPayModel:GetProduct()
	return self:GetActivitySingleData().list[1]._product
end

return FirstPayModel