local Model = require("ui.models.Model")
local CardBadgeModel = class(Model, "CardBadgeModel")
local PlayerCardsMapModel = require("ui.models.PlayerCardsMapModel")
local EquipsMapModel = require("ui.models.EquipsMapModel")
local EquipPieceMapModel = require("ui.models.EquipPieceMapModel")
local SimpleCardModel = require("ui.models.cardDetail.SimpleCardModel")
local Card = require("data.Card")
local Equipment = require("data.Equipment")

function CardBadgeModel:ctor()
    CardBadgeModel.super.ctor(self)
end

function CardBadgeModel:Init()
    self.playerCardsMapModel = PlayerCardsMapModel.new()
    self.playerCards = self.playerCardsMapModel.data
    self.equipsMapModel = EquipsMapModel.new()
    self.equipsMap = self.equipsMapModel.data
    self.equipPieceMapModel = EquipPieceMapModel.new()
    self.equipPieceMap = self.equipPieceMapModel.data
end

function CardBadgeModel:GetAllUpdateAvailablePcids()
    assert(type(self.playerCards) == "table")

    local pcidTable = {}

    for i, v in ipairs(table.keys(self.playerCards)) do
        if self:IsCardUpgradeAvailable(v) then
            table.insert(pcidTable, v)
        end
    end

    return pcidTable
end

function CardBadgeModel:IsItemUpgradeAvailable(eid)
    local eid = tostring(eid)

    if Equipment[eid] and Equipment[eid].pieceNum and type(self.equipPieceMap) == "table" and self.equipPieceMap[eid] and self.equipPieceMap[eid].num > Equipment[eid].pieceNum and Equipment[eid].pieceNum > 1 then
        return true
    end

    if type(self.equipsMap) == "table" and self.equipsMap[eid] and self.equipsMap[eid].num > 0 then
        return true
    end

    return false
end

function CardBadgeModel:IsCardUpgradeAvailable(pcid)
    assert(self.playerCards ~= nil and self.playerCards[tostring(pcid)] ~= nil)

    if not self:IsCardInTheAccount(pcid) then
        return false
    end

    local playerData = self.playerCards[tostring(pcid)]

    if type(playerData.equips) == "table" then
        for i, equipInfo in ipairs(playerData.equips) do
            local eid = equipInfo.eid
            local isEquip = equipInfo.isEquip

            if not isEquip and self:IsItemUpgradeAvailable(eid) then
                return true
            end
        end
    end

    return false
end

function CardBadgeModel:IsCardInTheAccount(pcid)
    local playerCardModel = SimpleCardModel.new(pcid)
    
    if playerCardModel:IsInPlayingLock() or playerCardModel:IsInPlayingRepLock() then
        return true
    end

    return false
end

return CardBadgeModel