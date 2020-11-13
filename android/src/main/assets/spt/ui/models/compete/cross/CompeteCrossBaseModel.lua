local Model = require("ui.models.Model")
local CompeteCrossBaseModel = class(Model, "CompeteCrossBaseModel")

function CompeteCrossBaseModel:ctor()
    CompeteCrossBaseModel.super.ctor(self)
	self.crossType = nil
	self.sortData = {}
end

function CompeteCrossBaseModel:Init(data)
    self.data = data or {}
end

function CompeteCrossBaseModel:InitSortData(data)
    self.sortData = data or {}
end

function CompeteCrossBaseModel:InitWithProtocol(data)
    assert(type(data) == "table")
    self:Init(data)
end

-- 整理好的数据
function CompeteCrossBaseModel:GetSortData()
    return self.sortData
end

function CompeteCrossBaseModel:GetAppointData(index)
    return self.sortData[index]
end

function CompeteCrossBaseModel:GetCrossType()
    return self.crossType
end

function CompeteCrossBaseModel:SetCrossType(crossType)
    self.crossType = crossType
end

function CompeteCrossBaseModel:GetCrossGroupType()
    return self.crossGroupType
end

function CompeteCrossBaseModel:SetCrossGroupType(crossGroupType)
    self.crossGroupType = crossGroupType
end

function CompeteCrossBaseModel:GetMatchScheduleData(matchScheduleType)
    return self.data[matchScheduleType]
end

function CompeteCrossBaseModel:SetTeamList(teamList)
	self.teamList = teamList
end

function CompeteCrossBaseModel:GetTeamList()
	return self.teamList
end

function CompeteCrossBaseModel:GetTeamInfo(pid)
	return self.teamList[pid] or {}
end

function CompeteCrossBaseModel:SetPlayerRoleId(playerId)
	self.playerId = playerId
end

function CompeteCrossBaseModel:GetPlayerRoleId()
	return self.playerId
end

return CompeteCrossBaseModel