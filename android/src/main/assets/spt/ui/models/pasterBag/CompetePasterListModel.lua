local Model = require("ui.models.Model")
local PasterStateType = require("ui.scene.paster.PasterStateType")
local PasterMainType = require("ui.scene.paster.PasterMainType")
local CardPastersMapModel = require("ui.models.CardPastersMapModel")
local CardPasterModel = require("ui.models.cardDetail.CardPasterModel")
local CompetePasterListModel = class(Model)

function CompetePasterListModel:ctor()
    CompetePasterListModel.super.ctor(self)
    self:Init()
end

function CompetePasterListModel:Init()
    self.cardPastersMapModel = CardPastersMapModel.new()
    self.CompetePasterListModel = {}
    self.pasterModelMap = {}
    self:InitData()
end

function CompetePasterListModel:InitData()
    self.CompetePasterListModel = {}
    self.pasterModelMap = {}
    local pasters = self.cardPastersMapModel:GetPasterMap()
    for ptid, v in pairs(pasters) do
        if v.num ~= 0 and v.type == PasterMainType.Compete then
            local pasterModel = CardPasterModel.new(ptid, PasterStateType.CanUse)
            local cache = self.cardPastersMapModel:GetPasterData(ptid)
            pasterModel:InitWithCache(cache)
            table.insert(self.CompetePasterListModel, pasterModel)
            self.pasterModelMap[tostring(ptid)] = pasterModel
        end
    end
    self:SortPasterList()
end

function CompetePasterListModel:SortPasterList()
    table.sort(self.CompetePasterListModel, function(aModel, bModel)
        if aModel:GetPasterType() == bModel:GetPasterType() then
            if aModel:GetPasterQuality() == bModel:GetPasterQuality() then
                return tonumber(aModel:GetPasterId()) < tonumber(bModel:GetPasterId())
            else
                return aModel:GetPasterQuality() > bModel:GetPasterQuality()
            end
        else
            return aModel:GetPasterType() > bModel:GetPasterType()
        end
    end)
end

function CompetePasterListModel:GetListModel()
    return self.CompetePasterListModel
end

function CompetePasterListModel:GetModel(ptid)
    return self.pasterModelMap[tostring(ptid)]
end

return CompetePasterListModel