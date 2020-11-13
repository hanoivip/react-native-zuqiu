local AssetFinder = require("ui.common.AssetFinder")
local DreamConstants = require("ui.scene.dreamLeague.dreamMain.DreamConstants")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local DreamLeagueRoom = require("data.DreamLeagueRoom")

local DreamBattleItemView = class(unity.base)

function DreamBattleItemView:ctor()
    self.homeIcon = self.___ex.homeIcon
    self.awayIcon = self.___ex.awayIcon
    self.homeNameTxt = self.___ex.homeNameTxt
    self.awayNameTxt = self.___ex.awayNameTxt
    self.enterBtn = self.___ex.enterBtn
    self.idTxt = self.___ex.idTxt
    self.btnStateTxt = self.___ex.btnStateTxt
    self.disable = self.___ex.disable
    self.minBetTxt = self.___ex.minBetTxt
end

function DreamBattleItemView:start()
end

function DreamBattleItemView:InitView(roomData)
    self.roomData = roomData
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

    local isShowEnterBtn = (tonumber(roomData.state) == DreamConstants.ResultState.NOT_OPEN)

    GameObjectHelper.FastSetActive(self.enterBtn.gameObject, isShowEnterBtn)
    GameObjectHelper.FastSetActive(self.disable, not isShowEnterBtn)

    if tonumber(roomData.state) == DreamConstants.ResultState.LOSING_LOTTERY then
        self.btnStateTxt.text = lang.trans("dream_not_win")
    elseif tonumber(roomData.state) == DreamConstants.ResultState.NOT_OPEN then
        self.btnStateTxt.text = lang.trans("quest_enter")
    elseif tonumber(roomData.state) == DreamConstants.ResultState.NOT_ACCEPT then
        self.btnStateTxt.text = lang.trans("belatedGift_item_nil_time")
    elseif tonumber(roomData.state) == DreamConstants.ResultState.ACCEPT then
        self.btnStateTxt.text = lang.trans("belatedGift_item_nil_time")
    end
end

return DreamBattleItemView
