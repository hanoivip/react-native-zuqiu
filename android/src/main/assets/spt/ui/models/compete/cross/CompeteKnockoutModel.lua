local CompeteCrossBaseModel = require("ui.models.compete.cross.CompeteCrossBaseModel")
local CompeteKnockoutModel = class(CompeteCrossBaseModel, "CompeteKnockoutModel")

function CompeteKnockoutModel:ctor()
    CompeteKnockoutModel.super.ctor(self)
end

function CompeteKnockoutModel:InitWithProtocol(data)
    assert(type(data) == "table")
	self:Init(data)
end

function CompeteKnockoutModel:GetMatchScheduleData(matchScheduleType)
	local scheduleData = self.data[matchScheduleType] or {}
	return scheduleData
end

local function GetGoalScore(useData)
	local score, penaltyScore = 0, 0
	for i, v in ipairs(useData) do
		score = score + tonumber(v.score)
		penaltyScore = penaltyScore + tonumber(v.penaltyScore)
	end
	return score, penaltyScore
end

return CompeteKnockoutModel