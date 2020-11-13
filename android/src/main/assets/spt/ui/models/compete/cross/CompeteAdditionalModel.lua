local CompeteDataHelper = require("ui.models.compete.main.CompeteDataHelper")
local CompeteCrossBaseModel = require("ui.models.compete.cross.CompeteCrossBaseModel")
local CompeteAdditionalModel = class(CompeteCrossBaseModel, "CompeteAdditionalModel")

function CompeteAdditionalModel:ctor()
    CompeteAdditionalModel.super.ctor(self)
end

function CompeteAdditionalModel:GetMatchData()
	return self.data.match or {}
end

function CompeteAdditionalModel:InitWithProtocol(data)
    assert(type(data) == "table")
    self:Init(data)
	self:SortPlayer()
	self:InitMatchData()
end

function CompeteAdditionalModel:InitMatchData()
	if self:IsMatching() then
		local pid1 = self:GetPlayer1Data().pid
		local pid2 = self:GetPlayer2Data().pid
		local matchData = self.data.match or {}
		self.pid1MatchData, self.pid2MatchData = CompeteDataHelper.GetMatchScoreStatistics(pid1, pid2, matchData)
	end
end

-- 左边显示的数据修正为玩家自身
function CompeteAdditionalModel:GetAttackData()
	return self.pid1MatchData or {}
end

function CompeteAdditionalModel:GetDefenderData()
	return self.pid2MatchData or {}
end

-- 在平局的时候会打第三场比赛
function CompeteAdditionalModel:GetPenaltyMatchData()
    return self.data.penaltyMatch or {}
end

-- 在平局的时候第三场比赛(加上点球得分)
function CompeteAdditionalModel:GetPenaltyScore()
    local rolePenaltyScore, opponentPenaltyScore = 0, 0
	local penaltyMatch = self:GetPenaltyMatchData()
	if next(penaltyMatch) then 
		local roleId = self:GetPlayer1Data().pid
		local opponentId = self:GetPlayer2Data().pid
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

--* 服务器数据不好判断自身在左边，客户端根据根据数据把自身放在player1里
function CompeteAdditionalModel:SortPlayer()
	local player1Data = self.data.player1 or {}
	local player2Data = self.data.player2 or {}
    local playerId = self:GetPlayerRoleId()
	if playerId == player2Data.pid then 
		self.data.player1 = player2Data
		self.data.player2 = player1Data
	end
end

function CompeteAdditionalModel:GetPlayer1Data()
    return self.data.player1 or {}
end

function CompeteAdditionalModel:GetPlayer2Data()
    return self.data.player2 or {}
end

-- 会出现轮空状态
function CompeteAdditionalModel:IsEmpty()
	local player1Data = self:GetPlayer1Data()
	local player2Data = self:GetPlayer2Data()
	local pid1 = player1Data.pid
	local pid2 = player2Data.pid
	local isEmpty = false
	if not pid1 or not pid2 then
		isEmpty = true
	end
	return isEmpty
end

-- 轮空状态直接晋级
-- 暂时未打完比赛不算赢
-- 当前进度5，那么前4表示通过，第5需要比较分数
function CompeteAdditionalModel:IsWin()
	local isEmpty = self:IsEmpty()
	if isEmpty then return true end
	local isMatchOver = self:IsMatchOver()
	if not isMatchOver then return false end

    local playerId = self:GetPlayerRoleId()
	local pid1 = self:GetPlayer1Data().pid
	local pid2 = self:GetPlayer2Data().pid
	local isWin = false

	local rolePenaltyScore, opponentPenaltyScore = self:GetPenaltyScore() 
	-- 两场比赛相同进球时需要比较客场比分，如果客场比分相同会继续打一场带点球的比赛
	if pid1 == playerId then 
		if self.pid1MatchData.score == self.pid2MatchData.score then 
			if self.pid1MatchData.attackScore == self.pid2MatchData.attackScore then
				isWin = tobool(rolePenaltyScore >  opponentPenaltyScore)
			else
				isWin = tobool(self.pid1MatchData.attackScore >  self.pid2MatchData.attackScore)
			end
		else
			isWin = tobool(self.pid1MatchData.score >  self.pid2MatchData.score)
		end
	elseif pid2 == playerId then
		if self.pid1MatchData.score == self.pid2MatchData.score then 
			if self.pid1MatchData.attackScore == self.pid2MatchData.attackScore then
				isWin = tobool(opponentPenaltyScore >  rolePenaltyScore)
			else
				isWin = tobool(self.pid2MatchData.attackScore >  self.pid1MatchData.attackScore)
			end
		else
			isWin = tobool(self.pid2MatchData.score >  self.pid1MatchData.score)
		end
	end

	return isWin
end

-- 本轮是否结算完比赛
function CompeteAdditionalModel:IsMatchOver()
	local matchData = self:GetMatchData()
	if next(matchData) then 
		return true
	end
	return false
end

-- status  0 未参与 1 参与 2 晋级    preselectionProgress 预选赛已完成第几轮
function CompeteAdditionalModel:GetAdditionStatus()
	return self.data.status or -1
end

function CompeteAdditionalModel:GetMyProgress()
	return self.data.myProgress
end

function CompeteAdditionalModel:GetAdditionProgress()
	return self.data.preselectionProgress
end

function CompeteAdditionalModel:IsRiseInMatch()
	local status = self:GetAdditionStatus()
	return tobool(status == 2)
end

function CompeteAdditionalModel:IsMatching()
	local status = self:GetAdditionStatus()
	return tobool(status == 1)
end

function CompeteAdditionalModel:IsFailInMatch()
	local status = self:GetAdditionStatus()
	return tobool(status == 0)
end

return CompeteAdditionalModel