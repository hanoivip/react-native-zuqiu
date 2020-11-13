local CompeteEnumHelper = require("ui.scene.compete.cross.CompeteEnumHelper")
local GroupBarView = class(unity.base)

function GroupBarView:ctor()
    self.groupNum = self.___ex.groupNum
    self.groupTime = self.___ex.groupTime
	self.totalScore1 = self.___ex.totalScore1
	self.totalScore2 = self.___ex.totalScore2

	self.bar1View = self.___ex.bar1View
	self.bar2View = self.___ex.bar2View
	self.bar3View = self.___ex.bar3View
	self.bar4View = self.___ex.bar4View
end

local function GetGoalScore(useData, pid)
	local score, penaltyScore = 0, 0
	local useData = useData or {}
	for i, v in ipairs(useData) do
		local attacker = v.attacker or {}
		local defender = v.defender or {}
		local attackerPid = attacker.attackerPid
		local opponentPid = defender.opponentPid
		if attackerPid == pid then 
			score = score + tonumber(attacker.score)
			penaltyScore = penaltyScore + tonumber(attacker.penaltyScore)
		elseif opponentPid == pid then
			score = score + tonumber(defender.score)
			penaltyScore = penaltyScore + tonumber(defender.penaltyScore)
		end
	end
	return score, penaltyScore
end

local function GetTotalScoreStr(data)
    local attacker = data.player1 or {}
    local opponent = data.player2 or {}
    local attackerId = attacker.pid
    local opponentId = opponent.pid
	local match = data.match or {}
    local attackerScore, attackerPenaltyScore = GetGoalScore(match, attackerId)
    local opponentScore, opponentPenaltyScore = GetGoalScore(match, opponentId)
	local scoreStr = "--"
	if attackerScore and opponentScore and (attackerScore ~= 0 and opponentScore ~=0) then
		scoreStr = attackerScore .. " : " .. opponentScore
		if attackerScore == opponentScore and (attackerPenaltyScore ~= 0 and opponentPenaltyScore ~=0) then
			local penaltyScore = lang.transstr("penalty_score", attackerPenaltyScore, opponentPenaltyScore)
			scoreStr = scoreStr .. "\n" .. "<color=#ffd200><size=16>" .. penaltyScore .. "</size></color>"
		end
	end

	return scoreStr
end

function GroupBarView:InitView(index, groupData, playerId, scheduleModel, groupIndex)
    self.playerId = playerId
	local symbol = CompeteEnumHelper.ScoreSymbol[tonumber(groupIndex)] or "Z"
    self.groupNum.text = lang.trans("compete_teamRace", symbol, index)
	local firstData = groupData[1] or {}
	local secondData = groupData[2] or {}
    local time = firstData.time or 0
    local convertTime = os.date(lang.transstr("calendar_time4"), time) 
    self.groupTime.text = convertTime

	self.totalScore1.text = GetTotalScoreStr(firstData)
	self.totalScore2.text = GetTotalScoreStr(secondData)

	self.bar1View:InitView(firstData, playerId, scheduleModel, 1)
	self.bar2View:InitView(firstData, playerId, scheduleModel, 2)
	self.bar3View:InitView(secondData, playerId, scheduleModel, 1)
	self.bar4View:InitView(secondData, playerId, scheduleModel, 2)
end

return GroupBarView