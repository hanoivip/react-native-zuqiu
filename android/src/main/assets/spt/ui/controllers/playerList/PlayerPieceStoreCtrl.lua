local PlayerPieceStoreModel = require("ui.models.playerList.PlayerPieceStoreModel")
local CardBuilder = require("ui.common.card.CardBuilder")
local StaticCardModel = require("ui.models.cardDetail.StaticCardModel")
local DialogManager = require("ui.control.manager.DialogManager")
local CardHelper = require("ui.scene.cardDetail.CardHelper")
local StoreModel = require("ui.models.store.StoreModel")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local PlayerPieceStoreCtrl = class(nil, "PlayerPieceStoreCtrl")

function PlayerPieceStoreCtrl:ctor(content)
    self:Init(content)
    self.playerPieceStoreModel = PlayerPieceStoreModel.new()
    self.view.cardClick = function(cardModel) self:OnCardClick(cardModel) end
    self.view.exchangeCard = function(cardModel) self:OnExchangeCard(cardModel) end
end

function PlayerPieceStoreCtrl:Init(content)
    local object, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/PlayerPiece/PieceStore.prefab")
    object.transform:SetParent(content, false)
    self.view = spt
end

function PlayerPieceStoreCtrl:InitView()
    local cacheScrollPos = StoreModel.GetPlayerPieceCacheScrollPos()
    clr.coroutine(function()
        local respone = req.getPieceStoreList(nil, nil, true)
        if api.success(respone) then 
            local data = respone.val
            self.playerPieceStoreModel:InitWithProtocol(data)
            self.view:InitView(self.playerPieceStoreModel, cacheScrollPos)
            StoreModel.SetPlayerPieceCacheScrollPos(nil)
        end
    end)
end

function PlayerPieceStoreCtrl:EnterScene()
end

function PlayerPieceStoreCtrl:OnCardClick(cardModel)
    StoreModel.SetPlayerPieceCacheScrollPos(self.view.scrollView:getScrollNormalizedPos())
    local selectCardId = cardModel:GetCid()
    res.PushScene("ui.controllers.cardDetail.CardDetailMainCtrl", {selectCardId}, 1, cardModel)
end

function PlayerPieceStoreCtrl:OnExchangeCard(cardModel)
    local selectCardId = cardModel:GetCid()
    local universalPieceNeed = cardModel:GetUniversalPieceNeed() 
    local universalPieceNum = self.playerPieceStoreModel:GetUniversalPieceNum()
    if universalPieceNum >= universalPieceNeed then
        local callback = function()
            clr.coroutine(function()
                local respone = req.cardIncorporateSpecial(selectCardId)
                if api.success(respone) then 
                    local data = respone.val
                    if next(data) then 
                        local cardPiece = data.cost.cardPiece
                        local cid = cardPiece.cid
                        local newNum = cardPiece.num
                        self.playerPieceStoreModel:ResetUniversalPieceNum(cid, newNum, cardPiece)
                        self.view:UpdateUniversalPieceNum(self.playerPieceStoreModel)
                        CongratulationsPageCtrl.new(data.contents)
                    end
                end
            end)
        end
        local tipTitle = lang.trans("player_exchange_title")
        local cardModel = StaticCardModel.new(selectCardId)
        local name = cardModel:GetName()
        local fixQuality = cardModel:GetCardFixQuality()
        local qualitySign = CardHelper.GetQualitySign(fixQuality)
        local nameStr = qualitySign .. lang.transstr("itemList_quality") .. name
        local tipContent = lang.trans("player_exchange_content", universalPieceNeed, nameStr)
        self:OnMessageBox(tipTitle, tipContent, callback) 
    else
        DialogManager.ShowToast(lang.trans("piece_not_enough"))
    end
end

function PlayerPieceStoreCtrl:OnMessageBox(titleText, contentText, callback) 
    local content = { }
    content.title = titleText
    content.content = contentText
    content.button1Text = lang.trans("cancel")
    content.button2Text = lang.trans("confirm")
    content.onButton2Clicked = function()
        callback()
    end
    local resDlg, dialogcomp = res.ShowDialog('Assets/CapstonesRes/Game/UI/Control/Dialog/MessageBox.prefab', 'overlay', true, true, nil, nil, 10000)
    dialogcomp.contentcomp:initData(content)
end


function PlayerPieceStoreCtrl:ShowPageVisible(isShow)
    self.view:ShowPageVisible(isShow)
end

return PlayerPieceStoreCtrl
