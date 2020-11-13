local GameObjectHelper = require("ui.common.GameObjectHelper")
local DreamStoreView = class(unity.base)

function DreamStoreView:ctor()
    self.cardStoreScrollView = self.___ex.cardStoreScrollView
    self.itemStoreScrollView = self.___ex.itemStoreScrollView
    self.switchBtnGroup = self.___ex.switchBtnGroup
    self.cardStore = self.___ex.cardStore
    self.itemStore = self.___ex.itemStore
    self.rightBtn = self.___ex.rightBtn
    self.leftBtn = self.___ex.leftBtn
end

function DreamStoreView:start()
    self.switchBtnGroup:BindMenuItem("cardStore", function() self:SwitchToCardStore() end)
    self.switchBtnGroup:BindMenuItem("itemStore", function() self:SwitchToItemStore() end)
end

function DreamStoreView:InitView(dreamStoreModel, selectTag)
    self:InitItemStoreScrollView(dreamStoreModel)
    self:InitCardScrollView(dreamStoreModel)
    if selectTag == "itemStore" then
        self:SwitchToItemStore()
    else
        self:SwitchToCardStore()
    end
end

function DreamStoreView:InitItemStoreScrollView(dreamStoreModel)
    local itemList = dreamStoreModel:GetItemList()
    self.itemStoreScrollView:RegOnItemButtonClick("clickBuy", self.clickBuyItem)
    self.itemStoreScrollView:InitView(itemList)
end

function DreamStoreView:InitCardScrollView(dreamStoreModel)
    local cardList = dreamStoreModel:GetCardList()
    self.cardStoreScrollView:RegOnItemButtonClick("clickBuy", self.clickBuyCard)
    self.cardStoreScrollView:InitView(cardList)
end

function DreamStoreView:SwitchToCardStore()
    self.switchBtnGroup:selectMenuItem("cardStore")
    GameObjectHelper.FastSetActive(self.cardStore, true)
    GameObjectHelper.FastSetActive(self.itemStore, false)
    if self.changeTag then
        self.changeTag("cardStore")
    end
end

function DreamStoreView:SwitchToItemStore()
    self.switchBtnGroup:selectMenuItem("itemStore")
    GameObjectHelper.FastSetActive(self.cardStore, false)
    GameObjectHelper.FastSetActive(self.itemStore, true)
    if self.changeTag then
        self.changeTag("itemStore")
    end
end

return DreamStoreView
