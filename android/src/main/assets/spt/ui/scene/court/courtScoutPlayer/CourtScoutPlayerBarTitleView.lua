local GameObjectHelper = require("ui.common.GameObjectHelper")
local CourtScoutPlayerBarTitleView = class(unity.base)

function CourtScoutPlayerBarTitleView:ctor()
    self.titleText = self.___ex.titleText
    self.unlockObj = self.___ex.unlockObj
end

function CourtScoutPlayerBarTitleView:InitView(index, playerNum, scoutLvl)
    self.titleText.text = lang.trans("scout_player_level", index)
    local isOpen = tobool(scoutLvl >= index)
    GameObjectHelper.FastSetActive(self.unlockObj, not isOpen)
end

return CourtScoutPlayerBarTitleView
