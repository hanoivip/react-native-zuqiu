local LuaScrollRectExSameSize = require("ui.control.scroll.LuaScrollRectExSameSize")

local PeakRankScrollView = class(LuaScrollRectExSameSize)

function PeakRankScrollView:ctor()
    PeakRankScrollView.super.ctor(self)
end

function PeakRankScrollView:createItem(index)
    if self.onScrollCreateItem then
        local obj, spt = self.onScrollCreateItem(index)
        self:resetItem(spt, index)
        return obj
    end 
end

function PeakRankScrollView:resetItem(spt, index)
    if self.onScrollResetItem then
        self.onScrollResetItem(spt, index)
    end  
end

return PeakRankScrollView