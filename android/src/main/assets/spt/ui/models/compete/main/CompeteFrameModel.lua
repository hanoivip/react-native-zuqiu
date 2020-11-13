local CompeteDataHelper = require("ui.models.compete.main.CompeteDataHelper")
local CompeteSchedule = require("ui.models.compete.main.CompeteSchedule")
local Model = require("ui.models.Model")
local CompeteFrameModel = class(Model, "CompeteFrameModel")

function CompeteFrameModel:ctor()
    CompeteFrameModel.super.ctor(self)
end

function CompeteFrameModel:Init(data)
    self.data = data or {}
end

function CompeteFrameModel:GetTime()
    return self.data.date or 0
end

function CompeteFrameModel:GetBeginTime()
    return self.data.beginTime or 0
end

function CompeteFrameModel:GetEndTime()
    return self.data.endTime or 0
end

function CompeteFrameModel:IsMatchOver()
    return tobool(self.data.over)
end

-- 1 2 3 4 5 6 7 8 9 10 11,(1-6 跨服， 7-11区服)
function CompeteFrameModel:IsServerCross()
    return tonumber(self.data.matchType) <= 6
end

function CompeteFrameModel:GetMatchType()
    return tonumber(self.data.matchType)
end

function CompeteFrameModel:GetOpponentPlayer()
    local opponentPlayer = self.data.opponentPlayer or {}
    return opponentPlayer
end

function CompeteFrameModel:GetShowName()
    local opponentPlayer = self:GetOpponentPlayer()
    local name = opponentPlayer.name or ""
    local serverName = opponentPlayer.serverName or ""
    return name .. "(" .. serverName .. ")"
end

function CompeteFrameModel:GetPid()
    local opponentPlayer = self:GetOpponentPlayer()
    return opponentPlayer.pid or ""
end

function CompeteFrameModel:GetSid()
    local opponentPlayer = self:GetOpponentPlayer()
    return opponentPlayer.sid or ""
end

function CompeteFrameModel:GetStatus()
    return tonumber(self.data.status)
end

-- 暂时未到时间
function CompeteFrameModel:IsNotOpenMatch()
    return tonumber(self.data.status) == 1
end
-- 正在比赛中（可以手动比赛）
function CompeteFrameModel:IsMatching()
    return tonumber(self.data.status) == 2
end
-- 正在比赛中（等待对手比赛）
function CompeteFrameModel:IsWaitMatch()
    return tonumber(self.data.status) == 3
end
-- 结束比赛
function CompeteFrameModel:IsMatchOver()
    return tonumber(self.data.status) == 4
end

function CompeteFrameModel:GetPlayerScore()
    return self.data.playerScore or 0
end

function CompeteFrameModel:GetOpponentScore()
    return self.data.opponentScore or 0
end

function CompeteFrameModel:SetRoleId(playerId)
    self.playerId = playerId
end

function CompeteFrameModel:GetRoleId()
    return self.playerId
end

function CompeteFrameModel:GetMatchData()
    return self.data.match or {}
end

-- 在平局的时候会打第三场比赛
function CompeteFrameModel:GetPenaltyMatchData()
    return self.data.penaltyMatch or {}
end

function CompeteFrameModel:GetPenaltyScore()
    local rolePenaltyScore, opponentPenaltyScore = 0, 0
	local penaltyMatch = self:GetPenaltyMatchData()
	if next(penaltyMatch) then 
		local roleId = self:GetRoleId()
		local opponentId = self:GetPid()
		local attacker = penaltyMatch.attacker or { }
		local defender = penaltyMatch.defender or { }
		if attacker.attackerPid == roleId then
			rolePenaltyScore = rolePenaltyScore + tonumber(attacker.score) + tonumber(attacker.penaltyScore)
		elseif attacker.attackerPid == opponentId then
			opponentPenaltyScore = opponentPenaltyScore + tonumber(attacker.score) + tonumber(attacker.penaltyScore)
		end

		if defender.opponentPid == roleId then
			rolePenaltyScore = rolePenaltyScore + tonumber(defender.score) + tonumber(defender.penaltyScore)
		elseif defender.opponentPid == opponentId then
			opponentPenaltyScore = opponentPenaltyScore + tonumber(defender.score) + tonumber(defender.penaltyScore)
		end
	end
	return rolePenaltyScore, opponentPenaltyScore
end

function CompeteFrameModel:GetMatchRound()
    return tonumber(self.data.round)
end

function CompeteFrameModel:SortMatchRound(round)
    self.data.round = round
end

function CompeteFrameModel:GetMatchScoreStatistics()
    local roleId = self:GetRoleId()
    local opponentId = self:GetPid()
    local matchData = self:GetMatchData()
	local roleData, opponentData = CompeteDataHelper.GetMatchScoreStatistics(roleId, opponentId, matchData)
	return roleData, opponentData
end

-- 淘汰赛比分相同时要比较主客场
function CompeteFrameModel:IsKnockout()
	local matchType = self:GetMatchType()
	return matchType == CompeteSchedule.Big_Ear_Match or 
			matchType == CompeteSchedule.Big_Ear_Match_Kick_Off or 
			matchType == CompeteSchedule.Small_Ear_Match or 
			matchType == CompeteSchedule.Small_Ear_Match_Kick_Off
end

function CompeteFrameModel:GetCompeteSign()
    return self.data.opponentPlayer.worldTournamentLevel
end

return CompeteFrameModel