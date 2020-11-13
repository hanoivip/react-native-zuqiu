local AssetFinder = require("ui.common.AssetFinder")
local DreamLeagueRoom = require("data.DreamLeagueRoom")

local DreamBattleItemView = class(unity.base)

function DreamBattleItemView:ctor()
    self.homeIcon = self.___ex.homeIcon
    self.awayIcon = self.___ex.awayIcon
    self.homeNameTxt = self.___ex.homeNameTxt
    self.awayNameTxt = self.___ex.awayNameTxt
    self.enterBtn = self.___ex.enterBtn
    self.idTxt = self.___ex.idTxt
    self.minBetTxt = self.___ex.minBetTxt
end

function DreamBattleItemView:start()

end

function DreamBattleItemView:InitView(roomData)
    self.homeIcon.overrideSprite = AssetFinder.GetNationIcon(roomData.homeTeamEn)
    self.awayIcon.overrideSprite = AssetFinder.GetNationIcon(roomData.awayTeamEn)

    self.homeNameTxt.text = roomData.homeTeam
    self.awayNameTxt.text = roomData.awayTeam

    local roomId = roomData.roomNum
    local currNum = roomData.num
    local time = string.formatTimestampNoYear(roomData.matchTime)
    local maxNum = DreamLeagueRoom[tostring(roomData.roomId)].maxPeople
    local roomName = DreamLeagueRoom[tostring(roomData.roomId)].name
    self.idTxt.text = lang.trans("dream_home_id", roomId, currNum, maxNum, time, roomName)

    self.minBetTxt.text = lang.trans("dream_min_bet_count", string.formatIntWithTenThousands(DreamLeagueRoom[tostring(roomData.roomId)].fee[1]))
end

return DreamBattleItemView
