local GameObjectHelper = require("ui.common.GameObjectHelper")

local ItemMallView = class(unity.base, "ItemMallView")

function ItemMallView:ctor()
    self.scroll = self.___ex.scroll
    self.scrollBar = self.___ex.scrollBar
    self.storeItemList = self.___ex.storeItemList
end

function ItemMallView:start()
end

function ItemMallView:EnterScene()
end

function ItemMallView:onDestroy()
end

function ItemMallView:ClearStoreItem()
    res.ClearChildren(self.storeItemList)
end

function ItemMallView:InitView(items)
    self:ClearStoreItem()

    if type(items) == "table" then
        if #items > 8 then
            self.scroll.enabled = true
            GameObjectHelper.FastSetActive(self.scrollBar, true)
        else
            self.scroll.enabled = false
            GameObjectHelper.FastSetActive(self.scrollBar, false)
        end
    end

    for i, v in ipairs(items) do
        v.transform:SetParent(self.storeItemList, false)
    end
end

function ItemMallView:ShowPageVisible(isShow)
    GameObjectHelper.FastSetActive(self.gameObject, isShow)
end

return ItemMallView
