local AssetFinder = require("ui.common.AssetFinder")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local CardHelper = require("ui.scene.cardDetail.CardHelper")

local PlayerPieceView = class(unity.base)

function PlayerPieceView:ctor()
    self.border = self.___ex.border
    self.normalPieceArea = self.___ex.normalPieceArea
    self.universalPieceArea = self.___ex.universalPieceArea
    self.quality = self.___ex.quality
    self.quality2 = self.___ex.quality2
    self.cardIcon = self.___ex.cardIcon
    self.cardIcon2 = self.___ex.cardIcon2
    self.nameTxt = self.___ex.name
    self.num = self.___ex.num
    self.selectBorder = self.___ex.selectBorder
    self.sign = self.___ex.sign
    self.typeName = self.___ex.typeName
    self.btnClick = self.___ex.btnClick
    self.pieceMask = self.___ex.pieceMask
    self.pieceShape = self.___ex.pieceShape
end

function PlayerPieceView:InitView(cardPieceModel, index, selectPieceIndex, cardResourceCache)
    self.cardPieceModel = cardPieceModel
    self.index = index

    local quality = cardPieceModel:GetQuality()
    local fixQuality = CardHelper.GetQualityFixed(quality, cardPieceModel:GetQualitySpecial())
    local isPasterPiece = cardPieceModel:IsPasterPiece()
    local isUniversalPiece = cardPieceModel:IsUniversalPiece()
    local isLegendPiece = cardPieceModel:IsLegendPiece()
    local isCoachIntelligencePiece = cardPieceModel:IsCoachIntelligencePiece()

    if isPasterPiece or isUniversalPiece or isCoachIntelligencePiece then
        self.sign.overrideSprite = res.LoadRes(cardPieceModel:GetPiecePath())
    elseif isLegendPiece then
        local iconRes = cardResourceCache:GetAvatarRes(cardPieceModel:GetAvatar())
        self.cardIcon.overrideSprite = iconRes
        self.cardIcon2.overrideSprite = iconRes
        local shapePath = "Assets/CapstonesRes/Game/UI/Common/Images/CardPiece/Shape/P_LegendMemory.png"
        self.pieceShape.overrideSprite = res.LoadRes(shapePath)
        self.pieceMask.overrideSprite = res.LoadRes(shapePath)
    else
        local iconRes = cardResourceCache:GetAvatarRes(cardPieceModel:GetAvatar())
        self.cardIcon.overrideSprite = iconRes
        self.cardIcon2.overrideSprite = iconRes
        local shapePath = "Assets/CapstonesRes/Game/UI/Common/Images/CardPiece/Shape/P"
        shapePath = shapePath .. fixQuality .. ".png"
        self.pieceShape.overrideSprite = res.LoadRes(shapePath)
        self.pieceMask.overrideSprite = res.LoadRes(shapePath)
    end
    self.typeName.text = cardPieceModel:GetTypeName()
    local boxRes = AssetFinder.GetCardPieceBox2(cardPieceModel:GetPieceBg(fixQuality))
    self.border.overrideSprite = boxRes
    self.nameTxt.text = cardPieceModel:GetName()
    local num = cardPieceModel:GetNum() or 0
    self.num.text = "x" .. string.formatNumWithUnit(num)
    local isUniversalShow = cardPieceModel:IsUniversalShow()
    GameObjectHelper.FastSetActive(self.normalPieceArea, not isUniversalShow)
    GameObjectHelper.FastSetActive(self.universalPieceArea, isUniversalShow)
    local isSelect = tobool(index == selectPieceIndex)
    self:IsSelect(isSelect)
end

function PlayerPieceView:UpdateItemIndex(index)
    self.index = index
end

function PlayerPieceView:start()
    self.btnClick:regOnButtonClick(function()
        self:OnCardPieceBoxClick()
    end)
end

function PlayerPieceView:IsSelect(isSelect)
    GameObjectHelper.FastSetActive(self.selectBorder.gameObject, isSelect)
end

function PlayerPieceView:OnCardPieceBoxClick()
    if self.clickCardPiece then 
        self.clickCardPiece(self.index, self.cardPieceModel)
    end
end

return PlayerPieceView