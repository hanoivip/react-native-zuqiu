local UnityEngine = clr.UnityEngine
local AssetFinder = require("ui.common.AssetFinder")
local CardHelper = require("ui.scene.cardDetail.CardHelper")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local PlayerPiecePanelView = class(unity.base)

function PlayerPiecePanelView:ctor()
    self.scrollView = self.___ex.scrollView
    self.pieceInfo = self.___ex.pieceInfo
    self.border = self.___ex.border
    self.normalPieceArea = self.___ex.normalPieceArea
    self.universalPieceArea = self.___ex.universalPieceArea
    self.quality = self.___ex.quality
    self.quality2 = self.___ex.quality2
    self.cardIcon = self.___ex.cardIcon
    self.cardIcon2 = self.___ex.cardIcon2
    self.nameTxt = self.___ex.name
    self.num = self.___ex.num
    self.content = self.___ex.content
    self.btnUse = self.___ex.btnUse
    self.contentText = self.___ex.contentText
    self.sign = self.___ex.sign
    self.pieceMask = self.___ex.pieceMask
    self.pieceShape = self.___ex.pieceShape
    self.scrollView.clickCardPiece = function(cardPieceModel) self:OnClickCardPiece(cardPieceModel) end
end

function PlayerPiecePanelView:start()
    self.btnUse:regOnButtonClick(function()
        self:OnBtnUse()
    end)
end

function PlayerPiecePanelView:OnClickCardPiece(cardPieceModel)
    self.cardPieceModel = cardPieceModel
    local quality = cardPieceModel:GetQuality()
    local fixQuality = CardHelper.GetQualityFixed(quality, cardPieceModel:GetQualitySpecial())
    local name = cardPieceModel:GetName()
    self.nameTxt.text = name
    self:ShowPieceNum(cardPieceModel)
    local isPasterPiece = cardPieceModel:IsPasterPiece()
    local isUniversalPiece = cardPieceModel:IsUniversalPiece()
    local isLegendPiece = cardPieceModel:IsLegendPiece()
    local isCoachIntelligencePiece = cardPieceModel:IsCoachIntelligencePiece()

    if isPasterPiece or isUniversalPiece or isCoachIntelligencePiece then
        self.sign.overrideSprite = res.LoadRes(cardPieceModel:GetPiecePath())
    elseif isLegendPiece then
        local iconRes = AssetFinder.GetPlayerIcon(cardPieceModel:GetAvatar())
        self.cardIcon.overrideSprite = iconRes
        self.cardIcon2.overrideSprite = iconRes
        local shapePath = "Assets/CapstonesRes/Game/UI/Common/Images/CardPiece/Shape/P_LegendMemory.png"
        self.pieceShape.overrideSprite = res.LoadRes(shapePath)
        self.pieceMask.overrideSprite = res.LoadRes(shapePath)
    else
        local iconRes = AssetFinder.GetPlayerIcon(cardPieceModel:GetAvatar())
        self.cardIcon.overrideSprite = iconRes
        self.cardIcon2.overrideSprite = iconRes
        local shapePath = "Assets/CapstonesRes/Game/UI/Common/Images/CardPiece/Shape/P"
        shapePath = shapePath .. fixQuality .. ".png"
        self.pieceShape.overrideSprite = res.LoadRes(shapePath)
        self.pieceMask.overrideSprite = res.LoadRes(shapePath)
    end
    self.content.text = cardPieceModel:GetStaticDesc()
    self.contentText.text = cardPieceModel:GetContentText()
    local boxRes = AssetFinder.GetCardPieceBox2(cardPieceModel:GetPieceBg(fixQuality))
    self.border.overrideSprite = boxRes

    local isShowButton = cardPieceModel:IsShowButton()
    local isUniversalShow = cardPieceModel:IsUniversalShow()
    GameObjectHelper.FastSetActive(self.normalPieceArea, not isUniversalShow)
    GameObjectHelper.FastSetActive(self.universalPieceArea, isUniversalShow)
    GameObjectHelper.FastSetActive(self.pieceInfo, true)
    GameObjectHelper.FastSetActive(self.btnUse.gameObject, isShowButton)
