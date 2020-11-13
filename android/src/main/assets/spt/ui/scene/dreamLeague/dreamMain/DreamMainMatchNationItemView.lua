local GameObjectHelper = require("ui.common.GameObjectHelper")
local AssetFinder = require("ui.common.AssetFinder")
local Nation = require("data.Nation")

local DreamMainMatchNationItemView = class(unity.base)

function DreamMainMatchNationItemView:ctor()
    self.nameHome = self.___ex.nameHome
    self.flagHome = self.___ex.flagHome
    self.flagAway = self.___ex.flagAway
    self.nameAway = self.___ex.nameAway
    self.result = self.___ex.result
    self.endMatch = self.___ex.endMatch
    self.matching = self.___ex.matching
    self.penalty = self.___ex.penalty
end

function DreamMainMatchNationItemView:InitView(matchData)
    self.flagHome.overrideSprite = AssetFinder.GetNationIcon(matchData.homeTeamEn)
    self.flagAway.overrideSprite = AssetFinder.GetNationIcon(matchData.awayTeamEn)
    self.nameHome.text = matchData.homeTeam
    self.nameAway.text = matchData.awayTeam
    if matchData.resultState ~= 0 then
        self.result.text = matchData.homeScore .. " - " .. matchData.awayScore
        if matchData.homePenaltyScore and matchData.awayPenaltyScore then
            self.penalty.text = "(" .. matchData.homePenaltyScore .. " - " .. matchData.awayPenaltyScore .. ")"
        end
    else
        self.result.text = ""
        self.penalty.text = ""
    end

    GameObjectHelper.FastSetActive(self.matching, matchData.resultState == 0)
end

return DreamMainMatchNationItemView
