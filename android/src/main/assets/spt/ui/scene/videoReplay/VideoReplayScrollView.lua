local LuaScrollRectExSameSize = require("ui.control.scroll.LuaScrollRectExSameSize")

local VideoReplayScrollView = class(LuaScrollRectExSameSize)

function VideoReplayScrollView:ctor()
    VideoReplayScrollView.super.ctor(self)
end

function VideoReplayScrollView:createItem(index)
    if self.onScrollCreateItem then
        local obj, spt = self.onScrollCreateItem(index)
        self:resetItem(spt, index)
        return obj
    end
end

function VideoReplayScrollView:resetItem(spt, index)
    if self.onScrollResetItem then
        self.onScrollResetItem(spt, index)
    end
end

return VideoReplayScrollView