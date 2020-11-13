local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local LuaScrollRectExSameSize = require("ui.control.scroll.LuaScrollRectExSameSize")
local PlayerPieceScrollView = class(LuaScrollRectExSameSize)

function PlayerPieceScrollView:ctor()
    PlayerPieceScrollView.super.ctor(self)
    self.scrollRect = self.___ex.scrollRect
    self.pieceMap = {}
    self.selectPieceIndex = nil
end

function PlayerPieceScrollView:GetPieceRes()
    if not self.pieceRes then 
        self.pieceRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/PlayerPiece/PlayerPiece.prefab")
    end
    return self.pieceRes
end

function PlayerPieceScrollView:createItem(index)
    local obj = Object.Instantiate(self:GetPieceRes())
    local spt = res.GetLuaScript(obj)
    spt.clickCardPiece = function(index, cardPieceModel) self:OnClickCardPiece(index, cardPieceModel) end
    self:resetItem(spt, index)
    return obj
end

function PlayerPieceScrollView:resetItem(spt, index)
    local cardPieceModel = self.itemDatas[index]
    spt:InitView(cardPieceModel, index, self.selectPieceIndex, self.cardResourceCache)
    self:updateItemIndex(spt, index)
end

function PlayerPieceScrollView:updateItemIndex(spt, index)
    spt:UpdateItemIndex(index)
    self.pieceMap[tostring(index)] = spt
end

function PlayerPieceScrollView:UpdatePiece(pieceModel, index)
    local pieceView = self.pieceMap[tostring(index)]
    if pieceView then
        pieceView:InitView(pieceModel, index, self.selectPieceIndex, self.cardResourceCache)
    end
end

function PlayerPieceScrollView:destroyItem(index)
    self.selectPieceIndex = nil
    if index > table.nums(self.itemDatas) then 
        index = 1
    end
    local nextCardPieceModel = self.itemDatas[index]
    if nextCardPieceModel then 
        self:OnClickCardPiece(index, nextCardPieceModel)
    end
end

function PlayerPieceScrollView:OnClickCardPiece(index, cardPieceModel)
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
        self.clickCardPiece(cardPieceModel)
    end
end

function PlayerPieceScrollView:InitView(piecesArray, cardResourceCache)
    self.selectPieceIndex = nil
    self.cardResourceCache = cardResourceCache
    self:refresh(piecesArray)
end

return PlayerPieceScrollView
