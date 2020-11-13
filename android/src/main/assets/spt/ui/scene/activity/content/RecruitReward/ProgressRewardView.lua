local LuaScrollRectExSameSize = require("ui.control.scroll.LuaScrollRectExSameSize")
local ProfressRewardView = class(LuaScrollRectExSameSize)

function ProfressRewardView:ctor()
    ProfressRewardView.super.ctor(self)
end

function ProfressRewardView:createItem(index)
    if self.onScrollCreateItem then
        local obj, spt = self.onScrollCreateItem(index)
        self:resetItem(spt, index)
        return obj
    end
end

function ProfressRewardView:resetItem(spt, index)
    if self.onScrollResetItem then
        self.onScrollResetItem(spt, index)
    end
end

return ProfressRewardView