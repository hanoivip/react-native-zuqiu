local CompeteCrossBaseModel = require("ui.models.compete.cross.CompeteCrossBaseModel")
local CompeteScoreModel = class(CompeteCrossBaseModel, "CompeteScoreModel")

function CompeteScoreModel:ctor()
    CompeteScoreModel.super.ctor(self)
end

function CompeteScoreModel:InitWithProtocol(data)
    assert(type(data) == "table")
	local teamMap = {}
	for index, v in pairs(data) do
		local teamNewData = {}
		local teamData = {}
		for pid, n in pairs(v) do
			local team = {}
			team.pid = n.pid
			team.rank = n.rank
			team.score = n.score
            team.worldTournamentLevel = n.worldTournamentLevel
			teamData[tonumber(team.rank)] = team
		end
		teamNewData.index = tonumber(index)
		teamNewData.teamData = teamData
		table.insert(teamMap, teamNewData)
	end
	table.sort(teamMap, function(a, b) return a.index < b.index end)

	self:InitSortData(teamMap)
end

return CompeteScoreModel