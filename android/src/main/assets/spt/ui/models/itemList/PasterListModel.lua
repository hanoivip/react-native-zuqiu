local Model = require("ui.models.Model")
local PasterStateType = require("ui.scene.paster.PasterStateType")
local CardPastersMapModel = require("ui.models.CardPastersMapModel")
local CardPasterModel = require("ui.models.cardDetail.CardPasterModel")
local PasterListModel = class(Model)

function PasterListModel:ctor()
    PasterListModel.super.ctor(self)
    self:Init()
end

function PasterListModel:Init()
    self.cardPastersMapModel = CardPastersMapModel.new()
    self.pasterListModel = { }
    self.pasterModelMap = { }
    self:InitData()
end

function PasterListModel:InitData()
    self.pasterListModel = { }
    self.pasterModelMap = { }
    local pasters = self.cardPastersMapModel:GetPasterMap()
    for ptid, v in pairs(pasters) do
        if v.num ~= 0 then
            local pasterModel = CardPasterModel.new(ptid, PasterStateType.CanUse)
            local cache = self.cardPastersMapModel:GetPasterData(ptid)
            pasterModel:InitWithCache(cache)
            table.insert(self.pasterListModel, pasterModel)
            self.pasterModelMap[tostring(ptid)] = pasterModel
        end
    end
    self:SortPasterList()
end

function PasterListModel:SortPasterList()
    table.sort(self.pasterListModel, function(aModel, bModel)
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

function PasterListModel:GetListModel()
    return self.pasterListModel
end

function PasterListModel:GetModel(ptid)
    return self.pasterModelMap[tostring(ptid)]
end

return PasterListModel