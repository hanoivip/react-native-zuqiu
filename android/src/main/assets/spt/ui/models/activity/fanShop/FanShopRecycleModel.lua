local RewardUpdateCacheModel = require("ui.models.common.RewardUpdateCacheModel")
local PlayerPiecesMapModel = require("ui.models.PlayerPiecesMapModel")
local PasterPiecesMapModel = require("ui.models.PasterPiecesMapModel")
local CardPieceModel = require("ui.models.cardDetail.CardPieceModel")
local ItemMapModel = require("ui.models.ItemsMapModel")
local EquipModel = require("ui.models.EquipModel")
local EquipPieceModel = require("ui.models.EquipPieceModel")
local CardPasterPieceModel = require("ui.models.cardDetail.CardPasterPieceModel")
local ItemModel = require("ui.models.ItemModel")
local StaticCardModel = require("ui.models.cardDetail.StaticCardModel")
local PlayerCardsMapModel = require("ui.models.PlayerCardsMapModel")
local CardBuilder = require("ui.common.card.CardBuilder")
local ItemType = require("ui.scene.itemList.ItemType")

local Model = require("ui.models.Model")
local FanShopRecycleModel = class(Model, "CardPasterModel")

function FanShopRecycleModel:Init()
    self.playerPiecesMapModel = PlayerPiecesMapModel.new()
    self.pasterPiecesMapModel = PasterPiecesMapModel.new()
    self.playerCardsMapModel = PlayerCardsMapModel.new()
    self.itemList = {}
end

function FanShopRecycleModel:InitWithProtocol(data)
    self.cacheData = data
    self:InitData()
end

function FanShopRecycleModel:GetItemList()
    return self.itemList
end

function FanShopRecycleModel:InitData()
    self.itemList = {}
    for k,v in pairs(self.cacheData) do
        if v.itemType ~= ItemType.Card then
            self:ChooseModel(v.itemType, v.itemID, v)
            v.contents = {[v.itemType] = {{["id"] = v.itemID, num = 0}}}
            table.insert(self.itemList, v)
        else
            local sid = v.itemID
            local isOwnCard = self:IsExistCardID(sid)
            if isOwnCard then
                self:ChooseCardModels(v, isOwnCard)
            end
        end
    end
end

function FanShopRecycleModel:ChooseModel(itemType, itemID, v)
    local itemModel = nil
    if itemType == ItemType.CardPiece then
        itemModel, v.num= self:GetPieceModel(itemID)
        v.typeName = lang.transstr("piece")
    elseif itemType == ItemType.PasterPiece then
        itemModel, v.num = self:GetPasterPieceModel(itemID)
        v.typeName = lang.transstr("piece")
    elseif itemType == ItemType.Item then
        itemModel, v.num = self:GetItemModel(itemID)
        v.typeName = lang.transstr("fanShop_item_name")
    elseif itemType == ItemType.Eqs then
        itemModel, v.num = self:GetEquipModel(itemID)
        v.typeName = lang.transstr("itemList_equipMenuItem")
    elseif itemType == ItemType.EquipPiece then
        itemModel, v.num = self:GetEquipPieceModel(itemID)
        v.typeName = lang.transstr("itemList_equipPieceMenuItem")
    end
    v.name = itemModel:GetName()
    v.fullName = itemModel:GetName()
    if (itemType == ItemType.CardPiece or itemType == ItemType.PasterPiece) and v.itemID ~= ItemType.GeneralPiece then
        v.fullName = v.fullName .. v.typeName
    end
    v.itemModel = itemModel
end

function FanShopRecycleModel:ChooseCardModels(originItemData, isOwnCard)
    local sid = originItemData.itemID
    local cardList = self:GetCardList(sid)
    originItemData.typeName = lang.transstr("fanshop_whole_card")
    if isOwnCard then
        for pcid, flag in pairs(cardList) do
            local itemData = clone(originItemData)
            local cardModel = self:GetCardModel(pcid, isOwnCard)
            itemData.pcid = pcid
            itemData.num = 1
            itemData.name = cardModel:GetName()
            itemData.fullName = itemData.name
            itemData.itemModel = cardModel
            itemData.contents = {[itemData.itemType] = {{["id"] = sid, num = 1}}}
            itemData.isLock = cardModel:GetLock()
            itemData.hasMedal = cardModel:HasMedal()
            itemData.hasPaster = cardModel:HasPaster()
            itemData.hasAscend = cardModel:GetAscend() > 0
            itemData.isSupporter = cardModel:IsSupportOtherCard()
            itemData.isSupported = cardModel:IsHasSupportCard()
            itemData.canRecycle = not itemData.isLock and not itemData.hasMedal and not itemData.hasPaster and not itemData.hasAscend
                                    and not itemData.isSupporter and not itemData.isSupported
            table.insert(self.itemList, itemData)
        end
    end
end

function FanShopRecycleModel:GetPieceModel(cid)
    local cardPieceModel = CardPieceModel.new()
    local pieceData = self.playerPiecesMapModel:GetPieceData(cid)
    local num = 0
    if pieceData then
        cardPieceModel:InitWithCache(pieceData)
        num = cardPieceModel:GetNum()
    else
        cardPieceModel:InitWithStatic(cid, 0)
    end
    return cardPieceModel, num
end

function FanShopRecycleModel:GetItemModel(id)
    local itemModel = ItemModel.new(id)
    return itemModel, itemModel:GetItemNum() or 0
end

function FanShopRecycleModel:GetEquipModel(id)
    local itemModel = EquipModel.new(id)
    return itemModel, itemModel:GetEquipNum() or 0
end

function FanShopRecycleModel:GetEquipPieceModel(id)
    local itemModel = EquipPieceModel.new(id)
    return itemModel, itemModel:GetEquipPieceNum() or 0
end

function FanShopRecycleModel:GetPasterPieceModel(id)
    local cardPasterPieceModel = CardPasterPieceModel.new()
    local pieceData = self.pasterPiecesMapModel:GetPieceData(id)
    local num = 0
    if pieceData then
        cardPasterPieceModel:InitWithCache(pieceData)
        num = cardPasterPieceModel:GetNum()
    else
        cardPasterPieceModel:InitWithStatic(id, 0)
    end
    return cardPasterPieceModel, num
end

function FanShopRecycleModel:GetCardModel(id, isOwnCard)
    local cardModel = nil
    if isOwnCard then
        cardModel = CardBuilder.GetOwnCardModel(id)
    else
        cardModel = StaticCardModel.new(id)
    end
    return cardModel
end

function FanShopRecycleModel:IsExistCardID(id)
    return self.playerCardsMapModel:IsExistCardID(id)
end

function FanShopRecycleModel:GetCardList(id)
    return self.playerCardsMapModel:GetSameCardList(id)
end

function FanShopRecycleModel:RefreshItemData(itemData, num)
    if itemData.itemType ~= ItemType.Card then
        self.itemList[itemData.index] = itemData
    else
        table.remove(self.itemList, itemData.index)
    end
end

function FanShopRecycleModel:CostItem(rewardData)
    if not rewardData then return end
    local rewardUpdateCacheModel = RewardUpdateCacheModel.new()
    rewardUpdateCacheModel:UpdateCache(rewardData)
end

function FanShopRecycleModel:RemoveCardData(pcid)
    self.playerCardsMapModel:RemoveCardData({pcid})
end

return FanShopRecycleModel