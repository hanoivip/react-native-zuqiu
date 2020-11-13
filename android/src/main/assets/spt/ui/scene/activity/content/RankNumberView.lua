local GameObjectHelper = require("ui.common.GameObjectHelper")
local RankNumberView = class(unity.base)

function RankNumberView:ctor()
    self.first = self.___ex.first
    self.second = self.___ex.second
    self.third = self.___ex.third
    self.normal = self.___ex.normal
end

function RankNumberView:InitView(number)
    if not number then
        return
    end
    
    number = tonumber(number)
    GameObjectHelper.FastSetActive(self.first, number == 1)
    GameObjectHelper.FastSetActive(self.second, number == 2)
    GameObjectHelper.FastSetActive(self.third, number == 3)
    GameObjectHelper.FastSetActive(self.normal.gameObject, number > 3)
    self.normal.text = tostring(number)    
end


return RankNumberView