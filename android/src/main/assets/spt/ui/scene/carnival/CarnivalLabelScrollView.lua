local LuaScrollRectExSameSize = require("ui.control.scroll.LuaScrollRectExSameSize")
local CarnivalLabelScrollView = class(LuaScrollRectExSameSize)

function CarnivalLabelScrollView:ctor()
    CarnivalLabelScrollView.super.ctor(self)
    self.dropDownTip = self.___ex.dropDownTip
    self.parentScrollRect = self.___ex.parentScrollRect
end

function CarnivalLabelScrollView:createItem(index)
    if self.onScrollCreateItem then
        local obj, spt = self.onScrollCreateItem(index)
        self:resetItem(spt, index)
        return obj
    end
end

function CarnivalLabelScrollView:resetItem(spt, index)
    if self.onScrollResetItem then
        self.onScrollResetItem(spt, index)
    end
end

return CarnivalLabelScrollView