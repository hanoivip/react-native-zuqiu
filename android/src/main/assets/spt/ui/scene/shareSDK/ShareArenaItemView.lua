local GameObjectHelper = require("ui.common.GameObjectHelper")

local ShareArenaItemView = class(unity.base)

function ShareArenaItemView:ctor()
    self.lightObj = self.___ex.lightObj
    self.grayObj = self.___ex.grayObj
    self.numTxt = self.___ex.numTxt
    self.season = self.___ex.season
end

function ShareArenaItemView:InitView(data)
    GameObjectHelper.FastSetActive(self.lightObj, data.champCnt > 0)
    GameObjectHelper.FastSetActive(self.grayObj, data.champCnt <= 0)
    self.numTxt.text = data.champCnt > 0 and lang.trans("share_champion", tostring(data.champCnt)) or ""
    self.season.text = lang.trans("season_pass", tostring(data.seasons))
end

return ShareArenaItemView