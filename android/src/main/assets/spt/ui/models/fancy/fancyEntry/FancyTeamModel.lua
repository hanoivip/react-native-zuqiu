local FancySort = require("data.FancySort")
local FancyCardsMapModel = require("ui.models.fancy.FancyCardsMapModel")
local Model = require("ui.models.Model")
local FancyTeamModel = class(Model, "FancyTeamModel")

function FancyTeamModel:ctor(sortId)
    FancyTeamModel.super.ctor(self)
    self.sortId = sortId
    self.staticSortData = FancySort[sortId]
    self.fancyCardsMapModel = FancyCardsMapModel.new()
end

function FancyTeamModel:Init(data)
    self.data = data
end

function FancyTeamModel:InitWithProtocol(data)
    assert(type(data) == "table")
    self:Init(data)
end

function FancyTeamModel:GetGroupList()
    local staticGID = self.staticSortData.groupID
    local sortIds = {}
    local attrs = self.fancyCardsMapModel:GetGroupsAttr()
    for i, v in pairs(staticGID) do
        local t = tostring(v)
        local lightCount = attrs[t].lightCount
        table.insert(sortIds, {groupId = v, lightCount = lightCount})
    end
    table.sort(sortIds, function(a, b)
          return a.lightCount > b.lightCount
    end)
    local id = {}
    for i, v in ipairs(sortIds) do
        table.insert(id, v.groupId)
    end
    return id
end

function FancyTeamModel:GetGroupName()
    return self.staticSortData.sortName
end

function FancyTeamModel:GetGroupIcon()
    return self.staticSortData.sortIcon
end

return FancyTeamModel
