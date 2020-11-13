local LuaScrollRectExSameSize = require("ui.control.scroll.LuaScrollRectExSameSize")
local HighlightsListScrollView = class(LuaScrollRectExSameSize)

function HighlightsListScrollView:ctor()
    HighlightsListScrollView.super.ctor(self)
end

function HighlightsListScrollView:createItem(index)
    if self.onScrollCreateItem then
        local obj, spt = self.onScrollCreateItem(index)
        self:resetItem(spt, index)
        return obj
    end
end

function HighlightsListScrollView:resetItem(spt, index)
    if self.onScrollResetItem then
        self.onScrollResetItem(spt, index)
    end
end

return HighlightsListScrollView