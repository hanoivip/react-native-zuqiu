local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local GameObjectHelper = require("ui.common.GameObjectHelper")
local AssetFinder = require("ui.common.AssetFinder")
local CardHelper = require("ui.scene.cardDetail.CardHelper")
local CardPieceModel = require("ui.models.cardDetail.CardPieceModel")

local LadderRewardDetailItemCardPieceRewardView = class(unity.base, "LadderRewardDetailItemCardPieceRewardView")


function LadderRewardDetailItemCardPieceRewardView:ctor()
    self.border = self.___ex.border
    self.nameTxt = self.___ex.name
    self.number = self.___ex.number
end

function LadderRewardDetailItemCardPieceRewardView:InitView(cardPieceData)
    if cardPieceData then
        self.cardPieceData = cardPieceData

        local cardPieceModel = CardPieceModel.new()
        cardPieceModel:InitWithStatic(cardPieceData.id, cardPieceData.num)

        self.nameTxt.text = cardPieceModel:GetQualityName()
        self.number.text = "x" .. cardPieceModel:GetAddNum()

        local quality = cardPieceModel:GetQuality()
        local fixQuality = CardHelper.GetQualityFixed(quality, cardPieceModel:GetQualitySpecial())
        local isUniversalPiece = cardPieceModel:IsUniversalPiece()
        self.border.overrideSprite = AssetFinder.GetCardPieceBox(isUniversalPiece, fixQuality)
    end
end

return LadderRewardDetailItemCardPieceRewardView