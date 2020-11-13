local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object

local ScrollViewSameSize = require("ui.control.scroll.ScrollViewSameSize")

local CompeteArenaRankScrollView = class(ScrollViewSameSize, "CompeteArenaRankScrollView")

function CompeteArenaRankScrollView:ctor()
    CompeteArenaRankScrollView.super.ctor(self)
end

function CompeteArenaRankScrollView:resetItem(spt, index)
    local data = self.data[index]
    data.index = index
    for name, func in pairs(self.onItemButtonClicks) do
        spt[name]:regOnButtonClick(
            function()
                func(data)
            end
        )
    end
    spt:InitView(data, unpack(self.args, 1, self.argc))
    self:updateItemIndex(spt, index)
end

return CompeteArenaRankScrollView