local LuaScrollRectExSameSize = require("ui.control.scroll.LuaScrollRectExSameSize")

local ItemListScrollView = class(LuaScrollRectExSameSize)

function ItemListScrollView:ctor()
    ItemListScrollView.super.ctor(self)
end

function ItemListScrollView:createItem(index)
    if self.onScrollCreateItem then
        local obj, spt = self.onScrollCreateItem(index)
        self:resetItem(spt, index)
        return obj
    end
end

function ItemListScrollView:resetItem(spt, index)
    if self.onScrollResetItem then
        self.onScrollResetItem(spt, index)
    end
end

return ItemListScrollView
