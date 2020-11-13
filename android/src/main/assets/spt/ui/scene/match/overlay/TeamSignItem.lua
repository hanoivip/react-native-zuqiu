local GameObjectHelper = require("ui.common.GameObjectHelper")

local TeamSignItem = class(unity.base)

function TeamSignItem:ctor()
    self.homeSign = self.___ex.homeSign
    self.awaySign = self.___ex.awaySign    
end

function TeamSignItem:init(isHome)
    GameObjectHelper.FastSetActive(self.homeSign, isHome)
    GameObjectHelper.FastSetActive(self.awaySign, not isHome)
end

function TeamSignItem:SetVisible(isVisible)
    GameObjectHelper.FastSetActive(self.gameObject, isVisible)
end

return TeamSignItem