local GameObjectHelper = require("ui.common.GameObjectHelper")
local AssetFinder = require("ui.common.AssetFinder")

local DreamHallMatchNationYesterdayItemView = class(unity.base)

function DreamHallMatchNationYesterdayItemView:ctor()
    self.nameHome = self.___ex.nameHome
    self.flagHome = self.___ex.flagHome
    self.flagAway = self.___ex.flagAway
    self.nameAway = self.___ex.nameAway
    self.result = self.___ex.result
    self.resultTxt = self.___ex.resultTxt
    self.endMatch = self.___ex.endMatch
    self.matching = self.___ex.matching
    self.penalty = self.___ex.penalty
    self.matchTime = self.___ex.matchTime
    self.more = self.___ex.more
    self.checking = self.___ex.checking
end

function DreamHallMatchNationYesterdayItemView:InitView(matchData)
    self.flagHome.overrideSprite = AssetFinder.GetNationIcon(matchData.homeTeamEn)
    self.flagAway.overrideSprite = AssetFinder.GetNationIcon(matchData.awayTeamEn)
    self.nameHome.text = matchData.homeTeam
    self.nameAway.text = matchData.awayTeam
    if matchData.resultState ~= 0 then
        self.result.text = matchData.homeScore .. ":" .. matchData.awayScore
        if matchData.homePenaltyScore and matchData.awayPenaltyScore then
            self.result.text = (matchData.homeScore + matchData.homePenaltyScore) .. ":" .. (matchData.awayScore+matchData.awayPenaltyScore)
        end
        self.resultTxt.text = self.result.text
    end
    self.matchTime.text = string.formatTimestampNoYear(matchData.matchTime)

    -- 0（VS+核算中） 1（比分+查看更多按钮）
    GameObjectHelper.FastSetActive(self.matching, matchData.resultState == 0)
    GameObjectHelper.FastSetActive(self.more.gameObject, matchData.resultState == 1)
    GameObjectHelper.FastSetActive(self.checking, matchData.resultState == 0)
    GameObjectHelper.FastSetActive(self.endMatch, matchData.resultState == 1)
end

return DreamHallMatchNationYesterdayItemView
