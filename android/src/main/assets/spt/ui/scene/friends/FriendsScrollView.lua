local LuaScrollRectExSameSize = require("ui.control.scroll.LuaScrollRectExSameSize")

local FriendsScrollView = class(LuaScrollRectExSameSize)

function FriendsScrollView:ctor()
    FriendsScrollView.super.ctor(self)
end

function FriendsScrollView:createItem(index)
    if self.onScrollCreateItem then
        local obj, spt = self.onScrollCreateItem(index)
        self:resetItem(spt, index)
        return obj
    end
end

function FriendsScrollView:resetItem(spt, index)
    if self.onScrollResetItem then
        self.onScrollResetItem(spt, index)
    end
end

return FriendsScrollView