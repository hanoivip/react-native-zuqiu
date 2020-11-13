local CompeteDataHelper = {}

-- 在双方比分平的时候需要优先判断客场（attack）方比分
local function AllotPlayerData(attackInfo, defenderInfo, pid)
	local score, penaltyScore, attackScore, defenderScore = 0, 0, 0, 0
	if attackInfo.attackerPid == pid then
		score = tonumber(attackInfo.score)
		penaltyScore = tonumber(attackInfo.penaltyScore)
		attackScore = score
	elseif defenderInfo.opponentPid == pid then
		score = tonumber(defenderInfo.score)
		penaltyScore = tonumber(defenderInfo.penaltyScore)
		defenderScore = score
	end
	return score, penaltyScore, attackScore, defenderScore
end

function CompeteDataHelper.GetMatchScoreStatistics(roleId, opponentId, matchData)
	local roleData = { pid = roleId, score = 0, penaltyScore = 0, attackScore = 0, defenderScore = 0 }
	local opponentData = { pid = opponentId, score = 0, penaltyScore = 0, attackScore = 0, defenderScore = 0 }
	for i, v in ipairs(matchData) do
		local attackInfo = v.attacker or { }
		local defenderInfo = v.defender or { }
		local roleScore, rolePenaltyScore, roleAttackScore, roleDefenderScore = AllotPlayerData(attackInfo, defenderInfo, roleId)
		local opponentScore, opponentPenaltyScore, opponentAttackScore, opponentDefenderScore = AllotPlayerData(attackInfo, defenderInfo, opponentId)

		roleData.score = roleData.score + roleScore
		roleData.penaltyScore = roleData.penaltyScore + rolePenaltyScore
		roleData.attackScore = roleData.attackScore + roleAttackScore
		roleData.defenderScore = roleData.defenderScore + roleDefenderScore
		opponentData.score = opponentData.score + opponentScore
		opponentData.penaltyScore = opponentData.penaltyScore + opponentPenaltyScore
		opponentData.attackScore = opponentData.attackScore + opponentAttackScore
		opponentData.defenderScore = opponentData.defenderScore + opponentDefenderScore
	end

	return roleData, opponentData
end

return CompeteDataHelper
