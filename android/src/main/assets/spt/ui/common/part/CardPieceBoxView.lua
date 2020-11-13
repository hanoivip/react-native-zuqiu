local UnityEngine = clr.UnityEngine
local Vector2 = UnityEngine.Vector2
local AssetFinder = require("ui.common.AssetFinder")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local CardHelper = require("ui.scene.cardDetail.CardHelper")

local CardPieceBoxView = class(unity.base)

function CardPieceBoxView:ctor()
    self.border = self.___ex.border
    self.normalPieceArea = self.___ex.normalPieceArea
    self.universalPieceArea = self.___ex.universalPieceArea
    self.pieceMask = self.___ex.pieceMask
    self.pieceShape = self.___ex.pieceShape
    self.cardIcon = self.___ex.cardIcon
    self.cardIcon2 = self.___ex.cardIcon2
    -- 名称
    self.nameTxt = self.___ex.name
    self.nameShadow = self.___ex.nameShadow
    -- 获得的数量
    self.addNum = self.___ex.addNum
    self.addNumText = self.___ex.addNumText
    -- 碎片图标
    self.rectTrans = self.___ex.rectTrans
    self.btnClick = self.___ex.btnClick
    self.sign = self.___ex.sign

    self.cardPieceModel = nil
    -- 是否显示名称
    self.isShowName = false
    -- 是否显示获得的数量
    self.isShowAddNum = false
    -- 是否要显示详情板
    self.isShowDetail = false
end

function CardPieceBoxView:InitView(cardPieceModel, isShowName, isShowAddNum, isShowDetail)
    self.cardPieceModel = cardPieceModel 
    self.isShowName = isShowName or false
    self.isShowAddNum = isShowAddNum or false
    self.isShowDetail = isShowDetail or false
    self:BuildPage()
end

function CardPieceBoxView:start()
    self:ResetAddNumSize()
    if self.isShowDetail then
        self.btnClick:regOnButtonClick(function()
            self:OnCardPieceBoxClick()
        end)
    end
end

function CardPieceBoxView:BuildPage()
    local isUniversalPiece = self.cardPieceModel:IsUniversalPiece()
    local quality = self.cardPieceModel:GetQuality()
    local fixQuality = CardHelper.GetQualityFixed(quality, self.cardPieceModel:GetQualitySpecial())
    local isPasterPiece = self.cardPieceModel:IsPasterPiece()
    local isLegendPiece = self.cardPieceModel:IsLegendPiece()
    local isCoachIntelligencePiece = self.cardPieceModel:IsCoachIntelligencePiece()

    if isPasterPiece or isUniversalPiece or isCoachIntelligencePiece then
        self.sign.overrideSprite = res.LoadRes(self.cardPieceModel:GetPiecePath())
    elseif isLegendPiece then
        local iconRes = AssetFinder.GetPlayerIcon(self.cardPieceModel:GetAvatar())
        self.cardIcon.overrideSprite = iconRes
        self.cardIcon2.overrideSprite = iconRes
        local shapePath = "Assets/CapstonesRes/Game/UI/Common/Images/CardPiece/Shape/P_LegendMemory.png"
        self.pieceShape.overrideSprite = res.LoadRes(shapePath)
        self.pieceMask.overrideSprite = res.LoadRes(shapePath)
    else
        local iconRes = AssetFinder.GetPlayerIcon(self.cardPieceModel:GetAvatar())
        self.cardIcon.overrideSprite = iconRes
        self.cardIcon2.overrideSprite = iconRes
        local shapePath = "Assets/CapstonesRes/Game/UI/Common/Images/CardPiece/Shape/P"
        shapePath = shapePath .. fixQuality .. ".png"
        self.pieceShape.overrideSprite = res.LoadRes(shapePath)
        self.pieceMask.overrideSprite = res.LoadRes(shapePath)
    end

    local boxRes = AssetFinder.GetCardPieceBox2(self.cardPieceModel:GetPieceBg(fixQuality))
    self.border.overrideSprite = boxRes

    self.nameTxt.text = self.cardPieceModel:GetName()
    GameObjectHelper.FastSetActive(self.nameTxt.gameObject, self.isShowName)

    if self.isShowAddNum then
        local addNum = self.cardPieceModel:GetAddNum() or 0
        self.addNumText.text = "x" .. string.formatNumWithUnit(addNum)
    end
    GameObjectHelper.FastSetActive(self.addNum.gameObject, self.isShowAddNum)
    local isUniversalShow = self.cardPieceModel:IsUniversalShow()
    GameObjectHelper.FastSetActive(self.normalPieceArea, not isUniversalShow)
    GameObjectHelper.FastSetActive(self.universalPieceArea, isUniversalShow)
end

function CardPieceBoxView:ResetAddNumSize()
    self:coroutine(function ()
        unity.waitForEndOfFrame()
        local boxRect = self.rectTrans.rect
        if boxRect.width ~= 82 then
            local scaleFactor = boxRect.width / 82
            scaleFactor = (scaleFactor - 1) / 2 + 1
            self.addNumText.fontSize = math.floor(16 * scaleFactor)
            local addNumSize = self.addNum.sizeDelta
            self.addNum.sizeDelta = Vector2(addNumSize.x, addNumSize.y * scaleFactor)
        end
    end)
end

--- 设置名称颜色
function CardPieceBoxView:SetNameColor(nameColor, nameShadowColor)
    self.nameTxt.color = nameColor
    self.nameShadow.effectColor = nameShadowColor
end

--- 设置名称字号
function CardPieceBoxView:SetNumFont(numFont)
    self.isFixNumFont = true
    self.addNumText.fontSize = numFont
    self.nameTxt.fontSize = numFont
end

function CardPieceBoxView:OnCardPieceBoxClick()
    res.PushDialog("ui.controllers.playerPiece.PlayerPieceDetailCtrl", self.cardPieceModel)
end

return CardPieceBoxView
