local GameObjectHelper = require("ui.common.GameObjectHelper")
local CardResourceCache = require("ui.common.card.CardResourceCache")
local HonorStoreView = class(unity.base)

function HonorStoreView:ctor()
    self.scrollView = self.___ex.scrollView
    self.num = self.___ex.num
    self.honorMoney = self.___ex.honorMoney
    self.diamond = self.___ex.diamond
    self.refreshBtn = self.___ex.refreshBtn
    self.helpBtn = self.___ex.helpBtn
    self.buyInfo = self.___ex.buyInfo
    self:RegScrollViewHandle()
    self:RegButton()
end

function HonorStoreView:RegScrollViewHandle()
    self.scrollView:regOnCreateItem(function(scrollSelf, index)
        local obj, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Store/HonorStoreItem.prefab")
        scrollSelf:resetItem(spt, index)
        return obj
    end)
    self.scrollView:regOnResetItem(function(scrollSelf, spt, index)
        local cardModel = scrollSelf.itemDatas[index]  -- CardModel
        spt:InitView(cardModel, index)
        spt.clickBuy = function()
            self:OnExchangeCard(cardModel) 
        end
        scrollSelf:updateItemIndex(spt or {}, index)
    end)
end

function HonorStoreView:RegButton()
    self.refreshBtn:regOnButtonClick(function()
    end)
    self.helpBtn:regOnButtonClick(function()
        if self.helpClick then 
            self.helpClick()
        end
    end)
end

function HonorStoreView:InitView(honorStoreModel)
    self.honorStoreModel = honorStoreModel 
    self.num.text = "x" .. honorStoreModel:GetHonorDiamondCount()
  
    self.scrollView:refresh(honorStoreModel:GetBoxList())
end

function HonorStoreView:OnExchangeCard(cardModel)
    if self.exchangeCard then 
        self.exchangeCard(cardModel)
    end
end

function HonorStoreView:RefreshHonorDiamond(val)
    self.num.text = tostring(val)
end

function HonorStoreView:ShowPageVisible(isShow)
    GameObjectHelper.FastSetActive(self.gameObject, isShow)
end

return HonorStoreView
