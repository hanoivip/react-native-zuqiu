local UnityEngine = clr.UnityEngine
local Color = UnityEngine.Color
local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")
local MatchScheduleType = require("ui.scene.arena.schedule.MatchScheduleType")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local GroupBarView = class(unity.base)

function GroupBarView:ctor()
    self.groupNum = self.___ex.groupNum
    self.groupTime = self.___ex.groupTime
    self.homeLogo1 = self.___ex.homeLogo1
    self.homeLogo2 = self.___ex.homeLogo2
    self.homeName1 = self.___ex.homeName1
    self.homeName2 = self.___ex.homeName2
    self.visitName1 = self.___ex.visitName1
    self.visitName2 = self.___ex.visitName2
    self.visitLogo1 = self.___ex.visitLogo1
    self.visitLogo2 = self.___ex.visitLogo2
    self.video1 = self.___ex.video1
    self.video2 = self.___ex.video2
    self.score1 = self.___ex.score1
    self.score2 = self.___ex.score2
end

function GroupBarView:ShowBarInfo(barData, homeLogo, homeName, visitLogo, visitName, score, video, arenaScheduleTeamModel)
    local home = barData.h == 1 and barData.t1 or barData.t2
    local visit = barData.h == 1 and barData.t2 or barData.t1
    local homeId = home.id
    local visitId = visit.id
    local homeScore = home.goal
    local visitScore = visit.goal
    local homePenaltyScore = home.goal_penalty
    local visitPenaltyScore = visit.goal_penalty
    local homeLogoData = arenaScheduleTeamModel:GetPlayerLogo(homeId)
    TeamLogoCtrl.BuildTeamLogo(homeLogo, homeLogoData)
    local visitLogoData = arenaScheduleTeamModel:GetPlayerLogo(visitId)
    TeamLogoCtrl.BuildTeamLogo(visitLogo, visitLogoData)
    homeName.text = arenaScheduleTeamModel:GetPlayerName(homeId)
    visitName.text = arenaScheduleTeamModel:GetPlayerName(visitId)

    if homeScore and visitScore then
        local scoreStr = homeScore .. ":" .. visitScore
        if homePenaltyScore and visitPenaltyScore and not(homePenaltyScore == 0 and visitPenaltyScore == 0) then 
            local penaltyScore = lang.transstr("penalty_score", homePenaltyScore, visitPenaltyScore)
            scoreStr = scoreStr .. "\n" .. "<color=#ffd200><size=16>" .. penaltyScore .. "</size></color>"
        end
        score.text = scoreStr
    else
        score.text = "VS"
    end

    homeName.color = homeId == self.playerId and Color.yellow or Color.white
    visitName.color = visitId == self.playerId and Color.yellow or Color.white
    GameObjectHelper.FastSetActive(video.gameObject, tobool(barData.vid))
end

function GroupBarView:InitView(index, groupData, playerId, arenaScheduleTeamModel)
    self.playerId = playerId
    self.groupNum.text = lang.trans("round_num", index)
    local time = arenaScheduleTeamModel:GetMatchTime(MatchScheduleType.Group, index)
    local convertTime = os.date(lang.transstr("calendar_time4"), time) 
    self.groupTime.text = tostring(convertTime)

    self:ShowBarInfo(groupData[1], self.homeLogo1, self.homeName1, self.visitLogo1, self.visitName1, self.score1, self.video1, arenaScheduleTeamModel)
    self:ShowBarInfo(groupData[2], self.homeLogo2, self.homeName2, self.visitLogo2, self.visitName2, self.score2, self.video2, arenaScheduleTeamModel)
end

return GroupBarView