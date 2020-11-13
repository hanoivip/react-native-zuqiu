local UnityEngine = clr.UnityEngine
local Color = UnityEngine.Color
local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local ArenaOutBarView = class(unity.base)

function ArenaOutBarView:ctor()
    self.homeLogo = self.___ex.homeLogo
    self.homeName = self.___ex.homeName
    self.visitName = self.___ex.visitName
    self.visitLogo = self.___ex.visitLogo
    self.bar = self.___ex.bar
    self.title = self.___ex.title
    self.round = self.___ex.round
    self.time = self.___ex.time
    self.score = self.___ex.score
    self.video = self.___ex.video
    self.video:regOnButtonClick(function()
        self:OnClickVideo()
    end)
end

function ArenaOutBarView:OnClickVideo()
    if self.clickVideo then 
        self.clickVideo(self.vid, self.version)
    end
end

function ArenaOutBarView:InitView(arenaOutData, arenaScheduleTeamModel, playerId)
    local isTitle = arenaOutData.isTitle
    local isShowTitle = true
    if isTitle then 
        local matchScheduleType = arenaOutData.round
        local totalMatchNum = arenaOutData.totalMatchNum
        local stageOrder = arenaOutData.index
        isShowTitle = tobool(stageOrder <= totalMatchNum)
        if totalMatchNum == 1 then -- 一场比赛不需要场次
            self.round.text = lang.transstr(matchScheduleType)
        else
            self.round.text = lang.transstr(matchScheduleType) .. lang.transstr("round_num", stageOrder)
        end
        local time = arenaScheduleTeamModel:GetMatchTime(matchScheduleType, stageOrder) or 0
        local convertTime = os.date(lang.transstr("calendar_time4"), tonumber(time)) 
        self.time.text = tostring(convertTime)
    else
        local barData = arenaOutData.data
        local home = barData.h == 1 and barData.t1 or barData.t2
        local visit = barData.h == 1 and barData.t2 or barData.t1
        local homeScore = home.goal
        local visitScore = visit.goal
        local homeId = home.id
        local visitId = visit.id
        local homePenaltyScore = home.goal_penalty
        local visitPenaltyScore = visit.goal_penalty
        local homeLogoData = arenaScheduleTeamModel:GetPlayerLogo(homeId)
        TeamLogoCtrl.BuildTeamLogo(self.homeLogo, homeLogoData)
        local visitLogoData = arenaScheduleTeamModel:GetPlayerLogo(visitId)
        TeamLogoCtrl.BuildTeamLogo(self.visitLogo, visitLogoData)
        self.homeName.text = arenaScheduleTeamModel:GetPlayerName(homeId)
        self.visitName.text = arenaScheduleTeamModel:GetPlayerName(visitId)

        self.homeName.color = homeId == playerId and Color.yellow or Color.white
        self.visitName.color = visitId == playerId and Color.yellow or Color.white

        self.vid = barData.vid
        self.version = barData.version
        if homeScore and visitScore then 
            local scoreStr = homeScore .. ":" .. visitScore
            if homePenaltyScore and visitPenaltyScore and not(homePenaltyScore == 0 and visitPenaltyScore == 0) then 
                local penaltyScore = lang.transstr("penalty_score", homePenaltyScore, visitPenaltyScore)
                scoreStr = scoreStr .. "\n" .. "<color=#ffd200><size=16>" .. penaltyScore.. "</size></color>"
            end
            self.score.text = scoreStr
        else
            self.score.text = "VS"
        end
        GameObjectHelper.FastSetActive(self.video.gameObject, tobool(self.vid))
    end

    GameObjectHelper.FastSetActive(self.bar, not isTitle)
    GameObjectHelper.FastSetActive(self.title, isShowTitle and isTitle)
end

return ArenaOutBarView