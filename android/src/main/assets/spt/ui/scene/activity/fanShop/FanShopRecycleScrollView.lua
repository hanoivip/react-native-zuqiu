local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local LuaScrollRectExSameSize = require("ui.control.scroll.LuaScrollRectExSameSize")
local FanShopRecycleScrollView = class(LuaScrollRectExSameSize)

function FanShopRecycleScrollView:ctor()
    FanShopRecycleScrollView.super.ctor(self)
    self.scrollRect = self.___ex.scrollRect
    self.pieceMap = nil
end

function FanShopRecycleScrollView:createItem(index)
    local obj, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Activties/FanShop/FanShopRecycleItem.prefab")
    spt.clickCardPiece = function(index, itemData) self:OnClickCardPiece(index, itemData) end
    self:resetItem(spt, index)
    return obj
end

function FanShopRecycleScrollView:resetItem(spt, index)
    local itemData = self.itemDatas[index]
    itemData.index = index
    spt:InitView(itemData, index, self.selectPieceIndex, self.cardResourceCache)
    self:updateItemIndex(spt, index)
end

function FanShopRecycleScrollView:updateItemIndex(spt, index)
    self.pieceMap[tostring(index)] = spt
end

function FanShopRecycleScrollView:UpdatePiece(pieceModel, index)
    local pieceView = self.pieceMap[tostring(index)]
    if pieceView then
        pieceView:InitView(pieceModel, index, self.selectPieceIndex, self.cardResourceCache)
    end
end

function FanShopRecycleScrollView:destroyItem(index)
    self.selectPieceIndex = nil
    if index > table.nums(self.itemDatas) then 
        index = 1
    end
    local nextCardPieceModel = self.itemDatas[index]
    if nextCardPieceModel then 
        self:OnClickCardPiece(index, nextCardPieceModel)
    end
end

function FanShopRecycleScrollView:OnClickCardPiece(index, itemData)
    if self.selectPieceIndex == index then 
        return 
    end

    local prePieceItem = self.pieceMap[tostring(self.selectPieceIndex)]
    if prePieceItem then 
        prePieceItem:IsSelect(false)
    end

    local currentPieceItem = self.pieceMap[tostring(index)]
    if currentPieceItem then 
        currentPieceItem:IsSelect(true)
    end

    self.selectPieceIndex = index
    if self.clickCardPiece then 
        self.clickCardPiece(itemData)
    end
end

function FanShopRecycleScrollView:InitView(piecesArray, cardResourceCache)
    self.selectPieceIndex = nil
    self.pieceMap = {}
    self.cardResourceCache = cardResourceCache
    self:refresh(piecesArray)
end

return FanShopRecycleScrollView
