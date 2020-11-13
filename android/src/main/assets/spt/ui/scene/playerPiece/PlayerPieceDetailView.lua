local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local PlayerPiecesMapModel = require("ui.models.PlayerPiecesMapModel")
local PasterPiecesMapModel = require("ui.models.PasterPiecesMapModel")
local CardHelper = require("ui.scene.cardDetail.CardHelper")
local PlayerPieceDetailView = class(unity.base)

function PlayerPieceDetailView:ctor()
    self.cardPiece = self.___ex.cardPiece
    self.nameTxt = self.___ex.name
    self.ownNum = self.___ex.ownNum
    self.content = self.___ex.content
    self.btnClose = self.___ex.btnClose
    self.title = self.___ex.title
    self.canvasGroup = self.___ex.canvasGroup
end

function PlayerPieceDetailView:start()
    self.btnClose:regOnButtonClick(function()
        self:Close()
    end)
    DialogAnimation.Appear(self.transform, self.canvasGroup)
end

function PlayerPieceDetailView:InitView(cardPieceModel)
    local isUniversalPiece = cardPieceModel:IsUniversalPiece()
    local isPasterPiece = cardPieceModel:IsPasterPiece()
    local isLegendPiece = cardPieceModel:IsLegendPiece()
    local name = cardPieceModel:GetName()
    self.title.text = lang.trans("player_piece")
    local num = 0
    if isPasterPiece then 
        local pasterPiecesMapModel = PasterPiecesMapModel.new()
        num = pasterPiecesMapModel:GetPieceNum(cardPieceModel:GetId())
        self.content.text = lang.trans("collect_player_paster_piece")
        self.title.text = lang.trans("paster_piece_title")
    else
        local playerPiecesMapModel = PlayerPiecesMapModel.new()
        num = playerPiecesMapModel:GetPieceNum(cardPieceModel:GetId())
        if isUniversalPiece then
            self.content.text = cardPieceModel:GetDesc()
        elseif isLegendPiece then
            self.content.text = cardPieceModel:GetStaticDesc()
            name = cardPieceModel:GetOriginName()
        else
            local composeNum = cardPieceModel:GetComposeNeedPiece()
            local qualitySpecial = cardPieceModel:GetQualitySpecial()
            local quality = cardPieceModel:GetQuality()
            local fixQuality = CardHelper.GetQualityFixed(quality, qualitySpecial)
            local qualitySign = CardHelper.GetQualitySign(fixQuality)
            local nameStr = qualitySign .. lang.transstr("itemList_quality") .. name
            self.content.text = lang.trans("collect_player_piece", composeNum, nameStr)
        end
    end

    self.nameTxt.text = name
    self.ownNum.text = lang.trans("itemDetail_number", num)
    self.cardPiece:InitView(cardPieceModel)
end

function PlayerPieceDetailView:Close()
    DialogAnimation.Disappear(self.transform, self.canvasGroup, function()
        if type(self.closeDialog) == 'function' then
            self.closeDialog()
        end
    end)
end

function PlayerPieceDetailView:EnterScene()
end

function PlayerPieceDetailView:ExitScene()
end

return PlayerPieceDetailView