local CompeteCrossBaseModel = require("ui.models.compete.cross.CompeteCrossBaseModel")
local CompeteTeamModel = class(CompeteCrossBaseModel, "CompeteTeamModel")

function CompeteTeamModel:ctor()
    CompeteTeamModel.super.ctor(self)
end

function CompeteTeamModel:InitWithProtocol(data)
    assert(type(data) == "table")
	local teamMap = {}
	for index, v in pairs(data) do
		local teamData = {}
		teamData.teamData = clone(v)
		teamData.index = index
		table.insert(teamMap, teamData)
	end
	table.sort(teamMap, function(a, b) return a.index < b.index end)
	self:InitSortData(teamMap)
end

return CompeteTeamModel