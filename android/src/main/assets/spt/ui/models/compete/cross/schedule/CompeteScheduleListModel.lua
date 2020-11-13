local Model = require("ui.models.Model")
local CompeteScheduleListModel = class(Model, "CompeteScheduleListModel")

function CompeteScheduleListModel:ctor()
    CompeteScheduleListModel.super.ctor(self)
	self.data = {}
end

function CompeteScheduleListModel:InitWithProtocol(data, crossType, teamList)
	self.crossType = crossType
	self.teamList = teamList
    self.data = data or {}
end

function CompeteScheduleListModel:SetPlayerRoleId(playerId)
	self.playerId = playerId
end

function CompeteScheduleListModel:GetPlayerRoleId()
	return self.playerId
end

function CompeteScheduleListModel:GetGroupData(groupIndex)
	local teamGroup = self.data.teamGroup or {}
	local scoreData = teamGroup[tostring(groupIndex)] or {}
	table.sort(scoreData, function(a, b) return tonumber(a.rank) < tonumber(b.rank) end)
	return scoreData
end

function CompeteScheduleListModel:GetScheduleData(groupIndex)
	local teamSchedule = self.data.teamSchedule or {}
	local scheduleData = teamSchedule[tostring(groupIndex)] or {}
	local groupData = {}
	for k, v in pairs(scheduleData) do
		local data = clone(v)
		data.index = tonumber(k)
		table.insert(groupData, data)
	end
	table.sort(groupData, function(a, b) return tonumber(a.index) < tonumber(b.index) end)
	return groupData
end

function CompeteScheduleListModel:GetTeamList()
	return self.teamList
end

function CompeteScheduleListModel:GetTeamInfo(pid)
	return self.teamList[pid] or {}
end

function CompeteScheduleListModel:GetMyGroupIndex()
	local groupIndex = 1
	local playerId = self:GetPlayerRoleId()
	local teamGroup = self.data.teamGroup or {}
	for k, v in pairs(teamGroup) do
		local group = clone(v) or {}
		for m, n in pairs(group) do
			local pid = n.pid
			if pid == playerId then 
				groupIndex = k
				return groupIndex
			end
		end	
	end
	return groupIndex
end

return CompeteScheduleListModel