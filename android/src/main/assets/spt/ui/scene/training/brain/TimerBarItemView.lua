local GameObjectHelper = require("ui.common.GameObjectHelper")

local TimerBarItemView = class(unity.base)

function TimerBarItemView:ctor()
    self.state = self.___ex.state
end

function TimerBarItemView:SetTimerView(showColor)
    for k, v in pairs(self.state) do
        GameObjectHelper.FastSetActive(v, v.name == showColor)
    end
end

return TimerBarItemView