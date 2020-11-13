local LuaScrollRectExSameSize = require("ui.control.scroll.LuaScrollRectExSameSize")
local ChemicalBarScrollView = class(LuaScrollRectExSameSize)

function ChemicalBarScrollView:ctor()
    ChemicalBarScrollView.super.ctor(self)
end

function ChemicalBarScrollView:createItem(index)
    if self.onScrollCreateItem then
        local obj, spt = self.onScrollCreateItem(index)
        self:resetItem(spt, index)
        return obj
    end
end

function ChemicalBarScrollView:resetItem(spt, index)
    if self.onScrollResetItem then
        self.onScrollResetItem(spt, index)
    end
end

return ChemicalBarScrollView
