local LuaScrollRectExSameSize = require("ui.control.scroll.LuaScrollRectExSameSize")
local SkillListScrollView = class(LuaScrollRectExSameSize)

function SkillListScrollView:ctor()
    SkillListScrollView.super.ctor(self)
    self.scrollRect = self.___ex.scrollRect
end

function SkillListScrollView:GetScrollNormalizedPosition()
    return self:getScrollNormalizedPos()
end

function SkillListScrollView:RefreshItemWithScrollPos(data, scrollPos)
    self:refresh(data, scrollPos)
end

---[[ 为了C#回调而写的方法
function SkillListScrollView:createItem(index)
    if self.onScrollCreateItem then
        local obj, spt = self.onScrollCreateItem(index)
        self:resetItem(spt, index)
        return obj
    end
end

function SkillListScrollView:resetItem(spt, index)
    if self.onScrollResetItem then
        self.onScrollResetItem(spt, index)
    end
end
--]]

return SkillListScrollView
