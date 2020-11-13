local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object

local ScrollViewSameSize = require("ui.control.scroll.ScrollViewSameSize")

local CompeteCrossInfoScrollView = class(ScrollViewSameSize, "CompeteCrossInfoScrollView")

function CompeteCrossInfoScrollView:ctor()
    CompeteCrossInfoScrollView.super.ctor(self)
end

function CompeteCrossInfoScrollView:resetItem(spt, index)
    local data = self.data[index]
    data.index = index
    for name, func in pairs(self.onItemButtonClicks) do    --没有效果
        spt[name]:regOnButtonClick(
            function()
                func(data)
            end
        )
    end
    spt:InitView(data, unpack(self.args, 1, self.argc))
    self:updateItemIndex(spt, index)
end

return CompeteCrossInfoScrollView