end

function PlayerPiecePanelView:ShowPieceNum(cardPieceModel)
    local num = cardPieceModel:GetNum() or 0
    local numStr = "x" .. string.formatNumWithUnit(num)
    self.num.text = lang.transstr("has_piece_num", numStr) 
end

local function QualitySort(aModel, bModel)
    local aQuality = aModel:GetQuality()
    local bQuality = bModel:GetQuality()

    if aQuality == bQuality then 
        local aNum = aModel:GetNum()
        local bNum = bModel:GetNum()
        return aNum > bNum
    else
        return aQuality > bQuality
    end
end

local function IdSort(aModel, bModel)
    local aId = aModel:GetId()
    local bId = bModel:GetId()

    return aId > bId
end

function PlayerPiecePanelView:InitView(playerListModel, cardResourceCache)
    self.playerListModel = playerListModel
    local pieceMap = playerListModel:GetPlayerPieceMap()
    local piecesArray = {}
    for cid, v in pairs(pieceMap) do
        local pieceModel = playerListModel:GetPieceModel(cid)
        table.insert(piecesArray, pieceModel)
    end

    table.sort(piecesArray, QualitySort)

    local pasterPieceMap = playerListModel:GetPlayerPasterPieceMap()
    local pasterPiecesArray = {}
    for id, v in pairs(pasterPieceMap) do
        local pieceModel = playerListModel:GetPasterPieceModel(id)
        table.insert(pasterPiecesArray, pieceModel)
    end
    table.sort(pasterPiecesArray, IdSort)

    for i, v in ipairs(pasterPiecesArray) do
        table.insert(piecesArray, i, v)
    end
    self.piecesArray = piecesArray
    self.scrollView:InitView(self.piecesArray, cardResourceCache)

    local index, nexModel = next(self.piecesArray)
    if nexModel then 
        self.scrollView:OnClickCardPiece(index, nexModel)
    else
        GameObjectHelper.FastSetActive(self.pieceInfo, false)
    end
end

function PlayerPiecePanelView:OnBtnUse()
    if self.clickUse then 
        self.clickUse(self.cardPieceModel)
    end
end

function PlayerPiecePanelView:EventResetPiece(cid)
    local index
    local pieceModel = self.playerListModel:GetPieceModel(cid)
    for i, v in ipairs(self.scrollView.itemDatas) do
        if tostring(v:GetId()) == tostring(cid) then
            index = i
            break
        end
    end

    if index then
        self.scrollView.itemDatas[index] = pieceModel
        self.scrollView:UpdatePiece(pieceModel, index)
        self:ShowPieceNum(pieceModel)
        self.cardPieceModel = pieceModel
    end
end

function PlayerPiecePanelView:EventRemovePiece(cid)
    local index
    for i, v in ipairs(self.scrollView.itemDatas) do
        if tostring(v:GetId()) == tostring(cid) then
            index = i
            break
        end
    end
    self.scrollView:removeItem(index)
    local hasPiece = table.nums(self.scrollView.itemDatas) > 0
    GameObjectHelper.FastSetActive(self.pieceInfo, hasPiece)
end

function PlayerPiecePanelView:EnterScene()
    EventSystem.AddEvent("PlayerPiecesMapModel_ResetPieceModel", self, self.EventResetPiece)
    EventSystem.AddEvent("PlayerPiecesMapModel_RemovePieceData", self, self.EventRemovePiece)
end

function PlayerPiecePanelView:ExitScene()
    EventSystem.RemoveEvent("PlayerPiecesMapModel_ResetPieceModel", self, self.EventResetPiece)
    EventSystem.RemoveEvent("PlayerPiecesMapModel_RemovePieceData", self, self.EventRemovePiece)
end

return PlayerPiecePanelView
