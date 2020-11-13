local GameObjectHelper = require("ui.common.GameObjectHelper")

local IndicatorDotView = class(unity.base, "IndicatorDotView")

function IndicatorDotView:ctor()
    self.up = self.___ex.up
    self.down = self.___ex.down
end

function IndicatorDotView:InitView(index)
    self.index = index
    GameObjectHelper.FastSetActive(self.up, false)
    GameObjectHelper.FastSetActive(self.down, true)
end

function IndicatorDotView:start()
end

function IndicatorDotView:SetSelect(isSelect)
    GameObjectHelper.FastSetActive(self.up.gameObject, isSelect)
end

function IndicatorDotView:GetIndex()
    return self.index
end

return IndicatorDotView