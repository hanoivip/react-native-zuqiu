local LuaScrollRectExSameSize = require("ui.control.scroll.LuaScrollRectExSameSize")
local PlayerListScrollView = class(LuaScrollRectExSameSize)

function PlayerListScrollView:ctor()
    PlayerListScrollView.super.ctor(self)
    self.scrollRect = self.___ex.scrollRect
end

function PlayerListScrollView:GetScrollNormalizedPosition()
    return self:getScrollNormalizedPos()
end

function PlayerListScrollView:RefreshItemWithScrollPos(data, scrollPos)
    self:refresh(data, scrollPos)
end

function PlayerListScrollView:createItem(index)
    if self.onScrollCreateItem then
        local obj, spt = self.onScrollCreateItem(index)
        self:resetItem(spt, index)
        return obj
    end
end

function PlayerListScrollView:resetItem(spt, index)
    if self.onScrollResetItem then
        self.onScrollResetItem(spt, index)
    end
end

return PlayerListScrollView
