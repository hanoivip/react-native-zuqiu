local RewardItemViewModel = require("ui.models.quest.RewardItemViewModel")

local CareerRaceRIViewModel = class(RewardItemViewModel, "CareerRaceRIViewModel")

function CareerRaceRIViewModel:ctor(data)
    CareerRaceRIViewModel.super.ctor(self, data)
end

function CareerRaceRIViewModel:GetConditionDesc()
	local singleData = self:GetSingleData()
    return singleData.conditionDesc
end

function CareerRaceRIViewModel:GetSubID()
	local singleData = self:GetSingleData()
    return singleData.subID
end

function CareerRaceRIViewModel:GetCondition()
	local singleData = self:GetSingleData()
    return singleData.condition
end

return CareerRaceRIViewModel