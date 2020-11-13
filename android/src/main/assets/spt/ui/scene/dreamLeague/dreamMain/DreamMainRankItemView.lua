local GameObjectHelper = require("ui.common.GameObjectHelper")
local AssetFinder = require("ui.common.AssetFinder")
local Nation = require("data.Nation")

local DreamMainMatchNationItemView = class(unity.base)

function DreamMainMatchNationItemView:ctor()
    self.playerName = self.___ex.playerName
    self.rankBack = self.___ex.rankBack
    self.serverName = self.___ex.serverName
    self.rank = self.___ex.rank
    self.rankNum = self.___ex.rankNum
    self.playerScore = self.___ex.playerScore
end

function DreamMainMatchNationItemView:InitView(rankData)
    for k,v in pairs(self.rank) do
        GameObjectHelper.FastSetActive(v, false)
    end
    GameObjectHelper.FastSetActive(self.rankNum.gameObject, false)
    if rankData.rank <= 3 then
        GameObjectHelper.FastSetActive(self.rank[tostring(rankData.rank)], true)
    else
        self.rankNum.text = tostring(rankData.rank)
        GameObjectHelper.FastSetActive(self.rankNum.gameObject, true)
    end
    local t1,t2 = math.modf(rankData.rank/2);
    if t2 == 0 then
        GameObjectHelper.FastSetActive(self.rankBack, false)
    else
        GameObjectHelper.FastSetActive(self.rankBack, true)
    end
    self.serverName.text = rankData.serverName
    self.playerName.text = rankData.name
    self.playerScore.text = tostring(rankData.score)
end

return DreamMainMatchNationItemView
