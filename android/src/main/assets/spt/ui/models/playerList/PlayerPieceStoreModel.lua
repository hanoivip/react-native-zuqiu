local EventSystem = require ("EventSystem")
local StaticCardModel = require("ui.models.cardDetail.StaticCardModel")
local PlayerPiecesMapModel = require("ui.models.PlayerPiecesMapModel")
local Model = require("ui.models.Model")
local PlayerPieceStoreModel = class(Model, "CardPieceModel")

function PlayerPieceStoreModel:ctor()
    PlayerPieceStoreModel.super.ctor(self)
    self.playerPiecesMapModel = PlayerPiecesMapModel.new()
end

function PlayerPieceStoreModel:Init(data)
    self.data = data or {}
end

function PlayerPieceStoreModel:GetLastTime()
    return self.data.endTime
end

function PlayerPieceStoreModel:InitWithProtocol(data)
    assert(type(data) == "table")
    self:Init(data)
end

local function QualityNumSortAsc(aModel, bModel)
    local aQuality = aModel:GetCardQuality()
    local bQuality = bModel:GetCardQuality()

    if aQuality == bQuality then 
        local aNum = aModel:GetUniversalPieceNeed()
        local bNum = bModel:GetUniversalPieceNeed()
        return aNum > bNum
    else
        return aQuality > bQuality
    end
end

function PlayerPieceStoreModel:GetPlayerListModelMap()
    local playerListArray = {}
    local list = self.data.list or {}
    for cid, v in pairs(list) do
        local cardModel = StaticCardModel.new(cid)
        table.insert(playerListArray, cardModel)
    end

    table.sort(playerListArray, QualityNumSortAsc)

    return playerListArray
end

function PlayerPieceStoreModel:GetUniversalPieceNum()
    return self.playerPiecesMapModel:GetUniversalPieceNum()
end

function PlayerPieceStoreModel:GetUniversalPieceKey()
    return self.playerPiecesMapModel:GetUniversalPieceKey()
end

function PlayerPieceStoreModel:ResetUniversalPieceNum(cid, num, data)
    if num > 0 then 
        self.playerPiecesMapModel:ResetPieceData(cid, data)
    else
        self.playerPiecesMapModel:RemovePieceData(cid)
    end
end

-- 获取参与当期活动来信的球员
function PlayerPieceStoreModel:GetActivityLetters()
    return self.data.letterList
end

return PlayerPieceStoreModel
