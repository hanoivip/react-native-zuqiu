local EventSystem = require ("EventSystem")
local Model = require("ui.models.Model")
local Card = require("data.Card")

local PlayerPiecesMapModel = class(Model, "PlayerPiecesMapModel")

function PlayerPiecesMapModel:ctor()
    PlayerPiecesMapModel.super.ctor(self)
end

function PlayerPiecesMapModel:Init(data)
    if not data then
        data = cache.getPlayerPiecesMap() or {}
    end
    self.data = data
end

function PlayerPiecesMapModel:InitWithProtocol(data)
    local piecesMap = {}
    if data then 
        for i, v in ipairs(data) do
            piecesMap[tostring(v.cid)] = v
        end
    end
    cache.setPlayerPiecesMap(piecesMap)
    self:Init(piecesMap)
end

-- 重置某一个球员碎片的model数据
function PlayerPiecesMapModel:ResetPieceData(cid, data)
    assert(type(data) == "table")
    self.data[tostring(cid)] = data

    EventSystem.SendEvent("PlayerPiecesMapModel_ResetPieceModel", cid)
end

-- 添加一张球员碎片
function PlayerPiecesMapModel:AddPieceData(cid, data)
    assert(cid and data and self.data[tostring(cid)] == nil)
    self.data[tostring(cid)] = data

    EventSystem.SendEvent("PlayerPiecesMapModel_AddPieceData", cid)
end

-- 删除一个球员碎片数据
function PlayerPiecesMapModel:RemovePieceData(cid)
    self.data[tostring(cid)] = nil

    EventSystem.SendEvent("PlayerPiecesMapModel_RemovePieceData", cid)
end

-- 删除一组球员碎片数据
function PlayerPiecesMapModel:RemovePiecesData(cids)
    local cidsMap = {}
    for i, cid in ipairs(cids) do
        self.data[tostring(cid)] = nil
    end

    EventSystem.SendEvent("PlayerPiecesMapModel_RemovePiecesData", cids)
end

-- 获取某个球员的碎片数据
function PlayerPiecesMapModel:GetPieceData(cid)
    return self.data[tostring(cid)]
end

function PlayerPiecesMapModel:GetPieceMap()
    return self.data
end

function PlayerPiecesMapModel:GetPieceNum(cid)
    local pieceData = self:GetPieceData(cid)
    return pieceData and tonumber(pieceData.num) or 0
end

function PlayerPiecesMapModel:AddPieceNum(cid, num)
    assert(cid)
    local pieceData = self:GetPieceData(cid)
    pieceData.num = pieceData.num + num
end

local UniversalKey = "generalPiece"
function PlayerPiecesMapModel:GetUniversalPieceKey()
    return UniversalKey
end

function PlayerPiecesMapModel:GetUniversalPieceNum()
    local key = self:GetUniversalPieceKey()
    return self:GetPieceNum(key)
end

function PlayerPiecesMapModel:UpdateFromReward(rewardTable)
    assert(rewardTable and type(rewardTable) == "table")
    if not rewardTable.cardPiece then return end

    for i, v in ipairs(rewardTable.cardPiece) do
        self:ResetPieceData(v.cid, v)
    end

    EventSystem.SendEvent("PlayerPiecesMapModel_UpdateFromReward")
end

return PlayerPiecesMapModel
