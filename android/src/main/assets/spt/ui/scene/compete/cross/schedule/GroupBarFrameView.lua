local UnityEngine = clr.UnityEngine
local Color = UnityEngine.Color
local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local Version = require("emulator.version")
local DialogManager = require("ui.control.manager.DialogManager")
local GroupBarFrameView = class(unity.base)

function GroupBarFrameView:ctor()
    self.attackerLogo = self.___ex.attackerLogo
    self.attackerName = self.___ex.attackerName
    self.opponentName = self.___ex.opponentName
    self.opponentLogo = self.___ex.opponentLogo
    self.video = self.___ex.video
    self.score = self.___ex.score
end

local function GetGoalScore(useData, pid)
	local score, penaltyScore = 0, 0
	local useData = useData or {}
	local attacker = useData.attacker or { }
	local defender = useData.defender or { }
	local attackerPid = attacker.attackerPid
	local opponentPid = defender.opponentPid
	if attackerPid == pid then
		score = tonumber(attacker.score)
		penaltyScore = tonumber(attacker.penaltyScore)
	elseif opponentPid == pid then
		score = tonumber(defender.score)
		penaltyScore = tonumber(defender.penaltyScore)
	end
	return score, penaltyScore
end

function GroupBarFrameView:InitView(barData, playerId, scheduleModel, roundIndex)
    local attacker = barData.player1 or {}
    local opponent = barData.player2 or {}
    local attackerId = attacker.pid
    local opponentId = opponent.pid
	local match = barData.match or {}
	local matchData = match[roundIndex] or {}
    local attackerScore, attackerPenaltyScore = GetGoalScore(matchData, attackerId)
    local opponentScore, opponentPenaltyScore = GetGoalScore(matchData, opponentId)
    local attackerLogoData = scheduleModel:GetTeamInfo(attackerId)
    TeamLogoCtrl.BuildTeamLogo(self.attackerLogo, attackerLogoData.logo)
    local opponentLogoData = scheduleModel:GetTeamInfo(opponentId)
    TeamLogoCtrl.BuildTeamLogo(self.opponentLogo, opponentLogoData.logo)
    self.attackerName.text = attackerLogoData.name
    self.opponentName.text = opponentLogoData.name

    if attackerScore and opponentScore and next(match) then
        local scoreStr = attackerScore .. ":" .. opponentScore
        if attackerPenaltyScore and opponentPenaltyScore and not(attackerPenaltyScore == 0 and opponentPenaltyScore == 0) then 
            local penaltyScore = lang.transstr("penalty_score", attackerPenaltyScore, opponentPenaltyScore)
            scoreStr = scoreStr .. "\n" .. "<color=#ffd200><size=16>" .. penaltyScore .. "</size></color>"
        end
        self.score.text = scoreStr
    else
        self.score.text = "VS"
    end

    self.attackerName.color = attackerId == playerId and Color.yellow or Color.white
    self.opponentName.color = opponentId == playerId and Color.yellow or Color.white
    local vid = matchData.vid
    local version = matchData.version
    GameObjectHelper.FastSetActive(self.video.gameObject, tobool(vid))
    if self.video and vid then
        self.video:regOnButtonClick(function()
            self:OnBtnVideo(vid, version)
        end)
    end
end
            
function GroupBarFrameView:OnBtnVideo(vid, version)
    local isVideoExpired = version and tonumber(version) ~= tonumber(Version.version) or false
    if isVideoExpired then 
        DialogManager.ShowToast(lang.trans("videoReplay_expired"))
    else
        self:coroutine(function()
            local respone = req.worldTournamentVideo(vid)
            if api.success(respone) then
                local ReplayCheckHelper = require("coregame.ReplayCheckHelper")
                ReplayCheckHelper.StartReplay(respone.val.video, vid)
            end
        end)
    end
end

return GroupBarFrameView