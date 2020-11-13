local GameObjectHelper = require("ui.common.GameObjectHelper")
local AssetFinder = require("ui.common.AssetFinder")
local CardHelper = require("ui.scene.cardDetail.CardHelper")
local UnityEngine = clr.UnityEngine
local Vector3 = clr.UnityEngine.Vector3

local PasterPieceView = class(unity.base)

function PasterPieceView:ctor()
    self.monthBG = self.___ex.monthBG
    self.monthPiece = self.___ex.monthPiece
    self.weekBG = self.___ex.weekBG
    self.weekPiece = self.___ex.weekPiece
end

function PasterPieceView:InitView(cardPasterModel)
    local isMonthPaster = cardPasterModel:IsMonthPaster()

    local id = cardPasterModel:GetPasterType()
    local path = "Assets/CapstonesRes/Game/UI/Common/Card/Paster/Image/Paster_Piece" .. id .. ".png"
    self[isMonthPaster and "monthPiece" or "weekPiece"].overrideSprite = res.LoadRes(path)

    local boxRes = AssetFinder.GetCardPieceBox2(cardPasterModel:GetPieceBg())
    self[isMonthPaster and "monthBG" or "weekBG"].overrideSprite = boxRes
    self[isMonthPaster and "monthBG" or "weekBG"].transform.localScale = Vector3(1.4, 1.4, 1)
end

return PasterPieceView