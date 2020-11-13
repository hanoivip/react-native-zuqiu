local EventSystem = require ("EventSystem")
local CardPasterModel = require("ui.models.cardDetail.CardPasterModel")
local PasterPiecesMapModel = require("ui.models.PasterPiecesMapModel")
local Model = require("ui.models.Model")
local PasterPieceStoreModel = class(Model, "PasterPieceStoreModel")

function PasterPieceStoreModel:ctor()
    PasterPieceStoreModel.super.ctor(self)
    self.pasterPiecesMapModel = PasterPiecesMapModel.new()
end

function PasterPieceStoreModel:Init(data)
    self.data = data or {}
end

function PasterPieceStoreModel:InitWithProtocol(data)
    assert(type(data) == "table")
    self:Init(data)
end

local function QualityNumSortAsc(aModel, bModel)
    if aModel:GetPasterType() == bModel:GetPasterType() then
        return aModel:GetPasterQuality() > bModel:GetPasterQuality()
    else
        return aModel:GetPasterType() > bModel:GetPasterType()
    end
end

function PasterPieceStoreModel:GetLastTime()
    return self.data.endTime
end

function PasterPieceStoreModel:GetPasterListModelMap(pasterType)
    local pasterListArray = {}
    if self.data.list and next(self.data.list) then
        for ptcid, v in pairs(self.data.list) do
            local cardPasterModel = CardPasterModel.new()
            cardPasterModel:InitWithStatic(ptcid)
            if pasterType then 
                if tostring(cardPasterModel:GetPasterType()) == tostring(pasterType) then 
                    table.insert(pasterListArray, cardPasterModel)
                end
            else 
                table.insert(pasterListArray, cardPasterModel)
            end
        end

        table.sort(pasterListArray, QualityNumSortAsc)
    end
    return pasterListArray
end

function PasterPieceStoreModel:GetWeekPieceNum()
    return self.pasterPiecesMapModel:GetPieceNum(1)
end

function PasterPieceStoreModel:GetMonthPieceNum()
    return self.pasterPiecesMapModel:GetPieceNum(2)
end

function PasterPieceStoreModel:GetPieceNum(pieceType)
    return self.pasterPiecesMapModel:GetPieceNum(pieceType)
end

function PasterPieceStoreModel:ResetPieceNum(typeId, num, data)
    if num > 0 then 
        self.pasterPiecesMapModel:ResetPieceData(typeId, data)
    else
        self.pasterPiecesMapModel:RemovePieceData(typeId)
    end
end

return PasterPieceStoreModel
