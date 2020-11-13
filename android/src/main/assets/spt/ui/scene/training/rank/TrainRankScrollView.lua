local LuaScrollRectExSameSize = require("ui.control.scroll.LuaScrollRectExSameSize")

local TrainRankScrollView = class(LuaScrollRectExSameSize)

function TrainRankScrollView:ctor()
    TrainRankScrollView.super.ctor(self)
end

function TrainRankScrollView:createItem(index)
    if self.onScrollCreateItem then
        local obj, spt = self.onScrollCreateItem(index)
        self:resetItem(spt, index)
        return obj
    end
end

function TrainRankScrollView:resetItem(spt, index, currentType)
    if self.onScrollResetItem then
        self.onScrollResetItem(spt, index, currentType)
    end
end

return TrainRankScrollView