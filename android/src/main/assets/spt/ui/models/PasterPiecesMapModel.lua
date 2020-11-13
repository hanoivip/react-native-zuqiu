local EventSystem = require ("EventSystem")
local Model = require("ui.models.Model")
local Paster = require("data.Paster")

local PasterPiecesMapModel = class(Model, "PasterPiecesMapModel")

function PasterPiecesMapModel:ctor()
    PasterPiecesMapModel.super.ctor(self)
end

function PasterPiecesMapModel:Init(data)
    if not data then
        data = cache.getPlayerPasterPiecesMap() or {}
    end
    self.data = data
end
--* 策划表用type为key，服务器也以type传入
function PasterPiecesMapModel:InitWithProtocol(data)
    local piecesMap = {}
    if data then 
        for i, v in ipairs(data) do
            piecesMap[tostring(v.type)] = v
        end
    end
    cache.setPlayerPasterPiecesMap(piecesMap)
    self:Init(piecesMap)
end

-- 重置某一个球员贴纸碎片的model数据
function PasterPiecesMapModel:ResetPieceData(typeId, data)
    assert(type(data) == "table")
    self.data[tostring(typeId)] = data

    EventSystem.SendEvent("PasterPiecesMapModel_ResetPieceModel", typeId)
end

-- 添加一张球员贴纸碎片
function PasterPiecesMapModel:AddPieceData(typeId, data)
    assert(type and data and self.data[tostring(typeId)] == nil)
    self.data[tostring(typeId)] = data

    EventSystem.SendEvent("PasterPiecesMapModel_AddPieceData", typeId)
end

-- 删除一个球员贴纸碎片数据
function PasterPiecesMapModel:RemovePieceData(typeId)
    self.data[tostring(typeId)] = nil

    EventSystem.SendEvent("PasterPiecesMapModel_RemovePieceData", typeId)
end

-- 删除一组球员贴纸碎片数据
function PasterPiecesMapModel:RemovePiecesData(types)
    local typesMap = {}
    for i, typeId in ipairs(types) do
        self.data[tostring(typeId)] = nil
    end

    EventSystem.SendEvent("PasterPiecesMapModel_RemovePiecesData", types)
end

-- 获取某个球员贴纸的碎片数据
function PasterPiecesMapModel:GetPieceData(typeId)
    return self.data[tostring(typeId)]
end

function PasterPiecesMapModel:GetPieceMap()
    return self.data
end

function PasterPiecesMapModel:GetPieceNum(typeId)
    local pieceData = self:GetPieceData(typeId)
    return pieceData and tonumber(pieceData.num) or 0
end

function PasterPiecesMapModel:AddPieceNum(typeId, addNum)
    local pieceData = self:GetPieceData(typeId)
    pieceData.num = pieceData.num + addNum
end

function PasterPiecesMapModel:UpdateFromReward(rewardTable)
    assert(rewardTable and type(rewardTable) == "table")
    if not rewardTable.pasterPiece then return end

    for i, v in ipairs(rewardTable.pasterPiece) do
        self:ResetPieceData(v.type, v)
    end

    EventSystem.SendEvent("PasterPiecesMapModel_UpdateFromReward")
end

return PasterPiecesMapModel
