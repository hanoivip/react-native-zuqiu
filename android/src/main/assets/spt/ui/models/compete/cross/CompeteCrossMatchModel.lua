local CrossAssetFinder = require("ui.scene.compete.cross.CrossAssetFinder")
local CrossContentOrder = require("ui.scene.compete.cross.CrossContentOrder")
local Model = require("ui.models.Model")
local CompeteCrossMatchModel = class(Model, "CompeteCrossMatchModel")

function CompeteCrossMatchModel:ctor()
    CompeteCrossMatchModel.super.ctor(self)
	self.crossMapModels = {}
	self.teamList = {}
	self.pageIndex = 1
	self.crossGroupType = nil
end

function CompeteCrossMatchModel:InitTeam(teamData)
	self.teamList = teamData or {}
end

function CompeteCrossMatchModel:Init(data)
    self.data = data or {}
	self:InitTeam(self.data.teamList)

	self.crossMapModels = {}
	local matchList = self.data.matchList or {}
	for k, v in pairs(matchList) do
		local modelPath = CrossAssetFinder.GetCrossModel(k)
		if modelPath then 
			local model = require(modelPath).new()
			model:SetCrossGroupType(self.crossGroupType)
			model:SetCrossType(k)
			model:SetTeamList(self.teamList)
			model:SetPlayerRoleId(self.playerId)
			model:InitWithProtocol(v)
			table.insert(self.crossMapModels, model)
		end
	end
end

function CompeteCrossMatchModel:SortModel(crossGroupType)
	local crossSortType
	if crossGroupType == CrossContentOrder.Type.UniverseType then 
		crossSortType = CrossContentOrder.UniverseSortOrder
	elseif crossGroupType == CrossContentOrder.Type.GalaxyType then 
		crossSortType = CrossContentOrder.GalaxySortOrder
	end
    table.sort(self.crossMapModels, function(aModel, bModel)
        local aCrossType = aModel:GetCrossType()
		local bCrossType = bModel:GetCrossType()
		local aIndex = crossSortType[aCrossType]
		local bIndex = crossSortType[bCrossType]
		return tonumber(aIndex) < tonumber(bIndex)
    end)
end

function CompeteCrossMatchModel:InitWithProtocol(data, crossGroupType)
    assert(type(data) == "table")
	self.crossGroupType = crossGroupType
    self:Init(data)
	self:SortModel(crossGroupType)
end

function CompeteCrossMatchModel:GetMatchModel()
	return self.crossMapModels
end

function CompeteCrossMatchModel:InitPageIndex(pageIndex)
	self.pageIndex = pageIndex
end

function CompeteCrossMatchModel:SetPageIndex(pageIndex)
	self.pageIndex = pageIndex
	EventSystem.SendEvent("CompeteCrossPageChange", self.pageIndex, self.crossGroupType)
end

function CompeteCrossMatchModel:GetPageIndex()
	return self.pageIndex
end

function CompeteCrossMatchModel:SetPlayerRoleId(playerId)
	self.playerId = playerId
end

function CompeteCrossMatchModel:GetPlayerRoleId()
	return self.playerId
end

function CompeteCrossMatchModel:HasMessage()
	return self.data.message
end

return CompeteCrossMatchModel