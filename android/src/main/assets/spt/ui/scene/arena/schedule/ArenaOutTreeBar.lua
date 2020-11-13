local UnityEngine = clr.UnityEngine
local Color = UnityEngine.Color
local MatchScheduleType = require("ui.scene.arena.schedule.MatchScheduleType")
local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local ArenaOutTreeBar = class(unity.base)

function ArenaOutTreeBar:ctor()
    self.logo = self.___ex.logo
    self.nameTxt = self.___ex.name
    self.firstH = self.___ex.firstH
    self.firstA = self.___ex.firstA
    self.firstScore = self.___ex.firstScore
    self.secondH = self.___ex.secondH
    self.secondA = self.___ex.secondA
    self.secondScore = self.___ex.secondScore
    self.win = self.___ex.win --(改成靠点球获胜才显示)
    self.canvasGroup = self.___ex.canvasGroup
end

-- 主客两场次
function ArenaOutTreeBar:InitView(barData, arenaScheduleTeamModel, isFirstHome, isOnlyOneMatch, playerId, matchScheduleType, index, hasPenaltyScore)
    local id = barData[1].id
    local hasMatch = false
    if id then 
        hasMatch = true
        self.logo.enabled = true
        local logoData = arenaScheduleTeamModel:GetPlayerLogo(id)
        TeamLogoCtrl.BuildTeamLogo(self.logo, logoData)
        self.nameTxt.text = arenaScheduleTeamModel:GetPlayerName(id)
        self.nameTxt.color = playerId == id and Color.yellow or Color.white
    else
        self.logo.enabled = false
        if matchScheduleType == MatchScheduleType.SixteenIntoEight then 
            local posIndexStr = "team_match_pos" .. index
            self.nameTxt.text = lang.trans(posIndexStr)
        else
            self.nameTxt.text = ""
        end
    end
    local isShowHomeAndAway = hasMatch and not isOnlyOneMatch 
    GameObjectHelper.FastSetActive(self.firstH, isShowHomeAndAway and isFirstHome)
    GameObjectHelper.FastSetActive(self.firstA, isShowHomeAndAway and not isFirstHome)
    GameObjectHelper.FastSetActive(self.secondA, isShowHomeAndAway and isFirstHome)
    GameObjectHelper.FastSetActive(self.secondH, isShowHomeAndAway and not isFirstHome)

    local firstScore = barData[1].goal and tostring(barData[1].goal) or ""
    local secondScore = barData[2].goal and tostring(barData[2].goal) or ""
    self.firstScore.text = firstScore
    self.secondScore.text = secondScore

    local isWin = hasPenaltyScore and (barData[1].advance == 1 or barData[2].advance == 1) or false
    GameObjectHelper.FastSetActive(self.win, isWin)

    self.canvasGroup.alpha = hasMatch and 1 or 0.6
end

return ArenaOutTreeBar
