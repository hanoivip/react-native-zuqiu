local LuaScrollRectExSameSize = require("ui.control.scroll.LuaScrollRectExSameSize")
local TimeLimitExploreScrollView = class(LuaScrollRectExSameSize)

function TimeLimitExploreScrollView:ctor()
    TimeLimitExploreScrollView.super.ctor(self)
    self.itemPrefabPath = self.___ex.itemPrefabPath
    self.itemParentScrollRect = self.___ex.itemParentScrollRect
end

function TimeLimitExploreScrollView:createItem(index)
    local obj, spt = res.Instantiate(self.itemPrefabPath)
    self:resetItem(spt, index)
    return obj
end

function TimeLimitExploreScrollView:resetItem(spt, index)
    local itemData = self.data[index]
    if self.onItemButtonClick then
        spt.onItemButtonClick = self.onItemButtonClick
    end
    spt:InitView(itemData, self.itemParentScrollRect, index)
    self:updateItemIndex(spt, index)
end

function TimeLimitExploreScrollView:InitView(data)
    self.data = data
    self:refresh(self.data)
end

function TimeLimitExploreScrollView:RegOnItemButtonClick(func)
    self.onItemButtonClick = func
end

return TimeLimitExploreScrollView