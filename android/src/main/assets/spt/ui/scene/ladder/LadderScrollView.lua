local LuaScrollRectExSameSize = require("ui.control.scroll.LuaScrollRectExSameSize")

local LadderScrollView = class(LuaScrollRectExSameSize)

function LadderScrollView:ctor()
    LadderScrollView.super.ctor(self)
end

function LadderScrollView:createItem(index)
    if self.onScrollCreateItem then
        local obj, spt = self.onScrollCreateItem(index)
        self:resetItem(spt, index)
        return obj
    end
end

function LadderScrollView:resetItem(spt, index)
    if self.onScrollResetItem then
        self.onScrollResetItem(spt, index)
    end
end

return LadderScrollView