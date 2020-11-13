local GameObjectHelper = require("ui.common.GameObjectHelper")
local dreamLeagueCardName = require("data.DreamLeagueCardName")
local DreamGuessLittleItemView = class(unity.base)

function DreamGuessLittleItemView:ctor()
    self.bg = self.___ex.bg
    self.rankTxt = self.___ex.rankTxt
    self.nameTxt = self.___ex.nameTxt
    self.numTxt = self.___ex.numTxt
    self.scrollbar = self.___ex.scrollbar
    self.rateTxt = self.___ex.rateTxt
    self.firstRank = self.___ex.firstRank
    self.secondRank = self.___ex.secondRank
    self.thirdRank = self.___ex.thirdRank
    self.normalRank = self.___ex.normalRank
end

function DreamGuessLittleItemView:start()

end

function DreamGuessLittleItemView:InitView(data)
    self.nameTxt.text = dreamLeagueCardName[data.cardName].name
    self.numTxt.text = tostring(data.num)
    self.rateTxt.text = data.support .. "%"
    self.scrollbar.size = data.support / 100
    self.normalRank.text = tostring(data.rank)
    self:InitRankShowState(data.rank)
    GameObjectHelper.FastSetActive(self.bg, data.rank % 2 == 0)
end

function DreamGuessLittleItemView:InitRankShowState(rank)
    GameObjectHelper.FastSetActive(self.firstRank, rank == 1)
    GameObjectHelper.FastSetActive(self.secondRank, rank == 2)
    GameObjectHelper.FastSetActive(self.thirdRank, rank == 3)
    GameObjectHelper.FastSetActive(self.normalRank.gameObject, rank >= 4)
end

return DreamGuessLittleItemView
