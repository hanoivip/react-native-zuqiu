local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local GameObjectHelper = require("ui.common.GameObjectHelper")
local StaticCardModel = require("ui.models.cardDetail.StaticCardModel")
local CardSymbolModel = require("ui.models.cardDetail.CardSymbolModel")
local CardResourceCache = require("ui.common.card.CardResourceCache")
local PlayerCardsMapModel = require("ui.models.PlayerCardsMapModel")
local CustomTagModel = require("ui.models.cardDetail.CustomTagModel")
local PlayerLeadIntoAidView = class(unity.base)

function PlayerLeadIntoAidView:ctor()
    self.content = self.___ex.content
    self.refresh = self.___ex.refresh
    self.refreshCost = self.___ex.refreshCost
    self.maxRefresh = self.___ex.maxRefresh
    self.refreshCostObj = self.___ex.refreshCostObj
    self.refreshCount = self.___ex.refreshCount
    self.refreshButton = self.___ex.refreshButton
    self.noPlayerTip = self.___ex.noPlayerTip
    self.scrollView = self.___ex.scrollView
    self.btnTip = self.___ex.btnTip
    self.cardsViewMap = {}
    self.cardResourceCache = CardResourceCache.new() 
    self:RegScrollViewHandle()
end

function PlayerLeadIntoAidView:start()
    self.refresh:regOnButtonClick(function()
        self:OnRefresh()
    end)
    self.btnTip:regOnButtonClick(function ()
        self:OnBtnTipClick()
    end)
end

function PlayerLeadIntoAidView:RegScrollViewHandle()
    self.scrollView:regOnCreateItem(function(scrollSelf, index)
        local obj = Object.Instantiate(self:GetAidCardRes())
        local spt = res.GetLuaScript(obj)
        scrollSelf:resetItem(spt, index)
        return obj
    end)
    local customTagModel = CustomTagModel.new()
    self.cardSymbolModel = CardSymbolModel.new()
    self.cardSymbolModel:InitAboutOtherFlag(true, true, true)
    self.scrollView:regOnResetItem(function(scrollSelf, spt, index)
        local cardData = scrollSelf.itemDatas[index]
        spt.clickCard = function(cid) self:OnClickCard(cid) end
        spt.clickBuy = function(index) self:OnClickBuy(index) end
        local cardModel = StaticCardModel.new(cardData.cid)
        spt:InitView(cardModel, cardData, index, cardResourceCache, self.cardSymbolModel:GetShowSymbolData(cardData.cid), customTagModel)
        scrollSelf:updateItemIndex(spt, index)
    end)
end

function PlayerLeadIntoAidView:EnterScene()
end


function PlayerLeadIntoAidView:onDestroy()
    self.cardResourceCache:Clear()
end

function PlayerLeadIntoAidView:OnRefresh()
    if self.clickRefresh then 
        self.clickRefresh()
    end
end

function PlayerLeadIntoAidView:OnBtnTipClick()
    if self.clickTip then
        self.clickTip()
    end
end

function PlayerLeadIntoAidView:ShowDisableArea(isShow)
    GameObjectHelper.FastSetActive(self.content.gameObject, isShow)
end

function PlayerLeadIntoAidView:EventUpdateState(index)
    
end

function PlayerLeadIntoAidView:GetAidCardRes()
    if not self.aidCardRes then 
        self.aidCardRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Store/AidCardFrame.prefab")
    end
    return self.aidCardRes
end

function PlayerLeadIntoAidView:InitView(aidModel, cacheScrollPos)
    self:ShowDisableArea(true)
    local hasCount = aidModel:HasAidCount()
    local aidCount = aidModel:GetAidCount()
    local maxAidCount = aidModel:GetMaxAidCount()
    local refreshCost = aidModel:GetRefreshCost()
    local countStr = hasCount and "<color=#9CDC14>" .. aidCount .. "</color>" .. " / " .. maxAidCount or "<color=red>" .. aidCount .. "</color>" .. " / " .. maxAidCount 
    self.refreshCount.text = countStr
    self.refreshCost.text = "x" .. refreshCost
    
    local cards = aidModel:GetAidCards()
    if next(cards) then 
        self.scrollView:refresh(cards, cacheScrollPos)
        self.noPlayerTip.text = ""
    else
        self.noPlayerTip.text = lang.trans("not_sign_player")
        hasCount = false
    end
    self.refreshButton.interactable = hasCount
    GameObjectHelper.FastSetActive(self.refreshCostObj, hasCount)
    GameObjectHelper.FastSetActive(self.maxRefresh, not hasCount)
end

function PlayerLeadIntoAidView:OnClickCard(cid) 
    if self.clickCard then 
        self.clickCard(cid)
    end
end

function PlayerLeadIntoAidView:OnClickBuy(index) 
    if self.clickBuy then 
        self.clickBuy(index)
    end
end

function PlayerLeadIntoAidView:ShowPageVisible(isShow)
    GameObjectHelper.FastSetActive(self.gameObject, isShow)
end

return PlayerLeadIntoAidView
