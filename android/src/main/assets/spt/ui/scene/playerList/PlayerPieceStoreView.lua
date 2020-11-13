local GameObjectHelper = require("ui.common.GameObjectHelper")
local CardResourceCache = require("ui.common.card.CardResourceCache")
local CardSymbolModel = require("ui.models.cardDetail.CardSymbolModel")
local CustomTagModel = require("ui.models.cardDetail.CustomTagModel")
local PlayerPieceStoreView = class(unity.base)

function PlayerPieceStoreView:ctor()
    self.scrollView = self.___ex.scrollView
    self.num = self.___ex.num
    self.lastTime = self.___ex.lastTime
    self.cardResourceCache = CardResourceCache.new()
    self:RegScrollViewHandle()
end

function PlayerPieceStoreView:RegScrollViewHandle()
    self.scrollView:regOnCreateItem(function(scrollSelf, index)
        local obj, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/PlayerPiece/CardPieceFrame.prefab")
        scrollSelf:resetItem(spt, index)
        return obj
    end)
    local cardSymbolModel = CardSymbolModel.new()
    cardSymbolModel:InitAboutOtherFlag(true, true, true, true)
    local customTagModel = CustomTagModel.new()
    self.scrollView:regOnResetItem(function(scrollSelf, spt, index)
        local cardModel = scrollSelf.itemDatas[index]  -- CardModel
        local cid = cardModel:GetCid()
        local baseId = cardModel:GetBaseID()
        local flagData = cardSymbolModel:GetShowSymbolData(cid, baseId, self.activityLetters)
        spt:InitView(cardModel, index, self.cardResourceCache, flagData, customTagModel)
        spt.clickCard = function()
            self:OnCardClick(cardModel) 
        end
        spt.clickBuy = function()
            self:OnExchangeCard(cardModel) 
        end
        scrollSelf:updateItemIndex(spt, index)
    end)
end

function PlayerPieceStoreView:start()
end

function PlayerPieceStoreView:Close()
end

function PlayerPieceStoreView:InitView(playerPieceStoreModel, cacheScrollPos)
    self.playerPieceStoreModel = playerPieceStoreModel
    local playerListModelMap = playerPieceStoreModel:GetPlayerListModelMap()
    self.activityLetters = playerPieceStoreModel:GetActivityLetters()
    self.scrollView:refresh(playerListModelMap, cacheScrollPos)

    self:UpdateUniversalPieceNum(playerPieceStoreModel)

    local time = playerPieceStoreModel:GetLastTime()
    if time then 
        local lastTime = string.convertSecondToMonth(time)
        self.lastTime.text = lang.transstr("end_time") .. lastTime
    else
        self.lastTime.text = ""
    end
end

function PlayerPieceStoreView:UpdateUniversalPieceNum(playerPieceStoreModel)
    local universalPieceNum = playerPieceStoreModel:GetUniversalPieceNum()
    self.num.text = "x" .. universalPieceNum
end

function PlayerPieceStoreView:onDestroy()
    self.cardResourceCache:Clear()
end

function PlayerPieceStoreView:OnCardClick(cardModel)
    if self.cardClick then 
        self.cardClick(cardModel)
    end
end

function PlayerPieceStoreView:OnExchangeCard(cardModel)
    if self.exchangeCard then 
        self.exchangeCard(cardModel)
    end
end

function PlayerPieceStoreView:ShowPageVisible(isShow)
    GameObjectHelper.FastSetActive(self.gameObject, isShow)
end

return PlayerPieceStoreView
