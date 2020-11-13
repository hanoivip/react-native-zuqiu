local GameObjectHelper = require("ui.common.GameObjectHelper")

local ArenaRankBoardView = class(unity.base)

function ArenaRankBoardView:ctor()
    self.scrollView = self.___ex.scrollView
    self.rankText = self.___ex.rankText
    self.rankValue = self.___ex.rankValue
    self.rankInfoObj = self.___ex.rankInfoObj
    self.rankValueObj = self.___ex.rankValueObj
    self.rankTextObj = self.___ex.rankTextObj
end

function ArenaRankBoardView:start()
end

function ArenaRankBoardView:InitView(arenaModel)
    local selfRank = tonumber(arenaModel.selfRank)
    if selfRank == 0 then
        GameObjectHelper.FastSetActive(self.rankInfoObj, true)
        GameObjectHelper.FastSetActive(self.rankTextObj, false)
        GameObjectHelper.FastSetActive(self.rankValueObj, false)
    else
        GameObjectHelper.FastSetActive(self.rankInfoObj, false)
        GameObjectHelper.FastSetActive(self.rankTextObj, true)
        GameObjectHelper.FastSetActive(self.rankValueObj, true)
        self.rankValue.text = lang.trans("arena_myRankValue",selfRank)
    end
end

return ArenaRankBoardView
