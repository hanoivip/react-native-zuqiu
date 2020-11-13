local LuaScrollRectExSameSize = require("ui.control.scroll.LuaScrollRectExSameSize")

local ArenaScrollView = class(LuaScrollRectExSameSize)

function ArenaScrollView:ctor()
    ArenaScrollView.super.ctor(self)
end

function ArenaScrollView:createItem(index)
    if self.onScrollCreateItem then
        local obj, spt = self.onScrollCreateItem(index)
        self:resetItem(spt, index)
        return obj
    end
end

function ArenaScrollView:resetItem(spt, index)
    if self.onScrollResetItem then
        self.onScrollResetItem(spt, index)
    end
end

return ArenaScrollView